//
//  KeychainService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  Shared Keychain - Works across QuantumNative and SwiftQuantum apps
//

import Foundation
import Security

class KeychainService {

    // MARK: - Singleton
    static let shared = KeychainService()

    // MARK: - Constants
    private let service = "com.swiftquantum.app"
    private let accessGroup = "com.swiftquantum.shared"
    private let tokenKey = "swiftquantum_access_token"
    private let userIdKey = "swiftquantum_user_id"

    private init() {}

    // MARK: - Save Token
    func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }

        // First try with access group (shared across apps)
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecValueData as String: data
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Save new
        var status = SecItemAdd(query as CFDictionary, nil)

        // Fallback: if access group fails, save without it
        if status != errSecSuccess {
            query.removeValue(forKey: kSecAttrAccessGroup as String)
            SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, nil)
        }

        if status == errSecSuccess {
            print("✅ Token saved to keychain (shared)")
        } else {
            print("❌ Failed to save token: \(status)")
        }
    }

    // MARK: - Get Token
    func getToken() -> String? {
        // First try with access group
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        var status = SecItemCopyMatching(query as CFDictionary, &result)

        // Fallback: try without access group
        if status != errSecSuccess {
            query.removeValue(forKey: kSecAttrAccessGroup as String)
            status = SecItemCopyMatching(query as CFDictionary, &result)
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    // MARK: - Delete Token
    func deleteToken() {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecAttrAccessGroup as String: accessGroup
        ]

        SecItemDelete(query as CFDictionary)

        // Also delete without access group (cleanup)
        query.removeValue(forKey: kSecAttrAccessGroup as String)
        SecItemDelete(query as CFDictionary)

        print("✅ Token deleted from keychain")
    }

    // MARK: - Save User ID
    func saveUserId(_ userId: Int) {
        UserDefaults(suiteName: accessGroup)?.set(userId, forKey: userIdKey)
        // Fallback to standard UserDefaults
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    // MARK: - Get User ID
    func getUserId() -> Int? {
        // Try shared UserDefaults first
        if let id = UserDefaults(suiteName: accessGroup)?.integer(forKey: userIdKey), id != 0 {
            return id
        }
        // Fallback to standard
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        return id != 0 ? id : nil
    }

    // MARK: - Delete User ID
    func deleteUserId() {
        UserDefaults(suiteName: accessGroup)?.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }

    // MARK: - Clear All
    func clearAll() {
        deleteToken()
        deleteUserId()
        print("✅ All credentials cleared")
    }
}
