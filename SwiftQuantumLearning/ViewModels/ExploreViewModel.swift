//
//  ExploreViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Explore Category Model
struct ExploreCategory: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let articles: [Article]
    
    struct Article: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let readTime: Int
        let difficulty: String
        let imageUrl: String?
    }
    
    static var sampleCategories: [ExploreCategory] {
        [
            ExploreCategory(
                title: "Quantum Basics",
                description: "Fundamental concepts and principles",
                icon: "atom",
                color: .quantumCyan,
                articles: [
                    Article(
                        title: "What is Quantum Computing?",
                        subtitle: "An introduction to the quantum world",
                        readTime: 5,
                        difficulty: "Beginner",
                        imageUrl: nil
                    ),
                    Article(
                        title: "Qubits vs Classical Bits",
                        subtitle: "Understanding the fundamental difference",
                        readTime: 8,
                        difficulty: "Beginner",
                        imageUrl: nil
                    )
                ]
            ),
            ExploreCategory(
                title: "Algorithms",
                description: "Quantum algorithms and applications",
                icon: "function",
                color: .quantumPurple,
                articles: [
                    Article(
                        title: "Shor's Algorithm",
                        subtitle: "Breaking RSA encryption with quantum computers",
                        readTime: 15,
                        difficulty: "Advanced",
                        imageUrl: nil
                    ),
                    Article(
                        title: "Grover's Search",
                        subtitle: "Finding needles in quantum haystacks",
                        readTime: 12,
                        difficulty: "Intermediate",
                        imageUrl: nil
                    )
                ]
            ),
            ExploreCategory(
                title: "Hardware",
                description: "Physical quantum systems",
                icon: "cpu",
                color: .completed,
                articles: [
                    Article(
                        title: "Superconducting Qubits",
                        subtitle: "IBM and Google's approach",
                        readTime: 10,
                        difficulty: "Intermediate",
                        imageUrl: nil
                    ),
                    Article(
                        title: "Ion Trap Systems",
                        subtitle: "Trapped ions for quantum computing",
                        readTime: 10,
                        difficulty: "Intermediate",
                        imageUrl: nil
                    )
                ]
            ),
            ExploreCategory(
                title: "Applications",
                description: "Real-world quantum use cases",
                icon: "lightbulb",
                color: .inProgress,
                articles: [
                    Article(
                        title: "Drug Discovery",
                        subtitle: "Quantum simulations for medicine",
                        readTime: 8,
                        difficulty: "Beginner",
                        imageUrl: nil
                    ),
                    Article(
                        title: "Cryptography",
                        subtitle: "Quantum-safe encryption methods",
                        readTime: 12,
                        difficulty: "Advanced",
                        imageUrl: nil
                    )
                ]
            )
        ]
    }
}

// MARK: - Explore View Model
@MainActor
class ExploreViewModel: ObservableObject {
    @Published var categories: [ExploreCategory] = []
    @Published var featuredArticles: [ExploreCategory.Article] = []
    @Published var searchText = ""
    @Published var selectedCategory: ExploreCategory?
    @Published var isLoading = false
    
    private let learningService = LearningService.shared
    
    init() {
        loadExploreContent()
    }
    
    func loadExploreContent() {
        isLoading = true
        
        DispatchQueue.main.async { [weak self] in
            self?.categories = ExploreCategory.sampleCategories
            self?.featuredArticles = self?.categories.flatMap { $0.articles }.shuffled() ?? []
            self?.isLoading = false
        }
    }
    
    var filteredCategories: [ExploreCategory] {
        if searchText.isEmpty {
            return categories
        }
        
        return categories.filter { category in
            category.title.localizedCaseInsensitiveContains(searchText) ||
            category.description.localizedCaseInsensitiveContains(searchText) ||
            category.articles.contains { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func selectCategory(_ category: ExploreCategory) {
        selectedCategory = category
    }
    
    func getRecommendedArticles() -> [ExploreCategory.Article] {
        // Return a mix of beginner and intermediate articles
        let allArticles = categories.flatMap { $0.articles }
        let beginnerArticles = allArticles.filter { $0.difficulty == "Beginner" }
        let intermediateArticles = allArticles.filter { $0.difficulty == "Intermediate" }
        
        var recommended: [ExploreCategory.Article] = []
        recommended.append(contentsOf: beginnerArticles.prefix(2))
        recommended.append(contentsOf: intermediateArticles.prefix(1))
        
        return recommended.shuffled()
    }
    
    func getArticlesForCategory(_ categoryId: UUID) -> [ExploreCategory.Article] {
        guard let category = categories.first(where: { $0.id == categoryId }) else {
            return []
        }
        return category.articles
    }
    
    func markArticleAsRead(_ articleId: UUID) {
        print("Marked article \(articleId) as read")
        // In a real app, this would update persistent storage
    }
}
