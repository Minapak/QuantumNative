//
//  TabBarView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Custom Tab Bar View
/// Custom tab bar with animations
struct TabBarView: View {
    
    // MARK: - Properties
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    @Namespace private var animation
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    selectedTab = index
                    QuantumTheme.Haptics.selection()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.bgCard
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
    }
}

// MARK: - Tab Item Model
struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with background
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.quantumCyan.opacity(0.2))
                            .frame(width: 56, height: 28)
                            .matchedGeometryEffect(id: "tabBackground", in: namespace)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .quantumCyan : .textTertiary)
                }
                .frame(height: 28)
                
                // Label
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .quantumCyan : .textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        
        TabBarView(
            selectedTab: .constant(0),
            tabs: [
                TabItem(title: "Home", icon: "house.fill"),
                TabItem(title: "Learn", icon: "book.fill"),
                TabItem(title: "Practice", icon: "flask.fill"),
                TabItem(title: "Explore", icon: "binoculars.fill"),
                TabItem(title: "Profile", icon: "person.fill")
            ]
        )
    }
    .background(Color.bgDark)
}