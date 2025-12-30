//
//  XPDisplay.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - XP Display View
/// Displays XP with animation effects
struct XPDisplay: View {
    
    // MARK: - Properties
    let xp: Int
    let showAnimation: Bool
    let size: Size
    
    @State private var animatedXP: Int = 0
    @State private var sparkleAnimation = false
    
    enum Size {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .headline
            case .large: return .title
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }
    }
    
    // MARK: - Initialization
    init(xp: Int, showAnimation: Bool = true, size: Size = .medium) {
        self.xp = xp
        self.showAnimation = showAnimation
        self.size = size
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 4) {
            // Star icon
            Image(systemName: "star.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(.quantumYellow)
                .rotationEffect(.degrees(sparkleAnimation ? 360 : 0))
            
            // XP value
            Text("\(showAnimation ? animatedXP : xp)")
                .font(size.fontSize)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
                .contentTransition(.numericText())
            
            // XP label
            Text("XP")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .onAppear {
            if showAnimation {
                animateXP()
            } else {
                animatedXP = xp
            }
        }
        .onChange(of: xp) { _, newValue in
            if showAnimation {
                animateXP()
            } else {
                animatedXP = newValue
            }
        }
    }
    
    // MARK: - Animation Methods
    
    private func animateXP() {
        let duration = 1.0
        let steps = 30
        let stepDuration = duration / Double(steps)
        let increment = (xp - animatedXP) / steps
        
        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.linear(duration: stepDuration)) {
                    if step == steps - 1 {
                        animatedXP = xp
                    } else {
                        animatedXP += increment
                    }
                }
            }
        }
        
        // Sparkle animation
        withAnimation(.easeInOut(duration: 0.5)) {
            sparkleAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sparkleAnimation = false
        }
    }
}

// MARK: - XP Badge View
/// Compact XP display badge
struct XPBadge: View {
    let xp: Int
    let color: Color
    
    init(xp: Int, color: Color = .quantumYellow) {
        self.xp = xp
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text("+\(xp)")
                .font(.caption.bold())
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - XP Progress Bar
/// Shows XP progress to next level
struct XPProgressBar: View {
    let currentXP: Int
    let nextLevelXP: Int
    let showLabels: Bool
    
    private var progress: Double {
        guard nextLevelXP > 0 else { return 0 }
        return Double(currentXP) / Double(nextLevelXP)
    }
    
    init(currentXP: Int, nextLevelXP: Int, showLabels: Bool = true) {
        self.currentXP = currentXP
        self.nextLevelXP = nextLevelXP
        self.showLabels = showLabels
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showLabels {
                HStack {
                    Text("\(currentXP) XP")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("\(nextLevelXP - currentXP) to next level")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        XPDisplay(xp: 1250)
        
        HStack(spacing: 20) {
            XPDisplay(xp: 500, size: .small)
            XPDisplay(xp: 2500, size: .large)
        }
        
        HStack(spacing: 12) {
            XPBadge(xp: 50)
            XPBadge(xp: 100, color: .quantumCyan)
            XPBadge(xp: 250, color: .quantumPurple)
        }
        
        XPProgressBar(currentXP: 750, nextLevelXP: 1000)
    }
    .padding()
    .background(Color.bgDark)
}