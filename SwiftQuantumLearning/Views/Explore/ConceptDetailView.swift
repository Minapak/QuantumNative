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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isBookmarked.toggle() }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.quantumCyan)
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(action: { isBookmarked.toggle() }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.quantumCyan)
                }
            }
            #endif
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
                description: "A qubit is the basic unit of quantum information. Unlike classical bits that must be either 0 or 1, qubits can exist in a superposition of both states simultaneously.",
                formula: "|ψ⟩ = α|0⟩ + β|1⟩",
                keyPoints: [
                    "Can exist in superposition of |0⟩ and |1⟩ states",
                    "Measurement collapses the quantum state",
                    "Represented as a point on the Bloch sphere",
                    "Physical implementations include photons, ions, and superconducting circuits"
                ],
                relatedConcepts: ["Superposition", "Measurement", "Bloch Sphere"]
            )
        case "superposition":
            return ConceptData(
                title: "Superposition",
                category: "Fundamentals",
                description: "Superposition is a fundamental principle of quantum mechanics where a quantum system can exist in multiple states simultaneously until measured.",
                formula: "|+⟩ = (|0⟩ + |1⟩)/√2",
                keyPoints: [
                    "Enables quantum parallelism",
                    "Created using Hadamard gate",
                    "Destroyed upon measurement",
                    "Key to quantum speedup"
                ],
                relatedConcepts: ["Qubit", "Hadamard Gate", "Measurement"]
            )
        case "entanglement":
            return ConceptData(
                title: "Entanglement",
                category: "Advanced Concepts",
                description: "Quantum entanglement is a phenomenon where two or more particles become interconnected, and the quantum state of each particle cannot be described independently.",
                formula: "|Φ+⟩ = (|00⟩ + |11⟩)/√2",
                keyPoints: [
                    "Einstein called it 'spooky action at a distance'",
                    "Cannot be used for faster-than-light communication",
                    "Key resource for quantum computing and quantum communication",
                    "Created using CNOT gate after Hadamard"
                ],
                relatedConcepts: ["Bell States", "CNOT Gate", "Quantum Teleportation"]
            )
        default:
            return ConceptData(
                title: "Quantum Concept",
                category: "General",
                description: "This is a fundamental concept in quantum computing that demonstrates the unique properties of quantum systems.",
                formula: nil,
                keyPoints: [
                    "Important quantum principle",
                    "Used in quantum algorithms",
                    "Differs from classical computing"
                ],
                relatedConcepts: ["Qubit", "Superposition", "Entanglement"]
            )
        }
    }
}
