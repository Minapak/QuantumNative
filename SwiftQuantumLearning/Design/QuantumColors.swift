//
//  QuantumColors.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Design System: Color Palette
//  This file defines all colors used throughout the app.
//  Using a centralized color system ensures consistency and easy theming.
//

import SwiftUI

// MARK: - Quantum Theme Colors Extension
/// Extension on Color to provide app-wide color constants.
/// Access colors like: Color.quantumCyan, Color.bgDark, etc.
extension Color {
    
    // MARK: - Primary Brand Colors
    /// Vibrant cyan - primary accent color for interactive elements
    static let quantumCyan = Color(red: 0.0, green: 0.85, blue: 1.0)
    
    /// Deep purple - secondary accent for gradients and highlights
    static let quantumPurple = Color(red: 0.616, green: 0.306, blue: 0.871)
    
    /// Warm orange - tertiary accent for alerts and emphasis
    static let quantumOrange = Color(red: 1.0, green: 0.42, blue: 0.212)
    

    
    // MARK: - Status Colors
    /// Green - indicates completed items, success states
    static let completed = Color(red: 0.0, green: 0.825, blue: 0.275)
    
    /// Yellow - indicates items in progress, warnings
    static let inProgress = Color(red: 1.0, green: 0.839, blue: 0.04)
    
    /// Gray - indicates locked or disabled items
    static let locked = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // MARK: - Text Colors
    /// Primary text color - high contrast for main content
    static let textPrimary = Color(white: 0.95)
    
    /// Secondary text color - lower contrast for supporting text
    static let textSecondary = Color(white: 0.6)
    
    /// Tertiary text color - subtle text for hints and captions
    static let textTertiary = Color(white: 0.4)
    
    // MARK: - Background Colors
    /// Dark background - main app background
    static let bgDark = Color(red: 0.04, green: 0.055, blue: 0.15)
    
    /// Slightly lighter background for cards and elevated surfaces
    static let bgCard = Color(red: 0.08, green: 0.10, blue: 0.20)
    
    /// Even lighter for hover states and selected items
    static let bgElevated = Color(red: 0.12, green: 0.14, blue: 0.25)
    
    /// Light background for light mode (if implemented)
    static let bgLight = Color(white: 1.0)
    
    // MARK: - Gradient Definitions
    /// Primary gradient for headers and hero sections
    static let gradientPrimary = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.06, blue: 0.15),
            Color(red: 0.09, green: 0.13, blue: 0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Accent gradient for buttons and interactive elements
    static let gradientAccent = LinearGradient(
        colors: [quantumCyan, quantumPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Subtle gradient for cards and containers
    static let gradientCard = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.02)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Hex Color Initializer
/// Convenience initializer to create colors from hex strings.
/// Usage: Color(hex: "1A1A2E") or Color(hex: "#1A1A2E")
extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (with or without # prefix)
    init(hex: String) {
        // Remove # prefix if present
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Scheme Helper
/// Struct to manage color schemes (dark/light mode)
struct QuantumColorScheme {
    let isDarkMode: Bool
    
    // MARK: - Dynamic Colors
    /// Returns appropriate background color based on color scheme
    var background: Color {
        isDarkMode ? .bgDark : .bgLight
    }
    
    /// Returns appropriate text color based on color scheme
    var text: Color {
        isDarkMode ? .textPrimary : Color(white: 0.1)
    }
    
    /// Returns appropriate card background based on color scheme
    var cardBackground: Color {
        isDarkMode ? .bgCard : Color(white: 0.95)
    }
}

// MARK: - Preview Provider
#Preview("Color Palette") {
    ScrollView {
        VStack(spacing: 20) {
            // Brand Colors Section
            Text("Brand Colors")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                ColorSwatch(color: .quantumCyan, name: "Cyan")
                ColorSwatch(color: .quantumPurple, name: "Purple")
                ColorSwatch(color: .quantumOrange, name: "Orange")
            }
            
            // Status Colors Section
            Text("Status Colors")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                ColorSwatch(color: .completed, name: "Completed")
                ColorSwatch(color: .inProgress, name: "In Progress")
                ColorSwatch(color: .locked, name: "Locked")
            }
            
            // Text Colors Section
            Text("Text Colors")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Primary Text").foregroundColor(.textPrimary)
                Text("Secondary Text").foregroundColor(.textSecondary)
                Text("Tertiary Text").foregroundColor(.textTertiary)
            }
            
            // Gradient Section
            Text("Gradients")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gradientAccent)
                .frame(height: 60)
                .overlay(
                    Text("Accent Gradient")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                )
        }
        .padding()
    }
    .background(Color.bgDark)
}

// MARK: - Helper View for Preview
/// Simple color swatch view for previewing colors
struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}
