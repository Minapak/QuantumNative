//
//  PracticeScreenView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Practice Screen View
//  Interactive practice area with quantum experiments and simulations.
//  Users can apply concepts learned in the Learn tab.
//

import SwiftUI

// MARK: - Practice Item Model
/// Represents a practice exercise/experiment
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
            case .beginner: return .completed
            case .intermediate: return .quantumCyan
            case .advanced: return .quantumPurple
            }
        }
    }
    
    var progressPercentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount)) * 100)
    }
}

// MARK: - Practice Screen View
/// Main practice screen with grid of experiments
struct PracticeScreenView: View {
    
    // MARK: - Environment
    @EnvironmentObject var progressViewModel: ProgressViewModel
    
    // MARK: - State
    @State private var selectedDifficulty: PracticeItem.Difficulty?
    @State private var animateItems = false
    
    // MARK: - Sample Data
    private let practiceItems: [PracticeItem] = [
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
            id: "bloch-sphere",
            title: "Bloch Sphere",
            subtitle: "Visualize qubit states in 3D",
            iconName: "globe",
            difficulty: .beginner,
            isUnlocked: true,
            completedCount: 5,
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
            id: "bell-state",
            title: "Bell States",
            subtitle: "Create entangled qubit pairs",
            iconName: "link.circle.fill",
            difficulty: .intermediate,
            isUnlocked: true,
            completedCount: 0,
            totalCount: 4
        ),
        PracticeItem(
            id: "deutsch",
            title: "Deutsch Algorithm",
            subtitle: "Quantum vs classical speedup",
            iconName: "bolt.circle.fill",
            difficulty: .advanced,
            isUnlocked: false,
            completedCount: 0,
            totalCount: 3
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
    
    /// Filtered items based on selected difficulty
    private var filteredItems: [PracticeItem] {
        if let difficulty = selectedDifficulty {
            return practiceItems.filter { $0.difficulty == difficulty }
        }
        return practiceItems
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter chips
                    filterChips
                    
                    // Practice grid
                    practiceGrid
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateItems = true
            }
        }
    }
    
    // MARK: - Filter Chips
    /// Horizontal scroll of difficulty filter chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All filter
                FilterChip(
                    title: "All",
                    isSelected: selectedDifficulty == nil,
                    color: .quantumCyan
                ) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedDifficulty = nil
                    }
                }
                
                // Difficulty filters
                ForEach(PracticeItem.Difficulty.allCases, id: \.self) { difficulty in
                    FilterChip(
                        title: difficulty.rawValue,
                        isSelected: selectedDifficulty == difficulty,
                        color: difficulty.color
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedDifficulty = difficulty
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Practice Grid
    /// Grid of practice items
    private var practiceGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    PracticeCardView(item: item)
                        .offset(y: animateItems ? 0 : 30)
                        .opacity(animateItems ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                            value: animateItems
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Tab bar padding
        }
    }
}

// MARK: - Filter Chip
/// Chip button for filtering
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isSelected ? .bgDark : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.bgCard)
                .cornerRadius(20)
        }
    }
}

// MARK: - Practice Card View
/// Card component for a practice item
struct PracticeCardView: View {
    let item: PracticeItem
    
    var body: some View {
        NavigationLink(destination: practiceDestination) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon and difficulty badge
                HStack {
                    // Icon
                    Image(systemName: item.iconName)
                        .font(.title)
                        .foregroundColor(item.isUnlocked ? item.difficulty.color : .textTertiary)
                    
                    Spacer()
                    
                    // Difficulty badge
                    Text(item.difficulty.rawValue)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(item.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.difficulty.color.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // Title
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(item.isUnlocked ? .textPrimary : .textTertiary)
                    .lineLimit(1)
                
                // Subtitle
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .top)
                
                // Progress or lock indicator
                if item.isUnlocked {
                    progressIndicator
                } else {
                    lockIndicator
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        item.completedCount == item.totalCount && item.isUnlocked
                            ? item.difficulty.color.opacity(0.5)
                            : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!item.isUnlocked)
    }
    
    /// Progress indicator for unlocked items
    private var progressIndicator: some View {
        VStack(spacing: 6) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.difficulty.color)
                        .frame(
                            width: geometry.size.width * CGFloat(item.progressPercentage) / 100,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            
            // Progress text
            HStack {
                Text("\(item.completedCount)/\(item.totalCount)")
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                if item.completedCount == item.totalCount {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.completed)
                }
            }
        }
    }
    
    /// Lock indicator for locked items
    private var lockIndicator: some View {
        HStack {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text("Complete previous levels")
                .font(.caption2)
        }
        .foregroundColor(.textTertiary)
    }
    
    /// Navigation destination based on practice type
    @ViewBuilder
    private var practiceDestination: some View {
        switch item.id {
        case "superposition":
            SuperpositionLabView()
        case "bloch-sphere":
            BlochSphereLabView()
        case "gates":
            QuantumGatesLabView()
        case "bell-state":
            BellStateLabView()
        default:
            ComingSoonView(title: item.title)
        }
    }
}

