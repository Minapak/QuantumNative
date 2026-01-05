//
//  APIClient.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine

// MARK: - API Configuration
class APIClient: ObservableObject {
    
    // MARK: - Singleton
    static let shared = APIClient()
    
    // MARK: - Properties
    @Published var accessToken: String? {
        didSet {
            if let token = accessToken {
                KeychainService.shared.saveToken(token)
            }
        }
    }
    
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // API Base URL
    private let baseURL: String
    private let session: URLSession
    
    // MARK: - Initialization
    private init() {
        #if DEBUG
        // iOS 시뮬레이터에서 Mac 서버에 접속
        // Mac IP: 172.30.1.68
        self.baseURL = "http://172.30.1.68:8000"
        #else
        self.baseURL = ProcessInfo.processInfo.environment["API_URL"] ?? "http://localhost:8000"
        #endif
        
        print("🔧 APIClient baseURL: \(self.baseURL)")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
        
        if let savedToken = KeychainService.shared.getToken() {
            self.accessToken = savedToken
            self.isLoggedIn = true
        }
    }
    // MARK: - HTTP Methods
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Authorization header
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        if let customHeaders = headers {
            customHeaders.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        print("🌐 API Request: \(method.rawValue) \(endpoint)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📊 API Response: \(httpResponse.statusCode)")
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
            
        case 401:
            // Unauthorized - clear token
            self.accessToken = nil
            self.isLoggedIn = false
            throw APIError.unauthorized
            
        case 404:
            throw APIError.notFound
            
        case 500...599:
            throw APIError.serverError(code: httpResponse.statusCode)
            
        default:
            let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.custom(error?.detail ?? "Unknown error")
        }
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .get)
    }
    
    func post<T: Decodable>(
        endpoint: String,
        body: Encodable
    ) async throws -> T {
        try await request(endpoint: endpoint, method: .post, body: body)
    }
    
    func put<T: Decodable>(
        endpoint: String,
        body: Encodable
    ) async throws -> T {
        try await request(endpoint: endpoint, method: .put, body: body)
    }
    
    func delete<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .delete)
    }

    // MARK: - Payment Verification

    /// 결제 영수증 검증 (서버 사이드 검증)
    func verifyReceipt(receiptData: [String: Any]) async throws {
        guard let url = URL(string: baseURL + "/api/v1/payment/verify") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: receiptData)

        print("🌐 API Request: POST /api/v1/payment/verify")

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("📊 API Response: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.custom("결제 검증 실패")
        }
    }

    /// 구독 상태 동기화 (서버에서 구독 상태 가져오기)
    func syncSubscriptionStatus() async throws -> SubscriptionSyncResponse {
        try await get(endpoint: "/api/v1/payment/subscription/status")
    }
}

// MARK: - Subscription Sync Response
struct SubscriptionSyncResponse: Codable {
    let isActive: Bool
    let productId: String?
    let expirationDate: String?
    let tier: String?

    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case productId = "product_id"
        case expirationDate = "expiration_date"
        case tier
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case serverError(code: Int)
    case custom(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error: \(code)"
        case .custom(let message):
            return message
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let detail: String?
}
