//
//  QuantumSpacing.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Design System: Spacing
//  This file defines all spacing values used throughout the app.
//  Consistent spacing creates visual rhythm and improves usability.
//

import SwiftUI

// MARK: - Spacing Constants
/// Namespace for all spacing-related values
/// Using a consistent spacing scale (4pt base) ensures visual harmony
enum QuantumSpacing {
    
    // MARK: - Base Spacing Scale (4pt increments)
    /// 4pt - Minimal spacing for tight layouts
    static let xxs: CGFloat = 4
    
    /// 8pt - Small spacing for related elements
    static let xs: CGFloat = 8
    
    /// 12pt - Default spacing between elements
    static let sm: CGFloat = 12
    
    /// 16pt - Standard spacing for sections
    static let md: CGFloat = 16
    
    /// 20pt - Comfortable spacing
    static let lg: CGFloat = 20
    
    /// 24pt - Large spacing for section separation
    static let xl: CGFloat = 24
    
    /// 32pt - Extra large for major sections
    static let xxl: CGFloat = 32
    
    /// 48pt - Maximum spacing for hero areas
    static let xxxl: CGFloat = 48
    
    // MARK: - Semantic Spacing
    /// Padding inside cards and containers
    static let cardPadding: CGFloat = 16
    
    /// Horizontal screen padding
    static let screenHorizontal: CGFloat = 16
    
    /// Vertical screen padding
    static let screenVertical: CGFloat = 12
    
    /// Space between cards in a list
    static let cardGap: CGFloat = 12
    
    /// Space between items in a row
    static let itemGap: CGFloat = 8
    
    /// Space for tab bar safe area
    static let tabBarHeight: CGFloat = 80
    
    /// Bottom padding to account for tab bar
    static let bottomSafeArea: CGFloat = 100
    
    // MARK: - Corner Radius Scale
    enum CornerRadius {
        /// 4pt - Subtle rounding for small elements
        static let xs: CGFloat = 4
        
        /// 8pt - Standard rounding for buttons
        static let sm: CGFloat = 8
        
        /// 12pt - Medium rounding for cards
        static let md: CGFloat = 12
        
        /// 16pt - Large rounding for containers
        static let lg: CGFloat = 16
        
        /// 24pt - Extra large for modal sheets
        static let xl: CGFloat = 24
        
        /// Full circle (use with .infinity or large value)
        static let full: CGFloat = 9999
    }
    
    // MARK: - Icon Sizes
    enum IconSize {
        /// 12pt - Tiny icons (indicators)
        static let xs: CGFloat = 12
        
        /// 16pt - Small icons (inline)
        static let sm: CGFloat = 16
        
        /// 20pt - Standard icons
        static let md: CGFloat = 20
        
        /// 24pt - Large icons (buttons)
        static let lg: CGFloat = 24
        
        /// 32pt - Extra large icons (features)
        static let xl: CGFloat = 32
        
        /// 48pt - Hero icons
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Component Heights
    enum Height {
        /// 36pt - Small buttons
        static let buttonSmall: CGFloat = 36
        
        /// 44pt - Standard buttons (minimum tap target)
        static let buttonMedium: CGFloat = 44
        
        /// 52pt - Large buttons (CTAs)
        static let buttonLarge: CGFloat = 52
        
        /// 48pt - Tab bar item height
        static let tabBarItem: CGFloat = 48
        
        /// 56pt - Navigation bar height
        static let navBar: CGFloat = 56
        
        /// 80pt - Progress card height
        static let progressCard: CGFloat = 80
    }
}

// MARK: - Padding View Modifier
/// ViewModifier for applying consistent padding
struct QuantumPaddingModifier: ViewModifier {
    let edges: Edge.Set
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content.padding(edges, size)
    }
}

// MARK: - View Extension for Spacing
extension View {
    /// Applies horizontal screen padding
    func screenHorizontalPadding() -> some View {
        self.padding(.horizontal, QuantumSpacing.screenHorizontal)
    }
    
    /// Applies vertical screen padding
    func screenVerticalPadding() -> some View {
        self.padding(.vertical, QuantumSpacing.screenVertical)
    }
    
    /// Applies standard card padding
    func cardPadding() -> some View {
        self.padding(QuantumSpacing.cardPadding)
    }
    
    /// Applies bottom safe area padding for tab bar
    func tabBarSafeArea() -> some View {
        self.padding(.bottom, QuantumSpacing.bottomSafeArea)
    }
    
    /// Applies standard corner radius
    func standardCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md))
    }
}

// MARK: - Stack Spacing Helpers
extension HStack {
    /// Creates an HStack with standard item gap
    static func quantumRow<Content: View>(
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: alignment, spacing: QuantumSpacing.itemGap, content: content)
    }
}

extension VStack {
    /// Creates a VStack with standard card gap
    static func quantumStack<Content: View>(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: alignment, spacing: QuantumSpacing.cardGap, content: content)
    }
}

// MARK: - Preview Provider
#Preview("Spacing Showcase") {
    ScrollView {
        VStack(alignment: .leading, spacing: QuantumSpacing.lg) {
            // Spacing Scale
            Text("Spacing Scale")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                SpacingDemo(name: "xxs (4pt)", size: QuantumSpacing.xxs)
                SpacingDemo(name: "xs (8pt)", size: QuantumSpacing.xs)
                SpacingDemo(name: "sm (12pt)", size: QuantumSpacing.sm)
                SpacingDemo(name: "md (16pt)", size: QuantumSpacing.md)
                SpacingDemo(name: "lg (20pt)", size: QuantumSpacing.lg)
                SpacingDemo(name: "xl (24pt)", size: QuantumSpacing.xl)
                SpacingDemo(name: "xxl (32pt)", size: QuantumSpacing.xxl)
            }
            
            Divider().background(Color.textTertiary)
            
            // Corner Radius Demo
            Text("Corner Radius")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                CornerRadiusDemo(name: "xs", radius: QuantumSpacing.CornerRadius.xs)
                CornerRadiusDemo(name: "sm", radius: QuantumSpacing.CornerRadius.sm)
                CornerRadiusDemo(name: "md", radius: QuantumSpacing.CornerRadius.md)
                CornerRadiusDemo(name: "lg", radius: QuantumSpacing.CornerRadius.lg)
            }
            
            Divider().background(Color.textTertiary)
            
            // Icon Sizes Demo
            Text("Icon Sizes")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 16) {
                IconSizeDemo(name: "xs", size: QuantumSpacing.IconSize.xs)
                IconSizeDemo(name: "sm", size: QuantumSpacing.IconSize.sm)
                IconSizeDemo(name: "md", size: QuantumSpacing.IconSize.md)
                IconSizeDemo(name: "lg", size: QuantumSpacing.IconSize.lg)
                IconSizeDemo(name: "xl", size: QuantumSpacing.IconSize.xl)
            }
        }
        .padding()
    }
    .background(Color.bgDark)
}

// MARK: - Preview Helper Views
struct SpacingDemo: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            Rectangle()
                .fill(Color.quantumCyan)
                .frame(width: size, height: 20)
        }
    }
}

struct CornerRadiusDemo: View {
    let name: String
    let radius: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.quantumPurple)
                .frame(width: 50, height: 50)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}

struct IconSizeDemo: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "atom")
                .font(.system(size: size))
                .foregroundColor(.quantumCyan)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}