// MARK: - Superposition Lab View
/// Interactive superposition experiment
struct SuperpositionLabView: View {
    @Environment(\.dismiss) var dismiss
    @State private var alpha: Double = 1.0
    @State private var beta: Double = 0.0
    @State private var measurementResults: [Int] = []
    @State private var isMeasuring = false
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // State visualization
                    stateVisualization
                    
                    // Controls
                    controlsSection
                    
                    // Measurement section
                    measurementSection
                    
                    // Results histogram
                    if !measurementResults.isEmpty {
                        resultsHistogram
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Superposition Lab")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// State visualization card
    private var stateVisualization: some View {
        VStack(spacing: 16) {
            Text("Current State")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // State equation
            HStack(spacing: 8) {
                Text("|ψ⟩ = ")
                    .font(.system(.title2, design: .serif))
                
                Text(String(format: "%.2f", alpha))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.quantumCyan)
                
                Text("|0⟩ + ")
                    .font(.system(.title2, design: .serif))
                
                Text(String(format: "%.2f", beta))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.quantumPurple)
                
                Text("|1⟩")
                    .font(.system(.title2, design: .serif))
            }
            .foregroundColor(.textPrimary)
            
            // Probability bars
            HStack(spacing: 16) {
                // |0⟩ probability
                VStack(spacing: 8) {
                    Text("|0⟩")
                        .font(.headline.monospaced())
                        .foregroundColor(.quantumCyan)
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 60, height: 120)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.quantumCyan)
                            .frame(width: 60, height: 120 * CGFloat(alpha * alpha))
                    }
                    
                    Text("\(Int(alpha * alpha * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.textSecondary)
                }
                
