//
//  Album.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation

// 专辑模型
struct Album: Identifiable {
    let id: String
    let name: String
    let artist: String
    let coverUrl: String
}
