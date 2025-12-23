# 📚 iOS Template - API Documentation

> Complete reference for all public APIs in iOS Template

**Version**: 1.0.0
**Last Updated**: November 2025
**Minimum iOS**: 16.0
**Swift Version**: 5.9+

---

## 📋 Table of Contents

- [Overview](#overview)
- [Core Components](#core-components)
  - [Dependency Injection](#dependency-injection)
  - [View Configurations](#view-configurations)
- [Services](#services)
  - [Firebase Services](#firebase-services)
  - [Storage Services](#storage-services)
  - [Authentication](#authentication)
  - [Notifications](#notifications)
- [Features](#features)
  - [Onboarding](#onboarding)
  - [Authentication UI](#authentication-ui)
- [Utilities](#utilities)
- [Complete Examples](#complete-examples)

---

## Overview

iOS Template là một **Swift Package** (library) cung cấp reusable components cho iOS apps. Template sử dụng **Parameterized Component Pattern** để cho phép customization mà không cần fork code.

### Key Patterns

1. **Parameterized Components**: Mỗi component nhận config object để customize
2. **Dependency Injection**: Sử dụng Swinject container
3. **TCA Architecture**: The Composable Architecture cho state management
4. **Protocol-Oriented**: Service protocols để dễ testing

---

## Core Components

### Dependency Injection

#### DIContainer

Central container để manage dependencies.

```swift
public final class DIContainer {
    public static let shared: DIContainer

    /// Resolve dependency
    public func resolve<T>(_ type: T.Type) -> T?

    /// Resolve with argument
    public func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T?

    /// Register dependency (for testing)
    public func register<T>(_ type: T.Type, factory: @escaping (Resolver) -> T)

    /// Remove all (for testing)
    public func removeAll()
}
```

**Convenience Properties:**

```swift
extension DIContainer {
    // Storage
    var userDefaultsStorage: StorageServiceProtocol { get }
    var keychainStorage: SecureStorageProtocol { get }
    var fileStorage: FileStorageProtocol { get }

    // Services
    var networkService: NetworkServiceProtocol? { get }
    var authService: AuthServiceProtocol? { get }
    var analyticsService: AnalyticsServiceProtocol? { get }
    var crashlyticsService: CrashlyticsServiceProtocol? { get }
    var remoteConfigService: RemoteConfigServiceProtocol? { get }
    var pushNotificationService: PushNotificationServiceProtocol? { get }
}
```

**Usage Example:**

```swift
// 1. Access services via singleton
let storage = DIContainer.shared.userDefaultsStorage
let keychain = DIContainer.shared.keychainStorage

// 2. Use @Injected property wrapper
class MyViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    func saveData() {
        try? storage.save("value", forKey: "key")
    }
}

// 3. For testing - register mocks
class MockStorage: StorageServiceProtocol {
    // Mock implementation
}

DIContainer.shared.register(StorageServiceProtocol.self) { _ in
    MockStorage()
}
```

#### @Injected Property Wrapper

Inject dependencies vào properties.

```swift
@propertyWrapper
public struct Injected<T> {
    public init(_ type: T.Type)
    public var wrappedValue: T { get }
}
```

**Example:**

```swift
class ProfileViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol
}
```

---

### View Configurations

#### OnboardingConfig

Configuration cho OnboardingView - cho phép customize onboarding flow.

```swift
public struct OnboardingConfig {
    // Properties
    public let pages: [OnboardingPage]
    public let backgroundColor: Color
    public let showSkipButton: Bool
    public let skipButtonText: String
    public let continueButtonText: String
    public let finalButtonText: String
    public let onComplete: () -> Void

    // Initializer
    public init(
        pages: [OnboardingPage],
        backgroundColor: Color = Color.theme.background,
        showSkipButton: Bool = true,
        skipButtonText: String = "Skip",
        continueButtonText: String = "Continue",
        finalButtonText: String = "Get Started",
        onComplete: @escaping () -> Void
    )
}

public struct OnboardingPage {
    public let icon: String
    public let title: String
    public let description: String
    public let color: Color

    public init(icon: String, title: String, description: String, color: Color)
}
```

**Default Config:**

```swift
extension OnboardingConfig {
    static func `default`(onComplete: @escaping () -> Void) -> OnboardingConfig
}
```

**Usage Example:**

```swift
// Custom config cho Banking App
let bankingConfig = OnboardingConfig(
    pages: [
        OnboardingPage(
            icon: "banknote",
            title: "Secure Banking",
            description: "Bank with confidence",
            color: .green
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Expenses",
            description: "Monitor your spending",
            color: .blue
        )
    ],
    backgroundColor: .green.opacity(0.05),
    finalButtonText: "Start Banking",
    onComplete: {
        // Navigate to main app
        store.send(.onboarding(.completed))
    }
)

OnboardingView(store: store, config: bankingConfig)
```

#### LoginConfig

Configuration cho LoginView.

```swift
public struct LoginConfig {
    public let title: String
    public let subtitle: String?
    public let primaryColor: Color
    public let showSocialLogin: Bool
    public let socialProviders: [SocialLoginProvider]
    public let onLogin: (String, String) async throws -> Void
    public let onSocialLogin: (SocialLoginProvider) async throws -> Void
    public let onForgotPassword: () -> Void

    public init(
        title: String = "Welcome Back",
        subtitle: String? = nil,
        primaryColor: Color = .theme.primary,
        showSocialLogin: Bool = true,
        socialProviders: [SocialLoginProvider] = [.apple, .google],
        onLogin: @escaping (String, String) async throws -> Void,
        onSocialLogin: @escaping (SocialLoginProvider) async throws -> Void,
        onForgotPassword: @escaping () -> Void
    )
}
```

---

## Services

### Firebase Services

#### FirebaseManager

Singleton manager để configure Firebase với custom settings.

```swift
public final class FirebaseManager {
    public static let shared: FirebaseManager

    // Properties
    public private(set) var isConfigured: Bool
    public private(set) var initializationError: Error?

    // Methods
    public func configure(with config: FirebaseConfig) throws
    public func isServiceEnabled(_ service: FirebaseService) -> Bool
}

public enum FirebaseService {
    case analytics
    case crashlytics
    case messaging
    case remoteConfig
    case performance
}

public enum FirebaseError: Error {
    case notConfigured
    case configurationFailed(Error)
    case plistNotFound(String)
    case invalidPlist(String)
    case serviceNotEnabled(String)
}
```

**Usage:**

```swift
// 1. Configure Firebase khi app launch
let config = FirebaseConfig.auto  // Auto detect environment
try await FirebaseManager.shared.configure(with: config)

// 2. Check configuration
if FirebaseManager.shared.isConfigured {
    // Firebase ready
}

// 3. Check specific services
if FirebaseManager.shared.isServiceEnabled(.analytics) {
    // Analytics enabled
}
```

#### FirebaseConfig

Configuration object cho Firebase.

```swift
public struct FirebaseConfig {
    public let plistName: String
    public let isAnalyticsEnabled: Bool
    public let isCrashlyticsEnabled: Bool
    public let isMessagingEnabled: Bool
    public let isRemoteConfigEnabled: Bool
    public let isPerformanceEnabled: Bool
    public let analyticsLogLevel: AnalyticsLogLevel
    public let remoteConfigFetchTimeout: TimeInterval
    public let remoteConfigCacheExpiration: TimeInterval
    public let isDebugMode: Bool

    public init(...)
}
```

**Presets:**

```swift
extension FirebaseConfig {
    static var auto: FirebaseConfig  // Auto detect từ build config
    static var development: FirebaseConfig
    static var staging: FirebaseConfig
    static var production: FirebaseConfig
}
```

**Example:**

```swift
// Development
let devConfig = FirebaseConfig.development

// Custom config
let customConfig = FirebaseConfig(
    plistName: "GoogleService-Info-Staging",
    isAnalyticsEnabled: true,
    isCrashlyticsEnabled: false,  // Disable trong development
    isDebugMode: true
)
```

#### FirebaseAnalyticsService

Service để track events và user properties.

```swift
public protocol AnalyticsServiceProtocol {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func setUserProperty(_ value: String?, forName name: String)
    func setUserId(_ userId: String?)
    func setScreenName(_ screenName: String, screenClass: String?)
}

public final class FirebaseAnalyticsService: AnalyticsServiceProtocol {
    public static let shared: FirebaseAnalyticsService

    public func logEvent(_ name: String, parameters: [String: Any]?)
    public func setUserProperty(_ value: String?, forName name: String)
    public func setUserId(_ userId: String?)
    public func setScreenName(_ screenName: String, screenClass: String?)
}
```

**Usage:**

```swift
let analytics = DIContainer.shared.analyticsService

// Log event
analytics?.logEvent("user_signup", parameters: [
    "method": "email",
    "source": "onboarding"
])

// Set user properties
analytics?.setUserProperty("premium", forName: "user_type")
analytics?.setUserId("user123")

// Track screen
analytics?.setScreenName("Home", screenClass: "HomeView")
```

#### FirebaseCrashlyticsService

Service để track crashes và non-fatal errors.

```swift
public protocol CrashlyticsServiceProtocol {
    func recordError(_ error: Error, userInfo: [String: Any]?)
    func log(_ message: String)
    func setCustomValue(_ value: Any, forKey key: String)
    func setUserId(_ userId: String)
}

public final class FirebaseCrashlyticsService: CrashlyticsServiceProtocol {
    public static let shared: FirebaseCrashlyticsService

    public func recordError(_ error: Error, userInfo: [String: Any]?)
    public func log(_ message: String)
    public func setCustomValue(_ value: Any, forKey key: String)
    public func setUserId(_ userId: String)
}
```

**Usage:**

```swift
let crashlytics = DIContainer.shared.crashlyticsService

// Record error
do {
    try riskyOperation()
} catch {
    crashlytics?.recordError(error, userInfo: [
        "context": "user_profile",
        "action": "save"
    ])
}

// Log breadcrumbs
crashlytics?.log("User tapped save button")

// Set custom keys
crashlytics?.setCustomValue("premium", forKey: "user_tier")
crashlytics?.setUserId("user123")
```

#### FirebaseMessagingService

Service cho push notifications.

```swift
public protocol PushNotificationServiceProtocol {
    func requestPermission() async -> Bool
    func getFCMToken() async throws -> String?
    func subscribeToTopic(_ topic: String) async throws
    func unsubscribeFromTopic(_ topic: String) async throws
}

public final class FirebaseMessagingService: PushNotificationServiceProtocol {
    public static let shared: FirebaseMessagingService

    public func requestPermission() async -> Bool
    public func getFCMToken() async throws -> String?
    public func subscribeToTopic(_ topic: String) async throws
    public func unsubscribeFromTopic(_ topic: String) async throws
}
```

**Usage:**

```swift
let messaging = DIContainer.shared.pushNotificationService

// Request permission
let granted = await messaging?.requestPermission()

// Get FCM token
if let token = try? await messaging?.getFCMToken() {
    print("FCM Token: \(token)")
}

// Subscribe to topics
try? await messaging?.subscribeToTopic("news")
try? await messaging?.subscribeToTopic("promotions")
```

#### FirebaseRemoteConfigService

Service cho remote configuration.

```swift
public protocol RemoteConfigServiceProtocol {
    func fetchAndActivate() async throws -> Bool
    func getString(forKey key: String) -> String
    func getBool(forKey key: String) -> Bool
    func getInt(forKey key: String) -> Int
    func getDouble(forKey key: String) -> Double
    func setDefaults(_ defaults: [String: Any])
}

public final class FirebaseRemoteConfigService: RemoteConfigServiceProtocol {
    public static let shared: FirebaseRemoteConfigService

    public func fetchAndActivate() async throws -> Bool
    public func getString(forKey key: String) -> String
    public func getBool(forKey key: String) -> Bool
    public func getInt(forKey key: String) -> Int
    public func getDouble(forKey key: String) -> Double
    public func setDefaults(_ defaults: [String: Any])
}
```

**Usage:**

```swift
let remoteConfig = DIContainer.shared.remoteConfigService

// Set defaults
remoteConfig?.setDefaults([
    "feature_enabled": false,
    "api_timeout": 30,
    "welcome_message": "Welcome!"
])

// Fetch và activate
try? await remoteConfig?.fetchAndActivate()

// Get values
let featureEnabled = remoteConfig?.getBool(forKey: "feature_enabled") ?? false
let timeout = remoteConfig?.getInt(forKey: "api_timeout") ?? 30
let message = remoteConfig?.getString(forKey: "welcome_message") ?? ""
```

---

### Storage Services

#### StorageServiceProtocol

Protocol cho UserDefaults storage.

```swift
public protocol StorageServiceProtocol {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func delete(forKey key: String)
    func exists(forKey key: String) -> Bool
    func clear()
}
```

**Usage:**

```swift
let storage = DIContainer.shared.userDefaultsStorage

// Save
try? storage.save("John Doe", forKey: "userName")
try? storage.save(User(name: "John"), forKey: "currentUser")

// Load
let name: String? = try? storage.load(String.self, forKey: "userName")
let user: User? = try? storage.load(User.self, forKey: "currentUser")

// Delete
storage.delete(forKey: "userName")

// Check existence
if storage.exists(forKey: "userName") {
    // ...
}
```

#### SecureStorageProtocol

Protocol cho Keychain storage (sensitive data).

```swift
public protocol SecureStorageProtocol {
    func saveSecure(_ value: String, forKey key: String) throws
    func loadSecure(forKey key: String) throws -> String?
    func deleteSecure(forKey key: String)
    func clearAll()
}
```

**Usage:**

```swift
let keychain = DIContainer.shared.keychainStorage

// Save tokens
try? keychain.saveSecure(accessToken, forKey: "auth.accessToken")
try? keychain.saveSecure(refreshToken, forKey: "auth.refreshToken")

// Load
let token = try? keychain.loadSecure(forKey: "auth.accessToken")

// Delete
keychain.deleteSecure(forKey: "auth.accessToken")

// Clear all
keychain.clearAll()
```

#### FileStorageProtocol

Protocol cho file-based storage.

```swift
public protocol FileStorageProtocol {
    func save(_ data: Data, fileName: String) throws
    func load(fileName: String) throws -> Data?
    func delete(fileName: String) throws
    func exists(fileName: String) -> Bool
    func fileURL(for fileName: String) -> URL
}
```

**Presets:**

```swift
public enum FileStorage {
    static var documents: FileStorageProtocol
    static var cache: FileStorageProtocol
    static var temporary: FileStorageProtocol
}
```

**Usage:**

```swift
let fileStorage = DIContainer.shared.fileStorage

// Save file
let data = try JSONEncoder().encode(largeObject)
try? fileStorage.save(data, fileName: "large_data.json")

// Load file
if let data = try? fileStorage.load(fileName: "large_data.json") {
    let object = try? JSONDecoder().decode(LargeObject.self, from: data)
}

// Get file URL
let url = fileStorage.fileURL(for: "large_data.json")

// Use specific storage
let cacheStorage = FileStorage.cache
try? cacheStorage.save(imageData, fileName: "profile.jpg")
```

---

## Features

### Onboarding

#### OnboardingView

SwiftUI view cho onboarding flow.

```swift
public struct OnboardingView: View {
    public init(store: StoreOf<AppReducer>, config: OnboardingConfig)
}
```

**Example:**

```swift
let config = OnboardingConfig(
    pages: [
        OnboardingPage(
            icon: "star.fill",
            title: "Welcome",
            description: "Get started with our app",
            color: .blue
        )
    ],
    onComplete: {
        store.send(.onboarding(.completed))
    }
)

OnboardingView(store: store, config: config)
```

### Authentication UI

#### LoginView

SwiftUI view cho login screen.

```swift
public struct LoginView: View {
    public init(store: StoreOf<AppReducer>, config: LoginConfig)
}
```

**Example:**

```swift
let config = LoginConfig(
    title: "Welcome Back",
    onLogin: { email, password in
        try await authService.login(email: email, password: password)
    },
    onSocialLogin: { provider in
        try await authService.socialLogin(provider: provider)
    },
    onForgotPassword: {
        store.send(.navigation(.push(.forgotPassword)))
    }
)

LoginView(store: store, config: config)
```

---

## Utilities

### Logger

Centralized logging system.

```swift
public struct Logger {
    public static func debug(_ message: String, file: String, function: String, line: Int)
    public static func info(_ message: String, file: String, function: String, line: Int)
    public static func warning(_ message: String, file: String, function: String, line: Int)
    public static func error(_ message: String, file: String, function: String, line: Int)
}
```

**Usage:**

```swift
Logger.debug("User tapped button")
Logger.info("API request started")
Logger.warning("Slow network detected")
Logger.error("Failed to load data")
```

### Cache

#### MemoryCache

In-memory cache với size limit.

```swift
public final class MemoryCache<Key: Hashable, Value> {
    public init(countLimit: Int = 100, totalCostLimit: Int = 50_MB)

    public func set(_ value: Value, forKey key: Key, cost: Int = 0)
    public func get(forKey key: Key) -> Value?
    public func remove(forKey key: Key)
    public func removeAll()
}
```

#### DiskCache

Disk-based cache.

```swift
public final class DiskCache {
    public static let shared: DiskCache

    public func set(_ data: Data, forKey key: String) throws
    public func get(forKey key: String) -> Data?
    public func remove(forKey key: String) throws
    public func clear() throws
    public func totalSize() -> Int64
}
```

---

## Complete Examples

### Example 1: Setup New App

```swift
// 1. App Entry Point
import SwiftUI
import iOSTemplate

@main
struct MyApp: App {
    init() {
        // Initialize DI Container
        _ = DIContainer.shared

        // Configure Firebase
        let firebaseConfig = FirebaseConfig.auto
        try? FirebaseManager.shared.configure(with: firebaseConfig)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Example 2: Custom Onboarding

```swift
let onboardingConfig = OnboardingConfig(
    pages: [
        OnboardingPage(
            icon: "heart.fill",
            title: "Track Your Health",
            description: "Monitor your daily activities",
            color: .red
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "View Progress",
            description: "See your improvements over time",
            color: .blue
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Achieve Goals",
            description: "Reach your fitness targets",
            color: .yellow
        )
    ],
    backgroundColor: .black,
    finalButtonText: "Start Journey",
    onComplete: {
        // Mark onboarding complete
        let storage = DIContainer.shared.userDefaultsStorage
        try? storage.save(true, forKey: "onboardingCompleted")

        // Track analytics
        let analytics = DIContainer.shared.analyticsService
        analytics?.logEvent("onboarding_completed", parameters: nil)

        // Navigate to main app
        store.send(.navigation(.setRoot(.main)))
    }
)

OnboardingView(store: store, config: onboardingConfig)
```

### Example 3: Using Services

```swift
class ProfileViewModel: ObservableObject {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    @Injected(CrashlyticsServiceProtocol.self)
    var crashlytics: CrashlyticsServiceProtocol

    func saveProfile(_ profile: UserProfile) {
        do {
            // Save to storage
            try storage.save(profile, forKey: "userProfile")

            // Track event
            analytics?.logEvent("profile_saved", parameters: [
                "fields_updated": profile.updatedFields.count
            ])

            // Log success
            crashlytics?.log("Profile saved successfully")

        } catch {
            // Record error
            crashlytics?.recordError(error, userInfo: [
                "action": "save_profile"
            ])
        }
    }
}
```

### Example 4: Remote Config Feature Flag

```swift
class FeatureManager {
    @Injected(RemoteConfigServiceProtocol.self)
    var remoteConfig: RemoteConfigServiceProtocol

    func checkNewFeature() async -> Bool {
        // Fetch latest config
        try? await remoteConfig?.fetchAndActivate()

        // Get feature flag
        let isEnabled = remoteConfig?.getBool(forKey: "new_dashboard_enabled") ?? false

        if isEnabled {
            // Show new dashboard
            return true
        } else {
            // Show old dashboard
            return false
        }
    }
}
```

### Example 5: Testing with Mocks

```swift
class MockStorage: StorageServiceProtocol {
    var storage: [String: Any] = [:]

    func save<T: Codable>(_ value: T, forKey key: String) throws {
        storage[key] = value
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        storage[key] as? T
    }

    func delete(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }

    func clear() {
        storage.removeAll()
    }
}

// In tests
class ProfileViewModelTests: XCTestCase {
    var viewModel: ProfileViewModel!
    var mockStorage: MockStorage!

    override func setUp() {
        super.setUp()

        // Register mock
        mockStorage = MockStorage()
        DIContainer.shared.register(StorageServiceProtocol.self) { _ in
            self.mockStorage
        }

        viewModel = ProfileViewModel()
    }

    func testSaveProfile() throws {
        // Given
        let profile = UserProfile(name: "John")

        // When
        viewModel.saveProfile(profile)

        // Then
        let saved: UserProfile? = try mockStorage.load(UserProfile.self, forKey: "userProfile")
        XCTAssertEqual(saved?.name, "John")
    }
}
```

---

## 🔗 Additional Resources

- **[Architecture Guide](../ARCHITECTURE.md)**: Kiến trúc modular và Swift Package structure
- **[Component Pattern Guide](../COMPONENT_PATTERN.md)**: Chi tiết về Parameterized Component Pattern
- **[Setup Guide](../SETUP.md)**: Hướng dẫn setup project
- **[Contributing Guide](./CONTRIBUTING.md)**: Hướng dẫn contribute code

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/kienpro307/ios-template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kienpro307/ios-template/discussions)
- **Documentation**: [Full Docs](https://github.com/kienpro307/ios-template/tree/main/docs)

---

**Generated from**: `iOSTemplate v1.0.0`
**Platform**: iOS 16.0+, Swift 5.9+
