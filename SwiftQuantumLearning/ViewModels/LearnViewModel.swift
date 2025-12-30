//
//  LearnViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - ViewModel: Learning
//  Manages learning content, tracks, and level selection.
//  Provides filtered views of content based on user selection.
//

import SwiftUI
import Combine

// MARK: - Learning ViewModel
/// ViewModel for managing learning content and navigation
@MainActor
class LearnViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All available learning levels
    @Published private(set) var allLevels: [LearningLevel] = LearningLevel.allLevels
    
    /// Currently selected track
    @Published var selectedTrack: Track = .beginner
    
    /// Currently selected level (for detail view)
    @Published var selectedLevel: LearningLevel?
    
    /// Search query for concept library
    @Published var searchQuery: String = ""
    
    /// Loading state
    @Published private(set) var isLoading: Bool = false
    
    /// Error message if any
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Levels filtered by selected track
    var levelsForSelectedTrack: [LearningLevel] {
        allLevels.filter { $0.track == selectedTrack }
    }
    
    /// All unique concepts from all levels
    var allConcepts: [String] {
        let concepts = allLevels.flatMap { $0.concepts }
        return Array(Set(concepts)).sorted()
    }
    
    /// Concepts filtered by search query
    var filteredConcepts: [String] {
        if searchQuery.isEmpty {
            return allConcepts
        }
        return allConcepts.filter { $0.lowercased().contains(searchQuery.lowercased()) }
    }
    
    /// Beginner track levels
    var beginnerLevels: [LearningLevel] {
        allLevels.filter { $0.track == .beginner }
    }
    
    /// Intermediate track levels
    var intermediateLevels: [LearningLevel] {
        allLevels.filter { $0.track == .intermediate }
    }
    
    /// Advanced track levels
    var advancedLevels: [LearningLevel] {
        allLevels.filter { $0.track == .advanced }
    }
    
    /// Track completion percentages
    var trackCompletionPercentages: [Track: Int] {
        var result: [Track: Int] = [:]
        
        for track in Track.allCases {
            let levels = allLevels.filter { $0.track == track }
            let completed = levels.filter { $0.isCompleted }.count
            let percentage = levels.isEmpty ? 0 : (completed * 100) / levels.count
            result[track] = percentage
        }
        
        return result
    }
    
    // MARK: - Initialization
    
    init() {
        loadLevels()
    }
    
    // MARK: - Data Loading
    
    /// Load levels from data source
    func loadLevels() {
        isLoading = true
        
        // In a real app, this might fetch from a server
        // For now, we use static data
        allLevels = LearningLevel.allLevels
        
        isLoading = false
    }
    
    /// Refresh levels (for pull-to-refresh)
    func refreshLevels() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        loadLevels()
        
        isLoading = false
    }
    
    // MARK: - Track Selection
    
    /// Select a track
    /// - Parameter track: The track to select
    func selectTrack(_ track: Track) {
        selectedTrack = track
        QuantumTheme.Haptics.selection()
    }
    
    /// Cycle to next track
    func nextTrack() {
        switch selectedTrack {
        case .beginner:
            selectedTrack = .intermediate
        case .intermediate:
            selectedTrack = .advanced
        case .advanced:
            selectedTrack = .beginner
        }
        QuantumTheme.Haptics.selection()
    }
    
    // MARK: - Level Selection
    
    /// Select a level
    /// - Parameter level: The level to select
    func selectLevel(_ level: LearningLevel) {
        selectedLevel = level
        QuantumTheme.Haptics.light()
    }
    
    /// Clear level selection
    func clearSelection() {
        selectedLevel = nil
    }
    
    /// Get level by ID
    /// - Parameter id: The level ID
    /// - Returns: The level if found
    func level(withId id: Int) -> LearningLevel? {
        allLevels.first { $0.id == id }
    }
    
    // MARK: - Level Progress Updates
    
    /// Update level with progress
    /// - Parameters:
    ///   - levelId: The level ID
    ///   - isCompleted: Whether level is completed
    ///   - progress: Progress percentage
    func updateLevelProgress(levelId: Int, isCompleted: Bool = false, progress: Int = 0) {
        if let index = allLevels.firstIndex(where: { $0.id == levelId }) {
            allLevels[index].isCompleted = isCompleted
            allLevels[index].progressPercentage = progress
            allLevels[index].isInProgress = progress > 0 && !isCompleted
        }
    }
    
    /// Sync with user progress
    /// - Parameter userProgress: The user's progress data
    func syncWithUserProgress(_ userProgress: UserProgress) {
        for (index, level) in allLevels.enumerated() {
            allLevels[index].isCompleted = userProgress.isLevelCompleted(level.id)
            
            if level.id == userProgress.currentLevelId {
                allLevels[index].isInProgress = true
                allLevels[index].progressPercentage = userProgress.currentLevelProgress
            }
        }
    }
    
    // MARK: - Search & Filtering
    
    /// Search for levels containing a concept
    /// - Parameter concept: The concept to search for
    /// - Returns: Levels containing the concept
    func levels(containing concept: String) -> [LearningLevel] {
        allLevels.filter { $0.concepts.contains(concept) }
    }
    
    /// Search levels by text
    /// - Parameter query: Search query
    /// - Returns: Matching levels
    func searchLevels(_ query: String) -> [LearningLevel] {
        guard !query.isEmpty else { return allLevels }
        
        let lowercasedQuery = query.lowercased()
        
        return allLevels.filter { level in
            level.name.lowercased().contains(lowercasedQuery) ||
            level.description.lowercased().contains(lowercasedQuery) ||
            level.concepts.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - Navigation Helpers
    
    /// Get next level after the given level
    /// - Parameter level: Current level
    /// - Returns: Next level in the same track, if any
    func nextLevel(after level: LearningLevel) -> LearningLevel? {
        let trackLevels = allLevels.filter { $0.track == level.track }
        guard let currentIndex = trackLevels.firstIndex(where: { $0.id == level.id }),
              currentIndex + 1 < trackLevels.count else {
            return nil
        }
        return trackLevels[currentIndex + 1]
    }
    
    /// Get previous level before the given level
    /// - Parameter level: Current level
    /// - Returns: Previous level in the same track, if any
    func previousLevel(before level: LearningLevel) -> LearningLevel? {
        let trackLevels = allLevels.filter { $0.track == level.track }
        guard let currentIndex = trackLevels.firstIndex(where: { $0.id == level.id }),
              currentIndex > 0 else {
            return nil
        }
        return trackLevels[currentIndex - 1]
    }
}

// MARK: - Preview Helper
extension LearnViewModel {
    /// Sample ViewModel for previews
    static var sample: LearnViewModel {
        let vm = LearnViewModel()
        // Mark first two levels as completed
        vm.updateLevelProgress(levelId: 1, isCompleted: true, progress: 100)
        vm.updateLevelProgress(levelId: 2, isCompleted: true, progress: 100)
        vm.updateLevelProgress(levelId: 3, isCompleted: false, progress: 45)
        return vm
    }
}

// MARK: - Preview Provider
#Preview("Learn ViewModel Demo") {
    struct LearningDemo: View {
        @StateObject private var viewModel = LearnViewModel.sample
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Track Selector
                        HStack(spacing: 12) {
                            ForEach(Track.allCases, id: \.self) { track in
                                Button(action: { viewModel.selectTrack(track) }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: track.iconName)
                                            .font(.title2)
                                        Text(track.shortName)
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.selectedTrack == track
                                            ? track.color.opacity(0.2)
                                            : Color.bgCard
                                    )
                                    .foregroundColor(
                                        viewModel.selectedTrack == track
                                            ? track.color
                                            : .textSecondary
                                    )
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Levels for Selected Track
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.selectedTrack.displayName)
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.levelsForSelectedTrack) { level in
                                LevelRowView(level: level) {
                                    viewModel.selectLevel(level)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Concepts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Concepts")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(viewModel.allConcepts.prefix(8), id: \.self) { concept in
                                    Text(concept)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.quantumCyan.opacity(0.1))
                                        .foregroundColor(.quantumCyan)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color.bgDark)
                .navigationTitle("Learn")
            }
        }
    }
    
    return LearningDemo()
}

// Helper view for preview
struct LevelRowView: View {
    let level: LearningLevel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status icon
                Image(systemName: level.statusIconName)
                    .font(.title2)
                    .foregroundColor(level.statusColor)
                    .frame(width: 40)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(level.number): \(level.name)")
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Progress
                if level.progressPercentage > 0 {
                    Text("\(level.progressPercentage)%")
                        .font(.caption.bold())
                        .foregroundColor(.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}
