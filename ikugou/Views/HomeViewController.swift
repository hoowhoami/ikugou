//
//  HomeViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

class HomeViewController: NSViewController {
    // 模拟数据
    private let featuredPlaylists = [
        Playlist(id: "1", name: "今日推荐", coverUrl: "https://picsum.photos/seed/playlist1/300/300", owner: "Spotify"),
        Playlist(id: "2", name: "流行新曲", coverUrl: "https://picsum.photos/seed/playlist2/300/300", owner: "Spotify"),
        Playlist(id: "3", name: "复古金曲", coverUrl: "https://picsum.photos/seed/playlist3/300/300", owner: "Spotify"),
        Playlist(id: "4", name: "工作专注", coverUrl: "https://picsum.photos/seed/playlist4/300/300", owner: "Spotify"),
        Playlist(id: "5", name: "放松心情", coverUrl: "https://picsum.photos/seed/playlist5/300/300", owner: "Spotify")
    ]
    
    private let recentlyPlayedSongs = [
        Song(id: "1", name: "Hello", artist: "Adele", album: "25", albumCoverUrl: "https://picsum.photos/seed/adele/300/300", audioUrl: "https://example.com/hello.mp3", duration: 215, trackNumber: 1),
        Song(id: "2", name: "Shape of You", artist: "Ed Sheeran", album: "÷", albumCoverUrl: "https://picsum.photos/seed/edsheeran/300/300", audioUrl: "https://example.com/shape.mp3", duration: 234, trackNumber: 1),
        Song(id: "3", name: "Blinding Lights", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://picsum.photos/seed/weeknd/300/300", audioUrl: "https://example.com/blinding.mp3", duration: 203, trackNumber: 2)
    ]
    
    private let recommendedSongs = [
        Song(id: "4", name: "Save Your Tears", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://picsum.photos/seed/weeknd2/300/300", audioUrl: "https://example.com/save.mp3", duration: 215, trackNumber: 3),
        Song(id: "5", name: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia", albumCoverUrl: "https://picsum.photos/seed/dualipa/300/300", audioUrl: "https://example.com/levitating.mp3", duration: 203, trackNumber: 2),
        Song(id: "6", name: "Shivers", artist: "Ed Sheeran", album: "=", albumCoverUrl: "https://picsum.photos/seed/edsheeran2/300/300", audioUrl: "https://example.com/shivers.mp3", duration: 220, trackNumber: 3),
        Song(id: "7", name: "Stay", artist: "Justin Bieber, The Kid LAROI", album: "F*CK LOVE 3+", albumCoverUrl: "https://picsum.photos/seed/justin/300/300", audioUrl: "https://example.com/stay.mp3", duration: 187, trackNumber: 5)
    ]
    
    // 主滚动视图
    private let scrollView = NSScrollView()
    private let contentView = NSView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupContent()
    }
    
    func loadData() {
        // 实际项目中从API加载数据
        setupContent()
    }
    
    private func setupView() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1).cgColor
        
        // 配置滚动视图
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        // 配置内容视图
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        
        // 添加到视图层级
        scrollView.documentView = contentView
        view.addSubview(scrollView)
    }
    
    private func setupLayout() {
        // 禁用 autoresizing mask
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置 修复滚动视图 edgesAnchor 问题
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图宽度与滚动视图一致
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupContent() {
        // 清除现有内容
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: NSView?
        
        // 添加标题
        let titleLabel = NSTextField(labelWithString: "首页")
        titleLabel.font = NSFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ])
        
        lastView = titleLabel
        
        // 添加精选播放列表区域
        let (featuredView, featuredLastView) = createPlaylistSection(
            title: "精选播放列表",
            playlists: featuredPlaylists,
            topAnchor: lastView!.bottomAnchor,
            topConstant: 30
        )
        contentView.addSubview(featuredView)
        lastView = featuredLastView
        
