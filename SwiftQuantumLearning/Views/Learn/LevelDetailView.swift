//
//  LevelDetailView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Level Section Model
struct LevelSection: Identifiable {
    let id: String
    let title: String
    let type: SectionType
    let content: String
    var keyPoints: [String] = []
    var hasVisual: Bool = false
    var quizOptions: [String] = []
    var correctAnswerIndex: Int = 0
    var explanation: String = ""
    
    enum SectionType {
        case theory, interactive, quiz, practice
    }
}

// MARK: - Level Detail View
struct LevelDetailView: View {
    let level: LearningLevel
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var learningViewModel = LearnViewModel()
    
    @State private var currentSectionIndex = 0
    @State private var showingCompletionAlert = false
    @State private var animateContent = false
    
    // Sample sections for demo
    private var sections: [LevelSection] {
        [
            LevelSection(
                id: "s1",
                title: "Introduction",
                type: .theory,
                content: "Welcome to \(level.title)",
                keyPoints: ["Key point 1", "Key point 2"]
            ),
            LevelSection(
                id: "s2",
                title: "Practice",
                type: .practice,
                content: "Let's practice what we learned"
            ),
            LevelSection(
                id: "s3",
                title: "Quiz",
                type: .quiz,
                content: "Test your knowledge",
                quizOptions: ["Option A", "Option B", "Option C"],
                correctAnswerIndex: 0
            )
        ]
    }
    
    private var currentSection: LevelSection? {
        guard currentSectionIndex < sections.count else { return nil }
        return sections[currentSectionIndex]
    }
    
    private var isLastSection: Bool {
        currentSectionIndex >= sections.count - 1
    }
    
    private var progressFraction: CGFloat {
        guard !sections.isEmpty else { return 0 }
        return CGFloat(currentSectionIndex + 1) / CGFloat(sections.count)
    }
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                progressHeader
                contentArea
                navigationFooter
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Level \(level.number)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(level.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .alert("Level Complete! 🎉", isPresented: $showingCompletionAlert) {
            Button("Continue", role: .cancel) {
                completeLevel()
                dismiss()
            }
        } message: {
            Text("You earned \(level.xpReward) XP!")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Section \(currentSectionIndex + 1) of \(sections.count)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                    Text("+\(level.xpReward) XP")
                        .font(.caption.bold())
                }
                .foregroundColor(.quantumOrange)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * progressFraction,
                            height: 4
                        )
                        .animation(.easeOut(duration: 0.3), value: currentSectionIndex)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.bgCard)
    }
    
    private var contentArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                if let section = currentSection {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(section.title)
                            .font(.title2.bold())
                            .foregroundColor(.textPrimary)
                        
                        Text(section.content)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                        
                        if !section.keyPoints.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Key Points")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                
                                ForEach(section.keyPoints, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(Color.quantumCyan)
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 6)
                                        
                                        Text(point)
                                            .font(.subheadline)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.bgCard)
                            .cornerRadius(12)
                        }
                        
                        // Add interactive element based on section type
                        switch section.type {
                        case .practice:
                            practiceElement
                        case .quiz:
                            quizElement(section: section)
                        case .interactive:
                            interactiveElement
                        default:
                            EmptyView()
                        }
                    }
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                } else {
                    emptyStateView
                }
            }
            .padding(20)
        }
    }
    
    private var practiceElement: some View {
        VStack(spacing: 16) {
            Text("Try It Yourself")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Button(action: {}) {
                Label("Open Practice", systemImage: "play.circle.fill")
                    .font(.headline)
                    .foregroundColor(.bgDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.quantumCyan)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private func quizElement(section: LevelSection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Check")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(Array(section.quizOptions.enumerated()), id: \.offset) { index, option in
                Button(action: {}) {
                    HStack {
                        Text(option)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Circle()
                            .stroke(Color.quantumCyan, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var interactiveElement: some View {
        VStack(spacing: 16) {
            Text("Interactive Demo")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Image(systemName: "atom")
                .font(.system(size: 60))
                .foregroundColor(.quantumCyan)
                .padding(40)
                .background(
                    Circle()
                        .fill(Color.quantumCyan.opacity(0.1))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("Content Coming Soon")
                .font(.headline)
                .foregroundColor(.textSecondary)
            
            Text("We're preparing this level's content.")
                .font(.subheadline)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var navigationFooter: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 16) {
                if currentSectionIndex > 0 {
                    Button(action: goToPreviousSection) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: goToNextSection) {
                    HStack {
                        Text(isLastSection ? "Complete" : "Continue")
                        if !isLastSection {
                            Image(systemName: "chevron.right")
                        } else {
                            Image(systemName: "checkmark")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.bgDark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .background(Color.bgCard)
        }
    }
    
    private func goToPreviousSection() {
        withAnimation(.easeOut(duration: 0.3)) {
            animateContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentSectionIndex -= 1
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = true
            }
        }
    }
    
    private func goToNextSection() {
        if isLastSection {
            showingCompletionAlert = true
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentSectionIndex += 1
                withAnimation(.easeOut(duration: 0.3)) {
                    animateContent = true
                }
            }
        }
    }
    
    private func completeLevel() {
        // Update progress
        progressViewModel.completeLevel(String(level.id), xp: level.xpReward)
        // Update learning service
        learningViewModel.completeLevel(level.id)
    }
}
