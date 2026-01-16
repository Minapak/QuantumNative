# QuantumNative Architecture

## Overview

QuantumNative is a premium quantum computing education platform built with **SwiftUI** following the **MVVM (Model-View-ViewModel)** architecture pattern. The app integrates Harvard-MIT 2026 research-based quantum simulation with real IBM QPU deployment capabilities.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Project Structure](#project-structure)
3. [Architecture Layers](#architecture-layers)
4. [Core Components](#core-components)
5. [Data Flow](#data-flow)
6. [Navigation System](#navigation-system)
7. [Service Layer](#service-layer)
8. [Quantum Simulation Engine](#quantum-simulation-engine)
9. [Localization System](#localization-system)
10. [Authentication & Security](#authentication--security)
11. [Payment System](#payment-system)
12. [API Integration](#api-integration)

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **Minimum iOS** | iOS 16.0+ |
| **Minimum macOS** | macOS 13.0+ |
| **Architecture** | MVVM |
| **Async** | Swift Concurrency (async/await) |
| **Payments** | StoreKit 2 |
| **Networking** | URLSession, WebSocket |
| **Security** | Keychain Services |
| **3D Graphics** | SceneKit (Bloch Sphere) |
| **Backend** | FastAPI (Python) |

---

## Project Structure

```
QuantumNative/
├── QuantumNativeApp.swift          # App entry point
├── Models/                          # Data models (12 files)
│   ├── QuantumCircuit.swift        # Core quantum simulation engine
│   ├── QubitState.swift            # Quantum state representation
│   ├── QuantumGate.swift           # Gate definitions
│   ├── Subscription.swift          # StoreKit 2 models
│   ├── AuthModels.swift            # Authentication DTOs
│   ├── UserProgress.swift          # XP & progress tracking
│   ├── Achievement.swift           # Badge system
│   ├── LearningTrack.swift         # Curriculum data
│   ├── LearningLevel.swift         # Level metadata
│   ├── PracticeItem.swift          # Practice problems
│   └── AdvancedLessons.swift       # Level 9-13 content
│
├── Views/                           # SwiftUI views (42 files)
│   ├── MainTabView.swift           # 4-tab navigation hub
│   ├── Odyssey/                    # Main frames
│   │   ├── CampusHubView.swift     # Level 1-13 roadmap
│   │   ├── InteractiveOdysseyView.swift  # Laboratory
│   │   ├── GlobalBridgeConsoleView.swift # IBM QPU
│   │   └── ExpertiseEvidenceDashboardView.swift
│   ├── Auth/
│   │   └── AuthenticationView.swift
│   ├── Learn/
│   │   ├── LearnView.swift
│   │   ├── LevelDetailView.swift
│   │   ├── AdvancedLessonView.swift
│   │   └── LearningStrategyView.swift
│   ├── Practice/
│   │   ├── PracticeView.swift
│   │   ├── ChallengesView.swift
│   │   └── Examples/*.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── SettingsView.swift
│   │   └── AchievementsView.swift
│   ├── Subscription/
│   │   └── PaywallView.swift
│   ├── Premium/
│   │   └── PremiumUpgradeView.swift
│   ├── QuantumFactory/
│   │   ├── QuantumFactoryView.swift
│   │   ├── NoiseVisualizationView.swift
│   │   └── HarvardMITDigitalTwinView.swift
│   ├── Passport/
│   │   ├── QuantumCareerPassportView.swift
│   │   ├── RadarChartView.swift
│   │   └── ReviewQueueView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   └── Components/
│       ├── TabBarView.swift
│       ├── ProgressRing.swift
│       ├── XPDisplay.swift
│       └── CustomButton.swift
│
├── ViewModels/                      # State management (8 files)
│   ├── AuthViewModel.swift
│   ├── HomeViewModel.swift
│   ├── LearnViewModel.swift
│   ├── PracticeViewModel.swift
│   ├── ExploreViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── ProgressViewModel.swift
│   └── AchievementViewModel.swift
│
├── Services/                        # Business logic (15 files)
│   ├── APIClient.swift             # HTTP client
│   ├── AuthService.swift           # Authentication
│   ├── StoreKitService.swift       # In-app purchases
│   ├── QuantumBridgeService.swift  # Cloud QPU integration
│   ├── QuantumTranslationManager.swift # Solar Agent + i18n
│   ├── KeychainService.swift       # Secure storage
│   ├── StorageService.swift        # UserDefaults
│   ├── LearningService.swift       # Curriculum
│   ├── ProgressService.swift       # XP tracking
│   ├── AchievementService.swift    # Badges
│   ├── CareerPassportService.swift # O1 evidence
│   ├── PDFReportService.swift      # Export
│   └── AgenticUpsellEngine.swift   # AI upsell
│
├── Design/
│   ├── QuantumTheme.swift          # Design tokens
│   └── Extensions.swift            # Color, View extensions
│
├── Persistence/
│   └── SubscriptionManager.swift   # Subscription state
│
├── Resources/
│   ├── Localizable.xcstrings       # 5-language localization
│   └── Assets.xcassets
│
└── QuantumNative.entitlements      # App capabilities
```

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    SwiftUI Views                     │    │
│  │  (MainTabView, CampusHubView, PaywallView, etc.)   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        VIEW MODELS                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │     @StateObject / @ObservableObject Classes        │    │
│  │  (AuthViewModel, LearnViewModel, ProgressViewModel) │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         SERVICES                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │    Singleton Services with async/await APIs         │    │
│  │  (APIClient, AuthService, StoreKitService, etc.)   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                          MODELS                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         Codable Structs & Business Logic            │    │
│  │  (QuantumCircuit, Subscription, UserProgress)       │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        PERSISTENCE                           │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │   Keychain    │  │  UserDefaults │  │   Backend     │   │
│  │   (Tokens)    │  │  (Settings)   │  │   (FastAPI)   │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. App Entry Point

```swift
// QuantumNativeApp.swift
@main
struct QuantumNativeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    // ... other ViewModels

    @AppStorage(OnboardingKeys.hasCompletedOnboarding)
    private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(progressViewModel)
            } else {
                OnboardingView()
            }
        }
    }
}
```

### 2. Environment Objects Flow

```
QuantumNativeApp
    │
    ├── AuthViewModel (login state, user info)
    ├── ProgressViewModel (XP, completed levels)
    ├── LearnViewModel (curriculum tracks)
    ├── AchievementViewModel (badges)
    ├── HomeViewModel (dashboard data)
    ├── PracticeViewModel (exercises)
    ├── ExploreViewModel (concepts)
    └── ProfileViewModel (settings)
    │
    └──► MainTabView
           │
           ├── CampusHubView (uses ProgressViewModel)
           ├── InteractiveOdysseyView (uses local state)
           ├── GlobalBridgeConsoleView (uses QuantumBridgeService)
           └── QuantumCareerPassportView (uses CareerPassportService)
```

---

## Navigation System

### 4-Frame Navigation (The Quantum Odyssey)

```swift
enum OdysseyTab: String, CaseIterable {
    case campus = "Campus"      // Free - 13 levels
    case laboratory = "Laboratory"  // Free - Bloch sphere
    case bridge = "Bridge"      // Premium - IBM QPU
    case portfolio = "Portfolio"  // Premium - O1 visa

    var requiresPremium: Bool {
        switch self {
        case .campus, .laboratory: return false
        case .bridge, .portfolio: return true
        }
    }
}
```

### Access Control Logic

```swift
// MainTabView.swift
private var canAccessPremiumTab: Bool {
    return authViewModel.isLoggedIn && storeKitService.isPremium
}
```

---

## Service Layer

### Singleton Pattern

All services use the singleton pattern for global access:

```swift
class AuthService {
    static let shared = AuthService()
    private init() { }
}

class StoreKitService {
    static let shared = StoreKitService()
    private init() { }
}
```

### Service Responsibilities

| Service | Responsibility |
|---------|----------------|
| `APIClient` | HTTP requests, token management |
| `AuthService` | Login, signup, logout, admin bypass |
| `StoreKitService` | Products, purchases, subscriptions |
| `QuantumBridgeService` | Job submission, polling, results |
| `KeychainService` | Secure token storage |
| `QuantumTranslationManager` | Solar Agent, localization |
| `ProgressService` | XP, levels, achievements |

---

## Quantum Simulation Engine

### QuantumCircuit Class

```swift
@MainActor
class QuantumCircuit: ObservableObject, Codable {
    @Published var qubitCount: Int
    @Published var gates: [QuantumGate]
    @Published var stateVector: [Complex]
    @Published var noiseModel: NoiseModel
    @Published var operationMode: ContinuousOperationMode

    // Harvard-MIT 2026 metrics
    @Published var fidelity: Double = 1.0
    @Published var atomReplenishmentCount: Int = 0
    @Published var coherenceTime: TimeInterval = 0
}
```

### Supported Gates

| Gate | Matrix | Qubits |
|------|--------|--------|
| Hadamard (H) | 1/√2 [[1,1],[1,-1]] | 1 |
| Pauli-X | [[0,1],[1,0]] | 1 |
| Pauli-Y | [[0,-i],[i,0]] | 1 |
| Pauli-Z | [[1,0],[0,-1]] | 1 |
| Phase (S) | [[1,0],[0,i]] | 1 |
| T | [[1,0],[0,e^(iπ/4)]] | 1 |
| CNOT | Control + target | 2 |
| SWAP | Exchange states | 2 |
| Toffoli | Double control | 3 |

### Noise Model (Harvard-MIT 2026)

```swift
struct NoiseModel: Codable {
    var dephasingRate: Double = 0.0005   // T2 decay
    var relaxationRate: Double = 0.001   // T1 decay
    var gateErrorRate: Double = 0.0001   // Single gate error
    var atomLossRate: Double = 0.00005   // Core innovation
    var continuousOperationCorrection: Double = 0.98
}
```

---

## Localization System

### 5 Languages with Solar Agent

```swift
class QuantumTranslationManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    @Published var currentExpertiseLevel: ExpertiseLevel = .beginner
    @Published var fireEnergyLevel: Double = 0.5

    enum Language: String, CaseIterable {
        case english = "en"
        case korean = "ko"
        case japanese = "ja"
        case chinese = "zh-Hans"
        case german = "de"
    }

    func getTerm(for key: String) -> String
    func getDescription(for key: String) -> String
    func getSolarAgentMessage(type: MessageType) -> String
}
```

### Solar Agent Message Types

1. **Encouragement** - Motivational messages
2. **Tips** - Learning suggestions
3. **Celebration** - Achievement recognition
4. **Challenge** - Pushing boundaries
5. **Fire Boost** - Energy renewal

---

## Authentication & Security

### Admin Bypass System

```swift
struct AdminCredentials {
    static let email = "admin@swiftquantum.io"
    static let password = "QuantumAdmin2026!"
}

// AuthService.swift
func login(email: String, password: String) async -> Bool {
    // Admin check first
    if email == AdminCredentials.email &&
       password == AdminCredentials.password {
        return await loginAsAdmin()
    }
    // Regular login...
}
```

### DEV Mode Premium Bypass

```swift
// StoreKitService.swift
var isPremium: Bool {
    #if DEBUG
    return true  // All premium features unlocked in DEV
    #endif

    if AuthService.shared.isAdmin {
        return true
    }
    return subscriptionInfo.isActive
}
```

### Token Storage

```swift
class KeychainService {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}
```

---

## Payment System

### StoreKit 2 Products

| Product ID | Tier | Price |
|------------|------|-------|
| `com.quantumnative.pro.monthly` | Pro | $9.99/mo |
| `com.quantumnative.pro.yearly` | Pro | $71.88/yr |
| `com.quantumnative.premium.monthly` | Premium | $29.99/mo |
| `com.quantumnative.premium.yearly` | Premium | $215.88/yr |

### Tier Benefits

| Feature | Free | Pro | Premium |
|---------|------|-----|---------|
| Levels | 1-5 | 1-13 | 1-13 |
| Max Qubits | 8 | 64 | 256 |
| Credits/month | 0 | 100 | 1000 |
| IBM QPU | No | Yes | Priority |
| Portfolio | No | No | Yes |

### Purchase Flow

```swift
// StoreKitService.swift
func purchase(_ product: Product) async -> PurchaseResult {
    let result = try await product.purchase()
    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)
        await updateSubscriptionStatus()
        await transaction.finish()
        return .success(transaction)
    case .userCancelled:
        return .userCancelled
    case .pending:
        return .pending
    }
}
```

---

## API Integration

### Base URLs

```swift
// APIClient.swift
private init() {
    #if DEBUG
    self.baseURL = "http://localhost:8000"
    self.bridgeURL = "http://localhost:8001"
    #else
    self.baseURL = "https://api.swiftquantum.tech"
    self.bridgeURL = "https://bridge.swiftquantum.tech"
    #endif
}
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/signup` | POST | User registration |
| `/api/v1/auth/login` | POST | User login |
| `/api/v1/users/me` | GET | Current user profile |
| `/api/v1/payment/verify` | POST | Receipt verification |
| `/api/v1/jobs` | POST | Submit quantum job |
| `/api/v1/jobs/{id}` | GET | Get job status |
| `/health` | GET | Bridge health check |
| `/bell-state` | POST | Run Bell state circuit |
| `/grover` | POST | Run Grover's algorithm |
| `/deutsch-jozsa` | POST | Run Deutsch-Jozsa |

### Response Models

```swift
struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
}

struct UserResponse: Codable {
    let id: Int
    let email: String
    let username: String
    let is_active: Bool
    let is_premium: Bool
    let subscription_tier: String?
}
```

---

## Design System

### Color Palette

```swift
extension Color {
    // Quantum Colors
    static let quantumCyan = Color(hex: "00CCFF")
    static let quantumPurple = Color(hex: "9966FF")
    static let quantumOrange = Color(hex: "FF9933")
    static let quantumGreen = Color(hex: "33E699")

    // Miami Sunrise Theme
    static let miamiSunrise = Color(hex: "FF7659")
    static let miamiGlow = Color(hex: "FFB366")
    static let solarGold = Color(hex: "FFD700")
    static let fireRed = Color(hex: "E64028")
    static let deepSeaNight = Color(hex: "0A0F26")

    // Backgrounds
    static let bgDark = Color(hex: "0D1117")
    static let bgCard = Color(hex: "161B22")
}
```

### Typography

```swift
struct QuantumTextStyle {
    static func title() -> Font
    static func headline() -> Font
    static func body() -> Font
    static func caption() -> Font
    static func small() -> Font
}
```

---

## Build Configurations

### Debug vs Release

| Setting | DEBUG | RELEASE |
|---------|-------|---------|
| API URL | localhost:8000 | api.swiftquantum.tech |
| Bridge URL | localhost:8001 | bridge.swiftquantum.tech |
| Premium Bypass | Yes | No |
| Admin Login | Yes | Yes |
| DEV Badge | Hidden | Hidden |

### Entitlements

```xml
<!-- QuantumNative.entitlements -->
<key>com.apple.developer.storekit.configuration</key>
<string>StoreKitConfiguration.storekit</string>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.quantumnative.app</string>
</array>
```

---

## Testing Strategy

### Unit Tests
- `SwiftQuantumLearningTests.swift` - Model tests
- Quantum gate operations
- State vector calculations

### UI Tests
- `SwiftQuantumLearningUITests.swift` - Flow tests
- Tab navigation
- Purchase flow

### Manual Testing
- Admin login: `admin@swiftquantum.io` / `QuantumAdmin2026!`
- All premium features accessible
- Full language switching

---

## Performance Considerations

1. **State Vector Size**: 2^n for n qubits (limit to 256)
2. **Noise Simulation**: Applied per gate operation
3. **WebSocket**: For real-time job updates
4. **Caching**: UserDefaults for subscription state
5. **Lazy Loading**: LazyVGrid for level display

---

## Future Architecture Plans

1. **CloudKit Sync** - Cross-device progress
2. **WidgetKit** - Learning reminders
3. **App Intents** - Siri shortcuts
4. **AR Foundation** - 3D qubit visualization
5. **Multi-user** - Collaborative learning
