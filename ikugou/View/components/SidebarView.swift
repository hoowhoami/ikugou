//
//  SidebarView.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import SwiftUI

// 左侧导航栏
struct SidebarView: View {
    @Binding var selectedItem: NavigationItemType
    @State private var showSettings = false
    @State private var showLoginSheet = false

    @EnvironmentObject private var userService: UserService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部个人中心
            Button(action: {
                if userService.isLoggedIn {
                    selectedItem = .userProfile
                } else {
                    showLoginSheet = true
                }
            }) {
                HStack(spacing: 12) {
                    if let avatar = userService.currentUser?.avatar, !avatar.isEmpty {
                        AsyncImage(url: URL(string: avatar)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                // 图片加载失败时显示默认图标
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.secondary)
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
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        if userService.isLoggedIn {
                            Text(userService.currentUser?.username ?? "用户")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            if userService.isVipUser {
                                Image("vip-open")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                            }
                        } else {
                            Text("点击登录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                    }

                    Spacer()
                }
                .frame(height: 60)
                .padding(.horizontal, 16)
                .contentShape(Rectangle()) // 确保整个区域可点击
            }
            .buttonStyle(.plain)
            .padding(.top, 20)

            // 导航项目
            VStack(alignment: .leading, spacing: 2) {
                SidebarNavigationItem(
                    title: "首页",
                    icon: "house",
                    isSelected: selectedItem == .home,
                    action: { selectedItem = .home }
                )

                SidebarNavigationItem(
                    title: "发现",
                    icon: "safari",
                    isSelected: selectedItem == .discover,
                    action: { selectedItem = .discover }
                )

                SidebarNavigationItem(
                    title: "乐库",
                    icon: "music.note.list",
                    isSelected: selectedItem == .library,
                    action: { selectedItem = .library }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            // 底部设置按钮
            VStack(spacing: 0) {
                // 细致的分割线
                Rectangle()
                    .fill(Color(NSColor.separatorColor).opacity(0.3))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)

                Button(action: {
                    showSettings = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        Text("设置")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 12)
                    .background(Color.clear)
                    .contentShape(Rectangle()) // 确保整个区域可点击
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 8) // 减少底部padding，让设置更接近底部
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
}

// 侧边栏导航项
struct SidebarNavigationItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .primary)
                
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle()) // 确保整个区域可点击
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SidebarView(selectedItem: .constant(.home))
        .frame(width: 200, height: 400)
}
