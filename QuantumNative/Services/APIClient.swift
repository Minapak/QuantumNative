//
//  APIClient.swift
//  QuantumNative
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
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

    // API Base URLs
    private let baseURL: String
    private let bridgeURL: String
    private let session: URLSession

    // MARK: - Initialization
    private init() {
        #if DEBUG
        // Local development
        self.baseURL = "http://localhost:8000"
        self.bridgeURL = "http://localhost:8001"
        #else
        // Production API URLs (AWS with HTTPS)
        self.baseURL = "https://api.swiftquantum.tech"
        self.bridgeURL = "https://bridge.swiftquantum.tech"
        #endif

        print("🔧 APIClient baseURL: \(self.baseURL)")
        print("🔧 APIClient bridgeURL: \(self.bridgeURL)")
        
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

    // MARK: - QuantumBridge API Methods

    /// QuantumBridge 상태 확인
    func bridgeHealthCheck() async throws -> BridgeHealthResponse {
        guard let url = URL(string: bridgeURL + "/health") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(BridgeHealthResponse.self, from: data)
    }

    /// Bell State 생성
    func runBellState(stateType: String = "phi_plus", shots: Int = 1024) async throws -> BellStateResponse {
        guard let url = URL(string: bridgeURL + "/bell-state") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["state_type": stateType, "shots": shots]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🌐 Bridge Request: POST /bell-state")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        print("📊 Bridge Response: \(httpResponse.statusCode)")
        return try JSONDecoder().decode(BellStateResponse.self, from: data)
    }

    /// 커스텀 양자 회로 실행
    func runQuantumCircuit(qasm: String, shots: Int = 1024) async throws -> CircuitResponse {
        guard let url = URL(string: bridgeURL + "/run-circuit") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["qasm": qasm, "shots": shots]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🌐 Bridge Request: POST /run-circuit")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        print("📊 Bridge Response: \(httpResponse.statusCode)")
        return try JSONDecoder().decode(CircuitResponse.self, from: data)
    }

    /// Grover 알고리즘 실행
    func runGrover(numQubits: Int = 3, markedStates: [Int] = [5], shots: Int = 1024) async throws -> GroverResponse {
        guard let url = URL(string: bridgeURL + "/grover") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "num_qubits": numQubits,
            "marked_states": markedStates,
            "shots": shots
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🌐 Bridge Request: POST /grover")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        print("📊 Bridge Response: \(httpResponse.statusCode)")
        return try JSONDecoder().decode(GroverResponse.self, from: data)
    }

    /// Deutsch-Jozsa 알고리즘 실행
    func runDeutschJozsa(numQubits: Int = 3, oracleType: String = "balanced", shots: Int = 1024) async throws -> DeutschJozsaResponse {
        guard let url = URL(string: bridgeURL + "/deutsch-jozsa") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "num_qubits": numQubits,
            "oracle_type": oracleType,
            "shots": shots
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🌐 Bridge Request: POST /deutsch-jozsa")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        print("📊 Bridge Response: \(httpResponse.statusCode)")
        return try JSONDecoder().decode(DeutschJozsaResponse.self, from: data)
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

// MARK: - QuantumBridge Response Models

struct BridgeHealthResponse: Codable {
    let status: String
    let qiskitVersion: String?
    let backends: [String]?
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case status
        case qiskitVersion = "qiskit_version"
        case backends
        case timestamp
    }
}

struct BellStateResponse: Codable {
    let stateType: String
    let results: BellStateResult
    let shots: Int

    enum CodingKeys: String, CodingKey {
        case stateType = "state_type"
        case results
        case shots
    }
}

struct BellStateResult: Codable {
    let counts: [String: Int]
    let statevector: [[Double]]?
}

struct CircuitResponse: Codable {
    let counts: [String: Int]
    let shots: Int
    let executionTime: Double?

    enum CodingKeys: String, CodingKey {
        case counts
        case shots
        case executionTime = "execution_time"
    }
}

struct GroverResponse: Codable {
    let algorithm: String
    let results: GroverResult
    let numQubits: Int
    let markedStates: [Int]
    let shots: Int

    enum CodingKeys: String, CodingKey {
        case algorithm
        case results
        case numQubits = "num_qubits"
        case markedStates = "marked_states"
        case shots
    }
}

struct GroverResult: Codable {
    let counts: [String: Int]
    let iterations: Int
    let successProbability: Double

    enum CodingKeys: String, CodingKey {
        case counts
        case iterations
        case successProbability = "success_probability"
    }
}

struct DeutschJozsaResponse: Codable {
    let algorithm: String
    let results: DeutschJozsaResult
    let numQubits: Int
    let oracleType: String
    let shots: Int

    enum CodingKeys: String, CodingKey {
        case algorithm
        case results
        case numQubits = "num_qubits"
        case oracleType = "oracle_type"
        case shots
    }
}

struct DeutschJozsaResult: Codable {
    let counts: [String: Int]
    let determination: String
    let isConstant: Bool

    enum CodingKeys: String, CodingKey {
        case counts
        case determination
        case isConstant = "is_constant"
    }
}