        // 添加最近播放区域
        let (recentView, recentLastView) = createSongListSection(
            title: "最近播放",
            songs: recentlyPlayedSongs,
            topAnchor: lastView!.bottomAnchor,
            topConstant: 30
        )
        contentView.addSubview(recentView)
        lastView = recentLastView
        
        // 添加推荐歌曲区域
        let (recommendedView, recommendedLastView) = createSongListSection(
            title: "为你推荐",
            songs: recommendedSongs,
            topAnchor: lastView!.bottomAnchor,
            topConstant: 30
        )
        contentView.addSubview(recommendedView)
        lastView = recommendedLastView
        
        // 底部间距
        let bottomSpacer = NSView()
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomSpacer)
        
        NSLayoutConstraint.activate([
            bottomSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSpacer.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 20),
            bottomSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // 创建播放列表展示区域
    private func createPlaylistSection(title: String, playlists: [Playlist], topAnchor: NSLayoutYAxisAnchor, topConstant: CGFloat) -> (NSView, NSView) {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // 水平滚动的播放列表
        let scrollView = NSScrollView()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let playlistContainer = NSView()
        playlistContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = playlistContainer
        
        container.addSubview(scrollView)
        
        // 添加播放列表项
        var lastPlaylistView: NSView?
        for (index, playlist) in playlists.enumerated() {
            let playlistView = PlaylistItemView(playlist: playlist)
            playlistView.translatesAutoresizingMaskIntoConstraints = false
            playlistContainer.addSubview(playlistView)
            
            NSLayoutConstraint.activate([
                playlistView.leadingAnchor.constraint(equalTo: lastPlaylistView == nil ? playlistContainer.leadingAnchor : lastPlaylistView!.trailingAnchor, constant: lastPlaylistView == nil ? 0 : 16),
                playlistView.topAnchor.constraint(equalTo: playlistContainer.topAnchor),
                playlistView.bottomAnchor.constraint(equalTo: playlistContainer.bottomAnchor),
                playlistView.widthAnchor.constraint(equalToConstant: 160),
                playlistView.heightAnchor.constraint(equalToConstant: 220)
            ])
            
            lastPlaylistView = playlistView
        }
        
        // 确保容器宽度足够容纳所有播放列表
        if let lastView = lastPlaylistView {
            NSLayoutConstraint.activate([
                playlistContainer.trailingAnchor.constraint(equalTo: lastView.trailingAnchor),
                playlistContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                playlistContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
        }
        
        // 容器约束
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        // 与父视图的约束
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            container.topAnchor.constraint(equalTo: topAnchor, constant: topConstant)
        ])
        
        return (container, scrollView)
    }
    
    // 创建歌曲列表区域
    private func createSongListSection(title: String, songs: [Song], topAnchor: NSLayoutYAxisAnchor, topConstant: CGFloat) -> (NSView, NSView) {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // 歌曲列表容器
        let songsContainer = NSView()
        songsContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(songsContainer)
        
        // 添加歌曲行
        var lastSongView: NSView?
        for song in songs {
            let songView = SongRowView(song: song)
            songView.translatesAutoresizingMaskIntoConstraints = false
            songsContainer.addSubview(songView)
            
            NSLayoutConstraint.activate([
                songView.leadingAnchor.constraint(equalTo: songsContainer.leadingAnchor),
                songView.trailingAnchor.constraint(equalTo: songsContainer.trailingAnchor),
                songView.topAnchor.constraint(equalTo: lastSongView == nil ? songsContainer.topAnchor : lastSongView!.bottomAnchor),
                songView.heightAnchor.constraint(equalToConstant: 45)
            ])
            
            // 点击播放歌曲
            songView.onPlay = { [weak self] in
                guard let mainVC = self?.parent as? MainViewController else { return }
                mainVC.playSong(song, in: songs)
            }
            
            lastSongView = songView
        }
        
        // 容器约束
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            
            songsContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            songsContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            songsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            songsContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // 与父视图的约束
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            container.topAnchor.constraint(equalTo: topAnchor, constant: topConstant)
        ])
        
        return (container, lastSongView ?? container)
    }
}
    
    
