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
    @State private var showUserMenu = false
    @State private var showSettings = false
    @State private var showLoginSheet = false

    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部个人中心
            HStack(spacing: 12) {
                Button(action: {
                    if appSettings.isLoggedIn {
                        showUserMenu.toggle()
                    } else {
                        showLoginSheet = true
                    }
                }) {
                    if let avatar = appSettings.userInfo?.avatar, !avatar.isEmpty {
                        AsyncImage(url: URL(string: avatar)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showUserMenu, arrowEdge: .trailing) {
                    UserInfoPopover()
                }
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    if appSettings.isLoggedIn {
                        Text(appSettings.userInfo?.username ?? "用户")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)

                        Text("已登录")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        Button(action: {
                            showLoginSheet = true
                        }) {
                            Text("点击登录")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.accentColor)
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

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)

            // 导航项目
            VStack(alignment: .leading, spacing: 8) {
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
                    title: "音乐库",
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
                Divider()

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
                    .frame(height: 80)
                    .padding(.horizontal, 12)
                    .background(Color.clear)
                    .contentShape(Rectangle()) // 确保整个区域可点击
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .padding(.horizontal, 16)
                //.padding(.bottom, 20)
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
            .frame(height: 32)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
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

// 用户信息弹窗
struct UserInfoPopover: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户基本信息
            VStack(alignment: .leading, spacing: 4) {
                Text(appSettings.userInfo?.username ?? "用户")
                    .font(.headline)
                    .fontWeight(.medium)

                Text("ID: \(appSettings.userInfo?.userid ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

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
        }
        .padding(12)
        .frame(width: 160)
    }
}

#Preview {
    SidebarView(selectedItem: .constant(.home))
        .frame(width: 200, height: 400)
}
