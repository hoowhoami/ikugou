//
//  NavigationSection.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import SwiftUI

// 全局导航选项枚举（可在整个项目中使用）
enum NavigationSection: String, CaseIterable, Identifiable {
    case home = "首页"
    case search = "搜索"
    case library = "你的媒体库"
    case liked = "喜欢的音乐"
    
    // 遵循Identifiable协议
    var id: Self { self }
    
    // 对应的SF符号
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "music.note.list"
        case .liked: return "heart.fill"
        }
    }
}
