//
//  ContentView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import SwiftUI
import AppKit

// 主应用视图
struct MainView: View {
    @State private var selectedSection: NavigationSection = .home
    @State private var isPlaying: Bool = false
    @State private var currentProgress: Double = 35
    
    let playlists = [
        Playlist(id: 1, name: "今日推荐", image: "playlist1"),
        Playlist(id: 2, name: "工作专注", image: "playlist2"),
        Playlist(id: 3, name: "经典摇滚", image: "playlist3"),
        Playlist(id: 4, name: "放松氛围", image: "playlist4")
    ]
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // 侧边栏
                SidebarView(
                    selectedSection: $selectedSection,
                    sections: NavigationSection.allCases
                )
                .frame(width: 220)
                .background(Color.spotifySidebar)
                .overlay(
                    VStack {}.frame(width: 1).background(Color.spotifyDivider),
                    alignment: .trailing
                )
                
                // 主内容区域
                VStack(spacing: 0) {
                    // 顶部拖拽区域（修复拖拽事件问题）
                    Rectangle()
                        .fill(Color.spotifyBackground)
                        .frame(height: 32)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // 获取当前事件并传递给拖拽方法
                                    if let event = NSApp.currentEvent {
                                        NSApp.mainWindow?.performDrag(with: event)
                                    }
                                }
                        )
                    
                    // 内容滚动区域
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            switch selectedSection {
                            case .home:
                                HomeView(playlists: playlists)
                            case .search:
                                SearchView()
                            case .library:
                                LibraryView()
                            case .liked:
                                LikedSongsView()
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.spotifyBackground)
                .foregroundColor(.white)
            }
            
            // 底部播放控制栏
            VStack {
                Spacer()
                PlaybackControlView(
                    isPlaying: $isPlaying,
                    progress: $currentProgress
                )
                .background(Color.spotifyPlayback)
                .frame(height: 90)
                .shadow(radius: 10)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// 侧边栏视图
struct SidebarView: View {
    @Binding var selectedSection: NavigationSection
    let sections: [NavigationSection]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 品牌标识
            VStack(spacing: 0) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.spotifyGreen)
                    .padding(.horizontal, 20)
                    .padding(.top, 32) // 适配无标题栏的顶部间距
                    .padding(.bottom, 16)
            }
            
            // 导航选项
            VStack(alignment: .leading, spacing: 2) {
                ForEach(sections) { section in
                    Button(action: { selectedSection = section }) {
                        HStack(spacing: 16) {
                            Image(systemName: section.icon)
                                .frame(width: 20)
                            Text(section.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundColor(selectedSection == section ? .spotifyGreen : .spotifyTextSecondary)
                    .background(selectedSection == section ? Color.spotifyGreen.opacity(0.2) : .clear)
                    .overlay(
                        Group {
                            if selectedSection == section {
                                VStack {}.frame(width: 3).background(Color.spotifyGreen)
                            }
                        },
                        alignment: .leading
                    )
                }
            }
            
            Spacer()
            
            // 用户区域
            VStack(alignment: .leading, spacing: 8) {
                Divider()
                    .background(Color.spotifyDivider)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("用户名")
                            .font(.system(size: 13, weight: .semibold))
                        Text("高级账户")
                            .font(.system(size: 11))
                            .foregroundColor(.spotifyTextSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }
}

// 首页视图
struct HomeView: View {
    let playlists: [Playlist]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("推荐内容")
                .font(.system(size: 28, weight: .bold))
            
            VStack(alignment: .leading, spacing: 16) {
                Text("为你推荐的播放列表")
                    .font(.system(size: 20, weight: .bold))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(playlists) { playlist in
                            PlaylistCard(playlist: playlist)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// 播放列表卡片
struct PlaylistCard: View {
    let playlist: Playlist
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.spotifyCard)
                
                Image(playlist.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(4)
                    .shadow(radius: isHovered ? 8 : 2)
                
                if isHovered {
                    Circle()
                        .fill(Color.spotifyGreen)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(.black)
                                .offset(x: 1)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 160, height: 160)
            .onHover { isHovered = $0 }
            
            Text(playlist.name)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            
            Text("多种艺术家")
                .font(.system(size: 12))
                .foregroundColor(.spotifyTextSecondary)
                .lineLimit(1)
        }
        .frame(width: 160)
    }
}

// 底部播放控制栏
struct PlaybackControlView: View {
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    
    var body: some View {
        VStack(spacing: 0) {
            Slider(value: $progress, in: 0...100)
                .accentColor(.spotifyTextSecondary)
                .padding(.horizontal)
                .frame(height: 4)
            
            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image("nowplaying")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("当前播放的歌曲")
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)
                        Text("艺术家名称")
                            .font(.system(size: 11))
                            .foregroundColor(.spotifyTextSecondary)
                            .lineLimit(1)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.spotifyTextSecondary)
                    }
                }
                .frame(width: 300)
                
                VStack {
                    HStack(spacing: 24) {
                        Button(action: {}) {
                            Image(systemName: "shuffle")
                                .foregroundColor(.spotifyTextSecondary)
                                .font(.system(size: 16))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "backward.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        Button(action: { isPlaying.toggle() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16))
                                    .offset(x: isPlaying ? 0 : 1)
                            }
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "repeat")
                                .foregroundColor(.spotifyTextSecondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.spotifyTextSecondary)
                            .font(.system(size: 14))
                    }
                    
                    Slider(value: .constant(70), in: 0...100)
                        .accentColor(.spotifyTextSecondary)
                        .frame(width: 100)
                }
                .frame(width: 160)
            }
            .padding(.horizontal)
        }
    }
}

// 其他视图和模型
struct Playlist: Identifiable {
    let id: Int
    let name: String
    let image: String
}

struct SearchView: View {
    var body: some View {
        Text("搜索界面")
            .foregroundColor(.spotifyTextSecondary)
    }
}

struct LibraryView: View {
    var body: some View {
        Text("你的媒体库")
            .foregroundColor(.spotifyTextSecondary)
    }
}

struct LikedSongsView: View {
    var body: some View {
        Text("喜欢的音乐")
            .foregroundColor(.spotifyTextSecondary)
    }
}

// 预览
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .frame(width: 1200, height: 800)
    }
}



