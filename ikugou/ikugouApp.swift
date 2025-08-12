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
        Window("ikugou", id: "main") {
            MainView()
                .environmentObject(playerService)
                .environmentObject(appSetting)
                .environmentObject(userService)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .commands {
            // 禁用"新建窗口"菜单项
            CommandGroup(replacing: .newItem) { }
        }

    }
}

// 预览配置
#Preview {
    // 预览 MainView 并手动注入环境
    MainView()
        .environmentObject(PlayerService.shared)
        .environmentObject(AppSetting.shared)
        .environmentObject(UserService.shared)
}
