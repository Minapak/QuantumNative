//
//  ExploreScreenView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Explore Screen View
//  Discovery section for exploring quantum computing concepts,
//  glossary, and additional resources.
//

import SwiftUI

// MARK: - Explore Item Model
/// Model for explore section items
struct ExploreCategory: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let items: [ExploreItem]
}

struct ExploreItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let type: ItemType
    
    enum ItemType {
        case concept
        case glossary
        case resource
        case tool
    }
}

// MARK: - Explore Screen View
/// Main explore screen with concept discovery
struct ExploreScreenView: View {
    
    // MARK: - State
    @State private var searchText = ""
    @State private var selectedCategory: ExploreCategory?
    @State private var animateContent = false
    
    // MARK: - Sample Data
    private let categories: [ExploreCategory] = [
        ExploreCategory(
            id: "fundamentals",
            title: "Fundamentals",
            subtitle: "Core quantum concepts",
            iconName: "atom",
            color: .quantumCyan,
            items: [
                ExploreItem(id: "qubit", title: "Qubit", subtitle: "The quantum bit", iconName: "circle.lefthalf.filled", type: .concept),
                ExploreItem(id: "superposition", title: "Superposition", subtitle: "Being in multiple states", iconName: "waveform", type: .concept),
                ExploreItem(id: "entanglement", title: "Entanglement", subtitle: "Quantum correlation", iconName: "link", type: .concept),
                ExploreItem(id: "measurement", title: "Measurement", subtitle: "Collapsing the wave function", iconName: "scope", type: .concept)
            ]
        ),
        ExploreCategory(
            id: "gates",
            title: "Quantum Gates",
            subtitle: "Operations on qubits",
            iconName: "square.grid.3x3",
            color: .quantumPurple,
            items: [
                ExploreItem(id: "pauli-x", title: "Pauli-X Gate", subtitle: "Quantum NOT gate", iconName: "x.circle", type: .concept),
                ExploreItem(id: "hadamard", title: "Hadamard Gate", subtitle: "Creates superposition", iconName: "h.circle", type: .concept),
                ExploreItem(id: "cnot", title: "CNOT Gate", subtitle: "Controlled NOT", iconName: "arrow.triangle.branch", type: .concept),
                ExploreItem(id: "phase", title: "Phase Gates", subtitle: "S, T, and Z gates", iconName: "dial.medium", type: .concept)
            ]
        ),
        ExploreCategory(
            id: "algorithms",
            title: "Algorithms",
            subtitle: "Quantum algorithms",
            iconName: "function",
            color: .quantumOrange,
            items: [
                ExploreItem(id: "deutsch", title: "Deutsch Algorithm", subtitle: "First quantum algorithm", iconName: "d.circle", type: .concept),
                ExploreItem(id: "grover", title: "Grover's Search", subtitle: "Quantum search", iconName: "magnifyingglass", type: .concept),
                ExploreItem(id: "shor", title: "Shor's Algorithm", subtitle: "Factoring integers", iconName: "divide", type: .concept),
                ExploreItem(id: "vqe", title: "VQE", subtitle: "Variational eigensolver", iconName: "waveform.path.ecg", type: .concept)
            ]
        ),
        ExploreCategory(
            id: "glossary",
            title: "Glossary",
            subtitle: "Terms and definitions",
            iconName: "book.closed",
            color: .completed,
            items: [
                ExploreItem(id: "amplitude", title: "Amplitude", subtitle: "Probability amplitude", iconName: "a.circle", type: .glossary),
                ExploreItem(id: "bloch-sphere", title: "Bloch Sphere", subtitle: "Visual representation", iconName: "globe", type: .glossary),
                ExploreItem(id: "decoherence", title: "Decoherence", subtitle: "Loss of quantum properties", iconName: "waveform.slash", type: .glossary),
                ExploreItem(id: "fidelity", title: "Fidelity", subtitle: "State accuracy measure", iconName: "checkmark.seal", type: .glossary)
            ]
        )
    ]
    
