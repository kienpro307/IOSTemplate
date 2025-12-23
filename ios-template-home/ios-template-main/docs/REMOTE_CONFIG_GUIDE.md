# Remote Config & Feature Flags Guide

Hướng dẫn toàn diện về Firebase Remote Config và Feature Flags system trong iOS Template Project.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Setup & Configuration](#setup--configuration)
4. [Remote Config Usage](#remote-config-usage)
5. [Feature Flags Usage](#feature-flags-usage)
6. [A/B Testing](#ab-testing)
7. [Best Practices](#best-practices)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)

---

## Overview

### Kiến trúc Remote Config

```
┌──────────────────────────────────────────────────┐
│         FeatureFlagManager                        │
│  (High-level API cho feature flags)              │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│     FirebaseRemoteConfigService                   │
│  (Low-level API cho remote config)               │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────┐
│         Firebase Remote Config                    │
│  (Cloud-based configuration)                     │
└──────────────────────────────────────────────────┘
```

### Components

1. **FeatureFlagManager**: High-level API để check feature flags
2. **FirebaseRemoteConfigService**: Low-level API để fetch và get config values
3. **RemoteConfigServiceProtocol**: Protocol định nghĩa remote config operations
4. **Firebase Remote Config**: Cloud service quản lý config values

### Use Cases

- **Feature Flags**: Enable/disable features remotely
- **A/B Testing**: Test different variations
- **Dynamic Configuration**: Update app behavior without new release
- **Gradual Rollout**: Roll out features to percentage of users
- **Emergency Kill Switch**: Disable problematic features instantly

---

## Quick Start

### 1. Fetch Remote Config (on app start)

```swift
// In AppDelegate or app initialization
Task {
    do {
        // Fetch latest config
        try await FirebaseRemoteConfigService.shared.fetch()
        print("✅ Remote Config updated")
    } catch {
        print("⚠️ Using cached config: \(error)")
    }
}
```

### 2. Check Feature Flags

```swift
import iOSTemplate

// Check if feature is enabled
if FeatureFlagManager.shared.isEnabled(.darkMode) {
    enableDarkMode()
}

// Check with detailed info
let config = FeatureFlagManager.shared.getConfig(for: .biometricLogin)
if config.isEnabled {
    print("Biometric login enabled via: \(config.source)")
    setupBiometricLogin()
}
```

### 3. Get Config Values

```swift
let service = FirebaseRemoteConfigService.shared

// Get typed values
let welcomeMessage = service.getString(
    forKey: "ui_welcome_message",
    defaultValue: "Welcome!"
)

let maxRetries = service.getInt(
    forKey: "max_login_attempts",
    defaultValue: 3
)

let isMaintenanceMode = service.getBool(
    forKey: "app_maintenance_mode",
    defaultValue: false
)
```

---

## Setup & Configuration

### Firebase Console Setup

#### 1. Create Remote Config Parameters

1. Mở [Firebase Console](https://console.firebase.google.com)
2. Project Settings → Remote Config
3. Click **Add parameter**

**Example Parameters**:

| Parameter Key | Type | Default Value |
|--------------|------|---------------|
| `feature_dark_mode_enabled` | Boolean | `true` |
| `feature_biometric_login_enabled` | Boolean | `true` |
| `ui_welcome_message` | String | `"Welcome to iOS Template!"` |
| `max_login_attempts` | Number | `5` |
| `app_maintenance_mode` | Boolean | `false` |

#### 2. Create Conditions (Optional)

**Target specific users**:
- App version (e.g., >= 1.5.0)
- Language (e.g., en, vi)
- Platform (iOS, Android)
- User percentile (e.g., 10% of users)
- Custom user properties

**Example Condition**:
```
Name: "Beta Users"
Applies if: User in audience "beta_testers"
Then:
  feature_new_onboarding_enabled = true
Otherwise:
  feature_new_onboarding_enabled = false
```

#### 3. Publish Changes

- Click **Publish changes**
- Add description (e.g., "Enable new onboarding for beta")
- Confirm

#### 4. Set Fetch Interval

**Default intervals**:
- **Debug**: 0 seconds (immediate)
- **Production**: 12 hours (43200 seconds)

**Change in code**:
```swift
// In FirebaseRemoteConfigService.setupRemoteConfig()
settings.minimumFetchInterval = 3600 // 1 hour
```

---

## Remote Config Usage

### Fetch Strategies

#### Strategy 1: Fetch on App Launch

```swift
// AppDelegate.swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    // Fetch config (background)
    Task {
        try? await FirebaseRemoteConfigService.shared.fetch()
    }

    return true
}
```

**Pros**: Config ready soon after launch
**Cons**: First launch uses defaults

#### Strategy 2: Fetch and Wait

```swift
// Before showing main UI
func loadApp() async {
    // Show splash screen

    do {
        // Wait for config
        try await FirebaseRemoteConfigService.shared.fetch()
        print("✅ Config loaded")
    } catch {
        print("⚠️ Using defaults: \(error)")
    }

    // Show main UI
    showMainUI()
}
```

**Pros**: Latest config before UI
**Cons**: Delays app start

#### Strategy 3: Periodic Refresh

```swift
// Refresh periodically (e.g., when app becomes active)
func applicationDidBecomeActive() {
    Task {
        try? await FirebaseRemoteConfigService.shared.fetch()
    }
}
```

**Pros**: Config stays fresh
**Cons**: Multiple network requests

### Get Values

#### Basic Types

```swift
let service = FirebaseRemoteConfigService.shared

// String
let message = service.getString(
    forKey: "ui_welcome_message",
    defaultValue: "Welcome!"
)

// Bool
let isEnabled = service.getBool(
    forKey: "feature_dark_mode_enabled",
    defaultValue: false
)

// Int
let maxAttempts = service.getInt(
    forKey: "max_login_attempts",
    defaultValue: 5
)

// Double
let timeout = service.getDouble(
    forKey: "api_timeout_seconds",
    defaultValue: 30.0
)
```

#### JSON Values

```swift
// Define model
struct AppConfig: Codable {
    let apiBaseURL: String
    let timeout: Int
    let retryCount: Int
}

// Get JSON config
if let config: AppConfig = service.getJSON(forKey: "app_config") {
    print("API URL: \(config.apiBaseURL)")
    print("Timeout: \(config.timeout)s")
}
```

**Firebase Console JSON**:
```json
{
  "apiBaseURL": "https://api.example.com",
  "timeout": 30,
  "retryCount": 3
}
```

### Predefined Keys

Use `RemoteConfigKey` constants:

```swift
// Instead of string literals
let message = service.getString(
    forKey: RemoteConfigKey.welcomeMessage,  // ✅ Type-safe
    defaultValue: "Welcome!"
)

// Instead of:
let message = service.getString(
    forKey: "ui_welcome_message",  // ❌ Error-prone
    defaultValue: "Welcome!"
)
```

**Available Keys**:
```swift
RemoteConfigKey.featureDarkMode
RemoteConfigKey.featureBiometricLogin
RemoteConfigKey.welcomeMessage
RemoteConfigKey.maxLoginAttempts
RemoteConfigKey.appForceUpdate
RemoteConfigKey.appMaintenanceMode
// ... and more
```

---

## Feature Flags Usage

### Check Features

#### Basic Check

```swift
// Simple boolean check
if FeatureFlagManager.shared.isEnabled(.darkMode) {
    applyDarkMode()
} else {
    applyLightMode()
}
```

#### Detailed Check

```swift
// Get configuration details
let config = FeatureFlagManager.shared.getConfig(for: .biometricLogin)

print("Enabled: \(config.isEnabled)")
print("Source: \(config.source)") // Override, Remote, or Default
print("Feature: \(config.feature.name)")
print("Description: \(config.feature.description)")

if config.isEnabled {
    setupBiometricLogin()
}
```

### Multiple Features

```swift
// AND logic - all must be enabled
let allEnabled = FeatureFlagManager.shared.areAllEnabled([
    .analytics,
    .crashlytics,
    .performanceMonitoring
])

if allEnabled {
    print("All monitoring features enabled")
}

// OR logic - any enabled
let anyEnabled = FeatureFlagManager.shared.isAnyEnabled([
    .inAppPurchases,
    .subscriptions
])

if anyEnabled {
    showPaymentOptions()
}
```

### SwiftUI Integration

```swift
import SwiftUI
import iOSTemplate

struct SettingsView: View {
    @FeatureFlagWrapper(.darkMode) var isDarkModeEnabled
    @FeatureFlagWrapper(.biometricLogin) var isBiometricEnabled

    var body: some View {
        Form {
            Section("Appearance") {
                if isDarkModeEnabled {
                    Toggle("Dark Mode", isOn: $darkModeOn)
                }
            }

            Section("Security") {
                if isBiometricEnabled {
                    Toggle("Face ID / Touch ID", isOn: $biometricOn)
                }
            }
        }
    }
}
```

### Development Overrides

```swift
#if DEBUG
// Override for testing (DEBUG only)
FeatureFlagManager.shared.override(.newOnboarding, enabled: true)
FeatureFlagManager.shared.override(.simplifiedLogin, enabled: false)

// Check
print("New onboarding: \(FeatureFlagManager.shared.isEnabled(.newOnboarding))")
// Output: true (from override)

// Clear override
FeatureFlagManager.shared.clearOverride(for: .newOnboarding)

// Clear all
FeatureFlagManager.shared.clearAllOverrides()
#endif
```

### Debug Screen

```swift
import SwiftUI

struct FeatureFlagsDebugView: View {
    let features = FeatureFlag.allCases
    let manager = FeatureFlagManager.shared

    var body: some View {
        List {
            ForEach(features, id: \.self) { feature in
                let config = manager.getConfig(for: feature)

                HStack {
                    VStack(alignment: .leading) {
                        Text(feature.name)
                            .font(.headline)

                        Text(feature.description)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Source: \(config.source.rawValue)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Image(systemName: config.isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(config.isEnabled ? .green : .red)
                }
            }
        }
        .navigationTitle("Feature Flags")
    }
}
```

### Available Features

| Feature | Key | Default | Description |
|---------|-----|---------|-------------|
| Dark Mode | `darkMode` | `true` | Enable dark mode UI |
| Biometric Login | `biometricLogin` | `true` | Face ID/Touch ID login |
| Offline Mode | `offlineMode` | `false` | Offline functionality |
| Show Onboarding | `showOnboarding` | `true` | Show onboarding screens |
| Analytics | `analytics` | `true` | Firebase Analytics |
| Crashlytics | `crashlytics` | `true` | Crash reporting |
| Performance Monitoring | `performanceMonitoring` | `true` | Performance tracking |
| New Onboarding | `newOnboarding` | `false` | A/B test: New flow |
| Simplified Login | `simplifiedLogin` | `false` | A/B test: Simplified UI |
| In-App Purchases | `inAppPurchases` | `false` | IAP support |
| Subscriptions | `subscriptions` | `false` | Subscription system |
| Referral Program | `referralProgram` | `false` | Referral rewards |

---

## A/B Testing

### Setup A/B Test

#### 1. Define Experiment in Firebase

1. Firebase Console → Remote Config
2. Click **"Create experiment"**
3. Configure experiment:
   - **Name**: "New Onboarding Test"
   - **Description**: "Test new onboarding flow vs. old"
   - **Parameter**: `experiment_new_onboarding`
   - **Baseline**: `false` (old onboarding)
   - **Variant A**: `true` (new onboarding)
   - **Targeting**: 50% of users

#### 2. Implement in Code

```swift
// Check which variant user is in
if FeatureFlagManager.shared.isEnabled(.newOnboarding) {
    // Variant A - New onboarding
    showNewOnboardingFlow()

    // Track analytics
    Analytics.logEvent("onboarding_variant_new", parameters: nil)
} else {
    // Baseline - Old onboarding
    showOldOnboardingFlow()

    // Track analytics
    Analytics.logEvent("onboarding_variant_old", parameters: nil)
}
```

#### 3. Track Goals

```swift
// Track conversion event
func onboardingCompleted() {
    // Track completion
    Analytics.logEvent("onboarding_completed", parameters: [
        "variant": FeatureFlagManager.shared.isEnabled(.newOnboarding) ? "new" : "old"
    ])
}

// Track retention
func userReturnedNextDay() {
    Analytics.logEvent("day_1_retention", parameters: [
        "onboarding_variant": FeatureFlagManager.shared.isEnabled(.newOnboarding) ? "new" : "old"
    ])
}
```

#### 4. Analyze Results

1. Firebase Console → Remote Config → Experiments
2. View experiment dashboard:
   - User distribution (50/50)
   - Conversion rate (baseline vs. variant)
   - Statistical significance
3. Make decision:
   - **Winner**: Roll out to 100%
   - **No difference**: Keep baseline
   - **Inconclusive**: Continue experiment

### Multi-Variant Testing

```swift
// Get experiment group
enum OnboardingVariant: String {
    case control = "control"
    case variantA = "variant_a"
    case variantB = "variant_b"
}

func getOnboardingVariant() -> OnboardingVariant {
    let service = FirebaseRemoteConfigService.shared
    let variantString = service.getString(
        forKey: "onboarding_experiment_variant",
        defaultValue: "control"
    )

    return OnboardingVariant(rawValue: variantString) ?? .control
}

// Use variant
switch getOnboardingVariant() {
case .control:
    showControlOnboarding()
case .variantA:
    showVariantAOnboarding() // 3 steps
case .variantB:
    showVariantBOnboarding() // 1 step
}
```

---

## Best Practices

### ✅ DO

1. **Always provide defaults**
   ```swift
   // Good
   let value = service.getString(forKey: "key", defaultValue: "fallback")

   // Bad
   let value = service.getString(forKey: "key", defaultValue: "")
   ```

2. **Fetch in background**
   ```swift
   // Good - non-blocking
   Task {
       try? await service.fetch()
   }

   // Bad - blocks UI
   let _ = try await service.fetch()
   showUI()
   ```

3. **Cache critical values locally**
   ```swift
   // Cache for offline use
   UserDefaults.standard.set(
       service.getBool(forKey: "feature_enabled", defaultValue: false),
       forKey: "cached_feature_enabled"
   )
   ```

4. **Use type-safe keys**
   ```swift
   // Good
   service.getString(forKey: RemoteConfigKey.welcomeMessage, defaultValue: "")

   // Bad
   service.getString(forKey: "welcom_mesage", defaultValue: "") // Typo!
   ```

5. **Test with overrides**
   ```swift
   #if DEBUG
   FeatureFlagManager.shared.override(.newFeature, enabled: true)
   #endif
   ```

### ❌ DON'T

1. **Don't store sensitive data**
   ```swift
   // Bad - API keys, secrets, passwords
   let apiKey = service.getString(forKey: "api_secret_key", defaultValue: "")

   // Good - use Info.plist or Keychain for secrets
   ```

2. **Don't fetch too frequently**
   ```swift
   // Bad - every 5 seconds
   settings.minimumFetchInterval = 5

   // Good - reasonable intervals
   settings.minimumFetchInterval = 3600 // 1 hour
   ```

3. **Don't rely on immediate availability**
   ```swift
   // Bad - no fallback
   try await service.fetch()
   let value = service.getString(forKey: "key", defaultValue: "")

   // Good - works offline
   let value = service.getString(forKey: "key", defaultValue: "fallback")
   try? await service.fetch() // Background update
   ```

4. **Don't use for user data**
   ```swift
   // Bad - user-specific data
   let userName = service.getString(forKey: "user_name", defaultValue: "")

   // Good - use database/API for user data
   ```

---

## Testing

### Test Scenarios

#### 1. First Launch (No Cache)

```swift
func testFirstLaunch() async {
    // Given: Fresh install

    // When: Get value before fetch
    let value = FeatureFlagManager.shared.isEnabled(.darkMode)

    // Then: Should use default value
    XCTAssertTrue(value) // default is true
}
```

#### 2. After Fetch

```swift
func testAfterFetch() async throws {
    // Given: Firebase has feature disabled

    // When: Fetch config
    try await FirebaseRemoteConfigService.shared.fetch()

    // Then: Should use remote value
    let value = FeatureFlagManager.shared.isEnabled(.darkMode)
    XCTAssertEqual(value, false) // From Firebase
}
```

#### 3. Offline Mode

```swift
func testOfflineMode() async {
    // Given: No internet, cached config available

    // When: Get value
    let value = FeatureFlagManager.shared.isEnabled(.darkMode)

    // Then: Should use cached value
    XCTAssertNotNil(value)
}
```

#### 4. Override (DEBUG)

```swift
func testOverride() {
    #if DEBUG
    // When: Override feature
    FeatureFlagManager.shared.override(.newOnboarding, enabled: true)

    // Then: Override takes priority
    XCTAssertTrue(FeatureFlagManager.shared.isEnabled(.newOnboarding))

    // When: Clear override
    FeatureFlagManager.shared.clearOverride(for: .newOnboarding)

    // Then: Uses remote/default value
    XCTAssertFalse(FeatureFlagManager.shared.isEnabled(.newOnboarding))
    #endif
}
```

### Manual Testing

#### Test with Firebase Console

1. Change value in Firebase Console
2. Publish changes
3. In app, force fetch:
   ```swift
   try await FirebaseRemoteConfigService.shared.fetch()
   ```
4. Verify new value:
   ```swift
   let value = service.getBool(forKey: "feature_enabled", defaultValue: false)
   print("New value: \(value)")
   ```

#### Test with Debug Menu

Create debug menu to test features:

```swift
struct RemoteConfigDebugView: View {
    @State private var isFetching = false

    var body: some View {
        List {
            Section("Actions") {
                Button("Fetch Now") {
                    isFetching = true
                    Task {
                        try? await FirebaseRemoteConfigService.shared.fetch()
                        isFetching = false
                    }
                }
                .disabled(isFetching)

                Button("Reset to Defaults") {
                    FirebaseRemoteConfigService.shared.resetToDefaults()
                }
            }

            Section("Status") {
                let info = FirebaseRemoteConfigService.shared.getConfigInfo()

                if let lastFetch = info.lastFetchTime {
                    Text("Last fetch: \(lastFetch.formatted())")
                }

                Text("Status: \(info.lastFetchStatus?.description ?? "Unknown")")
                Text("Throttled: \(info.isThrottled ? "Yes" : "No")")
            }

            Section("Values") {
                ForEach(FeatureFlag.allCases, id: \.self) { feature in
                    HStack {
                        Text(feature.name)
                        Spacer()
                        Text(FeatureFlagManager.shared.isEnabled(feature) ? "ON" : "OFF")
                    }
                }
            }
        }
    }
}
```

---

## Troubleshooting

### Issue 1: Config not updating

**Symptoms**: Remote config changes not reflecting in app

**Solutions**:
1. Check fetch interval (may be throttled)
   ```swift
   let info = FirebaseRemoteConfigService.shared.getConfigInfo()
   print("Throttled: \(info.isThrottled)")
   ```

2. Force fetch in DEBUG
   ```swift
   #if DEBUG
   // Set interval to 0 for immediate fetch
   remoteConfig.configSettings.minimumFetchInterval = 0
   #endif
   ```

3. Verify publish in Firebase Console

### Issue 2: Default values not working

**Symptoms**: Getting empty/nil values

**Solutions**:
1. Verify defaults are set
   ```swift
   // Check setDefaultValues() is called in init
   ```

2. Always provide default values when getting
   ```swift
   // Always specify default
   let value = service.getString(forKey: "key", defaultValue: "fallback")
   ```

### Issue 3: Fetch fails

**Symptoms**: Fetch throws error

**Solutions**:
1. Check network connection

2. Verify Firebase configuration
   ```swift
   // GoogleService-Info.plist exists and is correct
   ```

3. Handle errors gracefully
   ```swift
   do {
       try await service.fetch()
   } catch {
       print("Fetch failed, using cached values: \(error)")
       // App continues with cached/default values
   }
   ```

---

**Next Steps**: Check [TASK_3.3_TEST_SCENARIOS.md](TASK_3.3_TEST_SCENARIOS.md) for comprehensive testing checklist.
