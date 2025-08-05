//
//  PlayerManager.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//
import SwiftUI

/// 全局播放状态管理器（使用Player模型和PlayerService处理业务逻辑）
@Observable
class PlayerManager {
    /// 播放器状态
    private let player = Player()
    /// 播放器服务
    private let service = PlayerService.shared
    
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
    
    // MARK: - 播放控制方法
    /// 切换播放/暂停状态
    func togglePlayback() {
        service.togglePlayback(player: player)
    }

    /// 播放上一首
    func playPrevious() {
        service.playPrevious(player: player)
    }

    /// 播放下一首
    func playNext() {
        service.playNext(player: player)
    }

    /// 切换播放模式
    func togglePlayMode() {
        service.togglePlayMode(player: player)
    }

    /// 播放指定歌曲
    func playSong(at index: Int) {
        service.playSong(at: index, player: player)
    }

    /// 设置播放进度
    func seekTo(time: Double) {
        service.seekTo(time: time, player: player)
    }

    /// 设置音量
    func setVolume(_ newVolume: Double) {
        service.setVolume(newVolume, player: player)
    }

    /// 设置播放速度
    func setPlaybackSpeed(_ speed: Double) {
        service.setPlaybackSpeed(speed, player: player)
    }

    /// 加载播放列表
    func loadPlaylist(_ songs: [Song]) {
        service.loadPlaylist(songs, player: player)
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
}
