//
//  QubitState.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Complex Number
struct Complex: Codable {
    var real: Double
    var imaginary: Double
    
    static let zero = Complex(real: 0, imaginary: 0)
    static let one = Complex(real: 1, imaginary: 0)
    static let i = Complex(real: 0, imaginary: 1)
    
    var magnitude: Double {
        sqrt(real * real + imaginary * imaginary)
    }
    
    var conjugate: Complex {
        Complex(real: real, imaginary: -imaginary)
    }
}

// MARK: - Qubit State
class QubitState: ObservableObject {
    @Published var alpha: Complex
    @Published var beta: Complex
    
    init() {
        self.alpha = Complex.one
        self.beta = Complex.zero
    }
    
    var prob0: Double {
        alpha.magnitude * alpha.magnitude
    }
    
    var prob1: Double {
        beta.magnitude * beta.magnitude
    }
    
    func reset() {
        alpha = Complex.one
        beta = Complex.zero
    }
    
    func applyHadamard() {
        let sqrt2 = 1.0 / sqrt(2.0)
        let newAlpha = Complex(
            real: sqrt2 * (alpha.real + beta.real),
            imaginary: sqrt2 * (alpha.imaginary + beta.imaginary)
        )
        let newBeta = Complex(
            real: sqrt2 * (alpha.real - beta.real),
            imaginary: sqrt2 * (alpha.imaginary - beta.imaginary)
        )
        alpha = newAlpha
        beta = newBeta
    }
    
    func applyPauliX() {
        let temp = alpha
        alpha = beta
        beta = temp
    }
    
    func applyPauliY() {
        let newAlpha = Complex(
            real: -beta.imaginary,
            imaginary: beta.real
        )
        let newBeta = Complex(
            real: alpha.imaginary,
            imaginary: -alpha.real
        )
        alpha = newAlpha
        beta = newBeta
    }
    
    func applyPauliZ() {
        beta = Complex(real: -beta.real, imaginary: -beta.imaginary)
    }
    
    func applyPhaseS() {
        beta = Complex(real: -beta.imaginary, imaginary: beta.real)
    }
    
    func applyTGate() {
        let sqrt2 = 1.0 / sqrt(2.0)
        beta = Complex(
            real: sqrt2 * (beta.real - beta.imaginary),
            imaginary: sqrt2 * (beta.real + beta.imaginary)
        )
    }
}
