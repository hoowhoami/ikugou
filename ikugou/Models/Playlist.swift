//
//  Playlist.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation

// 播放列表模型
struct Playlist: Identifiable {
    let id: String
    let name: String
    let coverUrl: String
    let owner: String
}
