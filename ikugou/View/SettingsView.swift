//
//  SettingsView.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    
    @State private var selectedTab: SettingsTab = .appearance
    @State private var tempApiURL: String = ""
    
    var body: some View {
        NavigationSplitView {
            // 左侧设置分类
            List(SettingsTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200)
            .listStyle(.sidebar)
        } detail: {
            // 右侧设置内容
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedTab {
                    case .appearance:
                        AppearanceSettingsView()
                    case .api:
                        APISettingsView(tempApiURL: $tempApiURL)
                    case .about:
                        AboutSettingsView()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(selectedTab.title)
        }
        .frame(width: 600, height: 500)
        .onAppear {
            tempApiURL = appSettings.apiBaseURL
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") {
                    dismiss()
                }
            }
        }
    }
}

// 设置分类枚举
enum SettingsTab: String, CaseIterable {
    case appearance = "appearance"
    case api = "api"
    case about = "about"
    
    var title: String {
        switch self {
        case .appearance: return "外观"
        case .api: return "接口设置"
        case .about: return "关于"
        }
    }
    
    var icon: String {
        switch self {
        case .appearance: return "paintbrush"
        case .api: return "network"
        case .about: return "info.circle"
        }
    }
}

// 外观设置视图
struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("外观设置")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("主题模式")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        HStack {
                            Button(action: {
                                appSettings.appearanceMode = mode
                            }) {
                                HStack {
                                    Image(systemName: appSettings.appearanceMode == mode ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(appSettings.appearanceMode == mode ? .accentColor : .secondary)
                                    
                                    Text(mode.displayName)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.leading, 8)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("预览")
                    .font(.headline)
                
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary)
                        .frame(width: 60, height: 40)
                        .overlay(
                            Text("Aa")
                                .foregroundColor(Color(NSColor.windowBackgroundColor))
                                .font(.caption)
                        )
                    
                    Text("当前主题预览")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

// API设置视图
struct APISettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @Binding var tempApiURL: String
    @State private var showResetAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("接口设置")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("API 基础地址")
                    .font(.headline)
                
                TextField("请输入API地址", text: $tempApiURL)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
                
                HStack {
                    Button("保存") {
                        appSettings.apiBaseURL = tempApiURL
                    }
                    .disabled(tempApiURL == appSettings.apiBaseURL)
                    
                    Button("重置为默认") {
                        showResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Text("当前使用: \(appSettings.apiBaseURL)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("连接状态")
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("已连接")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .alert("重置设置", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                appSettings.resetSettings()
                tempApiURL = appSettings.apiBaseURL
            }
        } message: {
            Text("确定要重置所有设置为默认值吗？")
        }
    }
}

// 关于设置视图
struct AboutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("关于")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text("ikugou")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("一个现代化的音乐播放器应用")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("技术信息")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    InfoRow(label: "框架", value: "SwiftUI")
                    InfoRow(label: "平台", value: "macOS 14.0+")
                    InfoRow(label: "架构", value: "Apple Silicon & Intel")
                }
            }
            
            Spacer()
        }
    }
}

// 信息行组件
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .font(.caption)
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings.shared)
}
