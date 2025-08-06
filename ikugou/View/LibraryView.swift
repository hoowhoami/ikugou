//
//  LibraryView.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

struct LibraryView: View {
    @Environment(UserService.self) private var userService
    @State private var showLoginSheet = false
    @State private var selectedSection: LibrarySection = .myCreatedPlaylists
    
    // 内部导航状态管理
    @State private var currentPlaylist: UserPlaylistResponse.UserPlaylist?
    @State private var showingPlaylistDetail = false
    
    var body: some View {
        Group {
            if userService.isLoggedIn {
                if showingPlaylistDetail, let playlist = currentPlaylist {
                    // 显示歌单详情页
                    PlaylistDetailView(
                        playlist: playlist,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingPlaylistDetail = false
                                currentPlaylist = nil
                            }
                        }
                    )
                } else {
                    // 显示音乐库主页
                    VStack(spacing: 0) {
                        // 自定义标签栏
                        HStack(spacing: 0) {
                            ForEach(LibrarySection.allCases, id: \.self) { section in
                                Button(action: {
                                    selectedSection = section
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: section.icon)
                                            .font(.system(size: 14))
                                        Text(section.rawValue)
                                            .font(.system(size: 13))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .foregroundColor(selectedSection == section ? .accentColor : .secondary)
                                    .background(
                                        selectedSection == section ? 
                                        Color.accentColor.opacity(0.1) : Color.clear
                                    )
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        
                        // 内容区域
                        LibraryContentView(
                            section: selectedSection,
                            onPlaylistTapped: { playlist in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    currentPlaylist = playlist
                                    showingPlaylistDetail = true
                                }
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
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

/// 乐库分类枚举
enum LibrarySection: String, CaseIterable {
    case myCreatedPlaylists = "我创建的歌单"
    case myCollectedPlaylists = "我收藏的歌单"
    case myCollectedAlbums = "我收藏的专辑"
    case myFollowedArtists = "我关注的歌手"
    case myFollowedFriends = "我关注的好友"
    case myListenedSongs = "我听过的歌曲"
    
    var icon: String {
        switch self {
        case .myCreatedPlaylists:
            return "music.note"
        case .myCollectedPlaylists:
            return "heart.text.square"
        case .myCollectedAlbums:
            return "opticaldisc"
        case .myFollowedArtists:
            return "mic"
        case .myFollowedFriends:
            return "person.2"
        case .myListenedSongs:
            return "clock"
        }
    }
}

/// 乐库内容视图
struct LibraryContentView: View {
    let section: LibrarySection
    let onPlaylistTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)?
    @State private var libraryService = LibraryService.shared
    
    init(section: LibrarySection, onPlaylistTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)? = nil) {
        self.section = section
        self.onPlaylistTapped = onPlaylistTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 内容标题栏
            HStack {
                Text(section.rawValue)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 刷新按钮
                Button(action: {
                    Task {
                        await refreshContent()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("刷新")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(nsColor: .windowBackgroundColor))
            .overlay(alignment: .bottom) {
                Divider()
            }
            
            // 内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch section {
                    case .myListenedSongs:
                        ListenHistoryContentView()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    case .myCreatedPlaylists:
                        MyCreatedPlaylistsContentView(onPlaylistTapped: onPlaylistTapped)
                            .padding(.horizontal, 0)
                            .padding(.top, 20)
                    case .myCollectedPlaylists:
                        MyCollectedPlaylistsContentView()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    case .myCollectedAlbums:
                        MyCollectedAlbumsContentView()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    case .myFollowedArtists:
                        MyFollowedArtistsContentView()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    case .myFollowedFriends:
                        MyFollowedFriendsContentView()
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }
                }
            }
        }
        .background(Color.clear)
        .onAppear {
            Task {
                await loadContent()
            }
        }
    }
    
    private func refreshContent() async {
        await loadContent()
    }
    
    private func loadContent() async {
        switch section {
        case .myListenedSongs:
            await libraryService.getListenHistory()
        case .myCreatedPlaylists, .myCollectedPlaylists:
            await libraryService.getMyPlaylists()
        case .myFollowedArtists, .myFollowedFriends:
            await libraryService.getFollowData()
        case .myCollectedAlbums:
            // TODO: 实现获取收藏专辑的逻辑
            break
        }
    }
}

#Preview {
    LibraryView()
}

// MARK: - 临时占位符视图组件

struct MyCreatedPlaylistsContentView: View {
    @State private var libraryService = LibraryService.shared
    let onPlaylistTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)?
    
    init(onPlaylistTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)? = nil) {
        self.onPlaylistTapped = onPlaylistTapped
    }
    
    // 将歌单分组，每行4个
    private var chunkedPlaylists: [[UserPlaylistResponse.UserPlaylist]] {
        let itemsPerRow = 4
        return libraryService.myPlaylists.chunked(into: itemsPerRow)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if libraryService.isLoadingMyPlaylists {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("加载中...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = libraryService.myPlaylistsError {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("加载失败")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("重试") {
                        Task {
                            await libraryService.getMyPlaylists()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if libraryService.myPlaylists.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无歌单")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("创建您的第一个歌单")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 创建分组的歌单行
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(chunkedPlaylists, id: \.first?.listid) { playlistChunk in
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(playlistChunk, id: \.listid) { playlist in
                                PlaylistCardView(playlist: playlist, onTapped: onPlaylistTapped)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            Task {
                await libraryService.getMyPlaylists()
            }
        }
    }
}

struct PlaylistCardView: View {
    let playlist: UserPlaylistResponse.UserPlaylist
    let onTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)?
    
    init(playlist: UserPlaylistResponse.UserPlaylist, onTapped: ((UserPlaylistResponse.UserPlaylist) -> Void)? = nil) {
        self.playlist = playlist
        self.onTapped = onTapped
    }
    
    var body: some View {
        Button(action: {
            onTapped?(playlist)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // 歌单封面
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        )
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 歌单信息
                VStack(alignment: .leading, spacing: 3) {
                    Text(playlist.name ?? "未知歌单")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text("\(playlist.count ?? 0) 首歌曲")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(width: 100, alignment: .leading)
            }
            .frame(width: 116)
            .padding(4)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private var imageURL: URL? {
        guard let pic = playlist.pic, !pic.isEmpty else { 
            // 尝试使用create_user_pic作为备用
            guard let userPic = playlist.create_user_pic, !userPic.isEmpty else { return nil }
            return ImageURLHelper.processImageURL(userPic, size: .small)
        }
        return ImageURLHelper.processImageURL(pic, size: .small)
    }
}

struct MyCollectedPlaylistsContentView: View {
    var body: some View {
        Text("我收藏的歌单")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

struct MyCollectedAlbumsContentView: View {
    var body: some View {
        Text("我收藏的专辑")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

struct MyFollowedArtistsContentView: View {
    var body: some View {
        Text("我关注的歌手")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

struct MyFollowedFriendsContentView: View {
    var body: some View {
        Text("我关注的好友")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

// MARK: - Array 扩展

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - 歌单详情页

struct PlaylistDetailView: View {
    let playlist: UserPlaylistResponse.UserPlaylist
    let onBack: () -> Void
    @State private var libraryService = LibraryService.shared
    @State private var playlistDetail: PlaylistDetailInfo?
    @State private var tracks: [PlaylistTrackInfo] = []
    @State private var isLoadingDetail = false
    @State private var isLoadingTracks = false
    @State private var errorMessage: String?
    @State private var isSelectionMode = false
    @State private var selectedTracks: Set<UUID> = []
    @Environment(PlayerService.self) private var playerService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 返回按钮和标题栏
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("返回")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(playlist.name ?? "歌单")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 占位符，保持标题居中
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("返回")
                        .font(.system(size: 16))
                }
                .foregroundColor(.clear)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(alignment: .bottom) {
                Divider()
            }
            
            if let detail = playlistDetail {
                // 歌单头部信息
                playlistHeader(detail: detail)
                
                Divider()
                
                // 歌曲列表
                playlistTracksSection
            } else if isLoadingDetail {
                // 加载状态
                VStack {
                    ProgressView()
                    Text("加载中...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                // 错误状态
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("加载失败")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("重试") {
                        Task { await loadPlaylistData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            Task { await loadPlaylistData() }
        }
    }
    
    @ViewBuilder
    private func playlistHeader(detail: PlaylistDetailInfo) -> some View {
        HStack(alignment: .top, spacing: 20) {
            // 歌单封面
            AsyncImage(url: imageURL(from: detail.pic)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                            .font(.system(size: 40))
                    )
            }
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 歌单信息
            VStack(alignment: .leading, spacing: 8) {
                Text(detail.name ?? "未知歌单")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let intro = detail.intro, !intro.isEmpty {
                    Text(intro)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(detail.count ?? 0) 首歌曲")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let creator = detail.creator {
                            Text("创建者：\(creator)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let createTime = detail.create_time {
                            Text("创建时间：\(formatTimestamp(createTime))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let updateTime = detail.update_time {
                            Text("更新时间：\(formatTimestamp(updateTime))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: {
                        let songs = tracks.map { Song(from: $0) }
                        playerService.playAllSongs(songs)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("播放")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(.all, 20)
    }
    
    @ViewBuilder
    private var playlistTracksSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 歌曲列表头部
            HStack {
                if isSelectionMode {
                    HStack(spacing: 16) {
                        Button(selectedTracks.count == tracks.count ? "全选" : "取消") {
                            if selectedTracks.count == tracks.count {
                                selectedTracks.removeAll()
                            } else {
                                isSelectionMode = false
                                selectedTracks.removeAll()
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        
                        Button(selectedTracks.isEmpty ? "全选" : "全取消") {
                            if selectedTracks.isEmpty {
                                // 全选所有歌曲
                                selectedTracks = Set(tracks.map { $0.id })
                            } else {
                                // 全取消
                                selectedTracks.removeAll()
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        
                        Text("已选择 \(selectedTracks.count) 首歌曲")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if !selectedTracks.isEmpty {
                            Menu {
                                Button("添加到播放列表") {
                                    let selectedSongs = tracks.filter { track in
                                        selectedTracks.contains(track.id)
                                    }.map { Song(from: $0) }
                                    playerService.addSongs(selectedSongs)
                                    isSelectionMode = false
                                    selectedTracks.removeAll()
                                }
                                
                                Button("添加到其他歌单") {
                                    // TODO: 实现添加到其他歌单功能
                                }
                                
                                Button("从此歌单中删除") {
                                    // TODO: 实现从歌单中删除功能
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("批量操作")
                                        .font(.headline)
                                    
                                    if !selectedTracks.isEmpty {
                                        Text("(\(selectedTracks.count))")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                            }
                        }
                    }
                } else {
                    Text("歌曲")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            isSelectionMode = true
                        }) {
                            Text("批量选择")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        
                        if isLoadingTracks {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // 歌曲列表
            if tracks.isEmpty && !isLoadingTracks {
                VStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无歌曲")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                            PlaylistTrackRow(
                                track: track, 
                                index: index + 1,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedTracks.contains(track.id),
                                onSelectionToggle: { trackId in
                                    if selectedTracks.contains(trackId) {
                                        selectedTracks.remove(trackId)
                                    } else {
                                        selectedTracks.insert(trackId)
                                    }
                                }
                            )
                            .onTapGesture {
                                if isSelectionMode {
                                    if selectedTracks.contains(track.id) {
                                        selectedTracks.remove(track.id)
                                    } else {
                                        selectedTracks.insert(track.id)
                                    }
                                } else {
                                    let song = Song(from: track)
                                    playerService.playSong(song)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func imageURL(from urlString: String?) -> URL? {
        return ImageURLHelper.processImageURL(urlString, size: .large)
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func loadPlaylistData() async {
        guard let globalCollectionId = playlist.global_collection_id else { return }
        
        await MainActor.run {
            isLoadingDetail = true
            isLoadingTracks = true
            errorMessage = nil
        }
        
        do {
            // 获取歌单详情
            let detail = try await libraryService.getPlaylistDetail(globalCollectionId: globalCollectionId)
            
            // 获取所有页的歌曲列表
            var allTracks: [PlaylistTrackInfo] = []
            var currentPage = 1
            let pageSize = 100
            
            // 持续获取页面直到没有更多数据
            while true {
                let trackList = try await libraryService.getPlaylistTracks(
                    globalCollectionId: globalCollectionId, 
                    page: currentPage, 
                    pageSize: pageSize
                )
                
                if trackList.isEmpty {
                    break
                }
                
                allTracks.append(contentsOf: trackList)
                
                // 如果返回的歌曲数少于页大小，说明是最后一页
                if trackList.count < pageSize {
                    break
                }
                
                currentPage += 1
            }
            
            await MainActor.run {
                self.playlistDetail = detail
                self.tracks = allTracks
                self.isLoadingDetail = false
                self.isLoadingTracks = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoadingDetail = false
                self.isLoadingTracks = false
            }
        }
    }
}

// MARK: - 歌曲行组件

struct PlaylistTrackRow: View {
    let track: PlaylistTrackInfo
    let index: Int
    let isSelectionMode: Bool
    let isSelected: Bool
    let onSelectionToggle: ((UUID) -> Void)?
    @State private var showingMoreOptions = false
    @Environment(PlayerService.self) private var playerService
    
    init(track: PlaylistTrackInfo, index: Int, isSelectionMode: Bool = false, isSelected: Bool = false, onSelectionToggle: ((UUID) -> Void)? = nil) {
        self.track = track
        self.index = index
        self.isSelectionMode = isSelectionMode
        self.isSelected = isSelected
        self.onSelectionToggle = onSelectionToggle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if isSelectionMode {
                // 选择框
                Button(action: {
                    onSelectionToggle?(track.id)
                }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
            } else {
                // 序号
                Text("\(index)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
            }
            
            // 歌曲封面
            AsyncImage(url: albumImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // 歌曲信息
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    // 使用统一的歌曲名称处理逻辑
                    Text(songTitle)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                    
                    // 音质标识
                    if track.privilege == 10 {
                        Text("VIP")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 0.5)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(2)
                    }
                    
                    if let relateGoods = track.relate_goods, relateGoods.count > 2 {
                        Text("SQ")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 0.5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(2)
                    } else if let relateGoods = track.relate_goods, relateGoods.count > 1 {
                        Text("HQ")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 0.5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(2)
                    }
                }
                
                Text(track.singername ?? "未知歌手")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 专辑名
            Text(track.albumname ?? "")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(minWidth: 100, alignment: .leading)
            
            // 时长
            Text(formatDuration(track.duration))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
    }
    
    private var albumImageURL: URL? {
        return ImageURLHelper.processImageURL(track.cover, size: .small)
    }
    
    private func formatDuration(_ duration: Int?) -> String {
        guard let duration = duration, duration > 0 else { return "--:--" }
        
        let minutes = duration / 60
        let seconds = duration % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 处理歌曲名称：参考Song模型的初始化方法
    private var songTitle: String {
        let nameParts = (track.name ?? "未知歌曲").components(separatedBy: " - ")
        return nameParts.count > 1 ? nameParts[1] : (track.name ?? "未知歌曲")
    }
}
