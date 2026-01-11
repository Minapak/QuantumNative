//
//  QuantumCommonsView.swift
//  QuantumNative
//
//  Quantum Commons - Public Circuit Gallery & Fork System
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import SwiftUI

struct QuantumCommonsView: View {
    @StateObject private var passportService = CareerPassportService.shared
    @State private var searchText = ""
    @State private var selectedFilter: CircuitFilter = .recent
    @State private var showingCircuitDetail: PublishedCircuit?

    enum CircuitFilter: String, CaseIterable {
        case recent = "Recent"
        case popular = "Popular"
        case mostCited = "Most Cited"
        case verified = "Verified"
    }

    var filteredCircuits: [PublishedCircuit] {
        var circuits = passportService.publicCircuits

        if !searchText.isEmpty {
            circuits = circuits.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        switch selectedFilter {
        case .recent:
            return circuits
        case .popular:
            return circuits.sorted { $0.runCount > $1.runCount }
        case .mostCited:
            return circuits.sorted { $0.citationCount > $1.citationCount }
        case .verified:
            return circuits.filter { $0.isVerified }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar

                    // Filter chips
                    filterChips

                    // Circuit grid
                    circuitGrid
                }
            }
            .navigationTitle("QuantumCommons")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await passportService.fetchPublicCircuits()
            }
            .sheet(item: $showingCircuitDetail) { circuit in
                CircuitDetailView(circuit: circuit)
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search circuits...", text: $searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CircuitFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFilter == filter ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter
                                ? Color.cyan
                                : Color.white.opacity(0.1)
                            )
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    private var circuitGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredCircuits) { circuit in
                    CircuitGridCard(circuit: circuit) {
                        showingCircuitDetail = circuit
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Circuit Grid Card

struct CircuitGridCard: View {
    let circuit: PublishedCircuit
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(circuit.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(circuit.doi)
                            .font(.caption2)
                            .foregroundColor(.cyan)
                    }

                    Spacer()

                    if circuit.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                // Stats
                HStack(spacing: 12) {
                    MiniStat(icon: "cpu", value: circuit.qubitCount)
                    MiniStat(icon: "arrow.branch", value: circuit.forkCount)
                    MiniStat(icon: "quote.bubble", value: circuit.citationCount)
                }

                // Tags
                if let tags = circuit.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(circuit.tagList.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 9))
                                    .foregroundColor(.cyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MiniStat: View {
    let icon: String
    let value: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(value)")
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.gray)
    }
}

// MARK: - Circuit Detail View

struct CircuitDetailView: View {
    let circuit: PublishedCircuit
    @Environment(\.dismiss) private var dismiss
    @StateObject private var passportService = CareerPassportService.shared
    @State private var isRunning = false
    @State private var showingForkConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(circuit.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                if circuit.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }

                            Text(circuit.doi)
                                .font(.subheadline)
                                .foregroundColor(.cyan)

                            if let author = circuit.authorName {
                                Text("by \(author)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        // Description
                        if let description = circuit.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        // Circuit Info
                        VStack(spacing: 12) {
                            CircuitInfoRow(label: "Qubits", value: "\(circuit.qubitCount)")
                            CircuitInfoRow(label: "Gates", value: "\(circuit.gatesCount)")
                            CircuitInfoRow(label: "Depth", value: "\(circuit.depth)")
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Impact Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Impact")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 20) {
                                ImpactColumn(icon: "arrow.branch", value: circuit.forkCount, label: "Forks")
                                ImpactColumn(icon: "quote.bubble", value: circuit.citationCount, label: "Citations")
                                ImpactColumn(icon: "play.circle", value: circuit.runCount, label: "Runs")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Tags
                        if !circuit.tagList.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                CommonsFlowLayout(spacing: 8) {
                                    ForEach(circuit.tagList, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .foregroundColor(.cyan)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.cyan.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    isRunning = true
                                    try? await passportService.runCircuit(doi: circuit.doi)
                                    isRunning = false
                                }
                            } label: {
                                HStack {
                                    if isRunning {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Image(systemName: "play.fill")
                                    }
                                    Text("Run")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan)
                                .cornerRadius(12)
                            }

                            Button {
                                showingForkConfirm = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.branch")
                                    Text("Fork")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
            .alert("Fork Circuit", isPresented: $showingForkConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Fork") {
                    Task {
                        try? await passportService.forkCircuit(doi: circuit.doi)
                        dismiss()
                    }
                }
            } message: {
                Text("This will create a copy of this circuit in your portfolio and add a citation to the original author.")
            }
        }
    }
}

struct CircuitInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct ImpactColumn: View {
    let icon: String
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)

            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Flow Layout

struct CommonsFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)

        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var points: [CGPoint] = []
        var height: CGFloat = 0

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                points.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            height = y + rowHeight
        }
    }
}

// MARK: - Preview

#Preview {
    QuantumCommonsView()
}
