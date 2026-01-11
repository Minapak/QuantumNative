//
//  LevelCard.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct LevelCard: View {
    let level: LearningLevel
    let isUnlocked: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Level number indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? level.track.primaryColor :
                              isUnlocked ? level.track.secondaryColor :
                              Color.textTertiary.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("\(level.number)")
                        .font(.title2.bold())
                        .foregroundColor(isCompleted ? .white :
                                       isUnlocked ? level.track.primaryColor :
                                       .textTertiary)
                }
                
                // Level info
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .textPrimary : .textTertiary)
                        .lineLimit(1)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(isUnlocked ? .textSecondary : .textTertiary)
                        .lineLimit(2)
                    
                    // Stats
                    HStack(spacing: 12) {
                        Label("\(level.xpReward) XP", systemImage: "star.fill")
                            .font(.caption2)
                        
                        Label("\(level.estimatedTime) min", systemImage: "clock")
                            .font(.caption2)
                    }
                    .foregroundColor(isUnlocked ? level.track.primaryColor : .textTertiary)
                }
                
                Spacer()
                
                // Status icon
                Image(systemName: isCompleted ? "checkmark.circle.fill" :
                                isUnlocked ? "chevron.right" :
                                "lock.fill")
                    .foregroundColor(isCompleted ? .completed :
                                   isUnlocked ? .textSecondary :
                                   .textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isCompleted ? level.track.primaryColor.opacity(0.3) :
                                   Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
}

// Preview
struct LevelCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            LevelCard(
                level: LearningLevel.sampleLevels[0],
                isUnlocked: true,
                isCompleted: true
            ) { }
            
            LevelCard(
                level: LearningLevel.sampleLevels[1],
                isUnlocked: true,
                isCompleted: false
            ) { }
            
            LevelCard(
                level: LearningLevel.sampleLevels[2],
                isUnlocked: false,
                isCompleted: false
            ) { }
        }
        .padding()
        .background(Color.bgDark)
    }
}
