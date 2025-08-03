//
//  MainCoordinator.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

class MainCoordinator {
    private let window: NSWindow
    private var mainViewController: MainViewController!
    
    init(window: NSWindow) {
        self.window = window
    }
    
    func start() {
        // 初始化主视图控制器
        mainViewController = MainViewController()
        mainViewController.coordinator = self
        
        // 设置为窗口内容视图
        window.contentViewController = mainViewController
    }
    
    // 导航到不同页面
    func navigate(to page: PageType) {
        mainViewController.navigate(to: page)
    }
    
    // 播放指定歌曲
    func playSong(_ song: Song) {
        mainViewController.playSong(song)
    }
    
    // 切换播放状态
    func togglePlayPause() {
        mainViewController.togglePlayPause()
    }
}
    
