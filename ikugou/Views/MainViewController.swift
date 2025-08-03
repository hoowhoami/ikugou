//
//  MainViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa
import Combine

// 页面类型枚举
enum PageType {
    case home
    case search
    case yourLibrary
    case playlist(id: String)
    case album(id: String)
    case artist(id: String)
}

class MainViewController: NSViewController {
    var coordinator: MainCoordinator?
    private let audioEngine = AudioEngine()  // 使用修正后的AudioEngine

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        print("📱 MainViewController loadView 开始")
        view = NSView()
        print("📱 MainViewController loadView 完成")
    }
    
    // 子视图控制器
    private lazy var sidebarViewController = SidebarViewController()
    private lazy var homeViewController: HomeViewController = {
        let controller = HomeViewController()
        controller.onSongSelected = { [weak self] song in
            self?.playSong(song)
        }
        return controller
    }()
    private lazy var searchViewController = SearchViewController()
    private lazy var libraryViewController = LibraryViewController()
    private lazy var playerViewController = PlayerViewController()
    
    // 主内容区域容器
    private let contentContainerView = NSView()
    
    // 用于存储Combine订阅
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📱 MainViewController viewDidLoad 开始")
        setupView()
        print("📱 setupView 完成")
        setupLayout()
        print("📱 setupLayout 完成")
        setupBindings()
        print("📱 setupBindings 完成")

        // 默认显示首页
        navigate(to: .home)
        print("📱 MainViewController viewDidLoad 完成")
    }
    
    private func setupView() {
        view.wantsLayer = true
        // Spotify 风格的深色背景
        view.layer?.backgroundColor = NSColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1).cgColor

        contentContainerView.wantsLayer = true
        // 主内容区域稍微亮一点的背景
        contentContainerView.layer?.backgroundColor = NSColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1).cgColor

        // 设置侧边栏代理
        sidebarViewController.delegate = self

        // 设置顶部导航栏
        setupTopNavigationBar()
    }

    private func setupTopNavigationBar() {
        // 创建顶部导航栏容器 - QQ音乐风格
        let topNavBar = NSView()
        topNavBar.wantsLayer = true
        topNavBar.layer?.backgroundColor = NSColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1).cgColor
        topNavBar.translatesAutoresizingMaskIntoConstraints = false

        // 用户头像区域
        let userAvatar = NSImageView()
        userAvatar.image = NSImage(systemSymbolName: "person.circle.fill", accessibilityDescription: nil)
        userAvatar.contentTintColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        userAvatar.translatesAutoresizingMaskIntoConstraints = false

        // 用户名标签
        let usernameLabel = NSTextField(labelWithString: "whoami")
        usernameLabel.textColor = .white
        usernameLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false

        // VIP标签
        let vipLabel = NSTextField(labelWithString: "豪华VIP")
        vipLabel.textColor = NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1) // 金色
        vipLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        vipLabel.translatesAutoresizingMaskIntoConstraints = false

        // 前进后退按钮 - QQ音乐风格
        let backButton = NSButton()
        backButton.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
        backButton.bezelStyle = .regularSquare
        backButton.isBordered = false
        backButton.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        let forwardButton = NSButton()
        forwardButton.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
        forwardButton.bezelStyle = .regularSquare
        forwardButton.isBordered = false
        forwardButton.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false

        // 刷新按钮
        let refreshButton = NSButton()
        refreshButton.image = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
        refreshButton.bezelStyle = .regularSquare
        refreshButton.isBordered = false
        refreshButton.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false

        // 搜索框 - QQ音乐风格
        let searchField = NSSearchField()
        searchField.placeholderString = "搜索音乐"
        searchField.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        searchField.textColor = .white
        searchField.wantsLayer = true
        searchField.layer?.cornerRadius = 15
        searchField.layer?.borderWidth = 0
        searchField.isBordered = false
        searchField.focusRingType = .none
        searchField.translatesAutoresizingMaskIntoConstraints = false

        // 右侧功能按钮
        let skinButton = NSButton()
        skinButton.image = NSImage(systemSymbolName: "paintbrush.fill", accessibilityDescription: nil)
        skinButton.bezelStyle = .regularSquare
        skinButton.isBordered = false
        skinButton.contentTintColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1) // QQ音乐绿色
        skinButton.translatesAutoresizingMaskIntoConstraints = false

        let settingsButton = NSButton()
        settingsButton.image = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
        settingsButton.bezelStyle = .regularSquare
        settingsButton.isBordered = false
        settingsButton.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false

        // 添加到导航栏
        topNavBar.addSubview(userAvatar)
        topNavBar.addSubview(usernameLabel)
        topNavBar.addSubview(vipLabel)
        topNavBar.addSubview(backButton)
        topNavBar.addSubview(forwardButton)
        topNavBar.addSubview(refreshButton)
        topNavBar.addSubview(searchField)
        topNavBar.addSubview(skinButton)
        topNavBar.addSubview(settingsButton)

        // 添加到主视图
        view.addSubview(topNavBar)

        // 设置约束
        NSLayoutConstraint.activate([
            // 导航栏约束
            topNavBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topNavBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topNavBar.heightAnchor.constraint(equalToConstant: 48),

            // 用户头像
            userAvatar.leadingAnchor.constraint(equalTo: topNavBar.leadingAnchor, constant: 16),
            userAvatar.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            userAvatar.widthAnchor.constraint(equalToConstant: 32),
            userAvatar.heightAnchor.constraint(equalToConstant: 32),

            // 用户名
            usernameLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: userAvatar.topAnchor, constant: 2),

            // VIP标签
            vipLabel.leadingAnchor.constraint(equalTo: userAvatar.trailingAnchor, constant: 8),
            vipLabel.bottomAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: -2),

            // 后退按钮
            backButton.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 24),
            backButton.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            // 前进按钮
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            forwardButton.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalToConstant: 24),
            forwardButton.heightAnchor.constraint(equalToConstant: 24),

            // 刷新按钮
            refreshButton.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 8),
            refreshButton.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 24),
            refreshButton.heightAnchor.constraint(equalToConstant: 24),

            // 搜索框
            searchField.leadingAnchor.constraint(equalTo: refreshButton.trailingAnchor, constant: 24),
            searchField.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            searchField.widthAnchor.constraint(equalToConstant: 250),
            searchField.heightAnchor.constraint(equalToConstant: 30),

            // 右侧按钮
            settingsButton.trailingAnchor.constraint(equalTo: topNavBar.trailingAnchor, constant: -16),
            settingsButton.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalToConstant: 24),

            skinButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -12),
            skinButton.centerYAnchor.constraint(equalTo: topNavBar.centerYAnchor),
            skinButton.widthAnchor.constraint(equalToConstant: 24),
            skinButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupLayout() {
        // 添加子视图控制器
        addChild(sidebarViewController)
        addChild(homeViewController)
        addChild(searchViewController)
        addChild(libraryViewController)
        addChild(playerViewController)
        
        // 添加视图到主视图
        view.addSubview(sidebarViewController.view)
        view.addSubview(contentContainerView)
        view.addSubview(playerViewController.view)
        
        // 禁用 autoresizing mask
        sidebarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加主内容区域的子视图
        contentContainerView.addSubview(homeViewController.view)
        contentContainerView.addSubview(searchViewController.view)
        contentContainerView.addSubview(libraryViewController.view)

        homeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        searchViewController.view.translatesAutoresizingMaskIntoConstraints = false
        libraryViewController.view.translatesAutoresizingMaskIntoConstraints = false

        // 初始隐藏所有内容视图
        homeViewController.view.isHidden = true
        searchViewController.view.isHidden = true
        libraryViewController.view.isHidden = true
        
        // 设置约束 - Spotify 风格布局，为标题栏留出空间
        NSLayoutConstraint.activate([
            // 侧边栏约束 - 为顶部导航栏留出空间
            sidebarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            sidebarViewController.view.bottomAnchor.constraint(equalTo: playerViewController.view.topAnchor),
            sidebarViewController.view.widthAnchor.constraint(equalToConstant: 280), // 稍微宽一点，像 Spotify

            // 内容容器约束 - 也为导航栏留出空间
            contentContainerView.leadingAnchor.constraint(equalTo: sidebarViewController.view.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: playerViewController.view.topAnchor),
            
            // 主内容区域子视图约束 - 分别设置四个边，替代edgesAnchor
            // 首页视图
            homeViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            homeViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            homeViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            homeViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            // 搜索视图
            searchViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            searchViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            searchViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            searchViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            // 媒体库视图
            libraryViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            libraryViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            libraryViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            libraryViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            
            // 播放器约束
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerViewController.view.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setupBindings() {
        // 绑定播放器事件
        playerViewController.playPauseAction = { [weak self] in
            guard let self = self else { return }
            if self.audioEngine.isPlaying {
                self.audioEngine.pause()
            } else {
                self.audioEngine.resume()
            }
        }
        
        playerViewController.nextAction = { [weak self] in
            self?.audioEngine.next()
        }
        
        playerViewController.previousAction = { [weak self] in
            self?.audioEngine.previous()
        }
        
        playerViewController.seekAction = { [weak self] time in
            self?.audioEngine.seek(to: time)
        }
        
        playerViewController.volumeAction = { [weak self] volume in
            self?.audioEngine.setVolume(volume)
        }
        
        playerViewController.repeatAction = { [weak self] in
            self?.audioEngine.toggleRepeatMode()
        }
        
        playerViewController.shuffleAction = { [weak self] in
            self?.audioEngine.toggleShuffle()
        }
        
        // 监听播放状态变化
        audioEngine.$currentSong
            .receive(on: DispatchQueue.main)
            .sink { [weak self] song in
                if let song = song {
                    self?.playerViewController.update(with: song)
                }
            }
            .store(in: &cancellables)
        
        audioEngine.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.playerViewController.updatePlayPauseState(isPlaying: isPlaying)
            }
            .store(in: &cancellables)
        
        audioEngine.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.playerViewController.updateProgress(time: time)
            }
            .store(in: &cancellables)
    }
    
    // 导航到不同页面
    func navigate(to page: PageType) {
        // 隐藏所有内容视图
        homeViewController.view.isHidden = true
        searchViewController.view.isHidden = true
        libraryViewController.view.isHidden = true
        
        // 显示选中的视图
        switch page {
        case .home:
            homeViewController.view.isHidden = false
            // homeViewController.loadData()  // 暂时注释掉
        case .search:
            searchViewController.view.isHidden = false
        case .yourLibrary:
            libraryViewController.view.isHidden = false
            // libraryViewController.loadData()  // 暂时注释掉
        case .playlist(let id):
            // 这里可以导航到播放列表详情页
            print("导航到播放列表: \(id)")
        case .album(let id):
            // 这里可以导航到专辑详情页
            print("导航到专辑: \(id)")
        case .artist(let id):
            // 这里可以导航到艺术家详情页
            print("导航到艺术家: \(id)")
        }
    }
    
    // 播放指定歌曲
    func playSong(_ song: Song, in playlist: [Song] = []) {
        audioEngine.play(song: song, playlist: playlist)
    }
    
    // 切换播放/暂停
    func togglePlayPause() {
        if audioEngine.isPlaying {
            audioEngine.pause()
        } else {
            audioEngine.resume()
        }
    }
}

// 实现侧边栏代理
extension MainViewController: SidebarViewControllerDelegate {
    func sidebarDidSelectItem(_ item: SidebarItem) {
        switch item.type {
        case .home:
            coordinator?.navigate(to: .home)
        case .search:
            coordinator?.navigate(to: .search)
        case .yourLibrary:
            coordinator?.navigate(to: .yourLibrary)
        case .playlist(let id):
            coordinator?.navigate(to: .playlist(id: id))
        }
    }
}
    

    
