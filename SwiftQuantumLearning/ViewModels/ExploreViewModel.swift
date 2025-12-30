//
//  ExploreViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: ExploreCategory?
    @Published var categories: [ExploreCategory] = []
    
    init() {
        loadCategories()
    }
    
    func loadCategories() {
        categories = ExploreCategory.sampleCategories
    }
    
    var filteredCategories: [ExploreCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { category in
            category.title.localizedCaseInsensitiveContains(searchText) ||
            category.items.contains { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct ExploreCategory: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let items: [ExploreItem]
    
    static let sampleCategories: [ExploreCategory] = [
        ExploreCategory(
            id: "fundamentals",
            title: "Fundamentals",
            subtitle: "Core quantum concepts",
            iconName: "atom",
            color: .quantumCyan,
            items: [
                ExploreItem(id: "qubit", title: "Qubit", subtitle: "The quantum bit", iconName: "circle.lefthalf.filled"),
                ExploreItem(id: "superposition", title: "Superposition", subtitle: "Multiple states", iconName: "waveform")
            ]
        )
    ]
}

struct ExploreItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
}