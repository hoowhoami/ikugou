//
//  SettingsView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    // 引用全局配置
    private let config = AppConfig.shared
    
    // 本地状态（使用可选类型和安全默认值）
    @State private var apiBaseURL: String
    @State private var apiTimeout: Int
    @State private var enableCache: Bool
    @State private var selectedTheme: AppConfig.ThemeConfig.Mode
    @State private var animateTransitions: Bool
    
    // 初始化：安全处理可能为nil的配置
    init() {
        // 为API配置设置安全默认值（当config.api为nil时使用）
        let defaultAPI = AppConfig.APIConfig(
            baseURL: "http://localhost:3000",
            timeout: 15,
            enableCache: true,
            userAgent: "Default/1.0"
        )
        
        // 为主题配置设置安全默认值
        let defaultTheme = AppConfig.ThemeConfig(
            defaultMode: .system,
            accentColorLight: "#FF5722",
            accentColorDark: "#FF7A45",
            allowUserChange: true,
            animateTransitions: true
        )
        
        // 使用空合运算符处理可选配置
        let safeAPI = config.api ?? defaultAPI
        let safeTheme = config.theme ?? defaultTheme
        
        // 初始化状态
        _apiBaseURL = State(initialValue: safeAPI.baseURL)
        _apiTimeout = State(initialValue: Int(safeAPI.timeout))
        _enableCache = State(initialValue: safeAPI.enableCache)
        _selectedTheme = State(initialValue: safeTheme.defaultMode)
        _animateTransitions = State(initialValue: safeTheme.animateTransitions)
    }
    
    var body: some View {
        TabView {
            APISettingsView
                .tabItem {
                    Image(systemName: "network")
                    Text("API设置")
                }
            
            themeSettingsView
                .tabItem {
                    Image(systemName: "paintpalette")
                    Text("主题设置")
                }
        }
        .frame(width: 500, height: 300)
        .padding()
        // 显示配置加载警告（如果需要）
        .onAppear {
            if config.api == nil || config.theme == nil {
                showConfigWarning()
            }
        }
    }
    
    // 配置加载失败时显示警告
    private func showConfigWarning() {
        let alert = NSAlert()
        alert.messageText = "配置加载警告"
        alert.informativeText = "使用默认配置，可能导致部分功能异常"
        alert.addButton(withTitle: "知道了")
        alert.runModal()
    }
}

// API设置子视图（已确保安全访问）
private extension SettingsView {
    var APISettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("API配置")
                .font(.headline)
            
            TextField("API基础地址", text: $apiBaseURL)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Text("超时时间（秒）")
                Spacer()
                TextField("", value: $apiTimeout, format: .number)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
            }
            
            Toggle("启用请求缓存", isOn: $enableCache)
            
            HStack {
                Spacer()
                Button("保存设置") {
                    saveAPIConfig()
                }
            }
        }
        .padding()
    }
    
    private func saveAPIConfig() {
        // 保存前再次检查配置是否可用
        guard let currentAPI = config.api else {
            showConfigWarning()
            return
        }
        
        // 调用保存方法
        AppConfig.shared.saveAPIConfig(
            baseURL: apiBaseURL,
            timeout: TimeInterval(apiTimeout),
            enableCache: enableCache
        )
    }
}

// 主题设置子视图（已确保安全访问）
private extension SettingsView {
    var themeSettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("主题配置")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("主题模式")
                Picker("选择主题", selection: $selectedTheme) {
                    Text("跟随系统").tag(AppConfig.ThemeConfig.Mode.system)
                    Text("亮色模式").tag(AppConfig.ThemeConfig.Mode.light)
                    Text("暗色模式").tag(AppConfig.ThemeConfig.Mode.dark)
                }
                .pickerStyle(.segmented)
                // 安全处理可选的allowUserChange
                .disabled(config.theme?.allowUserChange == false)
            }
            
            // 强调色预览（双重安全检查）
            VStack(alignment: .leading) {
                Text("强调色预览")
                HStack(spacing: 20) {
                    let lightHex = config.theme?.accentColorLight ?? "#FF5722"
                    let darkHex = config.theme?.accentColorDark ?? "#FF7A45"
                    
                    Rectangle()
                        .fill(Color(NSColor(hex: lightHex)))
                        .frame(width: 50, height: 50)
                    
                    Rectangle()
                        .fill(Color(NSColor(hex: darkHex)))
                        .frame(width: 50, height: 50)
                }
            }
            
            HStack {
                Spacer()
                Button("应用主题") {
                    applyThemeConfig()
                }
            }
        }
        .padding()
    }
    
    private func applyThemeConfig() {
        guard config.theme != nil else {
            showConfigWarning()
            return
        }
        
        ThemeManager.shared.switchMode(to: selectedTheme)
        AppConfig.shared.saveThemeConfig(
            mode: selectedTheme,
            animateTransitions: animateTransitions
        )
    }
}


#Preview {
    SettingsView()
}
