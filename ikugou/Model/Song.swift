//
//  Song.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//
import SwiftUI

/// 歌曲数据模型
struct Song: Identifiable {
    let id = UUID()
    let title: String    // 歌曲名
    let artist: String   // 歌手
    let album: String    // 专辑
    let cover: String    // 封面图名称（本地 Assets 或网络地址）
}
