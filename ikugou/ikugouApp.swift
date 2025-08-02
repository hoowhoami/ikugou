//
//  ikugouApp.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import SwiftUI
import AppKit

@main
struct ikugouApp: App {
    @State private var windowConfigured = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    // 配置窗口样式
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        configureWindow()
                    }
                }
        }
    }
    
    // 窗口样式配置（隐藏标题栏，统一风格）
    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first, !windowConfigured else { return }
        
        window.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        window.titleVisibility = .hidden          // 完全隐藏标题
        window.titlebarAppearsTransparent = true  // 标题栏透明
        window.backgroundColor = .spotifyBackground // 与应用背景色统一
        window.isMovableByWindowBackground = true // 允许通过背景拖拽窗口
        windowConfigured = true
    }
}



