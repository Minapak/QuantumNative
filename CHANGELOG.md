# Changelog

All notable changes to QuantumNative will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.1.0] - 2026-01-15

### Added
- **Privacy Policy** for App Store submission
- **Production API endpoints** configured for Release builds
  - `https://api.swiftquantum.tech` (Main API)
  - `https://bridge.swiftquantum.tech` (QuantumBridge)
- **Instant language switching** without app restart
- **OnboardingView redesign** with QuantumNative branding

### Changed
- Renamed project from QuantumAcademy to **QuantumNative**
- Updated all internal references and bundle identifiers
- API URLs now switch between DEBUG (localhost) and RELEASE (production)

### Fixed
- Language switching now takes effect immediately
- Onboarding layout issues in safe area

---

## [2.0.2] - 2026-01-11

### Added
- **DEV mode premium bypass** for testing all features in DEBUG builds
- **Admin login system** with offline mode support
  - Email: `admin@swiftquantum.io`
  - Password: `QuantumAdmin2026!`
- Complete architecture documentation

### Changed
- DEV mode badge moved to top-right corner
- Premium features auto-unlocked in DEBUG mode
- All 13 learning levels accessible in DEV mode

### Fixed
- QA/QC verification pass completed
- All button functionality verified

---

## [2.0.1] - 2026-01-08

### Added
- **DEV mode badge** (top-right corner) with Miami Sunrise gradient
- Expandable badge showing development status

### Fixed
- OnboardingView layout issues
- Safe area handling for tutorial steps

---

## [2.0.0] - 2026-01-01

### Added
- **The Quantum Odyssey** - Complete platform redesign
- **4-Frame Navigation System**:
  1. **Campus Hub** - 13-level learning roadmap (beginner to advanced)
  2. **Laboratory** - Interactive Bloch sphere and quantum gates
  3. **Bridge Terminal** - IBM QPU deployment and hardware comparison
  4. **Portfolio** - O1 visa evidence dashboard with radar charts
- **5-Language Localization** with natural expressions:
  - English (en) - 780+ keys
  - Korean (ko) - 780+ keys
  - Japanese (ja) - 860+ keys
  - Chinese Simplified (zh-Hans) - 860+ keys
  - German (de) - 860+ keys
- **Solar Agent AI Companion**:
  - 5 message types (Encouragement, Tips, Celebration, Challenge, Fire Boost)
  - Fire Energy system (0-100%)
  - Expertise level adaptation (beginner/intermediate/advanced)
- **GlobalBridgeConsoleView** - QuantumBridge service integration
- **QuantumCareerPassportView** - O1 visa evidence documentation
- **Radar Chart visualization** for skill assessment

### Changed
- Complete UI/UX redesign with Apple HIG compliance
- Miami Sunrise gradient theme system
- Tab bar with glass morphism effects

---

## [1.5.0] - 2025-12-15

### Added
- **Harvard-MIT 2026 Research Integration**
  - 3,000 Qubit Array simulation
  - 2+ hour continuous operation mode
  - 96+ Logical Qubits fault-tolerant architecture
  - 99.85% Fidelity with active error correction
- **Noise Model System**:
  - Dephasing (T2 decay)
  - Relaxation (T1 decay)
  - Gate error rate
  - Atom loss rate (Harvard-MIT core innovation)
- **Error Correction Codes**:
  - Surface Code (threshold ~1%)
  - Steane [[7,1,3]]
  - Shor [[9,1,3]]
  - Color Code
  - BOSS Code (2026 research)
- **Optical Lattice Conveyor Belt** atom replenishment simulation

### Changed
- QuantumCircuit engine upgraded with noise simulation
- Continuous operation mode with 2+ hour runtime

---

## [1.4.0] - 2025-12-01

### Added
- **StoreKit 2 Integration**
  - Pro Monthly ($9.99)
  - Pro Yearly ($71.88 - 40% off)
  - Premium Monthly ($29.99)
  - Premium Yearly ($215.88 - 40% off)
- **PaywallView** with product cards
- **SubscriptionManager** for persistent storage
- **Receipt verification** API endpoint

### Changed
- Subscription tiers affect qubit limits:
  - Free: 8 qubits
  - Pro: 64 qubits, 100 credits/month
  - Premium: 256 qubits, 1000 credits/month, IBM QPU access

---

## [1.3.0] - 2025-11-15

### Added
- **QuantumBridgeService** for cloud integration
- **Real-time noise visualization**
- **Job submission and polling system**
- **Terminal log system** with color-coded messages
- **User evidence persistence** for portfolio

### Changed
- API client upgraded with WebSocket support
- Job history tracking implemented

---

## [1.2.0] - 2025-11-01

### Added
- **AuthService** with JWT authentication
- **KeychainService** for secure token storage
- **AuthenticationView** with Sign In/Sign Up forms
- **Password reset** functionality
- **Email verification** support

### Changed
- API endpoints migrated to v1 structure
- User profile loading on app launch

---

## [1.1.0] - 2025-10-15

### Added
- **Quantum Gates Implementation**:
  - Hadamard (H)
  - Pauli-X, Y, Z
  - Phase (S) and T gates
  - CNOT, SWAP, Toffoli
- **State Vector Simulation** with complex amplitudes
- **Measurement with state collapse**
- **Bloch Sphere 3D visualization** (SceneKit)

### Changed
- QuantumCircuit class made @MainActor for SwiftUI compatibility
- Gate operations optimized for state vector manipulation

---

## [1.0.0] - 2025-10-01

### Added
- Initial release of SwiftQuantumLearning
- **MVVM Architecture** with SwiftUI
- **HomeView** with daily learning dashboard
- **LearnView** with curriculum tracks
- **PracticeView** with interactive exercises
- **ExploreView** for concept browsing
- **ProfileView** with user statistics
- **XP and Achievement system**
- **Progress tracking** with UserDefaults
- **Dark mode** support
- **QuantumTheme** design system

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 2.1.0 | 2026-01-15 | Production API, Privacy Policy, Instant language switch |
| 2.0.2 | 2026-01-11 | DEV mode bypass, Admin login, QA/QC pass |
| 2.0.1 | 2026-01-08 | DEV badge, Onboarding fixes |
| 2.0.0 | 2026-01-01 | The Quantum Odyssey, 4-frame nav, 5 languages |
| 1.5.0 | 2025-12-15 | Harvard-MIT 2026 research integration |
| 1.4.0 | 2025-12-01 | StoreKit 2, Subscription tiers |
| 1.3.0 | 2025-11-15 | QuantumBridge cloud integration |
| 1.2.0 | 2025-11-01 | Authentication system |
| 1.1.0 | 2025-10-15 | Quantum gates, Bloch sphere |
| 1.0.0 | 2025-10-01 | Initial release |

---

## Roadmap

### Planned for v2.2.0
- [ ] Apple Watch companion app
- [ ] Widget support for learning reminders
- [ ] Push notifications for streak maintenance
- [ ] iCloud sync for cross-device progress

### Planned for v3.0.0
- [ ] AR visualization mode
- [ ] Multi-user collaboration
- [ ] Real IBM QPU integration (production)
- [ ] Certificate generation for completed courses
