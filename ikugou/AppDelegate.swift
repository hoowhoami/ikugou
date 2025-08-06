//
//  AppDelegate.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            configureWindow(window)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 应用即将终止时，确保保存播放状态
        // 注意：这里我们需要通过全局方式访问PlayerService，但由于架构限制，
        // 主要的保存操作已经在每次状态变更时进行，所以这里只是额外的保障
        UserDefaults.standard.synchronize()
    }
    
    private func configureWindow(_ window: NSWindow) {
        // 保持原生窗口样式，但隐藏标题并使标题栏透明
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor.windowBackgroundColor

        // 隐藏原生标题栏的标题文本
        window.title = ""

        // 确保标题栏完全透明
        if let titlebarView = window.standardWindowButton(.closeButton)?.superview {
            titlebarView.wantsLayer = true
            titlebarView.layer?.backgroundColor = NSColor.clear.cgColor
        }

        // window.setContentSize(NSSize(width: 1024, height: 600))
    }
}
