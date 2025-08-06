//
//  ListenHistoryView.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/6.
//

import SwiftUI

/// 听歌历史内容视图（用于乐库页面）
struct ListenHistoryContentView: View {
    @State private var libraryService = LibraryService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if libraryService.isLoadingListenHistory {
                LoadingView(message: "正在加载听歌历史...")
            } else if let errorMessage = libraryService.listenHistoryError {
                ErrorView(
                    message: errorMessage,
                    retryAction: {
                        Task {
                            await libraryService.getListenHistory()
                        }
                    }
                )
            } else if libraryService.listenHistory.isEmpty {
                EmptyStateView(
                    icon: "music.note.list",
                    title: "暂无听歌历史",
                    subtitle: "开始播放音乐后，这里将显示您的听歌记录"
                )
            } else {
                // 听歌历史网格布局
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 6),
                    spacing: 20
                ) {
                    ForEach(libraryService.listenHistory) { item in
                        ListenHistoryCardView(item: item)
                    }
                }
            }
        }
        .task {
            if libraryService.listenHistory.isEmpty {
                await libraryService.getListenHistory()
            }
        }
    }
}

/// 听歌历史卡片视图
struct ListenHistoryCardView: View {
    let item: ListenHistoryItem
    @State private var libraryService = LibraryService.shared
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 专辑封面
            AsyncImage(url: URL(string: libraryService.getAlbumCoverURL(from: item) ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
            }
            .frame(width: 120, height: 120)
            .clipped()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            .overlay(alignment: .bottomTrailing) {
                if isHovered {
                    Button(action: {
                        // 播放按钮逻辑
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .frame(width: 28, height: 28)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // 歌曲信息
            VStack(alignment: .leading, spacing: 2) {
                let songInfo = libraryService.getFormattedSongInfo(from: item)
                
                Text(songInfo.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(songInfo.artist)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let duration = item.duration, duration > 0 {
                    Text(libraryService.formatDuration(from: item))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            // 点击播放逻辑
        }
        .contextMenu {
            Button("播放") {
                // 播放逻辑
            }
            Button("添加到播放队列") {
                // 添加到队列逻辑
            }
            Divider()
            Button("查看专辑") {
                // 查看专辑逻辑
            }
            Button("查看歌手") {
                // 查看歌手逻辑
            }
        }
    }
}

/// 最近播放内容视图
struct RecentlyPlayedContentView: View {
    var body: some View {
        EmptyStateView(
            icon: "clock",
            title: "最近播放",
            subtitle: "这里将显示您最近播放的音乐"
        )
    }
}

/// 我的歌单内容视图
struct MyPlaylistsContentView: View {
    var body: some View {
        EmptyStateView(
            icon: "music.note",
            title: "我的歌单",
            subtitle: "这里将显示您创建和收藏的歌单"
        )
    }
}

/// 关注的歌手内容视图
struct FollowedArtistsContentView: View {
    var body: some View {
        EmptyStateView(
            icon: "person.2",
            title: "关注的歌手",
            subtitle: "这里将显示您关注的歌手"
        )
    }
}

/// 喜欢的音乐内容视图
struct LikedSongsContentView: View {
    var body: some View {
        EmptyStateView(
            icon: "heart",
            title: "喜欢的音乐",
            subtitle: "这里将显示您喜欢的音乐"
        )
    }
}

/// 加载状态视图
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
    }
}

/// 错误状态视图
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("加载失败")
                .font(.system(size: 18, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("重试") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
        .padding()
    }
}

/// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
        .padding()
    }
}

#Preview {
    ListenHistoryContentView()
        .frame(width: 800, height: 600)
}