//
//  LoginService.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/5.
//

import Foundation

/// 登录服务
class LoginService {
    static let shared = LoginService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    /// 发送验证码
    func sendCaptcha(mobile: String) async throws {
        // 验证手机号格式
        guard isValidMobile(mobile) else {
            throw LoginError.invalidMobile
        }
        
        do {
            let response: CaptchaResponse = try await networkManager.get(
                endpoint: "/captcha/sent",
                params: ["mobile": mobile],
                responseType: CaptchaResponse.self
            )
            
            if response.status != 1 {
                throw LoginError.serverError(response.error_code, "发送验证码失败")
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 手机号验证码登录
    func loginWithMobile(mobile: String, code: String) async throws -> LoginResponse.LoginData {
        // 验证输入
        guard isValidMobile(mobile) else {
            throw LoginError.invalidMobile
        }
        
        guard !code.isEmpty else {
            throw LoginError.invalidCode
        }
        
        do {
            let response: LoginResponse = try await networkManager.get(
                endpoint: "/login/cellphone",
                params: [
                    "mobile": mobile,
                    "code": code
                ],
                responseType: LoginResponse.self
            )
            
            if response.code == 200, let data = response.data {
                return data
            } else {
                throw LoginError.serverError(response.code, response.message)
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 用户名密码登录
    func loginWithUsername(username: String, password: String) async throws -> LoginResponse.LoginData {
        // 验证输入
        guard !username.isEmpty, !password.isEmpty else {
            throw LoginError.invalidCredentials
        }
        
        // 对密码进行URL编码
        guard let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw LoginError.invalidCredentials
        }
        
        do {
            let response: LoginResponse = try await networkManager.get(
                endpoint: "/login",
                params: [
                    "username": username,
                    "password": encodedPassword
                ],
                responseType: LoginResponse.self
            )
            
            if response.code == 200, let data = response.data {
                return data
            } else {
                throw LoginError.serverError(response.code, response.message)
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    // MARK: - 二维码登录方法
    
    /// 生成二维码（合并key生成和二维码创建）
    func generateQRCode() async throws -> (key: String, qrimg: String?) {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        
        do {
            let response: QRKeyResponse = try await networkManager.get(
                endpoint: "/login/qr/key",
                params: ["timestamp": timestamp],
                responseType: QRKeyResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return (data.qrcode, data.qrcode_img)
            } else {
                throw LoginError.serverError(response.error_code, "生成二维码失败")
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 检查二维码状态
    func checkQRStatus(key: String) async throws -> QRCheckResponse {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        
        do {
            let response: QRCheckResponse = try await networkManager.get(
                endpoint: "/login/qr/check",
                params: [
                    "key": key,
                    "timestamp": timestamp
                ],
                responseType: QRCheckResponse.self
            )
            
            return response
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    // MARK: - 私有方法
    
    /// 验证手机号格式
    private func isValidMobile(_ mobile: String) -> Bool {
        let mobileRegex = "^1[3-9]\\d{9}$"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobilePredicate.evaluate(with: mobile)
    }
    
    // MARK: - 用户信息获取方法
    
    /// 注册设备获取dfid
    func registerDevice() async throws -> String {
        do {
            let response: DeviceRegisterResponse = try await networkManager.get(
                endpoint: "/register/dev",
                responseType: DeviceRegisterResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data.dfid
            } else {
                throw LoginError.serverError(response.error_code, "获取设备ID失败")
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 获取用户详细信息
    func getUserDetail() async throws -> UserDetailResponse.UserDetailData {
        do {
            let response: UserDetailResponse = try await networkManager.get(
                endpoint: "/user/detail",
                responseType: UserDetailResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw LoginError.serverError(response.error_code, "获取用户详细信息失败")
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 获取用户VIP信息
    func getUserVip() async throws -> UserVipResponse.UserVipData {
        do {
            let response: UserVipResponse = try await networkManager.get(
                endpoint: "/user/vip/detail",
                responseType: UserVipResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw LoginError.serverError(response.error_code, "获取VIP信息失败")
            }
        } catch let error as NetworkError {
            throw LoginError.networkError(error.localizedDescription)
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.unknownError
        }
    }
    
    /// 完整登录流程（包括获取额外信息）
    func completeLoginProcess(loginData: LoginResponse.LoginData) async throws {
        let userid = loginData.userid ?? loginData.profile?.userId?.description ?? ""
        let token = loginData.token ?? ""
        let username = loginData.username ?? loginData.profile?.nickname
        let avatar = loginData.avatar ?? loginData.profile?.avatarUrl
        
        // 将HTTP头像URL转换为HTTPS以符合ATS要求
        let secureAvatar = avatar?.replacingOccurrences(of: "http://", with: "https://")
        
        // 基础登录
        AppSettings.shared.login(
            userid: userid,
            token: token,
            username: username,
            avatar: secureAvatar
        )
        
        // 并行获取额外信息
        async let dfidTask = registerDevice()
        async let userDetailTask = getUserDetail()
        async let vipInfoTask = getUserVip()
        
        do {
            let (dfid, userDetail, vipInfo) = try await (dfidTask, userDetailTask, vipInfoTask)
            
            // 更新完整用户信息
            AppSettings.shared.updateUserInfo(
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