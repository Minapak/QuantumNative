//
//  LearningLevel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Learning Level Model
struct LearningLevel: Identifiable {
    let id: Int
    let number: Int
    let title: String
    let description: String
    let track: Track
    let topics: [String]
    let xpReward: Int
    let estimatedTime: Int // in minutes
    var status: LevelStatus = .locked
    
    // MARK: - Level Status
    enum LevelStatus {
        case locked
        case unlocked
        case inProgress
        case completed
        
        var color: Color {
            switch self {
            case .locked: return .gray
            case .unlocked: return .quantumCyan
            case .inProgress: return .quantumOrange
            case .completed: return .quantumGreen
            }
        }
        
        var icon: String {
            switch self {
            case .locked: return "lock.fill"
            case .unlocked: return "lock.open"
            case .inProgress: return "clock.fill"
            case .completed: return "checkmark.circle.fill"
            }
        }
    }
    
    // MARK: - Sample Data
    static let allLevels: [LearningLevel] = [
        // Beginner Track
        LearningLevel(
            id: 1,
            number: 1,
            title: "Introduction to Quantum",
            description: "Learn the basics of quantum computing",
            track: .beginner,
            topics: ["Qubits", "Superposition", "History"],
            xpReward: 100,
            estimatedTime: 15,
            status: .unlocked
        ),
        LearningLevel(
            id: 2,
            number: 2,
            title: "What is a Qubit?",
            description: "Understanding the quantum bit",
            track: .beginner,
            topics: ["Qubit states", "Bloch sphere", "Measurement"],
            xpReward: 120,
            estimatedTime: 20
        ),
        LearningLevel(
            id: 3,
            number: 3,
            title: "Quantum Superposition",
            description: "Exploring quantum states",
            track: .beginner,
            topics: ["Superposition principle", "Wave functions", "Probability"],
            xpReward: 130,
            estimatedTime: 25
        ),
        
        // Intermediate Track
        LearningLevel(
            id: 4,
            number: 1,
            title: "Quantum Gates",
            description: "Basic quantum operations",
            track: .intermediate,
            topics: ["Pauli gates", "Hadamard", "Phase gates"],
            xpReward: 150,
            estimatedTime: 30
        ),
        LearningLevel(
            id: 5,
            number: 2,
            title: "Quantum Circuits",
            description: "Building quantum circuits",
            track: .intermediate,
            topics: ["Circuit notation", "Gate sequences", "Reversibility"],
            xpReward: 160,
            estimatedTime: 35
        ),
        
        // Advanced Track
        LearningLevel(
            id: 6,
            number: 1,
            title: "Quantum Algorithms",
            description: "Introduction to quantum algorithms",
            track: .advanced,
            topics: ["Deutsch-Jozsa", "Grover's", "Shor's"],
            xpReward: 200,
            estimatedTime: 45
        ),
        LearningLevel(
            id: 7,
            number: 2,
            title: "Quantum Error Correction",
            description: "Dealing with quantum noise",
            track: .advanced,
            topics: ["Error types", "Correction codes", "Fault tolerance"],
            xpReward: 250,
            estimatedTime: 60
        ),
        
        // Mathematics Track
        LearningLevel(
            id: 8,
            number: 1,
            title: "Linear Algebra for QC",
            description: "Essential mathematical foundations",
            track: .mathematics,
            topics: ["Vectors", "Matrices", "Eigenvalues"],
            xpReward: 180,
            estimatedTime: 40
        )
    ]
}

// MARK: - Track Enum
enum Track: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case mathematics = "Mathematics"
    case algorithms = "Algorithms"
    case hardware = "Hardware"
    case applications = "Applications"
    
    var color: Color {
        switch self {
        case .beginner: return .quantumGreen
        case .intermediate: return .quantumCyan
        case .advanced: return .quantumPurple
        case .mathematics: return .quantumOrange
        case .algorithms: return .quantumYellow
        case .hardware: return .quantumRed
        case .applications: return .quantumCyan
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "graduationcap.fill"
        case .advanced: return "brain"
        case .mathematics: return "function"
        case .algorithms: return "flowchart.fill"
        case .hardware: return "cpu"
        case .applications: return "app.badge.fill"
        }
    }
}
