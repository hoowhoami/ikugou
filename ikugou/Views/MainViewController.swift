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
    
    // 子视图控制器
    private let sidebarViewController = SidebarViewController()
    private let homeViewController = HomeViewController()
    private let searchViewController = SearchViewController()
    private let libraryViewController = LibraryViewController()
    private let playerViewController = PlayerViewController()
    
    // 主内容区域容器
    private let contentContainerView = NSView()
    
    // 用于存储Combine订阅
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupBindings()
        
        // 默认显示首页
        navigate(to: .home)
    }
    
    private func setupView() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        contentContainerView.wantsLayer = true
        contentContainerView.layer?.backgroundColor = NSColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1).cgColor
        
        // 设置侧边栏代理
        sidebarViewController.delegate = self
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
        
        // 设置约束 - 修复了edgesAnchor的问题
        NSLayoutConstraint.activate([
            // 侧边栏约束
            sidebarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarViewController.view.bottomAnchor.constraint(equalTo: playerViewController.view.topAnchor),
            sidebarViewController.view.widthAnchor.constraint(equalToConstant: 240),
            
            // 内容容器约束
            contentContainerView.leadingAnchor.constraint(equalTo: sidebarViewController.view.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: view.topAnchor),
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
            homeViewController.loadData()
        case .search:
            searchViewController.view.isHidden = false
        case .yourLibrary:
            libraryViewController.view.isHidden = false
            libraryViewController.loadData()
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
    

    
