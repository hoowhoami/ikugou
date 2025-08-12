//
//  MainView.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

// 主视图
struct MainView: View {
    /// 当前选中的导航项
    @State private var selectedItem: NavigationItemType = .home
    
    /// 控制侧边栏可见性的状态变量
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    @EnvironmentObject private var appSettings: AppSetting
    @EnvironmentObject private var userService: UserService

    var body: some View {
        // 1. 主体左右分栏布局（系统原生SplitView）
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // 左侧边栏
            SidebarView(selectedItem: $selectedItem)
                .frame(minWidth: 180)
                .navigationTitle("") // 不设置标题
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
                .onChange(of: selectedItem) { newItem in
                    addToNavigationHistory(newItem)
                }
                .toolbar {
                    // 左侧工具按钮
                    ToolbarItem(placement: .navigation) {
                        
                        HStack(spacing: 8) {
                            Button(action: { navigateBack() }) {
                                Image(systemName: "chevron.left")
                            }
                            .help("后退")
                            .disabled(!canNavigateBack)
                            
                            Button(action: { navigateForward() }) {
                                Image(systemName: "chevron.right")
                            }
                            .help("前进")
                            .disabled(!canNavigateForward)
                        }
                    }
                }
                
        } detail: {
            // 右侧主内容
            ContentView(selectedItem: selectedItem)
                .navigationTitle("")
                .toolbar {
                    
                    // 中间搜索框
                    ToolbarItem(placement: .automatic) {
                        TextField("搜索音乐、歌手、歌单", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                            .onSubmit {
                                performSearch()
                            }
                    }
                }
            
            PlayerView()
                .frame(height: 80)
                .background(Color(NSColor.windowBackgroundColor))
                .border(Color(NSColor.separatorColor), width: 1)
            
        }
        .frame(minWidth: 1000, minHeight: 680)
        .preferredColorScheme(appSettings.appearanceMode.colorScheme)
        .onAppear {
            // 初始化导航历史
            if navigationHistory.isEmpty {
                navigationHistory = [selectedItem]
                currentHistoryIndex = 0
            }
        }
        
    }

    
    // MARK: - State
    @State private var searchText = ""
    
    /// 导航历史栈
    @State private var navigationHistory: [NavigationItemType] = []
    /// 当前历史索引
    @State private var currentHistoryIndex = -1
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        print("搜索: \(searchText)")
        searchText = ""
    }
    
    // MARK: - Actions
    private func navigateBack() {
        guard currentHistoryIndex > 0 else { return }
        
        currentHistoryIndex -= 1
        selectedItem = navigationHistory[currentHistoryIndex]
    }

    private func navigateForward() {
        guard currentHistoryIndex < navigationHistory.count - 1 else { return }
        
        currentHistoryIndex += 1
        selectedItem = navigationHistory[currentHistoryIndex]
    }
    
    /// 添加导航历史
    private func addToNavigationHistory(_ item: NavigationItemType) {
        // 如果不是当前项，则添加到历史
        if item != selectedItem {
            // 移除当前索引之后的历史（前进历史）
            if currentHistoryIndex >= 0 {
                navigationHistory = Array(navigationHistory.prefix(currentHistoryIndex + 1))
            } else {
                navigationHistory = []
            }
            // 添加新的导航项
            navigationHistory.append(item)
            currentHistoryIndex = navigationHistory.count - 1
        }
    }
    
    /// 是否可以后退
    private var canNavigateBack: Bool {
        let canBack = currentHistoryIndex > 0
        return canBack
    }
    
    /// 是否可以前进
    private var canNavigateForward: Bool {
        let canForward = currentHistoryIndex < navigationHistory.count - 1 && currentHistoryIndex >= 0
        return canForward
    }
    
}


// MARK: - NavigationItemType Extension
extension NavigationItemType {
    var title: String {
        switch self {
        case .home:
            return "首页"
        case .discover:
            return "发现"
        case .library:
            return "乐库"
        case .userProfile:
            return "用户详情"
        }
    }
}
