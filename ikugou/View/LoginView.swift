//
//  LoginView.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            VStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("登录 ikugou")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("登录以同步您的音乐和播放列表")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // 登录表单
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户名")
                        .font(.headline)
                    
                    TextField("请输入用户名", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 36)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("密码")
                        .font(.headline)
                    
                    SecureField("请输入密码", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 36)
                }
                
                // 登录按钮
                Button(action: performLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        Text(isLoading ? "登录中..." : "登录")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(username.isEmpty || password.isEmpty || isLoading)
                .buttonStyle(.plain)
            }
            .frame(width: 300)
            
            // 其他选项
            VStack(spacing: 12) {
                Divider()
                
                HStack {
                    Text("还没有账号？")
                        .foregroundColor(.secondary)
                    
                    Button("注册") {
                        // 注册逻辑
                    }
                    .foregroundColor(.accentColor)
                }
                .font(.body)
                
                Button("游客模式") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                .font(.body)
            }
            
            Spacer()
        }
        .padding(32)
        .frame(width: 400, height: 500)
        .alert("登录失败", isPresented: $showError) {
            Button("确定") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performLogin() {
        guard !username.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        // 模拟登录请求
        Task {
            do {
                // 这里应该调用实际的登录API
                try await Task.sleep(nanoseconds: 1_000_000_000) // 模拟网络延迟
                
                await MainActor.run {
                    // 模拟成功登录
                    let userid = "user_\(Int.random(in: 1000...9999))"
                    let token = "token_\(UUID().uuidString)"
                    
                    appSettings.login(
                        userid: userid,
                        token: token,
                        username: username,
                        avatar: nil
                    )
                    
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "登录失败，请检查用户名和密码"
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AppSettings.shared)
}
