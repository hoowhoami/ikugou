//
//  PlayerService.swift
//  ikugou
//
//  Created on 2025/8/5.
//
import SwiftUI

/// 播放器服务，处理所有播放器相关的业务逻辑
@Observable
class PlayerService {
    static let shared = PlayerService()
    
    /// 播放器状态（内部使用）
    private let player = Player()
    
    /// 音乐播放服务
    private let musicService = MusicService.shared
    
    // MARK: - 持久化相关常量
    private let playlistKey = "SavedPlaylist"
    private let currentIndexKey = "CurrentIndex"
    private let currentTimeKey = "CurrentTime"
    private let playModeKey = "PlayMode"
    private let volumeKey = "Volume"
    private let playbackSpeedKey = "PlaybackSpeed"
    
    private init() {
        // 启动时恢复播放列表状态
        restorePlaylistState()
    }
    
    // MARK: - 对外暴露的属性（只读）
    var currentSong: Song? { player.currentSong }
    var isPlaying: Bool { player.isPlaying }
    var currentTime: Double { player.currentTime }
    var duration: Double { player.duration }
    var volume: Double { player.volume }
    var playbackSpeed: Double { player.playbackSpeed }
    var playMode: PlayMode { player.playMode }
    var playlist: [Song] { player.playlist }
    var currentIndex: Int { player.currentIndex }
    
    // MARK: - 持久化方法
    
    /// 保存播放状态到UserDefaults
    private func savePlaylistState() {
        let userDefaults = UserDefaults.standard
        
        // 保存播放列表
        if let playlistData = try? JSONEncoder().encode(player.playlist) {
            userDefaults.set(playlistData, forKey: playlistKey)
        }
        
        // 保存其他状态
        userDefaults.set(player.currentIndex, forKey: currentIndexKey)
        userDefaults.set(player.currentTime, forKey: currentTimeKey)
        userDefaults.set(player.playMode.rawValue, forKey: playModeKey)
        userDefaults.set(player.volume, forKey: volumeKey)
        userDefaults.set(player.playbackSpeed, forKey: playbackSpeedKey)
    }
    
    /// 从UserDefaults恢复播放状态
    private func restorePlaylistState() {
        let userDefaults = UserDefaults.standard
        
        // 恢复播放列表
        if let playlistData = userDefaults.data(forKey: playlistKey),
           let playlist = try? JSONDecoder().decode([Song].self, from: playlistData) {
            player.playlist = playlist
        }
        
        // 恢复播放索引
        let savedIndex = userDefaults.integer(forKey: currentIndexKey)
        if savedIndex >= 0 && savedIndex < player.playlist.count {
            player.currentIndex = savedIndex
            player.currentSong = player.playlist[savedIndex]
        } else if !player.playlist.isEmpty {
            player.currentIndex = 0
            player.currentSong = player.playlist[0]
        }
        
        // 恢复播放时间
        player.currentTime = userDefaults.double(forKey: currentTimeKey)
        
        // 恢复播放模式
        if let playModeRawValue = userDefaults.object(forKey: playModeKey) as? String,
           let playMode = PlayMode(rawValue: playModeRawValue) {
            player.playMode = playMode
        }
        
        // 恢复音量
        let savedVolume = userDefaults.double(forKey: volumeKey)
        if savedVolume > 0 {
            player.volume = savedVolume
        }
        
        // 恢复播放速度
        let savedSpeed = userDefaults.double(forKey: playbackSpeedKey)
        if savedSpeed >= 0.5 && savedSpeed <= 2.0 {
            player.playbackSpeed = savedSpeed
        }
        
        // 设置示例时长（如果有当前歌曲）
        if let currentSong = player.currentSong {
            player.duration = Double(currentSong.duration ?? 180)
        }
    }
    
