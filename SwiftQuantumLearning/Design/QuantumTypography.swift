//
//  QuantumTypography.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Design System: Typography
//  This file defines all text styles and font configurations.
//  Consistent typography improves readability and visual hierarchy.
//

import SwiftUI

// MARK: - Typography Style Enum
/// Defines all available text styles in the app
enum QuantumTextStyle {
    // MARK: Display Styles (Hero text, large headlines)
    case displayLarge    // 34pt, Bold
    case displayMedium   // 28pt, Bold
    
    // MARK: Title Styles (Section headers, card titles)
    case titleLarge      // 24pt, Semibold
    case titleMedium     // 20pt, Semibold
    case titleSmall      // 18pt, Semibold
    
    // MARK: Body Styles (Regular content)
    case bodyLarge       // 17pt, Regular
    case bodyMedium      // 15pt, Regular
    case bodySmall       // 13pt, Regular
    
    // MARK: Label Styles (Buttons, tags, metadata)
    case labelLarge      // 14pt, Semibold
    case labelMedium     // 12pt, Semibold
    case labelSmall      // 11pt, Medium
    
    // MARK: Caption Styles (Supporting text, hints)
    case caption         // 12pt, Regular
    case captionSmall    // 10pt, Regular
    
    // MARK: - Font Configuration
    /// Returns the Font for this text style
    var font: Font {
        switch self {
        case .displayLarge:
            return .system(size: 34, weight: .bold, design: .default)
        case .displayMedium:
            return .system(size: 28, weight: .bold, design: .default)
        case .titleLarge:
            return .system(size: 24, weight: .semibold, design: .default)
        case .titleMedium:
            return .system(size: 20, weight: .semibold, design: .default)
        case .titleSmall:
            return .system(size: 18, weight: .semibold, design: .default)
        case .bodyLarge:
            return .system(size: 17, weight: .regular, design: .default)
        case .bodyMedium:
            return .system(size: 15, weight: .regular, design: .default)
        case .bodySmall:
            return .system(size: 13, weight: .regular, design: .default)
        case .labelLarge:
            return .system(size: 14, weight: .semibold, design: .default)
        case .labelMedium:
            return .system(size: 12, weight: .semibold, design: .default)
        case .labelSmall:
            return .system(size: 11, weight: .medium, design: .default)
        case .caption:
            return .system(size: 12, weight: .regular, design: .default)
        case .captionSmall:
            return .system(size: 10, weight: .regular, design: .default)
        }
    }
    
    /// Returns the line spacing for this text style
    var lineSpacing: CGFloat {
        switch self {
        case .displayLarge, .displayMedium:
            return 4
        case .titleLarge, .titleMedium, .titleSmall:
            return 2
        case .bodyLarge, .bodyMedium, .bodySmall:
            return 4
        case .labelLarge, .labelMedium, .labelSmall:
            return 2
        case .caption, .captionSmall:
            return 2
        }
    }
}

// MARK: - Text Style View Modifier
/// ViewModifier that applies a QuantumTextStyle to a Text view
struct QuantumTextStyleModifier: ViewModifier {
    let style: QuantumTextStyle
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .foregroundColor(color)
    }
}

// MARK: - View Extension for Typography
extension View {
    /// Applies a Quantum text style to any view
    /// - Parameters:
    ///   - style: The QuantumTextStyle to apply
    ///   - color: Text color (defaults to primary text color)
    /// - Returns: Modified view with applied text style
    func quantumTextStyle(
        _ style: QuantumTextStyle,
        color: Color = .textPrimary
    ) -> some View {
        modifier(QuantumTextStyleModifier(style: style, color: color))
    }
}

// MARK: - Text Extension for Convenience
extension Text {
    /// Creates a Text view with a specific Quantum text style
    /// - Parameters:
    ///   - style: The QuantumTextStyle to apply
    ///   - color: Text color (defaults to primary text color)
    /// - Returns: Styled Text view
    func quantumStyle(
        _ style: QuantumTextStyle,
        color: Color = .textPrimary
    ) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .foregroundColor(color)
    }
}

// MARK: - Monospace Font for Code/Math
/// Extension for code and mathematical notation
extension Font {
    /// Monospace font for code snippets
    static func quantumCode(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    /// Rounded font for friendly UI elements
    static func quantumRounded(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Typography Constants
/// Namespace for typography-related constants
enum QuantumTypography {
    /// Standard letter spacing values
    enum LetterSpacing {
        static let tight: CGFloat = -0.5
        static let normal: CGFloat = 0
        static let wide: CGFloat = 0.5
        static let veryWide: CGFloat = 1.0
    }
    
    /// Standard paragraph spacing
    enum ParagraphSpacing {
        static let compact: CGFloat = 8
        static let normal: CGFloat = 12
        static let relaxed: CGFloat = 16
    }
}

// MARK: - Preview Provider
#Preview("Typography Showcase") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            // Display Styles
            Group {
                Text("Display Styles")
                    .quantumStyle(.labelMedium, color: .quantumCyan)
                
                Text("Display Large")
                    .quantumStyle(.displayLarge)
                
                Text("Display Medium")
                    .quantumStyle(.displayMedium)
            }
            
            Divider().background(Color.textTertiary)
            
            // Title Styles
            Group {
                Text("Title Styles")
                    .quantumStyle(.labelMedium, color: .quantumCyan)
                
                Text("Title Large")
                    .quantumStyle(.titleLarge)
                
                Text("Title Medium")
                    .quantumStyle(.titleMedium)
                
                Text("Title Small")
                    .quantumStyle(.titleSmall)
            }
            
            Divider().background(Color.textTertiary)
            
            // Body Styles
            Group {
                Text("Body Styles")
                    .quantumStyle(.labelMedium, color: .quantumCyan)
                
                Text("Body Large - Used for main content paragraphs and descriptions.")
                    .quantumStyle(.bodyLarge)
                
                Text("Body Medium - Secondary content and supporting text.")
                    .quantumStyle(.bodyMedium)
                
                Text("Body Small - Compact content areas.")
                    .quantumStyle(.bodySmall)
            }
            
            Divider().background(Color.textTertiary)
            
            // Label & Caption Styles
            Group {
                Text("Labels & Captions")
                    .quantumStyle(.labelMedium, color: .quantumCyan)
                
                HStack(spacing: 16) {
                    Text("LABEL LARGE")
                        .quantumStyle(.labelLarge)
                    
                    Text("LABEL MEDIUM")
                        .quantumStyle(.labelMedium)
                    
                    Text("LABEL SMALL")
                        .quantumStyle(.labelSmall)
                }
                
                Text("Caption - Supporting information and metadata")
                    .quantumStyle(.caption, color: .textSecondary)
                
                Text("Caption Small - Timestamps and minor details")
                    .quantumStyle(.captionSmall, color: .textTertiary)
            }
            
            Divider().background(Color.textTertiary)
            
            // Special Fonts
            Group {
                Text("Special Fonts")
                    .quantumStyle(.labelMedium, color: .quantumCyan)
                
                Text("let qubit = Qubit.zero")
                    .font(.quantumCode())
                    .foregroundColor(.quantumCyan)
                
                Text("Rounded Style")
                    .font(.quantumRounded(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
        }
        .padding()
    }
    .background(Color.bgDark)
}
