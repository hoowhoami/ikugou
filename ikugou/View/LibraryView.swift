//
//  LibraryView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

struct LibraryView: View {
    @Environment(UserService.self) private var userService
    @State private var showLoginSheet = false
    
    /// 我的音乐列表（演示数据）
    @State private var myMusic: [Song] = []
    
    var body: some View {
        Group {
            if userService.isLoggedIn {
                // 已登录状态 - 显示音乐库内容
                List {
                    Section("最近播放") {
                        ForEach(myMusic, id: \.id) { song in
                            SongRow(song: song) // 复用 DiscoverView 的行组件
                        }
                    }
                    
                    Section("我的歌单") {
                        Text("自定义歌单1")
                        Text("自定义歌单2")
                    }
                }
                .onAppear {
                    // 模拟加载数据
                    myMusic = [
                        Song(title: "我的音乐1", artist: "歌手X", album: "专辑P", cover: "cover5"),
                        Song(title: "我的音乐2", artist: "歌手Y", album: "专辑Q", cover: "cover6")
                    ]
                }
            } else {
                // 未登录状态 - 显示登录提示
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("访问音乐库需要登录")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("登录后您可以查看收藏的歌曲、创建的播放列表等内容")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        showLoginSheet = true
                    }) {
                        Text("立即登录")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 40)
                            .background(Color.accentColor)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
}

#Preview {
    LibraryView()
}
