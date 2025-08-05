//
//  ikugouApp.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI
import AppKit

// 应用入口
@main
struct ikugouApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// 全局播放管理器（注入环境，供所有视图访问）
    @State private var playerManager = PlayerManager()

    /// 应用设置管理器
    @State private var appSetting = AppSetting.shared
    
    /// 用户服务管理器
    @State private var userService = UserService.shared
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(playerManager)
                .environment(appSetting)
                .environment(userService)
                .onAppear {
                    loadSampleData()
                    configureWindow()
                }
        }
        .windowResizability(.contentSize)

    }

    /// 加载示例数据
    private func loadSampleData() {
        let sampleSongs = [
            Song(title: "我的音乐 1", artist: "歌手 X", album: "专辑 X", cover: "cover1"),
            Song(title: "我的音乐 2", artist: "歌手 Y", album: "专辑 Y", cover: "cover2"),
            Song(title: "自定义歌单 1", artist: "艺术家 A", album: "专辑 A", cover: "cover1"),
            Song(title: "自定义歌单 2", artist: "艺术家 B", album: "专辑 B", cover: "cover2"),
            Song(title: "收藏的音乐", artist: "多位艺术家", album: "精选集", cover: "cover1")
        ]

        playerManager.loadPlaylist(sampleSongs)
    }

    /// 配置窗口样式
    private func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // 隐藏标题栏但保留窗口控制按钮
                window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = true
                window.title = ""

                // 确保标题栏完全透明
                if let titlebarView = window.standardWindowButton(.closeButton)?.superview {
                    titlebarView.wantsLayer = true
                    titlebarView.layer?.backgroundColor = NSColor.clear.cgColor
                }
            }
        }
    }
}

// 预览配置
#Preview {
    // 预览 MainView 并手动注入环境
    MainView()
        .environment(PlayerManager())
        .environment(AppSetting.shared)
        .environment(UserService.shared)
}
