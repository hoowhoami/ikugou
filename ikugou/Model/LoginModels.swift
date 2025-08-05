//
//  LoginModels.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/5.
//

import Foundation

// MARK: - 登录方式枚举
enum LoginType {
    case mobile     // 手机验证码登录
    case username   // 用户名密码登录
    case qrcode     // 扫码登录（暂未实现）
}

// MARK: - 登录请求模型
struct MobileLoginRequest: Codable {
    let mobile: String
    let code: String
}

struct UsernameLoginRequest: Codable {
    let username: String
    let password: String
}

struct CaptchaSendRequest: Codable {
    let mobile: String
}

// MARK: - 二维码登录请求模型
struct QRKeyRequest: Codable {
    let timestamp: String
}

struct QRCreateRequest: Codable {
    let key: String
    let qrimg: String?
    let timestamp: String
}

struct QRCheckRequest: Codable {
    let key: String
    let timestamp: String
}

// MARK: - 登录响应模型
struct LoginResponse: Codable {
    let code: Int
    let message: String?
    let data: LoginData?
    
    struct LoginData: Codable {
        let token: String?
        let userid: String?
        let username: String?
        let avatar: String?
        let profile: UserProfile?
    }
    
    struct UserProfile: Codable {
        let userId: Int?
        let nickname: String?
        let avatarUrl: String?
    }
}

// MARK: - 验证码发送响应模型
struct CaptchaResponse: Codable {
    let status: Int
    let error_code: Int
    let data: CaptchaData?
    
    struct CaptchaData: Codable {
        let count: Int
    }
}

// MARK: - 二维码登录响应模型
struct QRKeyResponse: Codable {
    let status: Int
    let error_code: Int
    let data: QRKeyData?
    
    struct QRKeyData: Codable {
        let qrcode: String
        let qrcode_img: String?
    }
}

struct QRCreateResponse: Codable {
    let code: Int
    let data: QRCreateData?
    
    struct QRCreateData: Codable {
        let url: String
        let base64: String?
    }
}

struct QRCheckResponse: Codable {
    let status: Int
    let error_code: Int
    let data: QRCheckData?
    
    struct QRCheckData: Codable {
        let nickname: String?
        let pic: String?
        let token: String?
        let userid: Int?
        let status: Int
    }
}

// MARK: - 二维码状态枚举
enum QRCodeStatus: Int {
    case expired = 0     // 二维码过期
    case waiting = 1     // 等待扫码
    case scanned = 2     // 已扫码，待确认
    case confirmed = 4   // 授权登录成功
    
    var description: String {
        switch self {
        case .expired:
            return "二维码已过期"
        case .waiting:
            return "等待扫码"
        case .scanned:
            return "已扫码，请在手机上确认"
        case .confirmed:
            return "登录成功"
        }
    }
}

// MARK: - 登录错误类型
enum LoginError: Error, LocalizedError {
    case invalidMobile
    case invalidCode
    case invalidCredentials
    case networkError(String)
    case serverError(Int, String?)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidMobile:
            return "请输入正确的手机号码"
        case .invalidCode:
            return "请输入正确的验证码"
        case .invalidCredentials:
            return "用户名或密码错误"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .serverError(_, let message):
            return message ?? "服务器错误"
        case .unknownError:
            return "未知错误"
        }
    }
}

// MARK: - 设备注册响应模型
struct DeviceRegisterResponse: Codable {
    let status: Int
    let error_code: Int
    let data: DeviceRegisterData?
    
    struct DeviceRegisterData: Codable {
        let dfid: String
    }
}

// MARK: - 用户详细信息响应模型
struct UserDetailResponse: Codable {
    let status: Int
    let error_code: Int
    let data: UserDetailData?
    
    struct UserDetailData: Codable {
        let userid: Int?
        let username: String?
        let nickname: String?
        let avatar: String?
        let signature: String?
        let sex: Int?
        let birthday: String?
        let province: String?
        let city: String?
        let fans_count: Int?
        let follow_count: Int?
        let song_count: Int?
        let playlist_count: Int?
    }
}

// MARK: - 用户VIP信息响应模型
struct UserVipResponse: Codable {
    let status: Int
    let error_code: Int
    let data: UserVipData?
    
    struct UserVipData: Codable {
        let vip_type: Int?
        let vip_level: Int?
        let vip_expire_time: String?
        let is_vip: Bool?
        let vip_name: String?
    }
}