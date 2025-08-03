//
//  Song.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation

// 歌曲模型
struct Song: Identifiable, Codable {
    let id: String
    let name: String
    let artist: String
    let album: String
    let albumCoverUrl: String
    let audioUrl: String
    let duration: TimeInterval
    let trackNumber: Int
    let releaseDate: String?
    
    // 从JSON初始化
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artist = try container.decode(String.self, forKey: .artist)
        album = try container.decode(String.self, forKey: .album)
        albumCoverUrl = try container.decode(String.self, forKey: .albumCoverUrl)
        audioUrl = try container.decode(String.self, forKey: .audioUrl)
        
        // 处理时长 - 可能是秒数或毫秒数
        let durationValue = try container.decode(TimeInterval.self, forKey: .duration)
        duration = durationValue > 1000 ? durationValue / 1000 : durationValue
        
        trackNumber = try container.decode(Int.self, forKey: .trackNumber)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
    }
    
    // 手动初始化
    init(
        id: String,
        name: String,
        artist: String,
        album: String,
        albumCoverUrl: String,
        audioUrl: String,
        duration: TimeInterval,
        trackNumber: Int,
        releaseDate: String? = nil
    ) {
        self.id = id
        self.name = name
        self.artist = artist
        self.album = album
        self.albumCoverUrl = albumCoverUrl
        self.audioUrl = audioUrl
        self.duration = duration
        self.trackNumber = trackNumber
        self.releaseDate = releaseDate
    }
    
    // 编码键
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist
        case album
        case albumCoverUrl
        case audioUrl
        case duration
        case trackNumber
        case releaseDate
    }
}
