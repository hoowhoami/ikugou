//
//  PlaybackState.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation

// 播放状态模型
struct PlaybackState {
    let isPlaying: Bool
    let currentSong: Song?
    let progress: TimeInterval
    let volume: Float
    let repeatMode: RepeatMode
    let shuffleEnabled: Bool
}