    /// Filtered categories based on search
    private var filteredCategories: [ExploreCategory] {
        if searchText.isEmpty {
            return categories
        }
        
        return categories.compactMap { category in
            let filteredItems = category.items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
            
            if filteredItems.isEmpty && !category.title.localizedCaseInsensitiveContains(searchText) {
                return nil
            }
            
            return ExploreCategory(
                id: category.id,
                title: category.title,
                subtitle: category.subtitle,
                iconName: category.iconName,
                color: category.color,
                items: filteredItems.isEmpty ? category.items : filteredItems
            )
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Search bar
                        searchBar
                        
                        // Featured concept card
                        if searchText.isEmpty {
                            featuredConcept
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        
                        // Categories
                        ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                            CategorySection(category: category)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                                .animation(
                                    .easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.2),
                                    value: animateContent
                                )
                        }
                        
                        // Resources section
                        if searchText.isEmpty {
                            resourcesSection
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                                .animation(.easeOut(duration: 0.4).delay(0.5), value: animateContent)
                        }
                        
                        // Bottom padding for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateContent = true
                }
            }
        }
    }
    
    // MARK: - Search Bar
    /// Search input field
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            
            TextField("Search concepts...", text: $searchText)
                .font(.body)
                .foregroundColor(.textPrimary)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Featured Concept
    /// Highlighted featured concept card
    private var featuredConcept: some View {
        NavigationLink(destination: ConceptDetailView(conceptId: "entanglement")) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Label("Featured", systemImage: "star.fill")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.quantumOrange)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.textTertiary)
                }
                
                // Content
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.quantumCyan)
                    
                    // Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantum Entanglement")
                            .font(.title3.bold())
                            .foregroundColor(.textPrimary)
                        
                        Text("Discover the 'spooky action at a distance' that connects quantum particles across space.")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.quantumCyan.opacity(0.5), .quantumPurple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Resources Section
    /// External resources and tools
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resources")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Resource cards
            VStack(spacing: 12) {
                ResourceCard(
                    title: "SwiftQuantum GitHub",
                    subtitle: "Browse the source code",
                    iconName: "chevron.left.forwardslash.chevron.right",
                    color: .quantumCyan,
                    url: "https://github.com/eunmin-park/SwiftQuantum"
                )
                
                ResourceCard(
                    title: "iOS Quantum Engineer Blog",
                    subtitle: "Articles and tutorials",
                    iconName: "doc.text",
                    color: .quantumPurple,
                    url: "https://eunminpark.hashnode.dev"
                )
                
                ResourceCard(
                    title: "Qiskit Documentation",
                    subtitle: "Official Qiskit docs",
                    iconName: "book",
                    color: .quantumOrange,
                    url: "https://qiskit.org/documentation"
                )
            }
        }
    }
}

