//
//  PlayerService.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/5.
//
import SwiftUI

/// 播放器服务，处理所有播放器相关的业务逻辑
class PlayerService {
    static let shared = PlayerService()
    
    private init() {}
    
    /// 切换播放/暂停状态
    func togglePlayback(player: Player) {
        player.isPlaying.toggle()
    }
    
    /// 播放上一首
    func playPrevious(player: Player) {
        guard !player.playlist.isEmpty else { return }
        
        switch player.playMode {
        case .shuffle:
            player.currentIndex = Int.random(in: 0..<player.playlist.count)
        case .sequence, .repeatOne:
            player.currentIndex = player.currentIndex > 0 ? player.currentIndex - 1 : player.playlist.count - 1
        }
        
        player.currentSong = player.playlist[player.currentIndex]
        player.currentTime = 0
        // 这里可以添加实际的音频播放逻辑
    }
    
    /// 播放下一首
    func playNext(player: Player) {
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
        // 这里可以添加实际的音频播放逻辑
    }
    
    /// 切换播放模式
    func togglePlayMode(player: Player) {
        let allModes = PlayMode.allCases
        if let currentModeIndex = allModes.firstIndex(of: player.playMode) {
            let nextIndex = (currentModeIndex + 1) % allModes.count
            player.playMode = allModes[nextIndex]
        }
    }
    
    /// 播放指定歌曲
    func playSong(at index: Int, player: Player) {
        guard index >= 0 && index < player.playlist.count else { return }
        player.currentIndex = index
        player.currentSong = player.playlist[index]
        player.currentTime = 0
        player.isPlaying = true
        // 这里可以添加实际的音频播放逻辑
    }
    
    /// 设置播放进度
    func seekTo(time: Double, player: Player) {
        player.currentTime = max(0, min(player.duration, time))
        // 这里可以添加实际的音频跳转逻辑
    }
    
    /// 设置音量
    func setVolume(_ newVolume: Double, player: Player) {
        player.volume = max(0, min(1, newVolume))
        // 这里可以添加实际的音量控制逻辑
    }
    
    /// 设置播放速度
    func setPlaybackSpeed(_ speed: Double, player: Player) {
        player.playbackSpeed = max(0.5, min(2.0, speed))
        // 这里可以添加实际的播放速度控制逻辑
    }
    
    /// 加载播放列表
    func loadPlaylist(_ songs: [Song], player: Player) {
        player.playlist = songs
        if !songs.isEmpty && player.currentSong == nil {
            player.currentIndex = 0
            player.currentSong = songs[0]
            // 设置示例时长
            player.duration = 180 // 3分钟
        }
    }
    
    /// 验证播放索引是否有效
    func isValidIndex(_ index: Int, player: Player) -> Bool {
        return index >= 0 && index < player.playlist.count
    }
    
    /// 获取随机播放索引
    func getRandomIndex(player: Player) -> Int {
        guard !player.playlist.isEmpty else { return 0 }
        return Int.random(in: 0..<player.playlist.count)
    }
}