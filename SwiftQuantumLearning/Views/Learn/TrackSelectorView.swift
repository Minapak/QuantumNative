//
//  TrackSelectorView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Track Selector View
//  Allows users to select their learning track (beginner, intermediate, advanced, expert)
//

import SwiftUI

// MARK: - Track Selector View
/// Learning track selection interface
struct TrackSelectorView: View {
    
    // MARK: - Properties
    @EnvironmentObject var learningViewModel: LearningViewModel
    @Binding var selectedTrack: LearningLevel.Track
    @State private var expandedTrack: LearningLevel.Track?
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Choose Your Path")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Track cards
            VStack(spacing: 12) {
                ForEach(LearningLevel.Track.allCases, id: \.self) { track in
                    TrackCard(
                        track: track,
                        isSelected: selectedTrack == track,
                        isExpanded: expandedTrack == track,
                        levelsCount: learningViewModel.getLevelsCount(for: track),
                        completedCount: learningViewModel.getCompletedCount(for: track),
                        action: {
                            withAnimation(.spring()) {
                                selectedTrack = track
                                expandedTrack = expandedTrack == track ? nil : track
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Track Card
/// Individual track card component
struct TrackCard: View {
    
    // MARK: - Properties
    let track: LearningLevel.Track
    let isSelected: Bool
    let isExpanded: Bool
    let levelsCount: Int
    let completedCount: Int
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Main content
                HStack(spacing: 16) {
                    // Track icon
                    ZStack {
                        Circle()
                            .fill(
                                isSelected ?
                                LinearGradient(
                                    colors: [track.primaryColor, track.secondaryColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.bgCard, Color.bgCard],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: track.iconName)
                            .font(.title3)
                            .foregroundColor(isSelected ? .white : track.primaryColor)
                    }
                    
                    // Track info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(track.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.textPrimary)
                        
                        Text(track.description)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(isExpanded ? nil : 1)
                        
                        // Progress
                        HStack(spacing: 8) {
                            ProgressCapsule(
                                completed: completedCount,
                                total: levelsCount,
                                color: track.primaryColor
                            )
                            
                            Text("\(completedCount)/\(levelsCount) levels")
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? track.primaryColor : .textTertiary)
                        .font(.title3)
                }
                
                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                            .background(Color.textTertiary.opacity(0.2))
                        
                        // Prerequisites
                        if !track.prerequisites.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prerequisites")
                                    .font(.caption.bold())
                                    .foregroundColor(.textSecondary)
                                
                                ForEach(track.prerequisites, id: \.self) { prereq in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.quantumGreen)
                                        
                                        Text(prereq)
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                        }
                        
                        // Topics covered
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Topics Covered")
                                .font(.caption.bold())
                                .foregroundColor(.textSecondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(track.mainTopics, id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption2)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(track.primaryColor.opacity(0.1))
                                        .foregroundColor(track.primaryColor)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Estimated time
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                            
                            Text("Estimated: \(track.estimatedHours) hours")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? track.primaryColor.opacity(0.05) : Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? track.primaryColor.opacity(0.3) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Progress Capsule
/// Small progress indicator
struct ProgressCapsule: View {
    let completed: Int
    let total: Int
    let color: Color
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.2))
                    .frame(height: 4)
                
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * progress, height: 4)
            }
        }
        .frame(width: 60, height: 4)
    }
}

// MARK: - Flow Layout
/// Custom layout for wrapping content
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            spacing: spacing,
            subviews: subviews
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            spacing: spacing,
            subviews: subviews
        )
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]
        
        init(in width: CGFloat, spacing: CGFloat, subviews: Subviews) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            var frames: [CGRect] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                maxX = max(maxX, currentX)
            }
            
            self.size = CGSize(width: maxX, height: currentY + lineHeight)
            self.frames = frames
        }
    }
}

// MARK: - Track Extensions
extension LearningLevel.Track {
    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Start your quantum journey with the fundamentals"
        case .intermediate: return "Build on basics with deeper concepts and algorithms"
        case .advanced: return "Master complex quantum algorithms and applications"
        case .expert: return "Cutting-edge topics and research-level content"
        }
    }
    
    var iconName: String {
        switch self {
        case .beginner: return "star"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.fill"
        case .expert: return "sparkles"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .beginner: return .quantumGreen
        case .intermediate: return .quantumCyan
        case .advanced: return .quantumPurple
        case .expert: return .quantumRed
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .beginner: return .quantumCyan
        case .intermediate: return .quantumPurple
        case .advanced: return .quantumOrange
        case .expert: return .quantumPurple
        }
    }
    
    var prerequisites: [String] {
        switch self {
        case .beginner: return []
        case .intermediate: return ["Basic quantum concepts", "Linear algebra fundamentals"]
        case .advanced: return ["Quantum gates", "Circuit composition", "State vectors"]
        case .expert: return ["Advanced algorithms", "Quantum error correction", "Research methods"]
        }
    }
    
    var mainTopics: [String] {
        switch self {
        case .beginner:
            return ["Qubits", "Superposition", "Measurement", "Basic Gates"]
        case .intermediate:
            return ["Entanglement", "Bell States", "Quantum Circuits", "Simple Algorithms"]
        case .advanced:
            return ["Grover's Algorithm", "Shor's Algorithm", "QFT", "Error Correction"]
        case .expert:
            return ["QAOA", "VQE", "Quantum ML", "Topological Quantum"]
        }
    }
    
    var estimatedHours: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 20
        case .advanced: return 30
        case .expert: return 40
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        TrackSelectorView(selectedTrack: .constant(.beginner))
            .environmentObject(LearningViewModel())
            .padding()
            .background(Color.bgDark)
            .preferredColorScheme(.dark)
    }
}
