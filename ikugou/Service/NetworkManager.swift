//
//  NetworkManager.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/4.
//

import Foundation
import Combine

/// 网络错误类型
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .decodingError:
            return "数据解析错误"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

/// 用户认证信息
struct UserAuth {
    let token: String
    let userid: String
}

/// 网络管理器
@Observable
class NetworkManager {
    static let shared = NetworkManager()
    
    /// 基础URL
    private let baseURL = "https://kgmusic-api.vercel.app"
    
    /// 用户认证信息
    var userAuth: UserAuth?
    
    /// URLSession
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: config)
    }
    
    /// 构建完整URL
    private func buildURL(endpoint: String, params: [String: String] = [:]) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint) else {
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
        
        // 添加认证参数
        if let auth = userAuth {
            let cookieValue = "token=\(auth.token);userid=\(auth.userid)"
            queryItems.append(URLQueryItem(name: "cookie", value: cookieValue))
        }
        
        // 添加其他参数
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    /// 创建请求
    private func createRequest(url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    /// 执行网络请求
    private func performRequest<T: Codable>(
        request: URLRequest,
        responseType: T.Type
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}

/// HTTP方法枚举
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - 网络请求方法扩展
extension NetworkManager {
    /// GET 请求
    func get<T: Codable>(
        endpoint: String,
        params: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, params: params) else {
            throw NetworkError.invalidURL
        }
        
        let request = createRequest(url: url, method: .GET)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    /// POST 请求
    func post<T: Codable, U: Codable>(
        endpoint: String,
        params: [String: String] = [:],
        body: U? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, params: params) else {
            throw NetworkError.invalidURL
        }
        
        var requestBody: Data?
        if let body = body {
            requestBody = try JSONEncoder().encode(body)
        }
        
        let request = createRequest(url: url, method: .POST, body: requestBody)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    /// PUT 请求
    func put<T: Codable, U: Codable>(
        endpoint: String,
        params: [String: String] = [:],
        body: U? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, params: params) else {
            throw NetworkError.invalidURL
        }
        
        var requestBody: Data?
        if let body = body {
            requestBody = try JSONEncoder().encode(body)
        }
        
        let request = createRequest(url: url, method: .PUT, body: requestBody)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    /// DELETE 请求
    func delete<T: Codable>(
        endpoint: String,
        params: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, params: params) else {
            throw NetworkError.invalidURL
        }
        
        let request = createRequest(url: url, method: .DELETE)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    /// 设置用户认证信息
    func setUserAuth(token: String, userid: String) {
        self.userAuth = UserAuth(token: token, userid: userid)
    }
    
    /// 清除用户认证信息
    func clearUserAuth() {
        self.userAuth = nil
    }
}
