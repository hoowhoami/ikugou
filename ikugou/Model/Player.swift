//
//  Player.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/5.
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

/// 播放器状态模型
@Observable
class Player {
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
    
    init() {}
}