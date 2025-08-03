//
//  AppDelegate.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var mainCoordinator: MainCoordinator!
    private let audioEngine = AVAudioEngine()  // 音频引擎实例
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建主窗口
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1200, height: 800),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Spotify"
        window.setFrameAutosaveName("Main Window")
        
        // 设置主协调器
        mainCoordinator = MainCoordinator(window: window)
        mainCoordinator.start()
        
        window.makeKeyAndOrderFront(nil)
        
        // 配置音频环境（macOS 方式）
        configureAudioEnvironment()
    }
    
    // 配置 macOS 音频环境
    private func configureAudioEnvironment() {
        // 启动音频引擎作为音频环境的基础配置
        do {
            try audioEngine.start()
            print("音频引擎启动成功")
        } catch {
            print("音频引擎启动失败: \(error.localizedDescription)")
        }
        
        // 请求音频访问权限（对于现代 macOS 版本）
        if #available(macOS 10.14, *) {
            if #available(macOS 14.0, *) {
                AVAudioApplication.requestRecordPermission { _ in
                    // 在 macOS 中播放音频通常通常不需要不需要录音权限，但请求一下更保险
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 停止音频引擎并清理资源
        audioEngine.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window.makeKeyAndOrderFront(nil)
        return true
    }
}
    
    
