//
//  QuantumTheme.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Design System: Unified Theme
//  This file brings together all design tokens and provides
//  convenient access to the complete design system.
//

import SwiftUI

// MARK: - Quantum Theme
/// Central access point for all design system tokens
/// Usage: QuantumTheme.colors.primary, QuantumTheme.spacing.md, etc.
enum QuantumTheme {
    
    // MARK: - Color Tokens
    enum Colors {
        // Primary palette
        static let primary = Color.quantumCyan
        static let secondary = Color.quantumPurple
        static let tertiary = Color.quantumOrange
        
        // Semantic colors
        static let success = Color.completed
        static let warning = Color.inProgress
        static let disabled = Color.locked
        
        // Text colors
        static let textPrimary = Color.textPrimary
        static let textSecondary = Color.textSecondary
        static let textTertiary = Color.textTertiary
        
        // Background colors
        static let background = Color.bgDark
        static let surface = Color.bgCard
        static let surfaceElevated = Color.bgElevated
    }
    
    // MARK: - Spacing Tokens (Alias for QuantumSpacing)
    typealias Spacing = QuantumSpacing
    
    // MARK: - Typography Tokens (Alias for QuantumTextStyle)
    typealias TextStyle = QuantumTextStyle
    
    // MARK: - Animation Tokens
    enum Animation {
        /// Quick animation for micro-interactions (0.15s)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        
        /// Standard animation for most transitions (0.25s)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        
        /// Smooth animation for larger movements (0.35s)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        
        /// Spring animation for bouncy effects
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        
        /// Gentle spring for subtle movements
        static let gentleSpring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
    
    // MARK: - Shadow Tokens
    enum Shadow {
        /// Subtle shadow for cards
        static func card() -> some View {
            Color.black.opacity(0.2)
        }
        
        /// Shadow radius for cards
        static let cardRadius: CGFloat = 8
        
        /// Shadow offset for cards
        static let cardOffset = CGSize(width: 0, height: 4)
        
        /// Elevated shadow for modals
        static let elevatedRadius: CGFloat = 16
        static let elevatedOffset = CGSize(width: 0, height: 8)
    }
    
    // MARK: - Haptic Feedback
    enum Haptics {
        /// Light haptic for selections
        static func light() {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }
        
        /// Medium haptic for confirmations
        static func medium() {
            let impactMedium = UIImpactFeedbackGenerator(style: .medium)
            impactMedium.impactOccurred()
        }
        
        /// Success haptic for completions
        static func success() {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
        
        /// Error haptic for failures
        static func error() {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
        
        /// Selection haptic for tab changes
        static func selection() {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
}

// MARK: - Theme Environment Key
/// Environment key for theme customization
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true  // true = dark mode
}

extension EnvironmentValues {
    var isDarkMode: Bool {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Card Style Modifier
/// Standard card styling with background, padding, and corner radius
struct QuantumCardModifier: ViewModifier {
    var padding: CGFloat = QuantumSpacing.cardPadding
    var cornerRadius: CGFloat = QuantumSpacing.CornerRadius.md
    var background: Color = .bgCard
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(background)
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: QuantumTheme.Shadow.cardRadius,
                x: QuantumTheme.Shadow.cardOffset.width,
                y: QuantumTheme.Shadow.cardOffset.height
            )
    }
}

// MARK: - Glass Morphism Modifier
/// Applies a glass-like effect to views
struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = QuantumSpacing.CornerRadius.md
    var opacity: Double = 0.1
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Glow Effect Modifier
/// Adds a glow effect around views
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}

// MARK: - View Extensions for Theme
extension View {
    /// Applies standard card styling
    func quantumCard(
        padding: CGFloat = QuantumSpacing.cardPadding,
        cornerRadius: CGFloat = QuantumSpacing.CornerRadius.md,
        background: Color = .bgCard
    ) -> some View {
        modifier(QuantumCardModifier(
            padding: padding,
            cornerRadius: cornerRadius,
            background: background
        ))
    }
    
    /// Applies glass morphism effect
    func glassMorphism(
        cornerRadius: CGFloat = QuantumSpacing.CornerRadius.md,
        opacity: Double = 0.1
    ) -> some View {
        modifier(GlassMorphismModifier(
            cornerRadius: cornerRadius,
            opacity: opacity
        ))
    }
    
    /// Adds glow effect
    func quantumGlow(
        color: Color = .quantumCyan,
        radius: CGFloat = 8
    ) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
    
    /// Standard background gradient
    func quantumBackground() -> some View {
        self.background(
            LinearGradient(
                colors: [
                    Color(hex: "0A0E27"),
                    Color(hex: "16213E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Button Styles
/// Primary button style with gradient background
struct QuantumPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md)
                    .fill(
                        isEnabled
                            ? Color.gradientAccent
                            : LinearGradient(colors: [.locked], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(QuantumTheme.Animation.quick, value: configuration.isPressed)
    }
}

/// Secondary button style with outline
struct QuantumSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.quantumCyan)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md)
                    .fill(Color.quantumCyan.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md)
                            .stroke(Color.quantumCyan.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(QuantumTheme.Animation.quick, value: configuration.isPressed)
    }
}

/// Tertiary button style (text only)
struct QuantumTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.quantumCyan)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(QuantumTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == QuantumPrimaryButtonStyle {
    static var quantumPrimary: QuantumPrimaryButtonStyle { QuantumPrimaryButtonStyle() }
}

extension ButtonStyle where Self == QuantumSecondaryButtonStyle {
    static var quantumSecondary: QuantumSecondaryButtonStyle { QuantumSecondaryButtonStyle() }
}

extension ButtonStyle where Self == QuantumTertiaryButtonStyle {
    static var quantumTertiary: QuantumTertiaryButtonStyle { QuantumTertiaryButtonStyle() }
}

// MARK: - Preview Provider
#Preview("Theme Showcase") {
    ScrollView {
        VStack(spacing: 24) {
            // Card Demo
            Text("Card Styles")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Card")
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                Text("This is a card with default styling")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .quantumCard()
            
            // Glass Morphism Demo
            VStack(alignment: .leading, spacing: 8) {
                Text("Glass Effect")
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                Text("Frosted glass appearance")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassMorphism()
            
            // Button Styles
            Text("Button Styles")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Button("Primary Button") {}
                .buttonStyle(.quantumPrimary)
            
            Button("Secondary Button") {}
                .buttonStyle(.quantumSecondary)
            
            Button("Tertiary Button →") {}
                .buttonStyle(.quantumTertiary)
            
            // Glow Effect
            Text("Glow Effect")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Image(systemName: "atom")
                .font(.system(size: 48))
                .foregroundColor(.quantumCyan)
                .quantumGlow()
        }
        .padding()
    }
    .quantumBackground()
}
