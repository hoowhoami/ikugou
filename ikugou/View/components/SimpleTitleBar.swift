//
//  SimpleTitleBar.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import SwiftUI

// 标题栏 ViewModel，用于保持状态稳定
class TitleBarViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showUserMenu = false
    @Published var showSettings = false

    // 稳定的 ID，防止组件重新创建
    let stableID = UUID()
}

// 稳定的标题栏组件，不会因为导航状态变化而重新创建
struct StableTitleBarContent: View {
    @Binding var selectedItem: NavigationItemType
    @ObservedObject var viewModel: TitleBarViewModel

    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 左侧：前进后退按钮
            HStack(spacing: 8) {
                // 后退按钮
                Button(action: {
                    // 后退逻辑
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                // 前进按钮
                Button(action: {
                    // 前进逻辑
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                // 刷新按钮
                Button(action: {
                    // 刷新逻辑
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .frame(width: 200) // 固定左侧区域宽度

            // 中间：导航标签（居中）
            HStack {
                Spacer()

                HStack(spacing: 2) {
                    StableNavigationTab(
                        title: "首页",
                        isSelected: selectedItem == .home,
                        action: { selectedItem = .home }
                    )

                    StableNavigationTab(
                        title: "发现",
                        isSelected: selectedItem == .discover,
                        action: { selectedItem = .discover }
                    )

                    StableNavigationTab(
                        title: "音乐库",
                        isSelected: selectedItem == .library,
                        action: { selectedItem = .library }
                    )
                }

                Spacer()
            }

            // 右侧：搜索框和用户头像
            HStack(spacing: 16) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))

                    TextField("搜索音乐、歌手、歌单、分享码", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                }
                .frame(height: 20)
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(width: 280)

                // 用户头像
                Button(action: {
                    viewModel.showUserMenu.toggle()
                }) {
                    if let avatar = appSettings.userInfo?.avatar, !avatar.isEmpty {
                        AsyncImage(url: URL(string: avatar)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(let error):
                                // 图片加载失败时显示默认图标
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.secondary)
                                    .onAppear {
                                        print("SimpleTitleBar - 头像加载失败: \(error.localizedDescription)")
                                    }
                            case .empty:
                                // 加载中显示占位符
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.secondary)
                                    .opacity(0.5)
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .onAppear {
                            print("SimpleTitleBar - 尝试加载头像: \(avatar)")
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .onAppear {
                                print("SimpleTitleBar - 头像为空或nil，显示默认图标. Avatar: \(appSettings.userInfo?.avatar ?? "nil")")
                            }
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $viewModel.showUserMenu, arrowEdge: .bottom) {
                    UserMenuPopover(showSettings: $viewModel.showSettings)
                }
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .frame(width: 340) // 固定右侧区域宽度
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .id(viewModel.stableID) // 使用 ViewModel 的稳定 ID
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
        .onAppear {
            print("StableTitleBarContent appeared with ID: \(viewModel.stableID)")
        }
    }
}

// 稳定的导航标签组件
struct StableNavigationTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .accentColor : .primary)
                .frame(height: 20)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// 简化的标题栏组件：只有搜索框
struct SimplifiedTitleBarContent: View {
    @ObservedObject var viewModel: TitleBarViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                // 中间：搜索框 - 居中显示
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                        .frame(width: 13, height: 13)

                    TextField("搜索音乐、歌手、歌单、分享码", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                }
                .frame(width: 360, height: 28) // 固定宽度和高度，防止焦点变化时位移
                .padding(.horizontal, 14)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 32) // 确保左右有足够边距
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 50) // 固定标题栏高度
        .padding(.vertical, 8) // 添加垂直内边距
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// 导航标签组件
struct NavigationTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(height: 24)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .accentColor : .primary)
                .frame(height: 24)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// 用户菜单弹窗
struct UserMenuPopover: View {
    @Binding var showSettings: Bool
    @Environment(AppSettings.self) private var appSettings
    @State private var showLoginSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if appSettings.isLoggedIn {
                // 已登录状态
                VStack(alignment: .leading, spacing: 4) {
                    Text(appSettings.userInfo?.username ?? "用户")
                        .font(.headline)
                        .fontWeight(.medium)

                    Text("ID: \(appSettings.userInfo?.userid ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)

                Divider()

                // 登出按钮
                Button(action: {
                    appSettings.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("登出")
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
                // 未登录状态
                Button(action: {
                    showLoginSheet = true
                }) {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("登录")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(width: 160)
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
}
