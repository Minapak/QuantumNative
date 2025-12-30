//
//  LevelCard.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Level Card Component
//  Reusable card component for displaying learning level information
//

import SwiftUI

// MARK: - Level Card
/// Reusable card component for displaying level information
struct LevelCard: View {
    
    // MARK: - Properties
    let level: LearningLevel
    let progress: Double // 0.0 to 1.0
    let isLocked: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Top section with image/icon
                topSection
                
                // Content section
                contentSection
                
                // Progress bar
                if !isLocked && !isCompleted && progress > 0 {
                    progressBar
                }
            }
            .background(cardBackground)
            .cornerRadius(16)
            .shadow(
                color: isCompleted ? Color.quantumGreen.opacity(0.1) : Color.black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .onLongPressGesture(minimumDuration: 0) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    // MARK: - Subviews
    
    /// Top section with visual element
    private var topSection: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    level.track.primaryColor.opacity(isLocked ? 0.3 : 0.8),
                    level.track.secondaryColor.opacity(isLocked ? 0.3 : 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            
            // Overlay pattern
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - 30))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: geometry.size.height - 30),
                        control: CGPoint(x: geometry.size.width/2, y: geometry.size.height - 50)
                    )
                }
                .fill(Color.bgCard)
            }
            .frame(height: 120)
            
            // Level number or icon
            VStack {
                Spacer()
                
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.quantumGreen)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.title3)
                                .foregroundColor(.textTertiary)
                        } else {
                            Text("\(level.number)")
                                .font(.title2.bold())
                                .foregroundColor(level.track.primaryColor)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, -28)
                    
                    Spacer()
                    
                    // Status badge
                    if isCompleted {
                        Text("COMPLETE")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.quantumGreen)
                            .cornerRadius(12)
                            .padding(.trailing)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    /// Content section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and track
            VStack(alignment: .leading, spacing: 4) {
                Text(level.name)
                    .font(.headline)
                    .foregroundColor(isLocked ? .textTertiary : .textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(level.track.title, systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(level.track.primaryColor.opacity(isLocked ? 0.5 : 1))
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Label("\(level.estimatedDurationMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            // Description
            Text(level.description)
                .font(.caption)
                .foregroundColor(isLocked ? .textTertiary.opacity(0.7) : .textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Topics preview
            if !level.topics.isEmpty && !isLocked {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(level.topics.prefix(4), id: \.self) { topic in
                            TopicChip(topic: topic, color: level.track.primaryColor)
                        }
                    }
                }
            }
            
            // Bottom info
            HStack {
                // XP reward
                if !isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.quantumYellow)
                        
                        Text("+\(level.xpReward) XP")
                            .font(.caption.bold())
                            .foregroundColor(.quantumYellow)
                    }
                }
                
                Spacer()
                
                // Progress text
                if !isLocked && !isCompleted && progress > 0 {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption.bold())
                        .foregroundColor(.quantumCyan)
                } else if isLocked {
                    Text("Complete previous level")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding()
        .padding(.top, 20)
    }
    
    /// Progress bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.textTertiary.opacity(0.1))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [level.track.primaryColor, level.track.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 4)
    }
    
    /// Card background
    private var cardBackground: some View {
        Group {
            if isCompleted {
                Color.bgCard
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.quantumGreen.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else if isLocked {
                Color.bgCard.opacity(0.7)
            } else {
                Color.bgCard
            }
        }
    }
}

// MARK: - Topic Chip
/// Small topic display chip
struct TopicChip: View {
    let topic: String
    let color: Color
    
    var body: some View {
        Text(topic)
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

// MARK: - Compact Level Card
/// Smaller version of level card for lists
struct CompactLevelCard: View {
    let level: LearningLevel
    let isCompleted: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Status indicator
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ? Color.quantumGreen :
                            isLocked ? Color.textTertiary.opacity(0.2) :
                            LinearGradient(
                                colors: [level.track.primaryColor, level.track.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.textTertiary)
                    } else {
                        Text("\(level.number)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.subheadline.bold())
                        .foregroundColor(isLocked ? .textTertiary : .textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label("\(level.estimatedDurationMinutes) min", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        if !isLocked {
                            Label("+\(level.xpReward) XP", systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.quantumYellow)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
    }
}

// MARK: - Preview
#Preview("Level Card") {
    VStack(spacing: 16) {
        LevelCard(
            level: LearningLevel.sampleLevels[0],
            progress: 0.6,
            isLocked: false,
            isCompleted: false,
            action: {}
        )
        
        LevelCard(
            level: LearningLevel.sampleLevels[1],
            progress: 0,
            isLocked: false,
            isCompleted: true,
            action: {}
        )
        
        LevelCard(
            level: LearningLevel.sampleLevels[2],
            progress: 0,
            isLocked: true,
            isCompleted: false,
            action: {}
        )
    }
    .padding()
    .background(Color.bgDark)
    .preferredColorScheme(.dark)
}

#Preview("Compact Level Card") {
    VStack(spacing: 12) {
        CompactLevelCard(
            level: LearningLevel.sampleLevels[0],
            isCompleted: false,
            isLocked: false,
            action: {}
        )
        
        CompactLevelCard(
            level: LearningLevel.sampleLevels[1],
            isCompleted: true,
            isLocked: false,
            action: {}
        )
        
        CompactLevelCard(
            level: LearningLevel.sampleLevels[2],
            isCompleted: false,
            isLocked: true,
            action: {}
        )
    }
    .padding()
    .background(Color.bgDark)
    .preferredColorScheme(.dark)
}
