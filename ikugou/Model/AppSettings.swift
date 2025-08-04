//
//  AppSettings.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import SwiftUI

/// 外观模式
enum AppearanceMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .system: return "跟随系统"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

/// 用户信息
struct UserInfo: Codable {
    let userid: String
    let token: String
    let username: String?
    let avatar: String?
    
    init(userid: String, token: String, username: String? = nil, avatar: String? = nil) {
        self.userid = userid
        self.token = token
        self.username = username
        self.avatar = avatar
    }
}

/// 应用设置管理器
@Observable
class AppSettings {
    static let shared = AppSettings()
    
    /// 外观模式
    var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }
    
    /// API 基础URL
    var apiBaseURL: String {
        didSet {
            UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        }
    }
    
    /// 用户信息
    var userInfo: UserInfo? {
        didSet {
            if let userInfo = userInfo {
                if let encoded = try? JSONEncoder().encode(userInfo) {
                    UserDefaults.standard.set(encoded, forKey: "userInfo")
                }
                // 同步到网络管理器
                NetworkManager.shared.setUserAuth(token: userInfo.token, userid: userInfo.userid)
            } else {
                UserDefaults.standard.removeObject(forKey: "userInfo")
                NetworkManager.shared.clearUserAuth()
            }
        }
    }
    
    /// 是否已登录
    var isLoggedIn: Bool {
        return userInfo != nil
    }
    
    private init() {
        // 加载外观模式
        let savedAppearance = UserDefaults.standard.string(forKey: "appearanceMode") ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: savedAppearance) ?? .system
        
        // 加载API URL
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://kgmusic-api.vercel.app"
        
        // 加载用户信息
        if let userData = UserDefaults.standard.data(forKey: "userInfo"),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: userData) {
            self.userInfo = userInfo
            NetworkManager.shared.setUserAuth(token: userInfo.token, userid: userInfo.userid)
        } else {
            self.userInfo = nil
        }
    }
    
    /// 登录
    func login(userid: String, token: String, username: String? = nil, avatar: String? = nil) {
        let newUserInfo = UserInfo(userid: userid, token: token, username: username, avatar: avatar)
        self.userInfo = newUserInfo
    }
    
    /// 登出
    func logout() {
        self.userInfo = nil
    }
    
    /// 重置设置
    func resetSettings() {
        self.appearanceMode = .system
        self.apiBaseURL = "https://kgmusic-api.vercel.app"
    }
}
