//
//  NavigationItemType.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

/// 左侧导航栏选项枚举
enum NavigationItemType: String, CaseIterable, Identifiable {
    // 在线音乐
    case home = "个性推荐"
    case discover = "发现音乐"
    case videos = "视频"
    
    // 我的音乐
    case favoriteMusic = "喜欢的音乐"
    case myCloud = "我的云盘"
    case recentPlay = "最近播放"
    
    // 用户相关
    case userProfile = "用户详情"
    
    var id: String { rawValue }
    
    /// 导航项对应的 SF Symbol 图标
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "globe.americas.fill"
        case .videos: return "play.rectangle.fill"
        case .favoriteMusic: return "heart.fill"
        case .myCloud: return "icloud.fill"
        case .recentPlay: return "clock.fill"
        case .userProfile: return "person.circle"
        }
    }
    
    /// 获取所有在线音乐类型
    static var onlineMusicItems: [NavigationItemType] {
        return [.home, .discover, .videos]
    }
    
    /// 获取所有我的音乐类型
    static var myMusicItems: [NavigationItemType] {
        return [.favoriteMusic, .myCloud, .recentPlay]
    }
    
    /// 是否需要登录才能访问
    var requiresLogin: Bool {
        switch self {
        case .favoriteMusic, .myCloud, .recentPlay:
            return true
        default:
            return false
        }
    }
}

/// 歌单类型枚举
enum PlaylistType: String, CaseIterable, Identifiable {
    case created = "创建的歌单"
    case collected = "收藏的歌单"
    case albums = "收藏的专辑"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .created: return "music.note.list"
        case .collected: return "heart.text.square"
        case .albums: return "opticaldisc"
        }
    }
}
