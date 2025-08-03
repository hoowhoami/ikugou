//
//  AudioEngine.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation
import AVFoundation
import Combine
import AppKit

// 播放模式枚举
enum RepeatMode {
    case none       // 不重复
    case all        // 列表循环
    case one        // 单曲循环
}

class AudioEngine: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var currentSong: Song?
    @Published var repeatMode: RepeatMode = .none
    @Published var isShuffling: Bool = false
    
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var audioFormat: AVAudioFormat?
    private var audioDuration: TimeInterval = 0
    private var timer: Timer?
    private var url: URL?
    private var playlist: [Song] = []
    private var currentIndex: Int = 0
    private var shuffleQueue: [Int] = []
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownTime: TimeInterval = 0
    
    override init() {
        super.init()
        setupAudioEngine()
        setupNotifications()
    }
    
    // 配置音频引擎 - 修复函数声明错误
    private func setupAudioEngine() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("音频引擎启动失败: \(error.localizedDescription)")
        }
    }
    
    // 设置系统通知监听
    private func setupNotifications() {
        // 监听应用进入后台
        NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                if self?.isPlaying ?? false {
                    self?.pause()
                }
            }
            .store(in: &cancellables)
    }
    
    // 加载并播放指定歌曲
    func play(song: Song, playlist: [Song] = []) {
        if !playlist.isEmpty {
            self.playlist = playlist
            self.currentIndex = playlist.firstIndex { $0.id == song.id } ?? 0
            setupShuffleQueue()
        }
        
        currentSong = song
        audioDuration = song.duration
        currentTime = 0
        lastKnownTime = 0
        
        // 停止当前播放
        stop()
        
        // 加载音频文件
        loadAudio(from: song.audioUrl) { [weak self] success in
            guard let self = self, success else { return }
            self.startPlayback()
        }
    }
    
    // 从URL加载音频
    private func loadAudio(from urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            print("无效的音频URL")
            completion(false)
            return
        }
        
        // 检查是本地文件还是网络URL
        if url.isFileURL {
            loadLocalAudio(url: url, completion: completion)
        } else {
            loadRemoteAudio(url: url, completion: completion)
        }
    }
    
    // 加载本地音频
    private func loadLocalAudio(url: URL, completion: @escaping (Bool) -> Void) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            audioFormat = audioFile?.processingFormat
            self.url = url
            completion(true)
        } catch {
            print("加载本地音频失败: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // 加载网络音频
    private func loadRemoteAudio(url: URL, completion: @escaping (Bool) -> Void) {
        // 下载音频文件到临时目录
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let mimeType = response?.mimeType,
                  mimeType.starts(with: "audio/"),
                  let self = self else {
                print("下载音频失败: \(error?.localizedDescription ?? "未知错误")")
                completion(false)
                return
            }
            
            // 创建临时文件
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mp3"
            let tempUrl = tempDir.appendingPathComponent(fileName)
            
            do {
                try data.write(to: tempUrl)
                self.loadLocalAudio(url: tempUrl, completion: completion)
            } catch {
                print("保存临时音频文件失败: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    // 开始播放
    private func startPlayback() {
        guard let audioFile = audioFile else { return }
        
        // 使用带完成回调的调度方法
        playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackComplete()
            }
        }
        
        // 如果有已知的上次播放时间，从该位置开始播放
        if lastKnownTime > 0 {
            seek(to: lastKnownTime)
        } else {
            playerNode.play()
            isPlaying = true
            startProgressTimer()
        }
    }
    
    // 暂停播放
    func pause() {
        // 保存当前播放时间
        lastKnownTime = currentTime
        playerNode.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    // 继续播放
    func resume() {
        playerNode.play()
        isPlaying = true
        startProgressTimer()
    }
    
    // 停止播放
    func stop() {
        playerNode.stop()
        isPlaying = false
        timer?.invalidate()
        currentTime = 0
        lastKnownTime = 0
        // 清除当前调度的音频
        playerNode.reset()
    }
    
    // 跳转到指定时间 - 修复所有跳转相关错误
    func seek(to time: TimeInterval) {
        guard let audioFile = audioFile, let audioFormat = audioFormat else { return }
        
        let sampleRate = audioFormat.sampleRate
        let framePosition = AVAudioFramePosition(time * sampleRate)
        
        if framePosition < audioFile.length {
            let wasPlaying = isPlaying
            stop()
            
            // 计算需要从哪个位置开始播放
            let startFrame = AVAudioFrameCount(framePosition)
            let totalFrames = audioFile.length
            
            // 创建一个新的音频缓冲区，从指定位置开始
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(totalFrames - framePosition))!
            do {
                try audioFile.read(into: buffer, frameCount: AVAudioFrameCount(totalFrames - framePosition))
                audioFile.framePosition = framePosition // 设置文件读取位置
                
                // 调度从指定位置开始的音频
                playerNode.scheduleBuffer(buffer) { [weak self] in
                    DispatchQueue.main.async {
                        self?.handlePlaybackComplete()
                    }
                }
                
                // 开始播放
                playerNode.play()
                currentTime = time
                lastKnownTime = time
                
                if !wasPlaying {
                    pause()
                } else {
                    isPlaying = true
                    startProgressTimer()
                }
            } catch {
                print("音频跳转失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 调整音量
    func setVolume(_ volume: Float) {
        engine.mainMixerNode.volume = volume
    }
    
    // 下一曲
    func next() {
        if playlist.isEmpty { return }
        
        let nextIndex: Int
        
        if isShuffling, !shuffleQueue.isEmpty {
            nextIndex = shuffleQueue.removeFirst()
        } else {
            nextIndex = (currentIndex + 1) % playlist.count
        }
        
        currentIndex = nextIndex
        play(song: playlist[nextIndex], playlist: playlist)
    }
    
    // 上一曲
    func previous() {
        if playlist.isEmpty { return }
        
        let previousIndex: Int
        
        if currentTime > 3 {
            // 如果当前播放时间超过3秒，重新播放当前歌曲
            seek(to: 0)
            return
        } else if isShuffling, shuffleQueue.count < playlist.count - 1 {
            // 处理随机播放时的上一曲逻辑
            setupShuffleQueue()
            previousIndex = shuffleQueue.removeFirst()
        } else {
            previousIndex = (currentIndex - 1 + playlist.count) % playlist.count
        }
        
        currentIndex = previousIndex
        play(song: playlist[previousIndex], playlist: playlist)
    }
    
    // 切换重复模式
    func toggleRepeatMode() {
        switch repeatMode {
        case .none:
            repeatMode = .all
        case .all:
            repeatMode = .one
        case .one:
            repeatMode = .none
        }
    }
    
    // 切换随机播放
    func toggleShuffle() {
        isShuffling = !isShuffling
        setupShuffleQueue()
    }
    
    // 设置随机播放队列
    private func setupShuffleQueue() {
        guard isShuffling, !playlist.isEmpty else { return }
        
        var queue = Array(0..<playlist.count)
        queue.remove(at: currentIndex)
        queue.shuffle()
        shuffleQueue = queue
    }
    
    // 处理播放完成
    private func handlePlaybackComplete() {
        timer?.invalidate()
        
        switch repeatMode {
        case .one:
            // 单曲循环
            seek(to: 0)
        case .all:
            // 列表循环
            next()
        case .none:
            // 不重复，播放结束
            isPlaying = false
            currentTime = audioDuration
            lastKnownTime = audioDuration
        }
    }
    
    // 启动进度计时器
    private func startProgressTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else {
                self?.timer?.invalidate()
                return
            }
            
            if let nodeTime = self.playerNode.lastRenderTime,
               let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime),
               let sampleRate = self.audioFormat?.sampleRate {
                
                let currentTime = TimeInterval(playerTime.sampleTime) / sampleRate
                self.currentTime = min(currentTime, self.audioDuration)
                self.lastKnownTime = self.currentTime
            }
        }
    }
    
    // 清理资源
    deinit {
        timer?.invalidate()
        engine.stop()
        playerNode.stop()
        cancellables.removeAll()
    }
}
    
    
    
    
