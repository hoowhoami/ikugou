//
//  LibraryViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

class LibraryViewController: NSViewController {
    // 模拟数据
    private let myPlaylists = [
        Playlist(id: "1", name: "我的最爱", coverUrl: "https://.example.com/favorites.jpg", owner: "我"),
        Playlist(id: "2", name: "健身音乐", coverUrl: "https://example.com/workout.jpg", owner: "我"),
        Playlist(id: "3", name: "工作专注", coverUrl: "https://.example.com/focus.jpg", owner: "我"),
        Playlist(id: "4", name: "驾车车必备", coverUrl: "https://example.com/driving.jpg", owner: "我")
    ]
    
    private let likedSongs = [
        Song(id: "1", name: "Hello", artist: "Adele", album: "25", albumCoverUrl: "https://example.com/adele.jpg", audioUrl: "https://.example.com/hello.mp3", duration: 215, trackNumber: 1),
        Song(id: "2", name: "Shape of You", artist: "Ed Sheeran", album: "÷", albumCoverUrl: "https://example.com/edsheeran.jpg", audioUrl: "https://.example.com/shape.mp3", duration: 234, trackNumber: 1),
        Song(id: "3", name: "Blinding Lights", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://example.com/weeknd.jpg", audioUrl: "https://.example.com/blinding.mp3", duration: 203, trackNumber: 2),
        Song(id: "4", name: "Save Your Tears", artist: "The Weeknd", album: "After Hours", albumCoverUrl: "https://example.com/weeknd.jpg", audioUrl: "https://example.com/save.mp3", duration: 215, trackNumber: 3)
    ]
    
    private let myAlbums = [
        Album(id: "1", name: "25", artist: "Adele", coverUrl: "https://example.com/adele_album.jpg"),
        Album(id: "2", name: "÷", artist: "Ed Sheeran", coverUrl: "https://.example.com/ed_album.jpg"),
        Album(id: "3", name: "After Hours", artist: "The Weeknd", coverUrl: "https://example.com/weeknd_album.jpg"),
        Album(id: "4", name: "Future Nostalgia", artist: "Dua Lipa", coverUrl: "https://example.com/dua_album.jpg"),
        Album(id: "5", name: "= ", artist: "Ed Sheeran", coverUrl: "https://example.com/ed_eq_album.jpg")
    ]
    
    // 视图组件
    private let scrollView = NSScrollView()
    private let contentView = NSView()
    
    // 区域容器
    private let playlistsContainer = NSView()
    private let likedSongsContainer = NSView()
    private let albumsContainer = NSView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupContent()
    }
    
