//
//  ConceptDetailView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Concept Detail View
struct ConceptDetailView: View {
    let conceptId: String
    @State private var isBookmarked = false
    
    var conceptData: ConceptData {
        ConceptData.getConcept(for: conceptId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Formula if available
                if let formula = conceptData.formula {
                    formulaSection(formula)
                }
                
                // Description
                descriptionSection
                
                // Key Points
                keyPointsSection
                
                // Related Concepts
                relatedConceptsSection
            }
            .padding()
        }
        .background(Color.bgDark)
        .navigationTitle(conceptData.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isBookmarked.toggle() }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.quantumCyan)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(conceptData.category)
                .font(.caption)
                .foregroundColor(.quantumCyan)
            
            Text(conceptData.title)
                .font(.largeTitle.bold())
                .foregroundColor(.textPrimary)
        }
    }
    
    private func formulaSection(_ formula: String) -> some View {
        VStack(spacing: 12) {
            Text("Mathematical Representation")
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            Text(formula)
                .font(.title3.monospaced())
                .foregroundColor(.quantumCyan)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        Text(conceptData.description)
            .font(.body)
            .foregroundColor(.textSecondary)
            .lineSpacing(6)
    }
    
    private var keyPointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(conceptData.keyPoints, id: \.self) { point in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color.quantumCyan)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    
                    Text(point)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var relatedConceptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Concepts")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(conceptData.relatedConcepts, id: \.self) { concept in
                        NavigationLink(destination: ConceptDetailView(conceptId: concept.lowercased())) {
                            Text(concept)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.bgCard)
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Concept Data Model
struct ConceptData {
    let title: String
    let category: String
    let description: String
    let formula: String?
    let keyPoints: [String]
    let relatedConcepts: [String]
    
    static func getConcept(for id: String) -> ConceptData {
        // Sample data - in real app, this would come from a database
        switch id {
        case "qubit":
            return ConceptData(
                title: "Qubit",
                category: "Fundamentals",
                description: "A qubit is the basic unit of quantum information...",
                formula: "|ψ⟩ = α|0⟩ + β|1⟩",
                keyPoints: [
                    "Can be in superposition",
                    "Measurement collapses state",
                    "Represented on Bloch sphere"
                ],
                relatedConcepts: ["Superposition", "Measurement", "Bloch Sphere"]
            )
        default:
            return ConceptData(
                title: "Quantum Concept",
                category: "General",
                description: "Description of the quantum concept...",
                formula: nil,
                keyPoints: ["Key point 1", "Key point 2"],
                relatedConcepts: ["Related 1", "Related 2"]
            )
        }
    }
}