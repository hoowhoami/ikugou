//
//  DiscoverView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

struct DiscoverView: View {
    /// 模拟热门歌曲数据
    @State private var hotSongs: [Song] = []
    
    var body: some View {
        List(hotSongs, id: \.id) { song in
            SongRow(song: song)
        }
        .navigationTitle("发现")
        .onAppear {
            // 模拟加载热门歌曲
            hotSongs = [
                Song(title: "热门歌曲1", artist: "歌手C", album: "专辑M", cover: "cover3"),
                Song(title: "热门歌曲2", artist: "歌手D", album: "专辑N", cover: "cover4")
            ]
        }
    }
    
    /// 歌曲列表行组件
    struct SongRow: View {
        let song: Song
        var body: some View {
            HStack {
                Image(song.cover)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.subheadline)
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 播放按钮（演示）
                Button(action: {}) {
                    Image(systemName: "play.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
}
