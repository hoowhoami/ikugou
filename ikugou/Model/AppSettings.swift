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
    
    // 扩展信息
    let dfid: String?
    let nickname: String?
    let signature: String?
    let sex: Int?
    let birthday: String?
    let province: String?
    let city: String?
    let fans_count: Int?
    let follow_count: Int?
    let song_count: Int?
    let playlist_count: Int?
    
    // VIP信息
    let vip_type: Int?
    let vip_level: Int?
    let vip_expire_time: String?
    let is_vip: Bool?
    let vip_name: String?
    
    init(userid: String, token: String, username: String? = nil, avatar: String? = nil,
         dfid: String? = nil, nickname: String? = nil, signature: String? = nil,
         sex: Int? = nil, birthday: String? = nil, province: String? = nil, city: String? = nil,
         fans_count: Int? = nil, follow_count: Int? = nil, song_count: Int? = nil, playlist_count: Int? = nil,
         vip_type: Int? = nil, vip_level: Int? = nil, vip_expire_time: String? = nil,
         is_vip: Bool? = nil, vip_name: String? = nil) {
        self.userid = userid
        self.token = token
        self.username = username
        self.avatar = avatar
        
        self.dfid = dfid
        self.nickname = nickname
        self.signature = signature
        self.sex = sex
        self.birthday = birthday
        self.province = province
        self.city = city
        self.fans_count = fans_count
        self.follow_count = follow_count
        self.song_count = song_count
        self.playlist_count = playlist_count
        
        self.vip_type = vip_type
        self.vip_level = vip_level
        self.vip_expire_time = vip_expire_time
        self.is_vip = is_vip
        self.vip_name = vip_name
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
        print("AppSettings.login - 设置基础用户信息: \(newUserInfo)")
        self.userInfo = newUserInfo
    }
    
    /// 更新完整用户信息
    func updateUserInfo(dfid: String? = nil, userDetail: UserDetailResponse.UserDetailData? = nil, vipInfo: UserVipResponse.UserVipData? = nil) {
        guard let currentUser = userInfo else { return }
        
        let updatedUserInfo = UserInfo(
            userid: currentUser.userid,
            token: currentUser.token,
            username: userDetail?.username ?? currentUser.username,
            avatar: userDetail?.avatar ?? currentUser.avatar,
            dfid: dfid ?? currentUser.dfid,
            nickname: userDetail?.nickname ?? currentUser.nickname,
            signature: userDetail?.signature ?? currentUser.signature,
            sex: userDetail?.sex ?? currentUser.sex,
            birthday: userDetail?.birthday ?? currentUser.birthday,
            province: userDetail?.province ?? currentUser.province,
            city: userDetail?.city ?? currentUser.city,
            fans_count: userDetail?.fans_count ?? currentUser.fans_count,
            follow_count: userDetail?.follow_count ?? currentUser.follow_count,
            song_count: userDetail?.song_count ?? currentUser.song_count,
            playlist_count: userDetail?.playlist_count ?? currentUser.playlist_count,
            vip_type: vipInfo?.vip_type ?? currentUser.vip_type,
            vip_level: vipInfo?.vip_level ?? currentUser.vip_level,
            vip_expire_time: vipInfo?.vip_expire_time ?? currentUser.vip_expire_time,
            is_vip: vipInfo?.is_vip ?? currentUser.is_vip,
            vip_name: vipInfo?.vip_name ?? currentUser.vip_name
        )
        
        print("AppSettings.updateUserInfo - 更新完整用户信息")
        self.userInfo = updatedUserInfo
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
