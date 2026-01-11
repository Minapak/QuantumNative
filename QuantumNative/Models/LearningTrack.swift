//
//  LearningTrack.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct LearningTrack: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let levels: [LearningLevel]
    
    var totalXP: Int {
        levels.reduce(0) { $0 + $1.xpReward }
    }
}
