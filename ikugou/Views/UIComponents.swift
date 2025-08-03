//
//  UIComponents.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

// 歌曲行视图组件
class SongRowView: NSView {
    private let albumCoverView = NSImageView()
    private let titleLabel = NSTextField()
    private let artistLabel = NSTextField()
    private let albumLabel = NSTextField()
    private let durationLabel = NSTextField()
    private let playButton = NSButton()
    
    var onPlay: (() -> Void)?
    
    init(song: Song) {
        super.init(frame: .zero)
        setupView()
        setupLayout()
        configure(with: song)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // 鼠标悬停效果
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        
        // 专辑封面
        albumCoverView.imageScaling = NSImageScaling.scaleAxesIndependently
        albumCoverView.wantsLayer = true
        albumCoverView.layer?.masksToBounds = true
        albumCoverView.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题标签
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 艺术家标签
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.textColor = .lightGray
        artistLabel.font = NSFont.systemFont(ofSize: 12)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 专辑标签
        albumLabel.isEditable = false
        albumLabel.isBordered = false
        albumLabel.backgroundColor = .clear
        albumLabel.textColor = .lightGray
        albumLabel.font = NSFont.systemFont(ofSize: 12)
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 时长标签
        durationLabel.isEditable = false
        durationLabel.isBordered = false
        durationLabel.backgroundColor = .clear
        durationLabel.textColor = .lightGray
        durationLabel.font = NSFont.systemFont(ofSize: 12)
        durationLabel.alignment = .right
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 播放按钮
        playButton.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "播放")
        playButton.isBordered = false
        playButton.wantsLayer = true
        playButton.layer?.backgroundColor = NSColor.clear.cgColor
        playButton.isHidden = true
        playButton.target = self
        playButton.action = #selector(playButtonTapped)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        addSubview(albumCoverView)
        addSubview(titleLabel)
        addSubview(artistLabel)
        addSubview(albumLabel)
        addSubview(durationLabel)
        addSubview(playButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 专辑封面
            albumCoverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            albumCoverView.centerYAnchor.constraint(equalTo: centerYAnchor),
            albumCoverView.widthAnchor.constraint(equalToConstant: 40),
            albumCoverView.heightAnchor.constraint(equalToConstant: 40),
            
            // 播放按钮（覆盖在专辑封面上）
            playButton.centerXAnchor.constraint(equalTo: albumCoverView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: albumCoverView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 24),
            playButton.heightAnchor.constraint(equalToConstant: 24),
            
            // 标题标签
            titleLabel.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100),
            
            // 艺术家标签
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 专辑标签
            albumLabel.leadingAnchor.constraint(equalTo: artistLabel.trailingAnchor, constant: 10),
            albumLabel.centerYAnchor.constraint(equalTo: artistLabel.centerYAnchor),
            albumLabel.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -10),
            
            // 时长标签
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with song: Song) {
        titleLabel.stringValue = song.name
        artistLabel.stringValue = song.artist
        albumLabel.stringValue = song.album
        durationLabel.stringValue = formatDuration(song.duration)
        
        // 加载专辑封面
        if let url = URL(string: song.albumCoverUrl) {
            loadImage(from: url, into: albumCoverView)
        }
    }
    
    // 格式化时长（秒 -> mm:ss）
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // 加载图片
    private func loadImage(from url: URL, into imageView: NSImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    // 播放按钮点击事件
    @objc private func playButtonTapped() {
        onPlay?()
    }
    
    // 鼠标悬停事件
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        layer?.backgroundColor = NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1).cgColor
        playButton.isHidden = false
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        layer?.backgroundColor = NSColor.clear.cgColor
        playButton.isHidden = true
    }
    
    // 点击行任意位置播放
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onPlay?()
    }
}

// 播放列表项视图组件
class PlaylistItemView: NSView {
    private let coverView = NSImageView()
    private let titleLabel = NSTextField()
    private let ownerLabel = NSTextField()
    
    init(playlist: Playlist) {
        super.init(frame: .zero)
        setupView()
        setupLayout()
        configure(with: playlist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // 封面视图
        coverView.imageScaling = NSImageScaling.scaleAxesIndependently
        coverView.wantsLayer = true
        coverView.layer?.masksToBounds = true
        coverView.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题标签
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 所有者标签
        ownerLabel.isEditable = false
        ownerLabel.isBordered = false
        ownerLabel.backgroundColor = .clear
        ownerLabel.textColor = .lightGray
        ownerLabel.font = NSFont.systemFont(ofSize: 12)
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        addSubview(coverView)
        addSubview(titleLabel)
        addSubview(ownerLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 封面视图
            coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.heightAnchor.constraint(equalToConstant: 160),
            
            // 标题标签
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 10),
            
            // 所有者标签
            ownerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            ownerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ownerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with playlist: Playlist) {
        titleLabel.stringValue = playlist.name
        ownerLabel.stringValue = playlist.owner
        
        // 加载封面图片
        if let url = URL(string: playlist.coverUrl) {
            loadImage(from: url, into: coverView)
        }
    }
    
    // 加载图片
    private func loadImage(from url: URL, into imageView: NSImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}

// 专辑项视图组件
class AlbumItemView: NSView {
    private let coverView = NSImageView()
    private let titleLabel = NSTextField()
    private let artistLabel = NSTextField()
    
    init(album: Album) {
        super.init(frame: .zero)
        setupView()
        setupLayout()
        configure(with: album)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // 封面视图
        coverView.imageScaling = NSImageScaling.scaleAxesIndependently
        coverView.wantsLayer = true
        coverView.layer?.masksToBounds = true
        coverView.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题标签
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 艺术家标签
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.textColor = .lightGray
        artistLabel.font = NSFont.systemFont(ofSize: 12)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        addSubview(coverView)
        addSubview(titleLabel)
        addSubview(artistLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 封面视图
            coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.heightAnchor.constraint(equalToConstant: 140),
            
            // 标题标签
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 10),
            
            // 艺术家标签
            artistLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with album: Album) {
        titleLabel.stringValue = album.name
        artistLabel.stringValue = album.artist
        
        // 加载封面图片
        if let url = URL(string: album.coverUrl) {
            loadImage(from: url, into: coverView)
        }
    }
    
    // 加载图片
    private func loadImage(from url: URL, into imageView: NSImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}

// 艺术家项视图组件
class ArtistItemView: NSView {
    private let imageView = NSImageView()
    private let nameLabel = NSTextField()
    
    init(artist: Artist) {
        super.init(frame: .zero)
        setupView()
        setupLayout()
        configure(with: artist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // 图片视图（圆形）
        imageView.imageScaling = NSImageScaling.scaleAxesIndependently
        imageView.wantsLayer = true
        imageView.layer?.masksToBounds = true
        imageView.layer?.cornerRadius = 60 // 宽度的一半，形成圆形
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 名称标签
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.backgroundColor = .clear
        nameLabel.textColor = .white
        nameLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.alignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        addSubview(imageView)
        addSubview(nameLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 图片视图
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            // 名称标签
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10)
        ])
    }
    
    func configure(with artist: Artist) {
        nameLabel.stringValue = artist.name
        
        // 加载图片
        if let url = URL(string: artist.imageUrl) {
            loadImage(from: url, into: imageView)
        }
    }
    
    // 加载图片
    private func loadImage(from url: URL, into imageView: NSImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}
    
