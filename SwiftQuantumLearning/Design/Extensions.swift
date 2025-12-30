//
//  Extensions.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Background Colors
    static let bgDark = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let bgCard = Color(red: 0.08, green: 0.08, blue: 0.12)
    
    // Brand Colors
    static let quantumCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let quantumPurple = Color(red: 0.6, green: 0.4, blue: 1.0)
    static let quantumOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let quantumGreen = Color(red: 0.2, green: 0.9, blue: 0.6)
    static let quantumYellow = Color(red: 1.0, green: 0.9, blue: 0.2)
    static let quantumRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    
    // Status Colors
    static let completed = Color.quantumGreen
    static let inProgress = Color.quantumYellow
    static let locked = Color.gray
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
    }
    
    func glowEffect(color: Color = .quantumCyan) -> some View {
        self
            .shadow(color: color.opacity(0.3), radius: 10)
            .shadow(color: color.opacity(0.2), radius: 20)
    }
}

// MARK: - String Extensions
extension String {
    func padLeft(toLength length: Int, withPad pad: String = "0") -> String {
        let currentLength = self.count
        if currentLength >= length {
            return self
        }
        return String(repeating: pad, count: length - currentLength) + self
    }
}