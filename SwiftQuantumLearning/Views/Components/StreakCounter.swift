//
//  StreakCounter.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Streak Counter View
/// Displays current streak with flame animation
struct StreakCounter: View {
    
    // MARK: - Properties
    let currentStreak: Int
    let showLabel: Bool
    let size: Size
    
    @State private var flameAnimation = false
    
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
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            }
        }
    }
    
    // MARK: - Initialization
    init(currentStreak: Int, showLabel: Bool = true, size: Size = .medium) {
        self.currentStreak = currentStreak
        self.showLabel = showLabel
        self.size = size
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            // Flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(flameColor)
                .scaleEffect(flameAnimation ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: flameAnimation
                )
            
            // Streak number
            Text("\(currentStreak)")
                .font(size.fontSize)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            // Optional label
            if showLabel {
                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundView)
        .onAppear {
            if currentStreak > 0 {
                flameAnimation = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var flameColor: Color {
        switch currentStreak {
        case 0:
            return .gray
        case 1...6:
            return .orange
        case 7...29:
            return .quantumOrange
        case 30...99:
            return .quantumYellow
        default:
            return .quantumPurple
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                currentStreak > 0
                    ? flameColor.opacity(0.15)
                    : Color.gray.opacity(0.1)
            )
    }
}

// MARK: - Weekly Streak View
/// Shows a week of streak progress
struct WeeklyStreakView: View {
    let currentStreak: Int
    let lastSevenDays: [Bool]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { day in
                DayIndicator(isActive: day < lastSevenDays.count && lastSevenDays[day])
            }
        }
        .padding(12)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Day Indicator
struct DayIndicator: View {
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.quantumOrange : Color.white.opacity(0.1))
            .frame(width: 12, height: 12)
            .overlay(
                isActive ?
                Image(systemName: "flame.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                : nil
            )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        StreakCounter(currentStreak: 0)
        StreakCounter(currentStreak: 5)
        StreakCounter(currentStreak: 15, size: .large)
        StreakCounter(currentStreak: 30, showLabel: false, size: .small)
        StreakCounter(currentStreak: 100)
        
        WeeklyStreakView(
            currentStreak: 5,
            lastSevenDays: [true, true, true, true, true, false, false]
        )
    }
    .padding()
    .background(Color.bgDark)
}