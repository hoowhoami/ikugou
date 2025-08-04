//
//  PlayerManager.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//
import SwiftUI

/// 播放模式枚举
enum PlayMode: String, CaseIterable {
    case sequence = "repeat"           // 顺序播放
    case repeatOne = "repeat.1"        // 单曲循环
    case shuffle = "shuffle"           // 随机播放

    var displayName: String {
        switch self {
        case .sequence: return "顺序播放"
        case .repeatOne: return "单曲循环"
        case .shuffle: return "随机播放"
        }
    }
}

/// 全局播放状态管理器（用 @Observable 替代旧版 ObservableObject，SwiftUI 新特性）
@Observable
class PlayerManager {
    /// 当前播放歌曲（可选，无歌曲时为 nil）
    var currentSong: Song?
    /// 是否正在播放
    var isPlaying: Bool = false
    /// 当前播放时间（秒）
    var currentTime: Double = 0
    /// 歌曲总时长（秒）
    var duration: Double = 0
    /// 音量（0.0 - 1.0）
    var volume: Double = 0.7
    /// 播放速度（0.5 - 2.0）
    var playbackSpeed: Double = 1.0
    /// 播放模式
    var playMode: PlayMode = .sequence
    /// 播放列表
    var playlist: [Song] = []
    /// 当前播放索引
    var currentIndex: Int = 0

    /// 切换播放/暂停状态
    func togglePlayback() {
        isPlaying.toggle()
    }

    /// 播放上一首
    func playPrevious() {
        guard !playlist.isEmpty else { return }

        switch playMode {
        case .shuffle:
            currentIndex = Int.random(in: 0..<playlist.count)
        case .sequence, .repeatOne:
            currentIndex = currentIndex > 0 ? currentIndex - 1 : playlist.count - 1
        }

        currentSong = playlist[currentIndex]
        currentTime = 0
        // 这里可以添加实际的音频播放逻辑
    }

    /// 播放下一首
    func playNext() {
        guard !playlist.isEmpty else { return }

        switch playMode {
        case .shuffle:
            currentIndex = Int.random(in: 0..<playlist.count)
        case .repeatOne:
            // 单曲循环，不改变索引
            break
        case .sequence:
            currentIndex = (currentIndex + 1) % playlist.count
        }

        currentSong = playlist[currentIndex]
        currentTime = 0
        // 这里可以添加实际的音频播放逻辑
    }

    /// 切换播放模式
    func togglePlayMode() {
        let allModes = PlayMode.allCases
        if let currentModeIndex = allModes.firstIndex(of: playMode) {
            let nextIndex = (currentModeIndex + 1) % allModes.count
            playMode = allModes[nextIndex]
        }
    }

    /// 播放指定歌曲
    func playSong(at index: Int) {
        guard index >= 0 && index < playlist.count else { return }
        currentIndex = index
        currentSong = playlist[index]
        currentTime = 0
        isPlaying = true
        // 这里可以添加实际的音频播放逻辑
    }

    /// 设置播放进度
    func seekTo(time: Double) {
        currentTime = max(0, min(duration, time))
        // 这里可以添加实际的音频跳转逻辑
    }

    /// 设置音量
    func setVolume(_ newVolume: Double) {
        volume = max(0, min(1, newVolume))
        // 这里可以添加实际的音量控制逻辑
    }

    /// 设置播放速度
    func setPlaybackSpeed(_ speed: Double) {
        playbackSpeed = max(0.5, min(2.0, speed))
        // 这里可以添加实际的播放速度控制逻辑
    }

    /// 加载播放列表
    func loadPlaylist(_ songs: [Song]) {
        playlist = songs
        if !songs.isEmpty && currentSong == nil {
            currentIndex = 0
            currentSong = songs[0]
            // 设置示例时长
            duration = 180 // 3分钟
        }
    }
}
