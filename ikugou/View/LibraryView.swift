//
//  LibraryView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

struct LibraryView: View {
    /// 我的音乐列表（演示数据）
    @State private var myMusic: [Song] = []
    
    var body: some View {
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
    }
}

#Preview {
    LibraryView()
}
