//
//  ikugouApp.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI
import AppKit

// 应用入口
@main
struct ikugouApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// 全局播放管理器（注入环境，供所有视图访问）
    @State private var playerService = PlayerService.shared

    /// 应用设置管理器
    @State private var appSetting = AppSetting.shared
    
    /// 用户服务管理器
    @State private var userService = UserService.shared
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(playerService)
                .environment(appSetting)
                .environment(userService)
                .onAppear {
                    configureWindow()
                    
                    // app启动时自动刷新token和用户信息
                    Task {
                        await userService.autoRefreshOnAppLaunch()
                    }
                }
        }
        .windowResizability(.contentSize)

    }

    /// 配置窗口样式
    private func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // 隐藏标题栏但保留窗口控制按钮
                window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = false
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
        .environment(PlayerService.shared)
        .environment(AppSetting.shared)
        .environment(UserService.shared)
}
