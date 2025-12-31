//
//  AuthViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var email = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // 저장된 토큰 확인
        if apiClient.accessToken != nil {
            isLoggedIn = true
        }
    }
    
    // MARK: - Sign Up
    func signUp() async {
        guard validateSignUp() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = SignUpRequest(
            email: email,
            username: username,
            password: password
        )
        
        do {
            let response: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/signup",
                body: request
            )
            
            apiClient.accessToken = response.access_token
            apiClient.isLoggedIn = true
            
            isLoggedIn = true
            resetForm()
            
            print("✅ Sign up successful")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign up error: \(errorMessage ?? "")")
        }
        
        isLoading = false
    }
    
    // MARK: - Login
    func login() async {
        guard validateLogin() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(
            email: email,
            password: password
        )
        
        do {
            let response: AuthResponse = try await apiClient.post(
                endpoint: "/api/v1/auth/login",
                body: request
            )
            
            apiClient.accessToken = response.access_token
            apiClient.isLoggedIn = true
            
            isLoggedIn = true
            resetForm()
            
            print("✅ Login successful")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Login error: \(errorMessage ?? "")")
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    func logout() {
        apiClient.accessToken = nil
        apiClient.isLoggedIn = false
        KeychainService.shared.deleteToken()
        
        isLoggedIn = false
        resetForm()
        
        print("✅ Logged out")
    }
    
    // MARK: - Validation
    private func validateSignUp() -> Bool {
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
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
    
    private func validateLogin() -> Bool {
        errorMessage = nil
        
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    private func resetForm() {
        email = ""
        username = ""
        password = ""
        confirmPassword = ""
    }
}
