//
//  Home.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

struct HomeView: View {
    /// 首页数据
    @State private var recommendedPlaylists: [Song] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题
                Text("推荐歌单")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 横向滚动歌单
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendedPlaylists) { song in
                            PlaylistCard(song: song)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(20)
            .onAppear {
                // 模拟加载数据（实际可通过服务层从网络/本地获取）
                recommendedPlaylists = [
                    Song(title: "歌曲1", artist: "歌手A", album: "专辑X", cover: "cover1"),
                    Song(title: "歌曲2", artist: "歌手B", album: "专辑Y", cover: "cover2")
                ]
            }
        }
    }
}

/// 首页歌单卡片组件
struct PlaylistCard: View {
    let song: Song
    var body: some View {
        VStack(alignment: .leading) {
            // 封面
            Image(song.cover)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
                .cornerRadius(8)
            
            // 歌曲名
            Text(song.title)
                .font(.subheadline)
                .lineLimit(1)
            
            // 歌手
            Text(song.artist)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HomeView()
}
