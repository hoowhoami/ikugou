//
//  UserProfileView.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/5.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(UserService.self) private var userService
    @State private var showLogoutConfirmation = false
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标题
                HStack {
                    Text("用户详情")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // 刷新按钮
                    if userService.isLoggedIn {
                        Button(action: refreshUserInfo) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("刷新")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .disabled(isRefreshing)
                    }
                }
                .padding(.bottom, 8)
                
                if let userInfo = userService.currentUser {
                    // 用户头像和基本信息
                    HStack(spacing: 20) {
                        // 头像
                        if let avatar = userInfo.avatar, !avatar.isEmpty {
                            AsyncImage(url: URL(string: avatar)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.secondary)
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.secondary)
                        }
                        
                        // 基本信息
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userInfo.nickname.isEmpty ? userInfo.username : userInfo.nickname)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("用户名: \(userInfo.username)")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text("用户ID: \(userInfo.userid)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    
                    // 详细信息卡片
                    VStack(alignment: .leading, spacing: 16) {
                        Text("详细信息")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // 注册时间
                            if let regTime = userInfo.reg_time {
                                InfoCard(title: "注册时间", value: formatDate(regTime))
                            }
                            
                            // 服务器时间
                            if let serverTime = userInfo.servertime {
                                InfoCard(title: "最后登录", value: formatDate(serverTime))
                            }
                            
                            // VIP状态
                            if let isVip = userInfo.is_vip {
                                InfoCard(title: "VIP状态", value: isVip > 0 ? "是" : "否")
                            }
                            
                            // 用户类型
                            if let userType = userInfo.user_type {
                                InfoCard(title: "用户类型", value: "\(userType)")
                            }
                            
                            // 积分
                            if let score = userInfo.score {
                                InfoCard(title: "积分", value: "\(score)")
                            }
                            
                            // 经验值
                            if let exp = userInfo.exp {
                                InfoCard(title: "经验值", value: "\(exp)")
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    
                    // 操作按钮
                    VStack(spacing: 12) {
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("注销登录")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    
                } else {
                    // 未登录状态
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("未登录")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("请先登录以查看用户详情")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
                
                Spacer()
            }
            .padding(32)
        }
        .alert("确认注销", isPresented: $showLogoutConfirmation) {
            Button("取消", role: .cancel) { }
            Button("注销", role: .destructive) {
                userService.logout()
            }
        } message: {
            Text("确定要注销登录吗？")
        }
    }
    
    // 刷新用户信息
    private func refreshUserInfo() {
        guard !isRefreshing else { return }
        
        Task {
            isRefreshing = true
            defer { isRefreshing = false }
            
            do {
                try await UserService.shared.refreshUserInfo()
            } catch {
                print("刷新用户信息失败: \(error)")
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // 简单的日期格式化，可以根据需要调整
        return dateString
    }
}

// 信息卡片组件
struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
        )
    }
}

#Preview {
    UserProfileView()
        .environment(UserService.shared)
}
