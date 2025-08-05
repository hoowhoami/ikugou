//
//  MainView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

// 主视图
struct MainView: View {
    /// 当前选中的导航项
    @State private var selectedItem: NavigationItemType = .home

    @Environment(AppSetting.self) private var appSettings

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // 左侧导航栏
                SidebarView(selectedItem: $selectedItem)
                    .frame(width: 200)
                    .background(Color(NSColor.controlBackgroundColor))

                // 右侧主内容区域
                VStack(spacing: 0) {
                    // 主内容区域
                    ContentArea(selectedItem: selectedItem)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.windowBackgroundColor))

                    // 底部播放器
                    PlayerView()
                        .frame(height: 80)
                        .background(Color(NSColor.windowBackgroundColor))
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    // 简化的标题栏：只有搜索框
                    CustomTitleBarContent()
                        .frame(maxWidth: .infinity)
                }
            }
            .toolbarBackground(.visible, for: .windowToolbar)
        }
        .frame(minWidth: 800, minHeight: 600)
        .preferredColorScheme(appSettings.appearanceMode.colorScheme)
        .onAppear {
            configureWindow()
        }
    }

    /// 配置窗口以确保标题栏正确显示
    private func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
            }
        }
    }
}