    /// 清除保存的播放状态
    private func clearSavedPlaylistState() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: playlistKey)
        userDefaults.removeObject(forKey: currentIndexKey)
        userDefaults.removeObject(forKey: currentTimeKey)
        userDefaults.removeObject(forKey: playModeKey)
        userDefaults.removeObject(forKey: volumeKey)
        userDefaults.removeObject(forKey: playbackSpeedKey)
    }
    
    /// 切换播放/暂停状态
    func togglePlayback() {
        if player.isPlaying {
            musicService.pausePlayback()
            player.isPlaying = false
        } else {
            // 如果有当前歌曲但音频播放器未准备好，重新加载歌曲
            if let currentSong = player.currentSong, !musicService.isPlayerReady() {
                Task {
                    await playNewSong(currentSong)
                }
            } else {
                musicService.resumePlayback()
                player.isPlaying = true
            }
        }
        savePlaylistState()
    }
    
    /// 播放上一首
    func playPrevious() {
        guard !player.playlist.isEmpty else { return }
        
        switch player.playMode {
        case .shuffle:
            player.currentIndex = Int.random(in: 0..<player.playlist.count)
        case .sequence, .repeatOne:
            player.currentIndex = player.currentIndex > 0 ? player.currentIndex - 1 : player.playlist.count - 1
        }
        
        player.currentSong = player.playlist[player.currentIndex]
        player.currentTime = 0
        savePlaylistState()
        
        // 播放新歌曲
        if let currentSong = player.currentSong {
            Task {
                await playNewSong(currentSong)
            }
        }
    }
    
    /// 播放下一首
    func playNext() {
        guard !player.playlist.isEmpty else { return }
        
        switch player.playMode {
        case .shuffle:
            player.currentIndex = Int.random(in: 0..<player.playlist.count)
        case .repeatOne:
            // 单曲循环，不改变索引
            break
        case .sequence:
            player.currentIndex = (player.currentIndex + 1) % player.playlist.count
        }
        
        player.currentSong = player.playlist[player.currentIndex]
        player.currentTime = 0
        savePlaylistState()
        
        // 播放新歌曲
        if let currentSong = player.currentSong {
            Task {
                await playNewSong(currentSong)
            }
        }
    }
    
    /// 切换播放模式
    func togglePlayMode() {
        let allModes = PlayMode.allCases
        if let currentModeIndex = allModes.firstIndex(of: player.playMode) {
            let nextIndex = (currentModeIndex + 1) % allModes.count
            player.playMode = allModes[nextIndex]
        }
        savePlaylistState()
    }
    
    /// 播放指定歌曲
    func playSong(at index: Int) {
        guard index >= 0 && index < player.playlist.count else { return }
        player.currentIndex = index
        player.currentSong = player.playlist[index]
        player.currentTime = 0
        player.isPlaying = true
        savePlaylistState()
        
        // 播放新歌曲
        if let currentSong = player.currentSong {
            Task {
                await playNewSong(currentSong)
            }
        }
    }
    
    /// 设置播放进度
    func seekTo(time: Double) {
        player.currentTime = max(0, min(player.duration, time))
        musicService.seekTo(time)
        savePlaylistState()
    }
    
    /// 设置音量
    func setVolume(_ newVolume: Double) {
        player.volume = max(0, min(1, newVolume))
        musicService.setVolume(newVolume)
        savePlaylistState()
    }
    
    /// 设置播放速度
    func setPlaybackSpeed(_ speed: Double) {
        player.playbackSpeed = max(0.5, min(2.0, speed))
        musicService.setPlaybackSpeed(speed)
        savePlaylistState()
    }
    
    /// 加载播放列表
    func loadPlaylist(_ songs: [Song]) {
        player.playlist = songs
        if !songs.isEmpty && player.currentSong == nil {
            player.currentIndex = 0
            player.currentSong = songs[0]
            // 设置示例时长
            player.duration = 180 // 3分钟
        }
        savePlaylistState()
    }
    
    /// 添加歌曲到播放列表（去重）
    func addSongs(_ songs: [Song]) {
        let uniqueSongs = songs.filter { newSong in
            !player.playlist.contains { existingSong in
                existingSong == newSong
            }
        }
        
        player.playlist.append(contentsOf: uniqueSongs)
        
        // 如果当前没有播放歌曲，则设置第一首
        if player.currentSong == nil && !player.playlist.isEmpty {
            player.currentIndex = 0
            player.currentSong = player.playlist[0]
            player.duration = Double(player.playlist[0].duration ?? 180)
        }
        savePlaylistState()
    }
    
    /// 添加单首歌曲到播放列表（去重）
    func addSong(_ song: Song) {
        addSongs([song])
    }
    
    /// 播放指定的歌曲列表（替换当前播放列表）
    func playAllSongs(_ songs: [Song]) {
        let songsToPlay = songs.isEmpty ? [] : songs
        player.playlist = songsToPlay
        
        if !songsToPlay.isEmpty {
            player.currentIndex = 0
            player.currentSong = songsToPlay[0]
            player.duration = Double(songsToPlay[0].duration ?? 180)
            player.isPlaying = true
            
            // 播放第一首歌曲
            Task {
                await playNewSong(songsToPlay[0])
            }
        }
        savePlaylistState()
    }
    
    /// 播放指定歌曲（将歌曲添加到播放列表并播放）
    func playSong(_ song: Song) {
        // 如果歌曲已在播放列表中，直接播放
        if let existingIndex = player.playlist.firstIndex(where: { $0 == song }) {
            playSong(at: existingIndex)
        } else {
            // 添加歌曲到播放列表并播放
            player.playlist.append(song)
            let newIndex = player.playlist.count - 1
            playSong(at: newIndex)
        }
        // 注意: playSong(at:) 已经调用了 savePlaylistState，所以这里不需要重复调用
    }
    
    /// 从播放列表中删除指定歌曲
    func removeSong(at index: Int) {
        guard index >= 0 && index < player.playlist.count else { return }
        
        // 如果删除的是当前播放的歌曲
        if index == player.currentIndex {
            // 如果只有一首歌，停止播放
            if player.playlist.count == 1 {
                player.currentSong = nil
                player.isPlaying = false
                player.currentIndex = 0
            } else {
                // 如果删除的是最后一首歌，播放前一首
                if index == player.playlist.count - 1 {
                    player.currentIndex = index - 1
                } 
                // 否则播放下一首（因为删除后索引自动向前移动）
                player.playlist.remove(at: index)
                if player.currentIndex < player.playlist.count {
                    player.currentSong = player.playlist[player.currentIndex]
                } else {
                    player.currentIndex = 0
                    player.currentSong = player.playlist.isEmpty ? nil : player.playlist[0]
                }
                return
            }
        } else if index < player.currentIndex {
            // 如果删除的歌曲在当前播放歌曲之前，更新索引
            player.currentIndex -= 1
        }
        
        player.playlist.remove(at: index)
        savePlaylistState()
    }
    
    /// 清空播放列表
    func clearPlaylist() {
        player.playlist.removeAll()
        player.currentSong = nil
        player.currentIndex = 0
        player.isPlaying = false
        player.currentTime = 0
        musicService.stopPlayback()
        clearSavedPlaylistState()
    }
    
    /// 从播放列表中删除指定的歌曲
    func removeSongs(_ songsToRemove: [Song]) {
        // 找到要删除的歌曲索引
        var indicesToRemove: [Int] = []
        
        for song in songsToRemove {
            if let index = player.playlist.firstIndex(of: song) {
                indicesToRemove.append(index)
            }
        }
        
        // 按降序排列索引，从后往前删除避免索引变化问题
        indicesToRemove.sort(by: >)
        
        for index in indicesToRemove {
            removeSong(at: index)
        }
    }
    
    /// 验证播放索引是否有效
    func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < player.playlist.count
    }
    
    /// 获取随机播放索引
    func getRandomIndex() -> Int {
        guard !player.playlist.isEmpty else { return 0 }
        return Int.random(in: 0..<player.playlist.count)
    }
    
    // MARK: - 内部方法（用于直接更新状态，供音频播放器使用）
    /// 更新播放时间（通常由音频播放器定时器调用）
    func updateCurrentTime(_ time: Double) {
        player.currentTime = time
    }
    
    /// 更新歌曲时长（当加载新歌曲时调用）
    func updateDuration(_ duration: Double) {
        player.duration = duration
    }
    
    /// 更新播放状态（当音频播放器状态改变时调用）
    func updatePlayingState(_ isPlaying: Bool) {
        player.isPlaying = isPlaying
    }
    
    // MARK: - 私有方法
    
    /// 播放新歌曲的私有方法
    private func playNewSong(_ song: Song) async {
        // 立即设置预期时长（从歌曲信息中获取）
        if let duration = song.duration {
            player.duration = Double(duration)
        }
        
        await musicService.playSong(song, playerService: self)
    }
}