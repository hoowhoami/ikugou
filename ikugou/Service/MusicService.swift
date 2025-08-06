//
//  MusicService.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI
import AVFoundation
import AudioToolbox
import CoreBluetooth

/// 音乐播放服务 - 处理音频播放相关逻辑
@Observable
class MusicService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = MusicService()
    
    /// 当前正在播放的AVPlayer
    private var audioPlayer: AVPlayer?
    
    /// 播放时间观察器
    private var timeObserver: Any?
    
    /// 播放状态观察器
    private var playerStatusObserver: NSKeyValueObservation?
    
    /// 音频路由变化观察器
    private var audioRouteObserver: NSObjectProtocol?
    
    /// 音频会话中断观察器
    private var audioInterruptionObserver: NSObjectProtocol?
    
    /// 蓝牙管理器
    private var bluetoothManager: CBCentralManager?
    
    /// 记录音频中断前的播放状态
    private var wasPlayingBeforeInterruption: Bool = false
    
    /// 默认音质设置
    var preferredQuality: AudioQuality = .standard
    
    /// URL缓存，避免重复请求
    private var urlCache: [String: String] = [:]
    
    override private init() {
        super.init()
        setupAudioSession()
        setupInEarDetection()
    }
    
    deinit {
        cleanupPlayer()
    }
    
    // MARK: - 音频会话设置
    
    /// 设置音频会话
    private func setupAudioSession() {
        #if os(macOS)
        // macOS使用默认音频会话
        print("🎧 设置macOS音频会话")
        #else
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
            print("🎧 设置iOS音频会话成功")
        } catch {
            print("❌ 设置音频会话失败: \(error)")
        }
        #endif
    }
    
    /// 设置入耳检测
    private func setupInEarDetection() {
        print("🎧 开始设置入耳检测...")
        
        // 1. 设置蓝牙管理器
        bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
        
        // 2. 监听音频会话中断（这是入耳检测的主要途径）
        setupAudioInterruptionMonitoring()
        
        // 3. 监听音频路由变化作为补充
        setupAudioRouteMonitoring()
    }
    
    /// 监听音频会话中断
    private func setupAudioInterruptionMonitoring() {
        #if os(iOS)
        // iOS的音频会话中断监听
        audioInterruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioInterruption(notification: notification)
        }
        print("🎧 已设置iOS音频中断监听")
        #else
        // macOS通过系统通知监听音频中断
        audioInterruptionObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("com.apple.audio.SystemInterruption"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            print("🎧 收到macOS音频系统中断通知")
            self?.handleAudioInterruption(notification: notification)
        }
        
        // 同时监听AVPlayer的播放状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        // 监听AVPlayer的播放失败
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemFailedToPlayToEndTime),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil
        )
        
        print("🎧 已设置macOS音频中断监听")
        #endif
    }
    
    /// 处理音频中断
    private func handleAudioInterruption(notification: Notification) {
        print("🎧 收到音频中断通知: \(notification.name)")
        
        #if os(iOS)
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch interruptionType {
        case .began:
            print("🎧 音频中断开始 - 可能是离耳检测")
            handleInEarDetection(isInEar: false)
            
        case .ended:
            print("🎧 音频中断结束 - 可能是入耳检测")
            if let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    handleInEarDetection(isInEar: true)
                }
            }
            
        @unknown default:
            print("🎧 未知音频中断类型")
        }
        #else
        // macOS的处理逻辑
        if let userInfo = notification.userInfo {
            print("🎧 macOS音频中断详情: \(userInfo)")
            // 根据通知内容判断是否为入耳检测相关的中断
            handleInEarDetection(isInEar: false)
        }
        #endif
    }
    
    /// 处理入耳检测事件
    private func handleInEarDetection(isInEar: Bool) {
        guard let player = audioPlayer else {
            print("🎧 没有活跃的播放器")
            return
        }
        
        if isInEar {
            print("🎧 检测到入耳 - 准备恢复播放")
            // 如果之前因为离耳而暂停，现在恢复播放
            if wasPlayingBeforeInterruption && player.rate == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("▶️ 入耳检测：恢复播放")
                    player.play()
                    self.wasPlayingBeforeInterruption = false
                    // 更新播放器状态到PlayerService
                    self.syncPlayStateToPlayerService(isPlaying: true)
                }
            }
        } else {
            print("🎧 检测到离耳 - 准备暂停播放")
            // 如果正在播放，暂停并记录状态
            if player.rate > 0 {
                print("⏸️ 离耳检测：自动暂停播放")
                wasPlayingBeforeInterruption = true
                player.pause()
                // 更新播放器状态到PlayerService
                self.syncPlayStateToPlayerService(isPlaying: false)
            }
        }
    }
    
    // MARK: - 通知处理方法
    
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        print("🎧 播放完成")
        // 播放完成不应该触发入耳检测逻辑
    }
    
    @objc private func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        print("🎧 播放失败")
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            print("❌ 播放错误: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("🔵 蓝牙已开启，准备监听设备状态")
            // 开始扫描已连接的蓝牙设备
            scanForConnectedDevices()
            
        case .poweredOff:
            print("🔴 蓝牙已关闭")
            
        case .unauthorized:
            print("⚠️ 蓝牙权限未授权")
            
        case .unsupported:
            print("⚠️ 设备不支持蓝牙")
            
        case .resetting:
            print("🔄 蓝牙正在重置")
            
        case .unknown:
            print("❓ 蓝牙状态未知")
            
        @unknown default:
            print("❓ 未知蓝牙状态")
        }
    }
    
    /// 扫描已连接的蓝牙设备
    private func scanForConnectedDevices() {
        guard let bluetoothManager = bluetoothManager else { return }
        
        // 获取已连接的音频设备
        let connectedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [
            CBUUID(string: "180F"), // 电池服务
            CBUUID(string: "1812")  // HID服务
        ])
        
        for peripheral in connectedPeripherals {
            print("🎧 发现已连接的蓝牙设备: \(peripheral.name ?? "未知设备")")
            monitorPeripheral(peripheral)
        }
    }
    
    /// 监听外设状态变化
    private func monitorPeripheral(_ peripheral: CBPeripheral) {
        peripheral.delegate = self
        bluetoothManager?.connect(peripheral, options: nil)
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ 发现服务失败: \(error.localizedDescription)")
            return
        }
        
        print("🎧 已连接到设备: \(peripheral.name ?? "未知设备")")
        
        // 发现电池服务和其他相关服务
        peripheral.services?.forEach { service in
            print("🔍 发现服务: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ 发现特征失败: \(error.localizedDescription)")
            return
        }
        
        service.characteristics?.forEach { characteristic in
            print("🔍 发现特征: \(characteristic.uuid)")
            // 订阅特征值变化通知
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 更新特征值失败: \(error.localizedDescription)")
            return
        }
        
        // 这里可能接收到入耳检测相关的数据变化
        print("🎧 设备特征值变化: \(characteristic.uuid)")
        
        // 根据特征值变化判断入耳状态（这需要根据具体设备的协议来实现）
        if let data = characteristic.value {
            print("📊 特征值数据: \(data.map { String(format: "%02x", $0) }.joined(separator: " "))")
            
            // 这里需要根据具体的蓝牙设备协议来解析入耳状态
            // 不同设备的实现可能不同，这是一个通用的框架
        }
    }
    
    /// 设置音频路由监听
    private func setupAudioRouteMonitoring() {
        // macOS使用Core Audio监听
        var audioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // 注册音频设备变化回调
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &audioObjectPropertyAddress, { (objectID, numAddresses, addresses, clientData) -> OSStatus in
            DispatchQueue.main.async {
                let musicService = Unmanaged<MusicService>.fromOpaque(clientData!).takeUnretainedValue()
                print("🎧 macOS音频设备变化")
                musicService.handleMacOSAudioDeviceChange()
            }
            return noErr
        }, Unmanaged.passUnretained(self).toOpaque())
        
        print("🎧 已设置macOS音频设备监听")
    }
    
    /// 处理音频路由变化
    private func handleAudioRouteChange(notification: Notification? = nil) {
        print("🎧 检测到音频路由变化")
        
        // macOS直接检查当前音频设备
        checkCurrentAudioRoute()
    }
    
    /// 处理macOS音频设备变化
    private func handleMacOSAudioDeviceChange() {
        print("🎧 处理macOS音频设备变化")
        checkCurrentAudioRoute()
    }
    
    /// 检查当前音频路由状态
    private func checkCurrentAudioRoute() {
        // macOS使用Core Audio API检查音频设备
        checkMacOSAudioDevice()
    }
    
    /// 检查macOS音频设备
    private func checkMacOSAudioDevice() {
        var defaultOutputDevice: AudioDeviceID = 0
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let result = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &size,
            &defaultOutputDevice
        )
        
        if result == noErr && defaultOutputDevice != kAudioDeviceUnknown {
            // 获取设备名称
            var deviceName: CFString = "" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioObjectPropertyName,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            AudioObjectGetPropertyData(defaultOutputDevice, &nameAddress, 0, nil, &nameSize, &deviceName)
            let deviceNameString = deviceName as String
            print("🎧 当前macOS音频设备: \(deviceNameString)")
            
            // 检查是否为蓝牙/耳机设备
            let isHeadphoneDevice = deviceNameString.lowercased().contains("bluetooth") || 
                                   deviceNameString.lowercased().contains("airpods") ||
                                   deviceNameString.lowercased().contains("beats") ||
                                   deviceNameString.lowercased().contains("headphones")
            
            if isHeadphoneDevice {
                print("🎧 检测到耳机/蓝牙设备")
                // 如果之前暂停了，现在可以恢复
                if let player = audioPlayer, player.rate == 0 && wasPlayingBeforeInterruption {
                    handleInEarDetection(isInEar: true)
                }
            } else {
                print("🔊 检测到内置扬声器")
                // 如果正在播放，考虑暂停
                if let player = audioPlayer, player.rate > 0 {
                    handleInEarDetection(isInEar: false)
                }
            }
        } else {
            print("⚠️ 无法获取macOS音频输出设备")
        }
    }
    
    /// 同步播放状态到PlayerService
    private func syncPlayStateToPlayerService(isPlaying: Bool) {
        DispatchQueue.main.async {
            PlayerService.shared.updatePlayingState(isPlaying)
        }
    }
    
    // MARK: - URL获取相关方法
    
    /// 处理URL，确保格式正确
    private func processURL(_ urlString: String) -> String {
        var processedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🔗 原始URL: \(urlString)")
        
        // 确保URL有协议前缀
        if !processedURL.hasPrefix("http://") && !processedURL.hasPrefix("https://") {
            processedURL = "http://" + processedURL
        }
        
        // 验证URL格式
        if let url = URL(string: processedURL) {
            print("🔗 处理后URL: \(processedURL)")
            print("🔗 URL主机: \(url.host ?? "unknown")")
            print("🔗 URL协议: \(url.scheme ?? "unknown")")
        } else {
            print("❌ URL格式无效: \(processedURL)")
        }
        
        return processedURL
    }
    
    /// 获取歌曲播放URL
    /// - Parameters:
    ///   - song: 歌曲信息
    ///   - quality: 音质选择，默认使用用户首选音质
    ///   - freePart: 是否只获取试听部分
    /// - Returns: 播放URL字符串
    func getSongURL(for song: Song, quality: AudioQuality? = nil, freePart: Bool = false) async throws -> String? {
        guard let hash = song.hash else {
            throw MusicServiceError.invalidHash
        }
        
        let selectedQuality = quality ?? preferredQuality
        let cacheKey = "\(hash)_\(selectedQuality.rawValue)"
        
        // 检查缓存
        if let cachedURL = urlCache[cacheKey] {
            return cachedURL
        }
        
        // 构建请求参数
        var params: [String: String] = [
            "hash": hash,
            "quality": selectedQuality.rawValue
        ]
        
        if let albumId = song.albumId {
            params["album_id"] = albumId
        }
        
        if let albumAudioId = song.albumAudioId {
            params["album_audio_id"] = albumAudioId
        }
        
        if freePart {
            params["free_part"] = "1"
        }
        
        do {
            let response: SongURLResponse = try await NetworkService.shared.get(
                endpoint: "/song/url",
                params: params,
                responseType: SongURLResponse.self
            )
            
            if response.status == 1 {
                // 优先使用主URL列表的第一个
                if let urls = response.url, !urls.isEmpty, let firstURL = urls.first, !firstURL.isEmpty {
                    let processedURL = processURL(firstURL)
                    // 缓存URL
                    urlCache[cacheKey] = processedURL
                    return processedURL
                }
                
                // 如果主URL不可用，尝试备用URL
                if let backupUrls = response.backupUrl, !backupUrls.isEmpty, let firstBackupURL = backupUrls.first, !firstBackupURL.isEmpty {
                    let processedURL = processURL(firstBackupURL)
                    // 缓存URL
                    urlCache[cacheKey] = processedURL
                    return processedURL
                }
                
                // 如果请求的音质不可用，尝试降级到标准音质
                if selectedQuality != .standard {
                    return try await getSongURL(for: song, quality: .standard, freePart: freePart)
                }
                throw MusicServiceError.urlNotAvailable
            } else {
                throw MusicServiceError.urlNotAvailable
            }
        } catch let error as NetworkError {
            throw MusicServiceError.networkError(error.localizedDescription)
        } catch {
            throw MusicServiceError.unknownError
        }
    }
    
    /// 获取多个音质的URL（用于音质选择）
    func getAvailableQualities(for song: Song) async -> [AudioQuality: String] {
        var availableURLs: [AudioQuality: String] = [:]
        
        // 按优先级测试音质
        let priorityQualities: [AudioQuality] = [.standard, .high, .flac, .low]
        
        for quality in priorityQualities {
            do {
                if let url = try await getSongURL(for: song, quality: quality) {
                    availableURLs[quality] = url
                }
            } catch {
                // 忽略单个音质获取失败
                continue
            }
        }
        
        return availableURLs
    }
    
    // MARK: - 播放控制方法
    
    /// 播放歌曲（在线播放）
    func playSong(_ song: Song, playerService: PlayerService) async {
        do {
            print("🎵 开始播放歌曲: \(song.artist) - \(song.title)")
            
            guard let urlString = try await getSongURL(for: song) else {
                throw MusicServiceError.urlNotAvailable
            }
            
            print("🔗 获取到歌曲URL: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                print("❌ URL格式错误: \(urlString)")
                throw MusicServiceError.urlNotAvailable
            }
            
            await MainActor.run {
                // 清理当前播放器
                cleanupPlayer()
                
                print("🎬 创建 AVPlayer，在线播放: \(url)")
                audioPlayer = AVPlayer(url: url)
                
                // 设置播放器观察器
                setupPlayerObservers(playerService: playerService)
                
                // 开始播放
                audioPlayer?.play()
                playerService.updatePlayingState(true)
                print("▶️ 开始在线播放")
                
                // 设置音量和播放速度
                audioPlayer?.volume = Float(playerService.volume)
                audioPlayer?.rate = Float(playerService.playbackSpeed)
                print("🔊 音量: \(playerService.volume), 速度: \(playerService.playbackSpeed)")
            }
        } catch {
            await MainActor.run {
                playerService.updatePlayingState(false)
                print("❌ 播放失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - AVPlayer 控制方法
    
    /// 检查播放器是否准备好播放
    func isPlayerReady() -> Bool {
        return audioPlayer != nil && audioPlayer?.currentItem != nil
    }
    
    /// 暂停播放
    func pausePlayback() {
        audioPlayer?.pause()
    }
    
    /// 恢复播放
    func resumePlayback() {
        audioPlayer?.play()
    }
    
    /// 停止播放
    func stopPlayback() {
        cleanupPlayer()
    }
    
    /// 跳转到指定时间
    func seekTo(_ time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        audioPlayer?.seek(to: cmTime)
    }
    
    /// 设置音量
    func setVolume(_ volume: Double) {
        audioPlayer?.volume = Float(volume)
    }
    
    /// 设置播放速度
    func setPlaybackSpeed(_ speed: Double) {
        audioPlayer?.rate = Float(speed)
    }
    
    // MARK: - 播放器观察器设置
    
    /// 设置播放器观察器
    private func setupPlayerObservers(playerService: PlayerService) {
        guard let player = audioPlayer else { return }
        
        // 播放时间观察器
        let timeInterval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak playerService] time in
            let currentTime = time.seconds
            if !currentTime.isNaN && !currentTime.isInfinite {
                playerService?.updateCurrentTime(currentTime)
            }
        }
        
        // 播放状态观察器
        playerStatusObserver = player.observe(\.status, options: [.new]) { [weak playerService] player, _ in
            DispatchQueue.main.async {
                print("🔄 播放器状态变更: \(player.status.rawValue)")
                switch player.status {
                case .readyToPlay:
                    print("✅ 播放器就绪")
                    // 更新歌曲时长
                    if let duration = player.currentItem?.duration {
                        let seconds = duration.seconds
                        if !seconds.isNaN && !seconds.isInfinite {
                            print("🕰 获取到歌曲时长: \(seconds) 秒")
                            playerService?.updateDuration(seconds)
                        } else {
                            print("⚠️ 歌曲时长无效: \(seconds)")
                        }
                    } else {
                        print("⚠️ 未能获取歌曲时长")
                    }
                case .failed:
                    let errorDesc = player.error?.localizedDescription ?? "未知错误"
                    print("❌ 播放器失败: \(errorDesc)")
                    playerService?.updatePlayingState(false)
                case .unknown:
                    print("❓ 播放器状态未知")
                @unknown default:
                    print("❓ 播放器未知状态")
                }
            }
        }
        
        // 播放结束观察器
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak playerService] _ in
            playerService?.updatePlayingState(false)
            // 这里可以触发播放下一首
        }
    }
    
    /// 清理播放器和观察器
    private func cleanupPlayer() {
        // 移除时间观察器
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // 移除状态观察器
        playerStatusObserver?.invalidate()
        playerStatusObserver = nil
        
        // 移除音频路由观察器
        if let routeObserver = audioRouteObserver {
            NotificationCenter.default.removeObserver(routeObserver)
            audioRouteObserver = nil
        }
        
        // 移除音频中断观察器
        if let interruptionObserver = audioInterruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
            audioInterruptionObserver = nil
        }
        
        // 停止蓝牙扫描和连接
        bluetoothManager?.stopScan()
        bluetoothManager = nil
        
        // 移除通知观察器
        NotificationCenter.default.removeObserver(self)
        
        // 停止并清理播放器
        audioPlayer?.pause()
        audioPlayer = nil
        
        // 重置中断状态
        wasPlayingBeforeInterruption = false
    }
    
    /// 清理URL缓存
    func clearURLCache() {
        urlCache.removeAll()
    }
}

// MARK: - 错误定义

enum MusicServiceError: LocalizedError {
    case invalidHash
    case urlNotAvailable
    case networkError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidHash:
            return "歌曲标识无效"
        case .urlNotAvailable:
            return "无法获取播放链接"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .unknownError:
            return "未知错误"
        }
    }
}
