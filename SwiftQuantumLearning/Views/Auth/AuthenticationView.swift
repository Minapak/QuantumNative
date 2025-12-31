//
//  AuthenticationView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "atom")
                            .font(.system(size: 64))
                            .foregroundColor(.quantumCyan)
                        
                        Text("SwiftQuantum")
                            .font(.title.bold())
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.top, 60)
                    
                    // Form
                    if isSignUp {
                        signUpForm
                    } else {
                        loginForm
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            Text("Welcome Back")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                TextField("your@email.com", text: $authViewModel.email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                SecureField("••••••••", text: $authViewModel.password)
                    .textContentType(.password)
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Error message
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Login button
            Button(action: {
                Task {
                    await authViewModel.login()
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.bgDark)
                } else {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.bgDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.quantumCyan, .quantumPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(authViewModel.isLoading)
            
            // Sign up link
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(.textSecondary)
                
                Button(action: { isSignUp = true }) {
                    Text("Sign Up")
                        .foregroundColor(.quantumCyan)
                        .fontWeight(.semibold)
                }
            }
            .font(.caption)
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                TextField("your@email.com", text: $authViewModel.email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Username
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                TextField("username", text: $authViewModel.username)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                SecureField("••••••••", text: $authViewModel.password)
                    .textContentType(.newPassword)
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Confirm Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                SecureField("••••••••", text: $authViewModel.confirmPassword)
                    .textContentType(.newPassword)
                    .padding(12)
                    .background(Color.bgCard)
                    .cornerRadius(8)
            }
            
            // Error message
            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Sign up button
            Button(action: {
                Task {
                    await authViewModel.signUp()
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.bgDark)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.bgDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.quantumCyan, .quantumPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .disabled(authViewModel.isLoading)
            
            // Login link
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(.textSecondary)
                
                Button(action: { isSignUp = false }) {
                    Text("Login")
                        .foregroundColor(.quantumCyan)
                        .fontWeight(.semibold)
                }
            }
            .font(.caption)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthViewModel())
}
