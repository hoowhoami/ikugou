//
//  HomeViewModel.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

@Observable
class HomeViewModel {
    /// 推荐歌单数据
    var recommendedPlaylists: [Song] = []
    
    /// 加载推荐歌单（演示：实际可调用 Service 层）
    func loadRecommendedPlaylists() {
        // 模拟数据
        recommendedPlaylists = [
            Song(title: "热门推荐1", artist: "歌手A", album: "专辑1", cover: "cover1"),
            Song(title: "热门推荐2", artist: "歌手B", album: "专辑2", cover: "cover2")
        ]
    }
}
