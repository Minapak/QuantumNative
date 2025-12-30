//
//  RelatedContentView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Related Content View
struct RelatedContentView: View {
    let conceptId: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Related Levels
                relatedLevelsSection
                
                // Related Challenges
                relatedChallengesSection
                
                // External Resources
                externalResourcesSection
            }
            .padding()
        }
        .background(Color.bgDark)
        .navigationTitle("Related Content")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var relatedLevelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Lessons")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(0..<3) { _ in
                RelatedLevelCard()
            }
        }
    }
    
    private var relatedChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice Challenges")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<4) { _ in
                        RelatedChallengeCard()
                    }
                }
            }
        }
    }
    
    private var externalResourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("External Resources")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ResourceLink(
                    title: "Qiskit Textbook",
                    url: "https://qiskit.org/textbook",
                    icon: "book"
                )
                
                ResourceLink(
                    title: "arXiv Papers",
                    url: "https://arxiv.org",
                    icon: "doc.text"
                )
                
                ResourceLink(
                    title: "Video Tutorial",
                    url: "https://youtube.com",
                    icon: "play.rectangle"
                )
            }
        }
    }
}

// MARK: - Related Level Card
struct RelatedLevelCard: View {
    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .foregroundColor(.quantumCyan)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Level 3: Superposition")
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Learn about quantum superposition")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(8)
    }
}

// MARK: - Related Challenge Card
struct RelatedChallengeCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flask.fill")
                .font(.title2)
                .foregroundColor(.quantumPurple)
            
            Text("Bell State")
                .font(.caption.bold())
                .foregroundColor(.textPrimary)
            
            Text("+50 XP")
                .font(.caption2)
                .foregroundColor(.quantumYellow)
        }
        .frame(width: 100)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(8)
    }
}

// MARK: - Resource Link
struct ResourceLink: View {
    let title: String
    let url: String
    let icon: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.quantumCyan)
                
                Text(title)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(8)
        }
    }
}