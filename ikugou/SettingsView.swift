//
//  SettingsView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import AppKit
import SwiftUI

struct SettingsView: View {
    // 引用全局配置
    private let config = AppConfig.shared
    
    // 本地状态
    @State private var selectedTab: SettingsTab = .general
    @State private var apiBaseURL: String
    @State private var apiTimeout: Int
    @State private var enableCache: Bool
    @State private var selectedTheme: AppConfig.ThemeConfig.Mode
    @State private var animateTransitions: Bool
    @State private var isHovered: [SettingsTab: Bool] = [:]
    
    // 设置标签页枚举（参考Spotify分类）
    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "通用"
        case appearance = "外观"
        case playback = "播放"
        case api = "API设置"
        
        var id: Self { self }
        var icon: String {
            switch self {
            case .general: return "gear"
            case .appearance: return "paintpalette"
            case .playback: return "play.circle"
            case .api: return "network"
            }
        }
    }
    
    // 初始化
    init() {
        let defaultAPI = AppConfig.APIConfig(
            baseURL: "http://localhost:3000",
            timeout: 15,
            enableCache: true,
            userAgent: "Default/1.0"
        )
        
        let defaultTheme = AppConfig.ThemeConfig(
            defaultMode: .system,
            accentColorLight: "#FF5722",
            accentColorDark: "#FF7A45",
            allowUserChange: true,
            animateTransitions: true
        )
        
        let safeAPI = config.api ?? defaultAPI
        let safeTheme = config.theme ?? defaultTheme
        
        _apiBaseURL = State(initialValue: safeAPI.baseURL)
        _apiTimeout = State(initialValue: Int(safeAPI.timeout))
        _enableCache = State(initialValue: safeAPI.enableCache)
        _selectedTheme = State(initialValue: safeTheme.defaultMode)
        _animateTransitions = State(initialValue: safeTheme.animateTransitions)
        
        // 初始化悬停状态
        for tab in SettingsTab.allCases {
            isHovered[tab] = false
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 侧边栏导航（Spotify风格）
            VStack(alignment: .leading, spacing: 0) {
                Text("设置")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .padding(.leading, 24)
                
                ForEach(SettingsTab.allCases) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack(spacing: 16) {
                            Image(systemName: tab.icon)
                                .frame(width: 20)
                            Text(tab.rawValue)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundColor(selectedTab == tab ? .spotifyGreen : .spotifyTextSecondary)
                    .background(
                        Group {
                            if selectedTab == tab {
                                Color.spotifyGreen.opacity(0.2)
                            } else if isHovered[tab] == true {
                                Color.white.opacity(0.1)
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .onHover { hovering in
                        isHovered[tab] = hovering
                    }
                    .overlay(
                        Group {
                            if selectedTab == tab {
                                VStack {}.frame(width: 3).background(Color.spotifyGreen)
                            }
                        },
                        alignment: .leading
                    )
                }
                
                Spacer()
            }
            .frame(width: 220)
            .background(Color.spotifySidebar)
            
            // 主内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    switch selectedTab {
                    case .general:
                        GeneralSettingsView()
                    case .appearance:
                        AppearanceSettingsView()
                    case .playback:
                        PlaybackSettingsView()
                    case .api:
                        APISettingsView
                    }
                }
                .padding(30)
                .frame(maxWidth: 600)
            }
            .background(Color.spotifyBackground)
            .foregroundColor(.white)
        }
        .frame(width: 850, height: 550)
        .onAppear {
            if config.api == nil || config.theme == nil {
                showConfigWarning()
            }
        }
    }
    
    // 通用设置（Spotify风格分组）
    private struct GeneralSettingsView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("通用")
                    .font(.system(size: 24, weight: .bold))
                
                // 分组1: 基本设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("基本设置")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    Toggle("启动时自动播放", isOn: .constant(false))
                    Toggle("显示桌面通知", isOn: .constant(true))
                }
                
                Divider()
                    .background(Color.spotifyDivider)
                
                // 分组2: 缓存设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("缓存设置")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    HStack {
                        Text("缓存位置")
                        Spacer()
                        Text("默认位置")
                            .foregroundColor(.spotifyTextSecondary)
                        Button("更改") {
                            // 实现更改逻辑
                        }
                        .foregroundColor(.spotifyGreen)
                        .font(.system(size: 13))
                    }
                    
                    HStack {
                        Text("缓存大小限制")
                        Spacer()
                        Picker("", selection: .constant(1)) {
                            Text("1GB").tag(0)
                            Text("5GB").tag(1)
                            Text("10GB").tag(2)
                            Text("无限制").tag(3)
                        }
                        .frame(width: 120)
                    }
                }
            }
        }
    }
    
    // 外观设置（Spotify风格）
    private struct AppearanceSettingsView: View {
        @State private var selectedTheme: AppConfig.ThemeConfig.Mode
        @State private var animateTransitions: Bool
        
        init() {
            let defaultTheme = AppConfig.shared.theme ?? AppConfig.ThemeConfig(
                defaultMode: .system,
                accentColorLight: "#FF5722",
                accentColorDark: "#FF7A45",
                allowUserChange: true,
                animateTransitions: true
            )
            
            _selectedTheme = State(initialValue: defaultTheme.defaultMode)
            _animateTransitions = State(initialValue: defaultTheme.animateTransitions)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("外观")
                    .font(.system(size: 24, weight: .bold))
                
                // 主题模式
                VStack(alignment: .leading, spacing: 8) {
                    Text("主题模式")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    Picker("选择主题", selection: $selectedTheme) {
                        Text("跟随系统").tag(AppConfig.ThemeConfig.Mode.system)
                        Text("亮色模式").tag(AppConfig.ThemeConfig.Mode.light)
                        Text("暗色模式").tag(AppConfig.ThemeConfig.Mode.dark)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)
                    
                    Text("选择应用的显示模式，跟随系统会根据系统设置自动切换")
                        .font(.system(size: 12))
                        .foregroundColor(.spotifyTextSecondary)
                }
                
                Divider()
                    .background(Color.spotifyDivider)
                
                // 强调色
                VStack(alignment: .leading, spacing: 8) {
                    Text("强调色")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    HStack(spacing: 16) {
                        ColorOptionView(color: .spotifyGreen, label: "默认绿色", isSelected: true)
                        ColorOptionView(color: .red, label: "红色", isSelected: false)
                        ColorOptionView(color: .blue, label: "蓝色", isSelected: false)
                        ColorOptionView(color: .purple, label: "紫色", isSelected: false)
                        ColorOptionView(color: .orange, label: "橙色", isSelected: false)
                    }
                }
                
                Divider()
                    .background(Color.spotifyDivider)
                
                // 动画效果
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("启用界面过渡动画", isOn: $animateTransitions)
                    
                    Text("开启后，界面切换时会显示平滑过渡效果")
                        .font(.system(size: 12))
                        .foregroundColor(.spotifyTextSecondary)
                }
                
                HStack {
                    Spacer()
                    Button("应用设置") {
                        applyThemeConfig()
                    }
                    .buttonStyle(SpotifyButtonStyle())
                }
            }
        }
        
        // 颜色选择器组件
        private struct ColorOptionView: View {
            let color: Color
            let label: String
            let isSelected: Bool
            
            var body: some View {
                VStack {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                        
                        if isSelected {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 40, height: 40)
                        }
                    }
                    Text(label)
                        .font(.system(size: 11))
                        .padding(.top, 4)
                }
            }
        }
        
        private func applyThemeConfig() {
            ThemeManager.shared.switchMode(to: selectedTheme)
            AppConfig.shared.saveThemeConfig(
                mode: selectedTheme,
                animateTransitions: animateTransitions
            )
        }
    }
    
    // 播放设置
    private struct PlaybackSettingsView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("播放")
                    .font(.system(size: 24, weight: .bold))
                
                // 播放设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("播放设置")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    Toggle("播放结束后自动播放下一首", isOn: .constant(true))
                    Toggle("点击歌曲时从头开始播放", isOn: .constant(false))
                    
                    VStack(alignment: .leading) {
                        Text("交叉淡入淡出")
                        Picker("", selection: .constant(1)) {
                            Text("关闭").tag(0)
                            Text("1秒").tag(1)
                            Text("2秒").tag(2)
                            Text("3秒").tag(3)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Divider()
                    .background(Color.spotifyDivider)
                
                // 音量设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("音量")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.spotifyTextSecondary)
                    
                    Toggle("启动时恢复上次音量", isOn: .constant(true))
                    Toggle("使用音频增强", isOn: .constant(false))
                }
            }
        }
    }
    
    // API设置子视图
    private var APISettingsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("API设置")
                .font(.system(size: 24, weight: .bold))
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("API基础地址", text: $apiBaseURL)
                    .textFieldStyle(SpotifyTextFieldStyle())
                
                VStack(alignment: .leading) {
                    Text("超时时间（秒）")
                    TextField("", value: $apiTimeout, format: .number)
                        .textFieldStyle(SpotifyTextFieldStyle())
                        .frame(width: 100)
                }
                
                Toggle("启用请求缓存", isOn: $enableCache)
                
                Text("修改API设置可能影响应用功能，请确保地址正确")
                    .font(.system(size: 12))
                    .foregroundColor(.spotifyTextSecondary)
            }
            
            HStack {
                Spacer()
                Button("保存设置") {
                    saveAPIConfig()
                }
                .buttonStyle(SpotifyButtonStyle())
            }
        }
    }
    
    // 自定义按钮样式（Spotify风格）
    private struct SpotifyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(configuration.isPressed ? Color.spotifyGreen.opacity(0.8) : .spotifyGreen)
                .foregroundColor(.black)
                .cornerRadius(4)
                .font(.system(size: 13, weight: .medium))
                .animation(.none, value: configuration.isPressed)
        }
    }
    
    // 自定义文本框样式
    private struct SpotifyTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(8)
                .background(Color.spotifyCard)
                .foregroundColor(.white)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.spotifyDivider, lineWidth: 1)
                )
        }
    }
    
    // 保存API配置
    private func saveAPIConfig() {
        guard let currentAPI = config.api else {
            showConfigWarning()
            return
        }
        
        AppConfig.shared.saveAPIConfig(
            baseURL: apiBaseURL,
            timeout: TimeInterval(apiTimeout),
            enableCache: enableCache
        )
    }
    
    // 配置警告
    private func showConfigWarning() {
        let alert = NSAlert()
        alert.messageText = "配置加载警告"
        alert.informativeText = "使用默认配置，可能导致部分功能异常"
        alert.addButton(withTitle: "知道了")
        alert.runModal()
    }
}

#Preview {
    SettingsView()
}
