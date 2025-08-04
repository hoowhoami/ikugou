//
//  SongRow.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

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
            
            Button(action: {
                // 播放按钮逻辑（可后续通过环境对象绑定播放管理器）
            }) {
                Image(systemName: "play.circle")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    SongRow(song: Song(
        title: "预览歌曲",
        artist: "预览歌手",
        album: "预览专辑",
        cover: "cover1"
    ))
}
