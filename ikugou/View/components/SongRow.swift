//
//  SongRow.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

struct SongRow: View {
    let song: Song
    
    var body: some View {
        HStack {
            Image(song.cover ?? "")
                .resizable()
                .frame(width: 44, height: 44)
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(song.title ?? "")
                        .font(.subheadline)
                    
                    // 音质标识
                    if song.isVip == true {
                        Text("VIP")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(3)
                    }
                    
                    if song.isSq == true {
                        Text("SQ")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(3)
                    } else if song.isHq == true {
                        Text("HQ")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(3)
                    }
                }
                
                Text(song.artist ?? "")
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
    VStack(spacing: 8) {
        SongRow(song: Song(
            title: "普通歌曲",
            artist: "普通歌手",
            album: "普通专辑",
            cover: "cover1"
        ))
        
        SongRow(song: Song(
            title: "VIP歌曲",
            artist: "VIP歌手",
            album: "VIP专辑",
            cover: "cover1",
            isVip: true
        ))
        
        SongRow(song: Song(
            title: "HQ高音质歌曲",
            artist: "HQ歌手",
            album: "HQ专辑",
            cover: "cover1",
            isHq: true
        ))
        
        SongRow(song: Song(
            title: "SQ超品音质歌曲",
            artist: "SQ歌手",
            album: "SQ专辑",
            cover: "cover1",
            isSq: true
        ))
        
        SongRow(song: Song(
            title: "VIP+SQ全功能歌曲",
            artist: "全功能歌手",
            album: "全功能专辑",
            cover: "cover1",
            isVip: true,
            isSq: true
        ))
    }
    .padding()
}
