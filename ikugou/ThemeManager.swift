//
//  ThemeManager.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import Cocoa
import SwiftUI

class ThemeManager: NSObject {
    static let shared = ThemeManager()
    private let config = AppConfig.shared
    
    // 当前应用的主题模式
    private(set) var currentMode: AppConfig.ThemeConfig.Mode {
        get {
            if let savedMode = UserDefaults.standard.string(forKey: "UserSelectedTheme"),
               let mode = AppConfig.ThemeConfig.Mode(rawValue: savedMode) {
                return mode
            }
            return config.theme?.defaultMode ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "UserSelectedTheme")
            applyCurrentTheme()
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    override init() {
        super.init()
        
        // 使用字符串形式的通知名称以确保兼容性
        // 针对macOS 10.14+的外观变化通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: NSNotification.Name("NSApplicationAppearanceDidChangeNotification"),
            object: nil
        )
        
        // 针对旧版本系统的屏幕参数变化通知（间接监听主题变化）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: NSNotification.Name("NSWindowDidChangeScreenParametersNotification"),
            object: nil
        )
        
        applyCurrentTheme()
    }
    
    // 系统主题变化时触发
    @objc private func systemThemeChanged() {
        if currentMode == .system {
            applyCurrentTheme()
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    // 应用当前主题
    private func applyCurrentTheme() {
        let appearance: NSAppearance.Name
        switch currentMode {
        case .system:
            appearance = NSApp.effectiveAppearance.name
        case .light:
            appearance = .aqua
        case .dark:
            appearance = .darkAqua
        }
        
        NSApp.appearance = NSAppearance(named: appearance)
        
        if config.theme?.animateTransitions == true {
            NSApp.windows.forEach { $0.animator().appearance = NSApp.appearance }
        }
    }
    
    // 切换主题模式
    func switchMode(to mode: AppConfig.ThemeConfig.Mode) {
        currentMode = mode
    }
}

// 主题变化通知
extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeDidChangeNotification")
}

// SwiftUI视图扩展
extension View {
    func onThemeChange(perform action: @escaping () -> Void) -> some View {
        self
            .onAppear(perform: action)
            .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
                action()
            }
    }
    
    var isDarkMode: Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}




