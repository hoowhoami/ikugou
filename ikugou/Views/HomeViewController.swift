//
//  HomeViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa
import Combine

// MARK: - 简化的API响应模型
struct SimpleAPIResponse: Codable {
    let status: Int
    let data: SimpleAPIData
}

struct SimpleAPIData: Codable {
    let info: [SimpleSongInfo]
}

struct SimpleSongInfo: Codable {
    let hash: String
    let songname: String
    let singername: String
    let album_name: String?
    let duration: Int

    func toSong() -> Song {
        return Song(
            id: hash,
            name: songname,
            artist: singername,
            album: album_name ?? "未知专辑",
            albumCoverUrl: "https://picsum.photos/seed/\(hash)/300/300",
            audioUrl: "https://example.com/\(hash).mp3",
            duration: TimeInterval(duration),
            trackNumber: 1
        )
    }
}

class HomeViewController: NSViewController {

    // API服务
    private var cancellables = Set<AnyCancellable>()

    // 数据
    private var recommendedSongs: [Song] = []
    private var hotPlaylists: [Playlist] = []
    private var rankSongs: [Song] = []

    // 播放回调
    var onSongSelected: ((Song) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        setupSimpleView()
        loadAPIData()
    }

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
    

    
    // 主滚动视图
    private let scrollView = NSScrollView()
    private let contentView = NSView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSimpleView()
        // setupLayout()  // 暂时注释掉
        // setupContent() // 暂时注释掉
        print("🏠 HomeViewController viewDidLoad 完成")
    }

    private func setupSimpleView() {
        view.wantsLayer = true
        // QQ音乐风格的主内容区背景色
        view.layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor

        // 创建滚动视图
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // "Hi whoami 今日为你推荐" 标题
        let greetingLabel = NSTextField(labelWithString: "Hi whoami 今日为你推荐")
        greetingLabel.textColor = .white
        greetingLabel.font = NSFont.systemFont(ofSize: 24, weight: .medium)
        greetingLabel.isEditable = false
        greetingLabel.isBordered = false
        greetingLabel.backgroundColor = .clear
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false

        // "查看你的听歌报告" 链接
        let reportLabel = NSTextField(labelWithString: "查看你的听歌报告 >")
        reportLabel.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        reportLabel.font = NSFont.systemFont(ofSize: 14)
        reportLabel.isEditable = false
        reportLabel.isBordered = false
        reportLabel.backgroundColor = .clear

        // 添加点击手势
        let reportClickGesture = NSClickGestureRecognizer(target: self, action: #selector(reportLinkClicked))
        reportLabel.addGestureRecognizer(reportClickGesture)
        reportLabel.translatesAutoresizingMaskIntoConstraints = false

        // "下午茶" 推荐区域
        let afternoonTeaSection = createAfternoonTeaSection()

        // "你的歌单补给站" 区域
        let playlistSupplySection = createPlaylistSupplySection()

        contentView.addSubview(greetingLabel)
        contentView.addSubview(reportLabel)
        contentView.addSubview(afternoonTeaSection)
        contentView.addSubview(playlistSupplySection)

        scrollView.documentView = contentView
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            // 滚动视图
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 内容视图
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // 问候标题
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),

            // 报告链接
            reportLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            reportLabel.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),

            // 下午茶区域
            afternoonTeaSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            afternoonTeaSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            afternoonTeaSection.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 32),
            afternoonTeaSection.heightAnchor.constraint(equalToConstant: 280),

            // 歌单补给站区域
            playlistSupplySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            playlistSupplySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            playlistSupplySection.topAnchor.constraint(equalTo: afternoonTeaSection.bottomAnchor, constant: 40),
            playlistSupplySection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            playlistSupplySection.heightAnchor.constraint(equalToConstant: 400)
        ])

        // 暂时使用静态数据，后续集成API
        print("✅ QQ音乐风格界面加载完成")
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
        for (_, playlist) in playlists.enumerated() {
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

    // QQ音乐风格的分类标签栏
    private func createCategoryTabs() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let categories = ["精选", "新书", "排行", "歌手", "分类歌单", "数字专辑", "音质专区", "视频", "雷达"]
        var lastButton: NSButton?

        for (index, category) in categories.enumerated() {
            let button = NSButton()
            button.title = category
            button.bezelStyle = .regularSquare
            button.isBordered = false
            button.font = NSFont.systemFont(ofSize: 14, weight: .medium)

            button.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)

            if index == 0 { // 精选为选中状态
                button.contentTintColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1)

                // 添加下划线
                let underline = NSView()
                underline.wantsLayer = true
                underline.layer?.backgroundColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1).cgColor
                underline.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(underline)

                NSLayoutConstraint.activate([
                    underline.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                    underline.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                    underline.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    underline.heightAnchor.constraint(equalToConstant: 2)
                ])
            } else {
                button.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            }

            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: lastButton?.trailingAnchor ?? container.leadingAnchor, constant: lastButton == nil ? 0 : 32),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            lastButton = button
        }

        return container
    }

    // QQ音乐风格的推荐内容区域
    private func createRecommendedSection() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // 创建三个推荐卡片
        let card1 = createRecommendedCard(title: "最微弱的光", subtitle: "苏打绿 新歌", imageName: "music.note.list")
        let card2 = createRecommendedCard(title: "《说唱梦工厂》", subtitle: "对决火力开战", imageName: "mic.fill")
        let card3 = createRecommendedCard(title: "明星音乐家", subtitle: "《明星大侦探》", imageName: "star.fill")

        container.addSubview(card1)
        container.addSubview(card2)
        container.addSubview(card3)

        NSLayoutConstraint.activate([
            // 第一张卡片
            card1.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card1.topAnchor.constraint(equalTo: container.topAnchor),
            card1.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.3),
            card1.heightAnchor.constraint(equalToConstant: 200),

            // 第二张卡片
            card2.leadingAnchor.constraint(equalTo: card1.trailingAnchor, constant: 16),
            card2.topAnchor.constraint(equalTo: container.topAnchor),
            card2.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.3),
            card2.heightAnchor.constraint(equalToConstant: 200),

            // 第三张卡片
            card3.leadingAnchor.constraint(equalTo: card2.trailingAnchor, constant: 16),
            card3.topAnchor.constraint(equalTo: container.topAnchor),
            card3.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card3.heightAnchor.constraint(equalToConstant: 200)
        ])

        return container
    }

    // 创建推荐卡片
    private func createRecommendedCard(title: String, subtitle: String, imageName: String) -> NSView {
        let card = NSView()
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1).cgColor
        card.layer?.cornerRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        // 图标
        let iconView = NSImageView()
        iconView.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        iconView.contentTintColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 副标题
        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.textColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        subtitleLabel.font = NSFont.systemFont(ofSize: 12)
        subtitleLabel.isEditable = false
        subtitleLabel.isBordered = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),

            subtitleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])

        return card
    }

    // MARK: - 新的界面组件（按照截图1:1复刻）

    // "下午茶" 推荐区域
    private func createAfternoonTeaSection() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // "下午茶" 标题
        let titleLabel = NSTextField(labelWithString: "下午茶")
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 主推荐卡片（左侧大卡片）
        let mainCard = createMainRecommendCard()

        // 右侧4个小卡片
        let card1 = createSmallRecommendCard(title: "有点甜-汪苏泷", subtitle: "每日30首", imageName: "music.note")
        let card2 = createSmallRecommendCard(title: "冲动的惩罚-刀郎", subtitle: "雷达模式", imageName: "waveform")
        let card3 = createSmallRecommendCard(title: "活着viva (女版)-拉...", subtitle: "百万收藏", imageName: "heart.fill")
        let card4 = createSmallRecommendCard(title: "经典怀旧音乐", subtitle: "官方收藏", imageName: "star.fill")

        container.addSubview(titleLabel)
        container.addSubview(mainCard)
        container.addSubview(card1)
        container.addSubview(card2)
        container.addSubview(card3)
        container.addSubview(card4)

        NSLayoutConstraint.activate([
            // 标题
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),

            // 主卡片（左侧）
            mainCard.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            mainCard.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.4),
            mainCard.heightAnchor.constraint(equalToConstant: 240),

            // 右侧卡片网格 (2x2)
            card1.leadingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: 16),
            card1.topAnchor.constraint(equalTo: mainCard.topAnchor),
            card1.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.27),
            card1.heightAnchor.constraint(equalToConstant: 115),

            card2.leadingAnchor.constraint(equalTo: card1.trailingAnchor, constant: 12),
            card2.topAnchor.constraint(equalTo: mainCard.topAnchor),
            card2.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card2.heightAnchor.constraint(equalToConstant: 115),

            card3.leadingAnchor.constraint(equalTo: card1.leadingAnchor),
            card3.topAnchor.constraint(equalTo: card1.bottomAnchor, constant: 10),
            card3.widthAnchor.constraint(equalTo: card1.widthAnchor),
            card3.heightAnchor.constraint(equalToConstant: 115),

            card4.leadingAnchor.constraint(equalTo: card2.leadingAnchor),
            card4.topAnchor.constraint(equalTo: card2.bottomAnchor, constant: 10),
            card4.trailingAnchor.constraint(equalTo: card2.trailingAnchor),
            card4.heightAnchor.constraint(equalToConstant: 115)
        ])

        return container
    }

    // 主推荐卡片（左侧大卡片）
    private func createMainRecommendCard() -> NSView {
        let card = NSView()
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1).cgColor
        card.layer?.cornerRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        // 添加点击手势
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(mainCardClicked))
        card.addGestureRecognizer(clickGesture)

        // 背景渐变（模拟专辑封面）
        let backgroundView = NSView()
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 0.3).cgColor
        backgroundView.layer?.cornerRadius = 8
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        // 播放按钮
        let playButton = NSButton()
        playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        playButton.bezelStyle = .circular
        playButton.isBordered = false
        playButton.wantsLayer = true
        playButton.layer?.backgroundColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1).cgColor
        playButton.layer?.cornerRadius = 20
        playButton.contentTintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false

        // 歌曲信息
        let songLabel = NSTextField(labelWithString: "容易来风儿童音")
        songLabel.textColor = .white
        songLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        songLabel.isEditable = false
        songLabel.isBordered = false
        songLabel.backgroundColor = .clear
        songLabel.translatesAutoresizingMaskIntoConstraints = false

        let artistLabel = NSTextField(labelWithString: "乐器提琴吧一")
        artistLabel.textColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        artistLabel.font = NSFont.systemFont(ofSize: 14)
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = NSTextField(labelWithString: "沙漠骆驼 - 展展与罗罗\n舞你喜欢")
        descLabel.textColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        descLabel.font = NSFont.systemFont(ofSize: 12)
        descLabel.isEditable = false
        descLabel.isBordered = false
        descLabel.backgroundColor = .clear
        descLabel.maximumNumberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(backgroundView)
        card.addSubview(playButton)
        card.addSubview(songLabel)
        card.addSubview(artistLabel)
        card.addSubview(descLabel)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: card.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            playButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            playButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -80),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            songLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            songLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -50),

            artistLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            artistLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -30),

            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            descLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])

        return card
    }

    // 小推荐卡片（右侧网格）
    private func createSmallRecommendCard(title: String, subtitle: String, imageName: String) -> NSView {
        let card = NSView()
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1).cgColor
        card.layer?.cornerRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false

        // 添加点击手势
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(smallCardClicked(_:)))
        card.addGestureRecognizer(clickGesture)

        // 专辑封面
        let coverView = NSImageView()
        coverView.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        coverView.contentTintColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1)
        coverView.wantsLayer = true
        coverView.layer?.cornerRadius = 4
        coverView.translatesAutoresizingMaskIntoConstraints = false

        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 副标题
        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.textColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        subtitleLabel.font = NSFont.systemFont(ofSize: 11)
        subtitleLabel.isEditable = false
        subtitleLabel.isBordered = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(coverView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            coverView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            coverView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            coverView.widthAnchor.constraint(equalToConstant: 50),
            coverView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: coverView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: coverView.bottomAnchor, constant: -8),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        return card
    }

    // "你的歌单补给站" 区域
    private func createPlaylistSupplySection() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // 标题行
        let titleLabel = NSTextField(labelWithString: "你的歌单补给站")
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // VIP提示
        let vipLabel = NSTextField(labelWithString: "开通会员，畅享VIP曲库等超值特权 ¥10开通")
        vipLabel.textColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1)
        vipLabel.font = NSFont.systemFont(ofSize: 12)
        vipLabel.isEditable = false
        vipLabel.isBordered = false
        vipLabel.backgroundColor = .clear
        vipLabel.translatesAutoresizingMaskIntoConstraints = false

        // 歌单网格（5个歌单）
        let playlist1 = createPlaylistCard(title: "回忆 九零后最熟悉的音乐记忆", playCount: "1亿", imageName: "music.note.list")
        let playlist2 = createPlaylistCard(title: "90后青春 回忆欧美MP3里的时代音乐", playCount: "6487万", imageName: "globe")
        let playlist3 = createPlaylistCard(title: "80后 回忆经典老歌，青春当年情", playCount: "1.3亿", imageName: "heart")
        let playlist4 = createPlaylistCard(title: "重温经典：那在路边里的千情万种", playCount: "3293万", imageName: "star")
        let playlist5 = createPlaylistCard(title: "经典怀旧音乐：听说光回忆多月之声", playCount: "1.5亿", imageName: "music.mic")

        container.addSubview(titleLabel)
        container.addSubview(vipLabel)
        container.addSubview(playlist1)
        container.addSubview(playlist2)
        container.addSubview(playlist3)
        container.addSubview(playlist4)
        container.addSubview(playlist5)

        NSLayoutConstraint.activate([
            // 标题
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),

            // VIP提示
            vipLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            vipLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            // 歌单网格 (5列)
            playlist1.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            playlist1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            playlist1.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.18),
            playlist1.heightAnchor.constraint(equalToConstant: 240),

            playlist2.leadingAnchor.constraint(equalTo: playlist1.trailingAnchor, constant: 16),
            playlist2.topAnchor.constraint(equalTo: playlist1.topAnchor),
            playlist2.widthAnchor.constraint(equalTo: playlist1.widthAnchor),
            playlist2.heightAnchor.constraint(equalTo: playlist1.heightAnchor),

            playlist3.leadingAnchor.constraint(equalTo: playlist2.trailingAnchor, constant: 16),
            playlist3.topAnchor.constraint(equalTo: playlist1.topAnchor),
            playlist3.widthAnchor.constraint(equalTo: playlist1.widthAnchor),
            playlist3.heightAnchor.constraint(equalTo: playlist1.heightAnchor),

            playlist4.leadingAnchor.constraint(equalTo: playlist3.trailingAnchor, constant: 16),
            playlist4.topAnchor.constraint(equalTo: playlist1.topAnchor),
            playlist4.widthAnchor.constraint(equalTo: playlist1.widthAnchor),
            playlist4.heightAnchor.constraint(equalTo: playlist1.heightAnchor),

            playlist5.leadingAnchor.constraint(equalTo: playlist4.trailingAnchor, constant: 16),
            playlist5.topAnchor.constraint(equalTo: playlist1.topAnchor),
            playlist5.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            playlist5.heightAnchor.constraint(equalTo: playlist1.heightAnchor)
        ])

        return container
    }

    // 歌单卡片
    private func createPlaylistCard(title: String, playCount: String, imageName: String) -> NSView {
        let card = NSView()
        card.translatesAutoresizingMaskIntoConstraints = false

        // 添加点击手势
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(playlistCardClicked(_:)))
        card.addGestureRecognizer(clickGesture)

        // 封面
        let coverView = NSImageView()
        coverView.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        coverView.contentTintColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1)
        coverView.wantsLayer = true
        coverView.layer?.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        coverView.layer?.cornerRadius = 8
        coverView.translatesAutoresizingMaskIntoConstraints = false

        // 播放次数标签
        let playCountLabel = NSTextField(labelWithString: playCount)
        playCountLabel.textColor = .white
        playCountLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        playCountLabel.isEditable = false
        playCountLabel.isBordered = false
        playCountLabel.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        playCountLabel.wantsLayer = true
        playCountLabel.layer?.cornerRadius = 10
        playCountLabel.translatesAutoresizingMaskIntoConstraints = false

        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 13)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.maximumNumberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(coverView)
        card.addSubview(playCountLabel)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            coverView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            coverView.topAnchor.constraint(equalTo: card.topAnchor),
            coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor),

            playCountLabel.trailingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: -8),
            playCountLabel.topAnchor.constraint(equalTo: coverView.topAnchor, constant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        return card
    }

    // MARK: - API数据加载
    private func loadAPIData() {
        print("🎵 开始加载酷狗音乐API数据...")

        // 先加载模拟歌单数据
        hotPlaylists = [
            Playlist(id: "p1", name: "回忆 九零后最熟悉的音乐记忆", coverUrl: "https://picsum.photos/seed/90s/300/300", owner: "官方"),
            Playlist(id: "p2", name: "90后青春 回忆欧美MP3里的时代音乐", coverUrl: "https://picsum.photos/seed/western/300/300", owner: "官方"),
            Playlist(id: "p3", name: "80后 回忆经典老歌，青春当年情", coverUrl: "https://picsum.photos/seed/80s/300/300", owner: "官方"),
            Playlist(id: "p4", name: "重温经典：那在路边里的千情万种", coverUrl: "https://picsum.photos/seed/classic2/300/300", owner: "官方"),
            Playlist(id: "p5", name: "经典怀旧音乐：听说光回忆多月之声", coverUrl: "https://picsum.photos/seed/nostalgic/300/300", owner: "官方")
        ]

        // 调用真实API获取推荐歌曲
        loadSongsFromAPI()
    }

    private func loadSongsFromAPI() {
        guard let url = URL(string: "https://kgmusic-api.vercel.app/search?keyword=流行&pagesize=10") else {
            print("❌ API URL 无效")
            loadFallbackData()
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SimpleAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ API调用失败: \(error)")
                        self?.loadFallbackData()
                    }
                },
                receiveValue: { [weak self] response in
                    self?.recommendedSongs = response.data.info.map { $0.toSong() }
                    print("✅ 成功加载了 \(response.data.info.count) 首推荐歌曲")
                    self?.refreshUI()
                }
            )
            .store(in: &cancellables)
    }

    private func loadFallbackData() {
        print("🔄 加载备用数据...")
        recommendedSongs = [
            Song(id: "1", name: "有点甜", artist: "汪苏泷", album: "有点甜", albumCoverUrl: "https://picsum.photos/seed/sweet/300/300", audioUrl: "https://example.com/sweet.mp3", duration: 215, trackNumber: 1),
            Song(id: "2", name: "冲动的惩罚", artist: "刀郎", album: "2002年的第一场雪", albumCoverUrl: "https://picsum.photos/seed/punishment/300/300", audioUrl: "https://example.com/punishment.mp3", duration: 234, trackNumber: 1),
            Song(id: "3", name: "活着viva", artist: "拉拉", album: "活着", albumCoverUrl: "https://picsum.photos/seed/viva/300/300", audioUrl: "https://example.com/viva.mp3", duration: 203, trackNumber: 1),
            Song(id: "4", name: "经典怀旧音乐", artist: "群星", album: "怀旧金曲", albumCoverUrl: "https://picsum.photos/seed/classic/300/300", audioUrl: "https://example.com/classic.mp3", duration: 180, trackNumber: 1)
        ]
        refreshUI()
    }

    private func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.setupSimpleView()
        }
    }

    // MARK: - 点击事件处理
    @objc private func mainCardClicked() {
        print("🎵 主推荐卡片被点击")
        if let firstSong = recommendedSongs.first {
            onSongSelected?(firstSong)
            print("▶️ 播放歌曲: \(firstSong.name) - \(firstSong.artist)")
        }
    }

    @objc private func smallCardClicked(_ gesture: NSClickGestureRecognizer) {
        print("🎵 小推荐卡片被点击")
        if recommendedSongs.count > 1 {
            let randomIndex = Int.random(in: 1..<recommendedSongs.count)
            let song = recommendedSongs[randomIndex]
            onSongSelected?(song)
            print("▶️ 播放歌曲: \(song.name) - \(song.artist)")
        }
    }

    @objc private func playlistCardClicked(_ gesture: NSClickGestureRecognizer) {
        print("🎵 歌单卡片被点击")
        if let firstPlaylist = hotPlaylists.first {
            print("📂 打开歌单: \(firstPlaylist.name)")
            // TODO: 实现歌单详情页面
        } else {
            print("📂 歌单数据加载中...")
        }
    }

    @objc private func reportLinkClicked() {
        print("📊 查看听歌报告被点击")
        // TODO: 实现听歌报告页面
    }
}