// MARK: - Category Section
/// Section displaying a category with its items
struct CategorySection: View {
    let category: ExploreCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(category.color)
                
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: CategoryDetailView(category: category)) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            // Horizontal scroll of items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(category.items.prefix(5)) { item in
                        NavigationLink(destination: ConceptDetailView(conceptId: item.id)) {
                            ConceptCard(item: item, color: category.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Concept Card
/// Card displaying a single concept
struct ConceptCard: View {
    let item: ExploreItem
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: item.iconName)
                .font(.title2)
                .foregroundColor(color)
            
            // Title
            Text(item.title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            
            // Subtitle
            Text(item.subtitle)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
        }
        .frame(width: 140, alignment: .leading)
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Resource Card
/// Card for external resource link
struct ResourceCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}

// MARK: - Category Detail View
/// Full list view for a category
struct CategoryDetailView: View {
    let category: ExploreCategory
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(category.items) { item in
                        NavigationLink(destination: ConceptDetailView(conceptId: item.id)) {
                            ConceptRowView(item: item, color: category.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Concept Row View
/// Row item for concept list
struct ConceptRowView: View {
    let item: ExploreItem
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: item.iconName)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Concept Detail View
/// Detailed view for a single concept
struct ConceptDetailView: View {
    let conceptId: String
    
    @State private var isBookmarked = false
    
    // Sample content based on concept
    private var conceptData: (title: String, description: String, keyPoints: [String], formula: String?) {
        switch conceptId {
        case "qubit":
            return (
                "Qubit",
                "A qubit (quantum bit) is the fundamental unit of quantum information. Unlike a classical bit that can only be 0 or 1, a qubit can exist in a superposition of both states simultaneously. This property is what gives quantum computers their potential power.",
                [
                    "Can be in states |0⟩, |1⟩, or any combination",
                    "Represented on the Bloch sphere",
                    "Measurement collapses to 0 or 1",
                    "Physical implementations: photons, ions, superconducting circuits"
                ],
                "|ψ⟩ = α|0⟩ + β|1⟩"
            )
        case "superposition":
            return (
                "Superposition",
                "Superposition is a fundamental principle of quantum mechanics where a quantum system can exist in multiple states at the same time. It's only when we measure the system that it 'collapses' to one specific state.",
                [
                    "Enables quantum parallelism",
                    "Created using Hadamard gate",
                    "Destroyed upon measurement",
                    "Key to quantum speedup"
                ],
                "|+⟩ = (|0⟩ + |1⟩)/√2"
            )
        case "entanglement":
            return (
                "Quantum Entanglement",
                "Entanglement is a quantum mechanical phenomenon where two or more particles become interconnected. When particles are entangled, measuring one particle instantly affects the state of the other, regardless of the distance between them.",
                [
                    "Einstein called it 'spooky action at a distance'",
                    "Cannot be used for faster-than-light communication",
                    "Key resource for quantum computing",
                    "Created using CNOT gate after Hadamard"
                ],
                "|Φ+⟩ = (|00⟩ + |11⟩)/√2"
            )
        default:
            return (
                "Concept",
                "Detailed information about this quantum computing concept.",
                ["Key point 1", "Key point 2", "Key point 3"],
                nil
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(conceptData.title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.textPrimary)
                        
                        Text("Fundamental Concept")
                            .font(.subheadline)
                            .foregroundColor(.quantumCyan)
                    }
                    
                    // Formula card (if available)
                    if let formula = conceptData.formula {
                        formulaCard(formula)
                    }
                    
                    // Description
                    Text(conceptData.description)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(6)
                    
                    // Key points
                    keyPointsSection
                    
                    // Related concepts
                    relatedConceptsSection
                    
                    // Actions
                    actionsSection
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isBookmarked.toggle() }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .quantumOrange : .textSecondary)
                }
            }
        }
    }
    
    /// Formula display card
    private func formulaCard(_ formula: String) -> some View {
        VStack(spacing: 12) {
            Text("Mathematical Form")
                .font(.caption)
                .foregroundColor(.textTertiary)
            
            Text(formula)
                .font(.system(size: 24, design: .serif))
                .foregroundColor(.quantumCyan)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Key points section
    private var keyPointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(Array(conceptData.keyPoints.enumerated()), id: \.offset) { index, point in
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
    
    /// Related concepts section
    private var relatedConceptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Concepts")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    RelatedConceptChip(title: "Measurement", iconName: "scope")
                    RelatedConceptChip(title: "Gates", iconName: "square.grid.3x3")
                    RelatedConceptChip(title: "Bell States", iconName: "link")
                }
            }
        }
    }
    
    /// Actions section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: Text("Practice")) {
                HStack {
                    Image(systemName: "flask.fill")
                    Text("Practice This Concept")
                }
                .font(.headline)
                .foregroundColor(.bgDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.quantumCyan)
                .cornerRadius(12)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(.headline)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Related Concept Chip
/// Chip for related concept navigation
struct RelatedConceptChip: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.caption)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.bgCard)
        .cornerRadius(20)
    }
}

// MARK: - Preview Provider
#Preview("Explore Screen") {
    ExploreScreenView()
        .preferredColorScheme(.dark)
}

#Preview("Concept Detail - Qubit") {
    NavigationStack {
        ConceptDetailView(conceptId: "qubit")
    }
    .preferredColorScheme(.dark)
}

#Preview("Concept Detail - Entanglement") {
    NavigationStack {
        ConceptDetailView(conceptId: "entanglement")
    }
    .preferredColorScheme(.dark)
}