                // |1⟩ probability
                VStack(spacing: 8) {
                    Text("|1⟩")
                        .font(.headline.monospaced())
                        .foregroundColor(.quantumPurple)
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 60, height: 120)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.quantumPurple)
                            .frame(width: 60, height: 120 * CGFloat(beta * beta))
                    }
                    
                    Text("\(Int(beta * beta * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Controls section
    private var controlsSection: some View {
        VStack(spacing: 16) {
            Text("Adjust State")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Slider for superposition
            VStack(spacing: 8) {
                HStack {
                    Text("|0⟩")
                        .foregroundColor(.quantumCyan)
                    Spacer()
                    Text("|1⟩")
                        .foregroundColor(.quantumPurple)
                }
                .font(.caption)
                
                Slider(value: Binding(
                    get: { beta * beta },
                    set: { newValue in
                        beta = sqrt(newValue)
                        alpha = sqrt(1 - newValue)
                    }
                ), in: 0...1)
                .tint(.quantumCyan)
            }
            
            // Preset buttons
            HStack(spacing: 12) {
                presetButton(label: "|0⟩", a: 1, b: 0)
                presetButton(label: "|+⟩", a: 0.707, b: 0.707)
                presetButton(label: "|1⟩", a: 0, b: 1)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Preset state button
    private func presetButton(label: String, a: Double, b: Double) -> some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.3)) {
                alpha = a
                beta = b
            }
        }) {
            Text(label)
                .font(.headline.monospaced())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .foregroundColor(.textPrimary)
                .cornerRadius(8)
        }
    }
    
    /// Measurement section
    private var measurementSection: some View {
        VStack(spacing: 16) {
            Text("Measure")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("Click to collapse the superposition")
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 16) {
                // Single measurement
                Button(action: measureOnce) {
                    Label("Measure Once", systemImage: "scope")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.quantumCyan)
                        .foregroundColor(.bgDark)
                        .cornerRadius(12)
                }
                
                // Multiple measurements
                Button(action: measureMany) {
                    Label("×100", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.bgCard)
                        .foregroundColor(.quantumCyan)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.quantumCyan, lineWidth: 1)
                        )
                }
                .disabled(isMeasuring)
            }
            
            // Clear button
            if !measurementResults.isEmpty {
                Button(action: { measurementResults = [] }) {
                    Text("Clear Results")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Results histogram
    private var resultsHistogram: some View {
        let zeros = measurementResults.filter { $0 == 0 }.count
        let ones = measurementResults.count - zeros
        
        return VStack(spacing: 16) {
            HStack {
                Text("Results")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(measurementResults.count) measurements")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            HStack(spacing: 24) {
                // |0⟩ count
                VStack(spacing: 8) {
                    Text("\(zeros)")
                        .font(.title.bold())
                        .foregroundColor(.quantumCyan)
                    Text("|0⟩")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(Int(Double(zeros) / Double(measurementResults.count) * 100))%")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                
                // |1⟩ count
                VStack(spacing: 8) {
                    Text("\(ones)")
                        .font(.title.bold())
                        .foregroundColor(.quantumPurple)
                    Text("|1⟩")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(Int(Double(ones) / Double(measurementResults.count) * 100))%")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Perform single measurement
    private func measureOnce() {
        let probability = alpha * alpha
        let result = Double.random(in: 0...1) < probability ? 0 : 1
        measurementResults.append(result)
    }
    
    /// Perform multiple measurements
    private func measureMany() {
        isMeasuring = true
        let probability = alpha * alpha
        
        for i in 0..<100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.01) {
                let result = Double.random(in: 0...1) < probability ? 0 : 1
                measurementResults.append(result)
                
                if i == 99 {
                    isMeasuring = false
                }
            }
        }
    }
}

// MARK: - Bloch Sphere Lab View
/// 3D Bloch sphere visualization (placeholder)
struct BlochSphereLabView: View {
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Placeholder for 3D visualization
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .frame(height: 300)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "globe")
                                .font(.system(size: 64))
                                .foregroundColor(.quantumCyan)
                            
                            Text("3D Bloch Sphere")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text("Interactive visualization coming soon")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    )
                
                Text("Rotate and interact with the Bloch sphere to understand qubit states in 3D space.")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Bloch Sphere")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Quantum Gates Lab View
/// Quantum gates practice (placeholder)
struct QuantumGatesLabView: View {
    var body: some View {
        ComingSoonView(title: "Quantum Gates Lab")
    }
}

// MARK: - Bell State Lab View
/// Bell state creation practice (placeholder)
struct BellStateLabView: View {
    var body: some View {
        ComingSoonView(title: "Bell State Lab")
    }
}

// MARK: - Coming Soon View
/// Placeholder for upcoming features
struct ComingSoonView: View {
    let title: String
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.quantumCyan)
                
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                Text("We're working hard to bring you this feature. Stay tuned!")
                    .font(.body)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
#Preview("Practice Screen") {
    PracticeScreenView()
        .environmentObject(ProgressViewModel.sample)
        .preferredColorScheme(.dark)
}

#Preview("Practice Card") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            PracticeCardView(item: PracticeItem(
                id: "test",
                title: "Superposition Lab",
                subtitle: "Create superposition states",
                iconName: "waveform.circle.fill",
                difficulty: .beginner,
                isUnlocked: true,
                completedCount: 3,
                totalCount: 5
            ))
            
            PracticeCardView(item: PracticeItem(
                id: "test2",
                title: "Grover Search",
                subtitle: "Quantum search algorithm",
                iconName: "magnifyingglass.circle.fill",
                difficulty: .advanced,
                isUnlocked: false,
                completedCount: 0,
                totalCount: 4
            ))
        }
        .padding()
    }
}

#Preview("Superposition Lab") {
    NavigationStack {
        SuperpositionLabView()
    }
    .preferredColorScheme(.dark)
}
