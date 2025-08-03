//
//  SearchViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

class SearchViewController: NSViewController, NSSearchFieldDelegate {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
    }

    // 模拟搜索结果数据
    private let allSongs = [
        Song(id: "1", name: "Hello", artist: "Adele", album: "25", albumCoverUrl: "https://picsum.photos/seed/adele/300/300", audioUrl: "https://example.com/hello.mp3", duration: 215, trackNumber: 1),
        Song(id: "2", name: "Shape of You", artist: "Ed Sheeran", album: "÷", albumCoverUrl: "https://picsum.photos/seed/edsheeran/300/300", audioUrl: "https://example.com/shape.mp3", duration: 234, trackNumber: 1),
        Song(id: "3", name: "Blinding Lights", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://picsum.photos/seed/weeknd/300/300", audioUrl: "https://example.com/blinding.mp3", duration: 203, trackNumber: 2),
        Song(id: "4", name: "Save Your Tears", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://picsum.photos/seed/weeknd2/300/300", audioUrl: "https://example.com/save.mp3", duration: 215, trackNumber: 3),
        Song(id: "5", name: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia", albumCoverUrl: "https://picsum.photos/seed/dualipa/300/300", audioUrl: "https://example.com/levitating.mp3", duration: 203, trackNumber: 2)
    ]
    
    private let allArtists = [
        Artist(id: "1", name: "Adele", imageUrl: "https://picsum.photos/seed/artist1/300/300"),
        Artist(id: "2", name: "Ed Sheeran", imageUrl: "https://picsum.photos/seed/artist2/300/300"),
        Artist(id: "3", name: "The Weeknd", imageUrl: "https://picsum.photos/seed/artist3/300/300"),
        Artist(id: "4", name: "Dua Lipa", imageUrl: "https://picsum.photos/seed/artist4/300/300")
    ]
    
    private let allAlbums = [
        Album(id: "1", name: "25", artist: "Adele", coverUrl: "https://picsum.photos/seed/album1/300/300"),
        Album(id: "2", name: "÷", artist: "Ed Sheeran", coverUrl: "https://picsum.photos/seed/album2/300/300"),
        Album(id: "3", name: "After Hours", artist: "The Weeknd", coverUrl: "https://picsum.photos/seed/album3/300/300"),
        Album(id: "4", name: "Future Nostalgia", artist: "Dua Lipa", coverUrl: "https://picsum.photos/seed/album4/300/300")
    ]
    
    private let allPlaylists = [
        Playlist(id: "1", name: "Adele 精选", coverUrl: "https://picsum.photos/seed/playlist1/300/300", owner: "Spotify"),
        Playlist(id: "2", name: "流行精选", coverUrl: "https://picsum.photos/seed/playlist2/300/300", owner: "Spotify"),
        Playlist(id: "3", name: "周末放松", coverUrl: "https://picsum.photos/seed/playlist3/300/300", owner: "Spotify")
    ]
    
    // 搜索结果
    private var filteredSongs: [Song] = []
    private var filteredArtists: [Artist] = []
    private var filteredAlbums: [Album] = []
    private var filteredPlaylists: [Playlist] = []
    
    // UI组件
    private let searchField = NSSearchField()
    private let scrollView = NSScrollView()
    private let contentView = NSView()
    
    // 搜索结果分类标题
    private let songsTitleLabel = NSTextField(labelWithString: "歌曲")
    private let artistsTitleLabel = NSTextField(labelWithString: "艺术家")
    private let albumsTitleLabel = NSTextField(labelWithString: "专辑")
    private let playlistsTitleLabel = NSTextField(labelWithString: "播放列表")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupSearchField()
        setupInitialState()
    }
    
    private func setupView() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1).cgColor
        
        // 配置滚动视图
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        view.addSubview(scrollView)
        
        // 配置内容视图
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        scrollView.documentView = contentView
        
        // 配置标题样式
        [songsTitleLabel, artistsTitleLabel, albumsTitleLabel, playlistsTitleLabel].forEach {
            $0.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
            $0.textColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 添加搜索框
        view.addSubview(searchField)
    }
    
    private func setupLayout() {
        // 禁用 autoresizing mask
        searchField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置约束 - 修复滚动视图 edgesAnchor 问题
        NSLayoutConstraint.activate([
            // 搜索框约束
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchField.heightAnchor.constraint(equalToConstant: 32),
            
            // 滚动视图约束
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图约束
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupSearchField() {
        searchField.placeholderString = "搜索歌曲、艺术家、专辑或播放列表..."
        searchField.bezelStyle = .roundedBezel
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.font = NSFont.systemFont(ofSize: 14)
        
        // 设置搜索框样式
        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.backgroundColor = NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
            cell.textColor = .white
            cell.searchButtonCell?.image = nil
            cell.searchButtonCell?.title = ""
        }
    }
    
    private func setupInitialState() {
        // 初始显示提示文本
        let hintLabel = NSTextField(labelWithString: "请输入搜索内容...")
        hintLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        hintLabel.textColor = .lightGray
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // 执行搜索
    private func performSearch(query: String) {
        // 清除现有内容
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        guard !query.isEmpty else {
            setupInitialState()
            return
        }
        
        let lowercasedQuery = query.lowercased()
        
        // 过滤搜索结果
        filteredSongs = allSongs.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.artist.lowercased().contains(lowercasedQuery) ||
            $0.album.lowercased().contains(lowercasedQuery)
        }
        
        filteredArtists = allArtists.filter {
            $0.name.lowercased().contains(lowercasedQuery)
        }
        
        filteredAlbums = allAlbums.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.artist.lowercased().contains(lowercasedQuery)
        }
        
        filteredPlaylists = allPlaylists.filter {
            $0.name.lowercased().contains(lowercasedQuery)
        }
        
        // 显示搜索结果
        displaySearchResults()
    }
    
    // 显示搜索结果
    private func displaySearchResults() {
        var lastView: NSView?
        
        // 显示歌曲结果
        if !filteredSongs.isEmpty {
            contentView.addSubview(songsTitleLabel)
            
            NSLayoutConstraint.activate([
                songsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                songsTitleLabel.topAnchor.constraint(equalTo: lastView == nil ? contentView.topAnchor : lastView!.bottomAnchor, constant: lastView == nil ? 0 : 20)
            ])
            
            lastView = songsTitleLabel
            
            // 添加歌曲列表
            let songsContainer = NSView()
            songsContainer.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(songsContainer)
            
            NSLayoutConstraint.activate([
                songsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                songsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                songsContainer.topAnchor.constraint(equalTo: songsTitleLabel.bottomAnchor, constant: 10)
            ])
            
            var lastSongView: NSView?
            for song in filteredSongs {
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
                    mainVC.playSong(song, in: self?.filteredSongs ?? [])
                }
                
                lastSongView = songView
            }
            
            if let lastSong = lastSongView {
                NSLayoutConstraint.activate([
                    songsContainer.bottomAnchor.constraint(equalTo: lastSong.bottomAnchor)
                ])
                lastView = songsContainer
            }
        }
        
        // 显示艺术家结果
        if !filteredArtists.isEmpty {
            contentView.addSubview(artistsTitleLabel)
            
            NSLayoutConstraint.activate([
                artistsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                artistsTitleLabel.topAnchor.constraint(equalTo: lastView == nil ? contentView.topAnchor : lastView!.bottomAnchor, constant: lastView == nil ? 0 : 20)
            ])
            
            lastView = artistsTitleLabel
            
            // 艺术家滚动视图
            let scrollView = NSScrollView()
            scrollView.hasHorizontalScroller = true
            scrollView.hasVerticalScroller = false
            scrollView.autohidesScrollers = true
            scrollView.borderType = .noBorder
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            let artistsContainer = NSView()
            artistsContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollView.documentView = artistsContainer
            
            contentView.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                scrollView.topAnchor.constraint(equalTo: artistsTitleLabel.bottomAnchor, constant: 10),
                scrollView.heightAnchor.constraint(equalToConstant: 180)
            ])
            
            // 添加艺术家项
            var lastArtistView: NSView?
            for artist in filteredArtists {
                let artistView = ArtistItemView(artist: artist)
                artistView.translatesAutoresizingMaskIntoConstraints = false
                artistsContainer.addSubview(artistView)
                
                NSLayoutConstraint.activate([
                    artistView.leadingAnchor.constraint(equalTo: lastArtistView == nil ? artistsContainer.leadingAnchor : lastArtistView!.trailingAnchor, constant: lastArtistView == nil ? 0 : 20),
                    artistView.topAnchor.constraint(equalTo: artistsContainer.topAnchor),
                    artistView.bottomAnchor.constraint(equalTo: artistsContainer.bottomAnchor),
                    artistView.widthAnchor.constraint(equalToConstant: 120)
                ])
                
                lastArtistView = artistView
            }
            
            // 确保容器宽度足够
            if let lastArtist = lastArtistView {
                NSLayoutConstraint.activate([
                    artistsContainer.trailingAnchor.constraint(equalTo: lastArtist.trailingAnchor),
                    artistsContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    artistsContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ])
            }
            
            lastView = scrollView
        }
        
        // 显示专辑结果
        if !filteredAlbums.isEmpty {
            contentView.addSubview(albumsTitleLabel)
            
            NSLayoutConstraint.activate([
                albumsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                albumsTitleLabel.topAnchor.constraint(equalTo: lastView == nil ? contentView.topAnchor : lastView!.bottomAnchor, constant: lastView == nil ? 0 : 20)
            ])
            
            lastView = albumsTitleLabel
            
            // 专辑滚动视图
            let scrollView = NSScrollView()
            scrollView.hasHorizontalScroller = true
            scrollView.hasVerticalScroller = false
            scrollView.autohidesScrollers = true
            scrollView.borderType = .noBorder
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            let albumsContainer = NSView()
            albumsContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollView.documentView = albumsContainer
            
            contentView.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                scrollView.topAnchor.constraint(equalTo: albumsTitleLabel.bottomAnchor, constant: 10),
                scrollView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            // 添加专辑项
            var lastAlbumView: NSView?
            for album in filteredAlbums {
                let albumView = AlbumItemView(album: album)
                albumView.translatesAutoresizingMaskIntoConstraints = false
                albumsContainer.addSubview(albumView)
                
                NSLayoutConstraint.activate([
                    albumView.leadingAnchor.constraint(equalTo: lastAlbumView == nil ? albumsContainer.leadingAnchor : lastAlbumView!.trailingAnchor, constant: lastAlbumView == nil ? 0 : 20),
                    albumView.topAnchor.constraint(equalTo: albumsContainer.topAnchor),
                    albumView.bottomAnchor.constraint(equalTo: albumsContainer.bottomAnchor),
                    albumView.widthAnchor.constraint(equalToConstant: 140)
                ])
                
                lastAlbumView = albumView
            }
            
            // 确保容器宽度足够
            if let lastAlbum = lastAlbumView {
                NSLayoutConstraint.activate([
                    albumsContainer.trailingAnchor.constraint(equalTo: lastAlbum.trailingAnchor),
                    albumsContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    albumsContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ])
            }
            
            lastView = scrollView
        }
        
        // 显示播放列表结果
        if !filteredPlaylists.isEmpty {
            contentView.addSubview(playlistsTitleLabel)
            
            NSLayoutConstraint.activate([
                playlistsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                playlistsTitleLabel.topAnchor.constraint(equalTo: lastView == nil ? contentView.topAnchor : lastView!.bottomAnchor, constant: lastView == nil ? 0 : 20)
            ])
            
            lastView = playlistsTitleLabel
            
            // 播放列表滚动视图
            let scrollView = NSScrollView()
            scrollView.hasHorizontalScroller = true
            scrollView.hasVerticalScroller = false
            scrollView.autohidesScrollers = true
            scrollView.borderType = .noBorder
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            let playlistsContainer = NSView()
            playlistsContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollView.documentView = playlistsContainer
            
            contentView.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                scrollView.topAnchor.constraint(equalTo: playlistsTitleLabel.bottomAnchor, constant: 10),
                scrollView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            // 添加播放列表项
            var lastPlaylistView: NSView?
            for playlist in filteredPlaylists {
                let playlistView = PlaylistItemView(playlist: playlist)
                playlistView.translatesAutoresizingMaskIntoConstraints = false
                playlistsContainer.addSubview(playlistView)
                
                NSLayoutConstraint.activate([
                    playlistView.leadingAnchor.constraint(equalTo: lastPlaylistView == nil ? playlistsContainer.leadingAnchor : lastPlaylistView!.trailingAnchor, constant: lastPlaylistView == nil ? 0 : 20),
                    playlistView.topAnchor.constraint(equalTo: playlistsContainer.topAnchor),
                    playlistView.bottomAnchor.constraint(equalTo: playlistsContainer.bottomAnchor),
                    playlistView.widthAnchor.constraint(equalToConstant: 140)
                ])
                
                lastPlaylistView = playlistView
            }
            
            // 确保容器宽度足够
            if let lastPlaylist = lastPlaylistView {
                NSLayoutConstraint.activate([
                    playlistsContainer.trailingAnchor.constraint(equalTo: lastPlaylist.trailingAnchor),
                    playlistsContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    playlistsContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ])
            }
            
            lastView = scrollView
        }
        
        // 如果没有搜索结果
        if filteredSongs.isEmpty && filteredArtists.isEmpty &&
           filteredAlbums.isEmpty && filteredPlaylists.isEmpty {
            let noResultsLabel = NSTextField(labelWithString: "没有找到匹配的结果")
            noResultsLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
            noResultsLabel.textColor = .lightGray
            noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(noResultsLabel)
            
            NSLayoutConstraint.activate([
                noResultsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                noResultsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        } else if let lastView = lastView {
            // 添加底部间距
            let bottomSpacer = NSView()
            bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(bottomSpacer)
            
            NSLayoutConstraint.activate([
                bottomSpacer.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20),
                bottomSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bottomSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                bottomSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bottomSpacer.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
    }
    
    // 搜索框代理方法
    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else { return }
        performSearch(query: searchField.stringValue)
    }
}
    
    
