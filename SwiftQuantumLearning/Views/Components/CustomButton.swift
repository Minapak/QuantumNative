//
//  CustomButton.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Custom Button Styles
/// Quantum-themed button styles

// MARK: - Quantum Button
struct QuantumButton: View {
    
    // MARK: - Properties
    let title: String
    let icon: String?
    let style: ButtonVariant
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonVariant {
        case primary
        case secondary
        case tertiary
        case danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .quantumCyan
            case .secondary: return .bgCard
            case .tertiary: return .clear
            case .danger: return .red
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .bgDark
            case .secondary: return .quantumCyan
            case .tertiary: return .quantumCyan
            case .danger: return .white
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .secondary: return .quantumCyan
            case .tertiary: return nil
            default: return nil
            }
        }
    }
    
    // MARK: - Initialization
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            QuantumTheme.Haptics.light()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Group {
                    if style == .primary {
                        LinearGradient(
                            colors: [style.backgroundColor, style.backgroundColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        style.backgroundColor
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor ?? Color.clear, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            QuantumTheme.Haptics.medium()
            action()
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [.quantumCyan, .quantumPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            withAnimation(.spring()) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    init(
        icon: String,
        size: CGFloat = 24,
        color: Color = .quantumCyan,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        QuantumButton("Continue", icon: "arrow.right") {
            print("Primary tapped")
        }
        
        QuantumButton("Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        QuantumButton("Text Button", style: .tertiary) {
            print("Tertiary tapped")
        }
        
        QuantumButton("Delete", icon: "trash", style: .danger) {
            print("Danger tapped")
        }
        
        HStack {
            FloatingActionButton(icon: "plus") {
                print("FAB tapped")
            }
            
            Spacer()
            
            IconButton(icon: "gearshape.fill") {
                print("Icon tapped")
            }
        }
    }
    .padding()
    .background(Color.bgDark)
}