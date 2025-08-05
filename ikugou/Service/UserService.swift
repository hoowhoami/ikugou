//
//  UserService.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/5.
//

import Foundation

/// 用户信息服务（负责用户状态管理和API交互）
@Observable
class UserService {
    static let shared = UserService()
    private let networkService = NetworkService.shared
    
    // MARK: - 用户状态
    
    /// 当前用户信息
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                // 保存到本地存储
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "userInfo")
                }
                // 同步到网络管理器
                NetworkService.shared.setUserAuth(token: user.token, userid: String(user.userid))
            } else {
                // 清除本地存储和网络认证
                UserDefaults.standard.removeObject(forKey: "userInfo")
                NetworkService.shared.clearUserAuth()
            }
        }
    }
    
    /// 是否已登录
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    private init() {
        // 从本地存储恢复用户信息
        loadUserFromStorage()
    }
    
    // MARK: - 用户状态管理
    
    /// 从本地存储加载用户信息
    private func loadUserFromStorage() {
        if let userData = UserDefaults.standard.data(forKey: "userInfo"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            NetworkService.shared.setUserAuth(token: user.token, userid: String(user.userid))
        }
    }
    
    /// 登录（设置基础用户信息）
    func login(userid: String, token: String, username: String? = nil, avatar: String? = nil) {
        // 将HTTP头像URL转换为HTTPS以符合ATS要求
        let secureAvatar = avatar?.replacingOccurrences(of: "http://", with: "https://")
        
        let newUser = User(
            userid: Int(userid) ?? 0,
            username: username ?? "",
            nickname: username ?? "",
            token: token,
            avatar: secureAvatar
        )
        
        print("UserService.login - 设置基础用户信息: \(newUser)")
        self.currentUser = newUser
    }
    
    /// 更新完整用户信息
    func updateUserInfo(dfid: String? = nil, userDetail: UserDetailResponse.UserDetailData? = nil, vipInfo: UserVipResponse.UserVipData? = nil) {
        guard let user = currentUser else { return }
        
        // 处理头像URL，确保使用HTTPS
        let avatarURL = userDetail?.pic ?? user.avatar
        let secureAvatar = avatarURL?.replacingOccurrences(of: "http://", with: "https://")
        
        // 创建更新后的用户信息
        let updatedUser = User(
            userid: user.userid,
            username: userDetail?.nickname ?? user.username,
            nickname: userDetail?.nickname ?? user.nickname,
            token: user.token,
            avatar: secureAvatar
        )
        
        print("UserService.updateUserInfo - 更新完整用户信息")
        self.currentUser = updatedUser
    }
    
    /// 登出
    func logout() {
        print("UserService.logout - 用户登出")
        self.currentUser = nil
    }
    
    // MARK: - 基础用户信息API
    
    /// 获取设备ID (dfid)
    func getDfid() async throws -> String {
        do {
            let response: DeviceRegisterResponse = try await networkService.get(
                endpoint: "/register/dev",
                responseType: DeviceRegisterResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data.dfid
            } else {
                throw UserServiceError.serverError(response.error_code, "获取设备ID失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    /// 获取用户详细信息
    func getUserDetail() async throws -> UserDetailResponse.UserDetailData {
        do {
            let response: UserDetailResponse = try await networkService.get(
                endpoint: "/user/detail",
                responseType: UserDetailResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw UserServiceError.serverError(response.error_code, "获取用户详细信息失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    /// 获取用户VIP信息
    func getUserVipDetail() async throws -> UserVipResponse.UserVipData {
        do {
            let response: UserVipResponse = try await networkService.get(
                endpoint: "/user/vip/detail",
                responseType: UserVipResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw UserServiceError.serverError(response.error_code, "获取VIP信息失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    // MARK: - 组合方法
    
    /// 获取完整用户信息（登录成功后调用）
    func fetchCompleteUserInfo() async throws -> (dfid: String, userDetail: UserDetailResponse.UserDetailData, vipInfo: UserVipResponse.UserVipData) {
        // 并行获取所有信息
        async let dfidTask = getDfid()
        async let userDetailTask = getUserDetail()
        async let vipInfoTask = getUserVipDetail()
        
        let (dfid, userDetail, vipInfo) = try await (dfidTask, userDetailTask, vipInfoTask)
        
        return (dfid, userDetail, vipInfo)
    }
    
    /// 刷新用户信息（用户点击头像进入个人中心时调用）
    func refreshUserInfo() async throws {
        guard isLoggedIn else {
            throw UserServiceError.userNotLoggedIn
        }
        
        do {
            let (dfid, userDetail, vipInfo) = try await fetchCompleteUserInfo()
            
            // 更新用户信息
            updateUserInfo(
                dfid: dfid,
                userDetail: userDetail,
                vipInfo: vipInfo
            )
            
            print("✅ 用户信息刷新成功")
        } catch {
            print("❌ 刷新用户信息失败: \(error)")
            throw error
        }
    }
    
    /// 完整登录流程（包括获取额外信息）
    func completeLoginProcess(userInfo: User) async throws {
        let userid = String(userInfo.userid)
        let token = userInfo.token
        let username = userInfo.username.isEmpty ? userInfo.nickname : userInfo.username
        let avatar = userInfo.avatar
        
        // 基础登录（已经包含HTTPS转换）
        login(
            userid: userid,
            token: token,
            username: username,
            avatar: avatar
        )
        
        // 获取额外信息
        do {
            let (dfid, userDetail, vipInfo) = try await fetchCompleteUserInfo()
            
            // 更新完整用户信息
            updateUserInfo(
                dfid: dfid,
                userDetail: userDetail,
                vipInfo: vipInfo
            )
            
            print("✅ 完整登录流程完成 - DFID: \(dfid)")
        } catch {
            print("⚠️ 获取额外用户信息失败，但基础登录已完成: \(error)")
            // 即使获取额外信息失败，基础登录仍然有效
        }
    }
}

// MARK: - 用户服务错误类型
enum UserServiceError: Error, LocalizedError {
    case networkError(String)
    case serverError(Int, String?)
    case userNotLoggedIn
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误: \(message)"
        case .serverError(_, let message):
            return message ?? "服务器错误"
        case .userNotLoggedIn:
            return "用户未登录"
        case .unknownError:
            return "未知错误"
        }
    }
}
