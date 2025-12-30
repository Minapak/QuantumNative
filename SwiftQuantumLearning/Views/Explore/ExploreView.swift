//
//  ExploreView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Explore Section Model (이름 변경)
struct ExploreSection: Identifiable {
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
struct ExploreView: View {
    
    // MARK: - State
    @State private var searchText = ""
    @State private var selectedSection: ExploreSection?
    @State private var animateContent = false
    
    // MARK: - Sample Data
    private let sections: [ExploreSection] = [
        ExploreSection(
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
        ExploreSection(
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
        ExploreSection(
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
        ExploreSection(
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
    
    /// Filtered sections based on search
    private var filteredSections: [ExploreSection] {
        if searchText.isEmpty {
            return sections
        }
        
        return sections.compactMap { section in
            let filteredItems = section.items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
            
            if filteredItems.isEmpty && !section.title.localizedCaseInsensitiveContains(searchText) {
                return nil
            }
            
            return ExploreSection(
                id: section.id,
                title: section.title,
                subtitle: section.subtitle,
                iconName: section.iconName,
                color: section.color,
                items: filteredItems.isEmpty ? section.items : filteredItems
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
                        
                        // Sections
                        ForEach(Array(filteredSections.enumerated()), id: \.element.id) { index, section in
                            ExploreSectionView(section: section)
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateContent = true
                }
            }
        }
    }
    
    // MARK: - Search Bar
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

// MARK: - Explore Section View (이름 변경)
struct ExploreSectionView: View {
    let section: ExploreSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: section.iconName)
                    .foregroundColor(section.color)
                
                Text(section.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: SectionDetailView(section: section)) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            // Horizontal scroll of items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.items.prefix(5)) { item in
                        NavigationLink(destination: ConceptDetailView(conceptId: item.id)) {
                            ConceptCard(item: item, color: section.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Concept Card
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

// MARK: - Section Detail View (이름 변경)
struct SectionDetailView: View {
    let section: ExploreSection
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(section.items) { item in
                        NavigationLink(destination: ConceptDetailView(conceptId: item.id)) {
                            ConceptRowView(item: item, color: section.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(section.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Concept Row View
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

// 나머지 코드는 그대로 유지 (ConceptDetailView, RelatedConceptChip 등)
