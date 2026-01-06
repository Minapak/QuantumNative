//
//  AuthService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine

// MARK: - Profile Update Request
struct UpdateProfileRequest: Codable {
    let username: String?

    enum CodingKeys: String, CodingKey {
        case username
    }
}

// MARK: - Admin Credentials (Development/Testing Only)
struct AdminCredentials {
    static let email = "admin@swiftquantum.io"
    static let password = "QuantumAdmin2026!"
    static let username = "SwiftQuantum Admin"
}

// MARK: - Auth Service
@MainActor
class AuthService: ObservableObject {

    // MARK: - Singleton
    static let shared = AuthService()

    // MARK: - Published Properties
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: UserResponse?
    @Published var isAdmin = false  // Admin flag for premium bypass

    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private let keychainService = KeychainService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UserDefaults Keys
    private let isAdminKey = "swiftquantum.isAdmin"

    // MARK: - Initialization
    private init() {
        isAdmin = UserDefaults.standard.bool(forKey: isAdminKey)
        checkAuthStatus()
    }
    
    // MARK: - Public Methods
    
    /// Check if user is already authenticated
    func checkAuthStatus() {
        if let token = keychainService.getToken() {
            apiClient.accessToken = token
            apiClient.isLoggedIn = true
            isLoggedIn = true
            // ✅ Task로 비동기 함수 호출
            Task {
                await loadUserProfile()
            }
        } else {
            isLoggedIn = false
        }
    }
    
    /// Sign up with email and password
    func signUp(email: String, username: String, password: String) async -> Bool {
        guard validateSignUp(email: email, username: username, password: password) else {
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = SignUpRequest(
                email: email,
                username: username,
                password: password
            )
            
            let response: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/signup",
                body: request
            )
            
            apiClient.accessToken = response.access_token
            apiClient.isLoggedIn = true
            
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.isLoading = false
            }
            
            await loadUserProfile()
            
            print("✅ Sign up successful")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Sign up error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Login with email and password
    func login(email: String, password: String) async -> Bool {
        guard validateLogin(email: email, password: password) else {
            return false
        }

        isLoading = true
        errorMessage = nil

        // Check for Admin login (offline mode)
        if email == AdminCredentials.email && password == AdminCredentials.password {
            return await loginAsAdmin()
        }

        do {
            let request = LoginRequest(
                email: email,
                password: password
            )

            let response: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/login",
                body: request
            )

            apiClient.accessToken = response.access_token
            apiClient.isLoggedIn = true

            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.isLoading = false
                self.isAdmin = false
                UserDefaults.standard.set(false, forKey: self.isAdminKey)
            }

            await loadUserProfile()

            print("✅ Login successful")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Login error: \(error.localizedDescription)")
            return false
        }
    }

    /// Admin login (offline mode with full premium access)
    private func loginAsAdmin() async -> Bool {
        // Create mock admin user (id must be Int)
        let adminUser = UserResponse(
            id: 999999,
            email: AdminCredentials.email,
            username: AdminCredentials.username,
            is_active: true,
            is_premium: true,
            created_at: "2026-01-01T00:00:00Z",
            subscription_tier: "premium",
            subscription_expires_at: "2099-12-31T23:59:59Z"
        )

        DispatchQueue.main.async {
            self.currentUser = adminUser
            self.isLoggedIn = true
            self.isAdmin = true
            self.isLoading = false
            UserDefaults.standard.set(true, forKey: self.isAdminKey)
        }

        print("✅ Admin login successful - Full premium access enabled")
        return true
    }

    /// Logout
    func logout() {
        apiClient.accessToken = nil
        apiClient.isLoggedIn = false
        keychainService.deleteToken()

        isLoggedIn = false
        currentUser = nil
        errorMessage = nil
        isAdmin = false
        UserDefaults.standard.set(false, forKey: isAdminKey)

        print("✅ Logged out")
    }
    
    /// Load current user profile
    func loadUserProfile() async {
        isLoading = true
        
        do {
            let user: UserResponse = try await apiClient.get(
                endpoint: "/api/v1/users/me"
            )
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoading = false
            }
            
            print("✅ User profile loaded")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Failed to load user profile: \(error.localizedDescription)")
        }
    }
    
    /// Verify email token
    func verifyEmailToken(_ token: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let requestBody: [String: String] = ["token": token]
            let _: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/verify-email",
                body: requestBody
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ Email verified")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Email verification failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Request password reset
    func requestPasswordReset(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let requestBody: [String: String] = ["email": email]
            let _: ErrorResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/reset-password-request",
                body: requestBody
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ Password reset email sent")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Password reset request failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Reset password with token
    func resetPassword(token: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let requestBody: [String: String] = [
                "token": token,
                "new_password": newPassword
            ]
            let _: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/reset-password",
                body: requestBody
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ Password reset successful")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Password reset failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Change password
    func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let requestBody: [String: String] = [
                "current_password": currentPassword,
                "new_password": newPassword
            ]
            let _: ErrorResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/change-password",
                body: requestBody
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print("✅ Password changed successfully")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Password change failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Update user profile
    func updateProfile(username: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = UpdateProfileRequest(username: username)
            
            let _: UserResponse = try await apiClient.put(
                endpoint: "/api/v1/users/me",
                body: request
            )
            
            await loadUserProfile()
            
            print("✅ Profile updated")
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Profile update failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private Validation Methods
    
    private func validateSignUp(email: String, username: String, password: String) -> Bool {
        errorMessage = nil
        
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        
        if !email.contains("@") {
            errorMessage = "Invalid email format"
            return false
        }
        
        if username.isEmpty {
            errorMessage = "Username is required"
            return false
        }
        
        if username.count < 3 {
            errorMessage = "Username must be at least 3 characters"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    private func validateLogin(email: String, password: String) -> Bool {
        errorMessage = nil
        
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        
        if !email.contains("@") {
            errorMessage = "Invalid email format"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        
        return true
    }
}