    func loadData() {
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
        
        // 区域容器
        [playlistsContainer, likedSongsContainer, albumsContainer].forEach {
            $0.wantsLayer = true
            $0.layer?.backgroundColor = NSColor.clear.cgColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // 添加到视图层级
        scrollView.documentView = contentView
        view.addSubview(scrollView)
    }
    
    private func setupLayout() {
        // 禁用 autoresizing mask
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图宽度与滚动视图一致
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 区域容器约束
            playlistsContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            playlistsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playlistsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            likedSongsContainer.topAnchor.constraint(equalTo: playlistsContainer.bottomAnchor, constant: 30),
            likedSongsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedSongsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            albumsContainer.topAnchor.constraint(equalTo: likedSongsContainer.bottomAnchor, constant: 30),
            albumsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            albumsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            albumsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupContent() {
        // 清除现有内容
        [playlistsContainer, likedSongsContainer, albumsContainer].forEach {
            $0.subviews.forEach { $0.removeFromSuperview() }
        }
        
        // 设置我的播放列表区域
        setupPlaylistsSection()
        
        // 设置喜欢的歌曲区域
        setupLikedSongsSection()
        
        // 设置我的专辑区域
        setupAlbumsSection()
    }
    
    // 创建标题标签的辅助方法
    private func createTitleLabel(text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // 创建"查看全部"按钮的辅助方法 - 修复了NSButton文本颜色设置问题
    private func createSeeAllButton() -> NSButton {
        let button = NSButton(title: "查看全部", target: nil, action: nil)
        button.bezelStyle = .texturedRounded
        button.isBordered = false
        button.font = NSFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 在macOS中设置按钮文本颜色的正确方式
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.systemBlue,
            .font: button.font!
        ]
        button.attributedTitle = NSAttributedString(string: "查看全部", attributes: attributes)
        
        return button
    }
    
    // 设置我的播放列表区域
    private func setupPlaylistsSection() {
        // 标题栏
        let headerView = NSView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        playlistsContainer.addSubview(headerView)
        
        let titleLabel = createTitleLabel(text: "我的播放列表")
        let seeAllButton = createSeeAllButton()
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(seeAllButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // 播放列表滚动视图
        let scrollView = NSScrollView()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = container
        
        playlistsContainer.addSubview(scrollView)
        
        // 添加播放列表项
        var lastView: NSView?
        for playlist in myPlaylists {
            let playlistView = PlaylistItemView(playlist: playlist)
            playlistView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(playlistView)
            
            NSLayoutConstraint.activate([
                playlistView.leadingAnchor.constraint(equalTo: lastView == nil ? container.leadingAnchor : lastView!.trailingAnchor, constant: lastView == nil ? 0 : 16),
                playlistView.topAnchor.constraint(equalTo: container.topAnchor),
                playlistView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                playlistView.widthAnchor.constraint(equalToConstant: 160),
                playlistView.heightAnchor.constraint(equalToConstant: 220)
            ])
            
            lastView = playlistView
        }
        
        if let lastView = lastView {
            NSLayoutConstraint.activate([
                container.trailingAnchor.constraint(equalTo: lastView.trailingAnchor),
                container.heightAnchor.constraint(equalToConstant: 220)
            ])
        }
        
        // 容器约束
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: playlistsContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: playlistsContainer.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: playlistsContainer.topAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: playlistsContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: playlistsContainer.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: playlistsContainer.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    // 设置喜欢的歌曲区域
    private func setupLikedSongsSection() {
        // 标题栏
        let headerView = NSView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        likedSongsContainer.addSubview(headerView)
        
        let titleLabel = createTitleLabel(text: "喜欢的歌曲")
        let seeAllButton = createSeeAllButton()
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(seeAllButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // 歌曲列表容器
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        likedSongsContainer.addSubview(container)
        
        // 添加歌曲行
        var lastView: NSView?
        for song in likedSongs {
            let songView = SongRowView(song: song)
            songView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(songView)
            
            NSLayoutConstraint.activate([
                songView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                songView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                songView.topAnchor.constraint(equalTo: lastView == nil ? container.topAnchor : lastView!.bottomAnchor),
                songView.heightAnchor.constraint(equalToConstant: 45)
            ])
            
            // 点击播放歌曲
            songView.onPlay = { [weak self] in
                guard let mainVC = self?.parent as? MainViewController else { return }
                mainVC.playSong(song, in: self?.likedSongs ?? [])
            }
            
            lastView = songView
        }
        
        // 容器约束
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: likedSongsContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: likedSongsContainer.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: likedSongsContainer.topAnchor),
            
            container.leadingAnchor.constraint(equalTo: likedSongsContainer.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: likedSongsContainer.trailingAnchor),
            container.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            container.bottomAnchor.constraint(equalTo: likedSongsContainer.bottomAnchor)
        ])
    }
    
    // 设置我的专辑区域
    private func setupAlbumsSection() {
        // 标题栏
        let headerView = NSView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        albumsContainer.addSubview(headerView)
        
        let titleLabel = createTitleLabel(text: "我的专辑")
        let seeAllButton = createSeeAllButton()
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(seeAllButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // 专辑网格视图
        let gridView = NSCollectionView()
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.wantsLayer = true
        gridView.layer?.backgroundColor = NSColor.clear.cgColor
        
        // 设置集合视图布局
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 140, height: 180)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        gridView.collectionViewLayout = layout
        
        // 注册单元格
        gridView.register(AlbumCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("AlbumCell"))
        
        // 设置数据源
        let dataSource = AlbumCollectionViewDataSource(albums: myAlbums)
        gridView.dataSource = dataSource
        
        albumsContainer.addSubview(gridView)
        
        // 容器约束
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: albumsContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: albumsContainer.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: albumsContainer.topAnchor),
            
            gridView.leadingAnchor.constraint(equalTo: albumsContainer.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: albumsContainer.trailingAnchor),
            gridView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            gridView.bottomAnchor.constraint(equalTo: albumsContainer.bottomAnchor)
        ])
    }
}

// 专辑集合视图项
class AlbumCollectionViewItem: NSCollectionViewItem {
    private let albumView = AlbumItemView(album: Album(id: "", name: "", artist: "", coverUrl: ""))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.addSubview(albumView)
        
        albumView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albumView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumView.topAnchor.constraint(equalTo: view.topAnchor),
            albumView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configure(with album: Album) {
        albumView.configure(with: album)
    }
}

// 专辑集合视图数据源
class AlbumCollectionViewDataSource: NSObject, NSCollectionViewDataSource {
    private let albums: [Album]
    
    init(albums: [Album]) {
        self.albums = albums
        super.init()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("AlbumCell"), for: indexPath) as? AlbumCollectionViewItem else {
            return NSCollectionViewItem()
        }
        
        let album = albums[indexPath.item]
        item.configure(with: album)
        return item
    }
}
    
    
    
    
    
