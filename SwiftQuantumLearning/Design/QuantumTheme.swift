//
//  QuantumTheme.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Spacing System
enum QuantumSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    
    enum CornerRadius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let round: CGFloat = 999
    }
}

// MARK: - Text Styles
enum QuantumTextStyle {
    static func title() -> Font {
        .system(size: 28, weight: .bold)
    }
    
    static func headline() -> Font {
        .system(size: 20, weight: .semibold)
    }
    
    static func body() -> Font {
        .system(size: 16)
    }
    
    static func caption() -> Font {
        .system(size: 14)
    }
    
    static func small() -> Font {
        .system(size: 12)
    }
}

// MARK: - Additional Color Extensions
extension Color {
    static let bgElevated = Color(white: 0.15)
    
    static let gradientAccent = LinearGradient(
        colors: [.quantumCyan, .quantumPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Quantum Theme
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
    
    // MARK: - Spacing Tokens
    typealias Spacing = QuantumSpacing
    
    // MARK: - Typography Tokens
    typealias TextStyle = QuantumTextStyle
    
    // MARK: - Animation Tokens
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let gentleSpring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
    
    // MARK: - Shadow Tokens
    enum Shadow {
        static func card() -> some View {
            Color.black.opacity(0.2)
        }
        
        static let cardRadius: CGFloat = 8
        static let cardOffset = CGSize(width: 0, height: 4)
        static let elevatedRadius: CGFloat = 16
        static let elevatedOffset = CGSize(width: 0, height: 8)
    }
    
    // MARK: - Haptic Feedback (iOS Only)
    #if os(iOS)
    enum Haptics {
        static func light() {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }
        
        static func medium() {
            let impactMedium = UIImpactFeedbackGenerator(style: .medium)
            impactMedium.impactOccurred()
        }
        
        static func success() {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
        
        static func error() {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
        
        static func selection() {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    #else
    // macOS placeholder - no haptics
    enum Haptics {
        static func light() { }
        static func medium() { }
        static func success() { }
        static func error() { }
        static func selection() { }
    }
    #endif
}

// MARK: - Theme Environment Key
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var isDarkMode: Bool {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Card Style Modifier
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
    
    func glassMorphism(
        cornerRadius: CGFloat = QuantumSpacing.CornerRadius.md,
        opacity: Double = 0.1
    ) -> some View {
        modifier(GlassMorphismModifier(
            cornerRadius: cornerRadius,
            opacity: opacity
        ))
    }
    
    func quantumGlow(
        color: Color = .quantumCyan,
        radius: CGFloat = 8
    ) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
    
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
                        LinearGradient(
                            colors: isEnabled ? [.quantumCyan, .quantumPurple] : [.locked, .locked],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(QuantumTheme.Animation.quick, value: configuration.isPressed)
    }
}

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
