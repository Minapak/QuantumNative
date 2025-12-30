//
//  LearningLevel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Track Enum
enum Track: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var id: String { rawValue }
    
    var name: String { rawValue }
    
    var color: Color {
        switch self {
        case .beginner: return .quantumCyan
        case .intermediate: return .quantumPurple
        case .advanced: return .quantumOrange
        }
    }
    
    var primaryColor: Color { color }
    
    var secondaryColor: Color {
        switch self {
        case .beginner: return .quantumCyan.opacity(0.3)
        case .intermediate: return .quantumPurple.opacity(0.3)
        case .advanced: return .quantumOrange.opacity(0.3)
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.circle.fill"
        }
    }
}

// MARK: - Learning Level
struct LearningLevel: Identifiable {
    let id: Int
    let number: Int
    let title: String
    let name: String  // Added for compatibility
    let description: String
    let track: Track
    let xpReward: Int
    let estimatedTime: Int
    let prerequisites: [Int]
    let lessons: [Lesson]
    
    struct Lesson: Identifiable {
        let id: String
        let title: String
        let type: LessonType
        let content: String
        
        enum LessonType {
            case theory
            case practice
            case quiz
        }
    }
    
    // Static property for all levels
    static var allLevels: [LearningLevel] {
        sampleLevels
    }
    
    // Sample data
    static let sampleLevels: [LearningLevel] = [
        // Beginner Track
        LearningLevel(
            id: 1,
            number: 1,
            title: "Introduction to Quantum Computing",
            name: "Introduction to Quantum Computing",
            description: "Learn the basics of quantum computing and qubits",
            track: .beginner,
            xpReward: 100,
            estimatedTime: 30,
            prerequisites: [],
            lessons: [
                Lesson(id: "1-1", title: "What is Quantum Computing?", type: .theory, content: "Overview of quantum computing"),
                Lesson(id: "1-2", title: "Classical vs Quantum", type: .theory, content: "Differences between classical and quantum"),
                Lesson(id: "1-3", title: "Quiz: Basics", type: .quiz, content: "Test your understanding")
            ]
        ),
        LearningLevel(
            id: 2,
            number: 2,
            title: "Understanding Qubits",
            name: "Understanding Qubits",
            description: "Deep dive into quantum bits",
            track: .beginner,
            xpReward: 150,
            estimatedTime: 45,
            prerequisites: [1],
            lessons: [
                Lesson(id: "2-1", title: "Qubit States", type: .theory, content: "Understanding |0⟩ and |1⟩"),
                Lesson(id: "2-2", title: "Superposition", type: .practice, content: "Creating superposition states"),
                Lesson(id: "2-3", title: "Measurement", type: .practice, content: "Measuring qubits")
            ]
        ),
        // Intermediate Track
        LearningLevel(
            id: 3,
            number: 1,
            title: "Quantum Gates",
            name: "Quantum Gates",
            description: "Learn about quantum logic gates",
            track: .intermediate,
            xpReward: 200,
            estimatedTime: 60,
            prerequisites: [2],
            lessons: [
                Lesson(id: "3-1", title: "Pauli Gates", type: .theory, content: "X, Y, Z gates"),
                Lesson(id: "3-2", title: "Hadamard Gate", type: .practice, content: "Creating superposition"),
                Lesson(id: "3-3", title: "Gate Combinations", type: .practice, content: "Combining gates")
            ]
        ),
        // Advanced Track
        LearningLevel(
            id: 4,
            number: 1,
            title: "Quantum Algorithms",
            name: "Quantum Algorithms",
            description: "Implement quantum algorithms",
            track: .advanced,
            xpReward: 300,
            estimatedTime: 90,
            prerequisites: [3],
            lessons: [
                Lesson(id: "4-1", title: "Deutsch's Algorithm", type: .theory, content: "First quantum algorithm"),
                Lesson(id: "4-2", title: "Grover's Search", type: .practice, content: "Quantum search algorithm"),
                Lesson(id: "4-3", title: "Algorithm Implementation", type: .practice, content: "Build your own")
            ]
        )
    ]
}
