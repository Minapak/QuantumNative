//
//  PracticeItem.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct PracticeItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let difficulty: Difficulty
    let isUnlocked: Bool
    let completedCount: Int
    let totalCount: Int
    
    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: Color {
            switch self {
            case .beginner: return .quantumGreen
            case .intermediate: return .quantumCyan
            case .advanced: return .quantumPurple
            }
        }
    }
    
    var progressPercentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount)) * 100)
    }
    
    static let sampleItems: [PracticeItem] = [
        PracticeItem(
            id: "superposition",
            title: "Superposition Lab",
            subtitle: "Create and measure superposition states",
            iconName: "waveform.circle.fill",
            difficulty: .beginner,
            isUnlocked: true,
            completedCount: 3,
            totalCount: 5
        ),
        PracticeItem(
            id: "gates",
            title: "Quantum Gates",
            subtitle: "Apply gates and see transformations",
            iconName: "square.grid.3x3.fill",
            difficulty: .intermediate,
            isUnlocked: true,
            completedCount: 2,
            totalCount: 8
        ),
        PracticeItem(
            id: "grover",
            title: "Grover Search",
            subtitle: "Quantum database search",
            iconName: "magnifyingglass.circle.fill",
            difficulty: .advanced,
            isUnlocked: false,
            completedCount: 0,
            totalCount: 4
        )
    ]
}
