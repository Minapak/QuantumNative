//
//  PracticeViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

@MainActor
class PracticeViewModel: ObservableObject {
    @Published var practiceItems: [PracticeItem] = []
    @Published var selectedDifficulty: PracticeItem.Difficulty?
    @Published var isLoading = false
    
    init() {
        loadPracticeItems()
    }
    
    func loadPracticeItems() {
        practiceItems = PracticeItem.sampleItems
    }
    
    var filteredItems: [PracticeItem] {
        if let difficulty = selectedDifficulty {
            return practiceItems.filter { $0.difficulty == difficulty }
        }
        return practiceItems
    }
}