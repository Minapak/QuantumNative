# QuantumNative iOS App Test Guide

## Overview

This document provides a comprehensive testing guide for the QuantumNative iOS application, including feature verification, admin testing procedures, and App Store submission preparation.

---

## Table of Contents

1. [Test Environment Setup](#test-environment-setup)
2. [Admin Credentials](#admin-credentials)
3. [Feature Testing Checklist](#feature-testing-checklist)
4. [Payment Flow Testing](#payment-flow-testing)
5. [Language Switching Test](#language-switching-test)
6. [Screenshot Capture Guide](#screenshot-capture-guide)
7. [Known Issues & Solutions](#known-issues--solutions)

---

## Test Environment Setup

### Prerequisites
- Xcode 16.0+
- iOS Simulator (iPhone 17 Pro recommended) or physical device
- macOS 14.0+

### Build Configuration
```bash
# Build for Simulator
xcodebuild -scheme QuantumNative -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' build

# Install on Simulator
xcrun simctl install "iPhone 17 Pro" /path/to/QuantumNative.app
xcrun simctl launch "iPhone 17 Pro" com.eunminpark.quantumnative
```

### Debug vs Release
| Setting | DEBUG | RELEASE |
|---------|-------|---------|
| API URL | localhost:8000 | api.swiftquantum.tech |
| Premium Bypass | Yes | No |
| Admin Login | Yes | Yes |

---

## Admin Credentials

**For full feature testing, use the admin account:**

| Field | Value |
|-------|-------|
| Email | `admin@swiftquantum.io` |
| Password | `QuantumAdmin2026!` |

### Admin Features
- Full premium access (all 13 levels unlocked)
- 1000 credits/month for QuantumBridge
- IBM QPU access enabled
- Portfolio features unlocked
- No subscription required

---

## Feature Testing Checklist

### 1. Onboarding Flow
- [ ] App launches to language selection screen
- [ ] 5 languages available (English, Korean, Japanese, Chinese, German)
- [ ] Language selection updates UI immediately
- [ ] Continue button shows localized text
- [ ] Welcome screen displays correctly
- [ ] User type selection works (Student, Developer, Parent, Sci-Fan, Investor)
- [ ] Tutorial screens navigate correctly
- [ ] Ready screen transitions to main app

### 2. Campus Hub (Tab 1)
- [ ] Welcome message displays user name
- [ ] XP counter shows total XP
- [ ] Progress bar shows completed levels (0/13)
- [ ] Level 1 (Introduction) is unlocked
- [ ] Levels 2-5 show lock icon (free tier)
- [ ] Levels 6-13 show "PRO" badge (premium tier)
- [ ] Solar Agent bubble appears with messages
- [ ] Tapping locked level shows appropriate message

### 3. Laboratory (Tab 2)
- [ ] Bloch sphere visualization loads
- [ ] Quantum gates palette displayed
- [ ] Can add qubits (up to limit based on tier)
- [ ] Gate operations animate correctly
- [ ] Measurement shows probability distribution
- [ ] Reset button clears circuit

### 4. Bridge Terminal (Tab 3) - Premium
- [ ] Hardware status indicator shows (Online/Offline)
- [ ] Credit balance displayed
- [ ] Job submission form works
- [ ] Algorithm selection (Bell State, Grover, Deutsch-Jozsa)
- [ ] Job queue shows submitted jobs
- [ ] Results display after completion
- [ ] Noise visualization works

### 5. Portfolio (Tab 4) - Premium
- [ ] Career passport displays
- [ ] Radar chart renders correctly
- [ ] Evidence cards show properly
- [ ] Export functionality works
- [ ] O1 visa metrics display

### 6. Profile & Settings
- [ ] Profile view shows user info
- [ ] Settings accessible
- [ ] Language picker opens
- [ ] Language change reflects immediately
- [ ] Logout functionality works
- [ ] Privacy Policy link works
- [ ] Terms of Service link works

---

## Payment Flow Testing

### StoreKit 2 Products
| Product ID | Tier | Price |
|------------|------|-------|
| `com.quantumnative.pro.monthly` | Pro | $9.99/mo |
| `com.quantumnative.pro.yearly` | Pro | $71.88/yr |
| `com.quantumnative.premium.monthly` | Premium | $29.99/mo |
| `com.quantumnative.premium.yearly` | Premium | $215.88/yr |

### Testing in Sandbox

1. **Set up Sandbox Account** in App Store Connect
2. **Sign out** of production App Store on device
3. **Launch app** and navigate to Paywall
4. **Select subscription** tier
5. **Authenticate** with sandbox credentials
6. **Verify** purchase completes
7. **Check** premium features unlock

### DEBUG Mode
In DEBUG builds, premium is automatically bypassed:
```swift
var isPremium: Bool {
    #if DEBUG
    return true  // Always premium in debug
    #endif
    // ...
}
```

### Testing Restore Purchases
1. Complete a sandbox purchase
2. Delete and reinstall app
3. Launch app and go to settings
4. Tap "Restore Purchases"
5. Verify subscription status restored

---

## Language Switching Test

### Supported Languages
| Code | Language | Native Name |
|------|----------|-------------|
| en | English | English |
| ko | Korean | 한국어 |
| ja | Japanese | 日本語 |
| zh-Hans | Chinese Simplified | 简体中文 |
| de | German | Deutsch |

### Test Procedure
1. Launch app fresh (delete UserDefaults)
2. On language selection screen, note default language
3. Select each language one by one
4. Verify "Continue" button text changes:
   - English: "Continue"
   - Korean: "계속"
   - Japanese: "続ける"
   - Chinese: "继续"
   - German: "Weiter"
5. Complete onboarding
6. Go to Settings > Language
7. Change language
8. Verify all UI elements update immediately

---

## Screenshot Capture Guide

### Required Sizes for App Store

**iPhone 6.5" Display:**
- 1242 × 2688 px (portrait)
- 2688 × 1242 px (landscape)
- Or 1284 × 2778 px / 2778 × 1284 px

**iPad 12.9" Display:**
- 2064 × 2752 px (portrait)
- 2752 × 2064 px (landscape)
- Or 2048 × 2732 px / 2732 × 2048 px

### Screenshot Checklist (per language)

1. **Onboarding** - Language selection with app logo
2. **Campus Hub** - 13-level roadmap with Solar Agent
3. **Laboratory** - Bloch sphere with quantum gates
4. **Bridge Terminal** - IBM QPU job submission
5. **Portfolio** - Radar chart with O1 evidence

### Capture Commands
```bash
# Capture current screen
xcrun simctl io "iPhone 17 Pro" screenshot ~/Desktop/screenshot.png

# Set language before capture
xcrun simctl spawn "iPhone 17 Pro" defaults write com.eunminpark.quantumnative "selectedLanguage" -string "en"
```

### Folder Structure
```
AppStoreScreenshots/
├── iPhone_6.5/
│   ├── en/
│   │   ├── 01_Onboarding.png
│   │   ├── 02_Campus_Hub.png
│   │   ├── 03_Laboratory.png
│   │   ├── 04_Bridge.png
│   │   └── 05_Portfolio.png
│   ├── ko/
│   ├── ja/
│   ├── zh-Hans/
│   └── de/
└── iPad_12.9/
    └── (same structure)
```

---

## Known Issues & Solutions

### Issue 1: Language not switching immediately
**Solution:** Implemented `LocalizationManager` with dynamic bundle switching. Language changes are now reflected instantly without app restart.

### Issue 2: Premium features not unlocking in DEBUG
**Solution:** StoreKitService.isPremium returns `true` in DEBUG builds automatically.

### Issue 3: Admin login fails with network error
**Solution:** Admin login works offline with mock user data. No backend connection required.

### Issue 4: Hardcoded URLs throughout codebase
**Solution:** Created `AppConfiguration.swift` to centralize all URLs and settings.

---

## API Endpoints Reference

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/signup` | POST | User registration |
| `/api/v1/auth/login` | POST | User login |
| `/api/v1/users/me` | GET | Current user profile |

### QuantumBridge
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Bridge health check |
| `/bell-state` | POST | Run Bell state circuit |
| `/grover` | POST | Run Grover's algorithm |
| `/deutsch-jozsa` | POST | Run Deutsch-Jozsa |

---

## Test Flow Summary

### Complete Test Path

```
1. Fresh Install
   ↓
2. Onboarding (5 screens)
   - Language Selection → Select English
   - Welcome → Continue
   - User Type → Select "Student"
   - Tutorial (4 pages)
   - Ready → Start Learning
   ↓
3. Campus Hub
   - View levels 1-13
   - Tap Level 1 → View detail sheet
   - Start learning → Complete lesson
   ↓
4. Laboratory
   - Add qubit → Apply H gate → Measure
   ↓
5. Profile → Login
   - Email: admin@swiftquantum.io
   - Password: QuantumAdmin2026!
   ↓
6. Bridge Terminal (Premium)
   - Submit Bell State job
   - View results
   ↓
7. Portfolio (Premium)
   - View radar chart
   - Check evidence cards
   ↓
8. Settings
   - Change language → Korean
   - Verify UI updates
   ↓
9. Logout
```

---

## Conclusion

This test guide covers all major features of the QuantumNative app. For any issues or questions, please contact the development team.

**Version:** 2.1.0
**Last Updated:** January 16, 2026
