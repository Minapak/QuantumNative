//
//  ProgressRing.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Progress Ring View
/// Circular progress indicator with animation
struct ProgressRing: View {
    
    // MARK: - Properties
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat
    let primaryColor: Color
    let secondaryColor: Color
    let showPercentage: Bool
    
    @State private var animatedProgress: Double = 0
    
    // MARK: - Initialization
    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        size: CGFloat = 100,
        primaryColor: Color = .quantumCyan,
        secondaryColor: Color = .quantumPurple,
        showPercentage: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.showPercentage = showPercentage
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animatedProgress)
            
            // Percentage text
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress * 100))")
                        .font(.system(size: size * 0.3, weight: .bold, design: .default))
                        .foregroundColor(.textPrimary)
                    
                    Text("%")
                        .font(.system(size: size * 0.12, weight: .medium, design: .default))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ProgressRing(progress: 0.75)
        
        HStack(spacing: 30) {
            ProgressRing(
                progress: 0.3,
                size: 60,
                showPercentage: false
            )
            
            ProgressRing(
                progress: 0.6,
                size: 80,
                primaryColor: .quantumGreen,
                secondaryColor: .quantumCyan
            )
            
            ProgressRing(
                progress: 0.9,
                lineWidth: 12,
                size: 120
            )
        }
    }
    .padding()
    .background(Color.bgDark)
}