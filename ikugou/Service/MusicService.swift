//
//  MusicService.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import Foundation

class MusicService {
    /// 获取推荐歌单（演示：实际用 URLSession 或 Alamofire 发请求）
    func fetchRecommendedPlaylists() async throws -> [Song] {
        // 模拟返回数据
        return [
            Song(title: "推荐1", artist: "歌手A", album: "专辑X", cover: "cover1"),
            Song(title: "推荐2", artist: "歌手B", album: "专辑Y", cover: "cover2")
        ]
    }
    
    /// 搜索歌曲（演示模板）
    func searchSongs(keyword: String) async throws -> [Song] {
        // 实际实现网络请求...
        return []
    }
}
