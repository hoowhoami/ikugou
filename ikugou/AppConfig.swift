//
//  AppConfig.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import AppKit
import Foundation

class AppConfig {
    static let shared = AppConfig()
    private init() { loadConfig() }
        
    // 1. API配置
    struct APIConfig {
        let baseURL: String
        let timeout: TimeInterval
        let enableCache: Bool
        let userAgent: String
    }
        
    // 2. 主题配置
    struct ThemeConfig {
        enum Mode: String {
            case system, light, dark
        }

        let defaultMode: Mode
        let accentColorLight: String
        let accentColorDark: String
        let allowUserChange: Bool
        let animateTransitions: Bool
    }
        
    var api: APIConfig!
    var theme: ThemeConfig!
        
    // 从plist加载配置
    private func loadConfig() {
        // 获取配置文件路径（优先使用Documents目录中的修改版，没有则用Bundle中的默认版）
        let defaultPath = Bundle.main.path(forResource: "AppConfig", ofType: "plist")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writablePath = documentsPath + "/AppConfig.plist"
            
        // 确定最终使用的路径
        let path: String?
        if FileManager.default.fileExists(atPath: writablePath) {
            path = writablePath
        } else {
            path = defaultPath
        }
            
        guard let configPath = path,
              let rootDict = NSDictionary(contentsOfFile: configPath) as? [String: Any]
        else {
            // 加载失败时使用默认配置
            setDefaultConfig()
            return
        }
            
        // 解析API配置
        if let apiDict = rootDict["API"] as? [String: Any] {
            api = APIConfig(
                baseURL: apiDict["BaseURL"] as? String ?? "http://localhost:3000",
                timeout: TimeInterval(apiDict["Timeout"] as? Int ?? 15),
                enableCache: apiDict["EnableCache"] as? Bool ?? true,
                userAgent: apiDict["UserAgent"] as? String ?? "iKugou/1.0.0 (macOS)"
            )
        } else {
            api = APIConfig(
                baseURL: "http://localhost:3000",
                timeout: 15,
                enableCache: true,
                userAgent: "iKugou/1.0.0 (macOS)"
            )
        }
            
        // 解析主题配置
        if let themeDict = rootDict["Theme"] as? [String: Any] {
            theme = ThemeConfig(
                defaultMode: ThemeConfig.Mode(rawValue: themeDict["DefaultMode"] as? String ?? "system") ?? .system,
                accentColorLight: themeDict["AccentColorLight"] as? String ?? "#FF5722",
                accentColorDark: themeDict["AccentColorDark"] as? String ?? "#FF7A45",
                allowUserChange: themeDict["AllowUserChange"] as? Bool ?? true,
                animateTransitions: themeDict["AnimateTransitions"] as? Bool ?? true
            )
        } else {
            theme = ThemeConfig(
                defaultMode: .system,
                accentColorLight: "#FF5722",
                accentColorDark: "#FF7A45",
                allowUserChange: true,
                animateTransitions: true
            )
        }
    }
        
    // 设置默认配置（当配置文件加载失败时）
    private func setDefaultConfig() {
        api = APIConfig(
            baseURL: "http://localhost:3000",
            timeout: 15,
            enableCache: true,
            userAgent: "iKugou/1.0.0 (macOS)"
        )
            
        theme = ThemeConfig(
            defaultMode: .system,
            accentColorLight: "#FF5722",
            accentColorDark: "#FF7A45",
            allowUserChange: true,
            animateTransitions: true
        )
    }
        
    // 新增：保存主题配置到文件
    func saveThemeConfig(mode: ThemeConfig.Mode, animateTransitions: Bool) {
        // 获取可写路径
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writablePath = documentsPath + "/AppConfig.plist"
            
        // 读取现有配置（如果不存在则创建新字典）
        let rootDict = NSMutableDictionary(contentsOfFile: writablePath) ?? NSMutableDictionary()
            
        // 确保Theme字典存在
        let themeDict = rootDict["Theme"] as? NSMutableDictionary ?? NSMutableDictionary()
            
        // 更新主题配置
        themeDict["DefaultMode"] = mode.rawValue
        themeDict["AnimateTransitions"] = animateTransitions
        // 保留其他主题配置（如颜色、是否允许修改等）
        if theme != nil {
            themeDict["AccentColorLight"] = theme.accentColorLight
            themeDict["AccentColorDark"] = theme.accentColorDark
            themeDict["AllowUserChange"] = theme.allowUserChange
        }
            
        // 保存回根字典
        rootDict["Theme"] = themeDict
            
        // 写入文件
        rootDict.write(toFile: writablePath, atomically: true)
            
        // 重新加载配置
        loadConfig()
    }
        
    // 新增：保存API配置到文件
    func saveAPIConfig(baseURL: String, timeout: TimeInterval, enableCache: Bool) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writablePath = documentsPath + "/AppConfig.plist"
            
        let rootDict = NSMutableDictionary(contentsOfFile: writablePath) ?? NSMutableDictionary()
        let apiDict = rootDict["API"] as? NSMutableDictionary ?? NSMutableDictionary()
            
        apiDict["BaseURL"] = baseURL
        apiDict["Timeout"] = Int(timeout)
        apiDict["EnableCache"] = enableCache
        if api != nil {
            apiDict["UserAgent"] = api.userAgent
        }
            
        rootDict["API"] = apiDict
        rootDict.write(toFile: writablePath, atomically: true)
            
        loadConfig()
    }
}

// 扩展用于将十六进制颜色字符串转换为NSColor
extension NSColor {
    convenience init(hex: String) {
        // 移除#符号
        let hexString = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var hexNumber: UInt64 = 0

        // 解析十六进制字符串
        Scanner(string: hexString).scanHexInt64(&hexNumber)

        // 提取RGBA值
        let red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
        let alpha = hexString.count == 8 ? CGFloat(hexNumber & 0x000000FF) / 255.0 : 1.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
