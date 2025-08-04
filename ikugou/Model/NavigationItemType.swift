//
//  NavigationItemType.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

/// 左侧导航栏选项枚举
enum NavigationItemType: String, CaseIterable, Identifiable {
    case home = "首页"
    case discover = "发现"
    case library = "音乐库"
    
    var id: String { rawValue }
    
    /// 导航项对应的 SF Symbol 图标
    var icon: String {
        switch self {
        case .home: return "house"
        case .discover: return "compass"
        case .library: return "music.note.list"
        }
    }
}
