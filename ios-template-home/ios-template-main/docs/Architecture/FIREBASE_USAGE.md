# Firebase Services - Usage Guide

Comprehensive guide for using Firebase services in the iOS Template.

---

## 📋 Table of Contents

1. [Setup](#setup)
2. [Analytics Service](#analytics-service)
3. [Crashlytics Service](#crashlytics-service)
4. [Remote Config Service](#remote-config-service)
5. [Messaging Service](#messaging-service)
6. [Performance Service](#performance-service)
7. [TCA Integration](#tca-integration)
8. [SwiftUI Extensions](#swiftui-extensions)
9. [Testing](#testing)

---

## 🚀 Setup

### Step 1: Add GoogleService-Info.plist

```
YourApp/
├── YourApp.swift
└── GoogleService-Info.plist  ← Add this file
```

### Step 2: Configure Firebase in App Init

```swift
import SwiftUI
import iOSTemplate

@main
struct YourApp: App {
    init() {
        // Configure Firebase
        try? FirebaseManager.shared.configure(with: .auto)
        
        // Optional: Setup messaging
        MessagingService.shared.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Step 3: (Optional) Custom Configuration

```swift
// Custom config
let config = FirebaseConfig(
    isAnalyticsEnabled: true,
    isCrashlyticsEnabled: true,
    isMessagingEnabled: true,
    isRemoteConfigEnabled: true,
    isPerformanceEnabled: true,
    isDebugMode: true
)

try? FirebaseManager.shared.configure(with: config)
```

---

## 📊 Analytics Service

### Basic Event Logging

```swift
import iOSTemplate

// Log custom event
AnalyticsService.shared.logEvent(.featureUsed, parameters: [
    "feature": "dark_mode"
])

// Log with string name
AnalyticsService.shared.logEvent("button_tapped", parameters: [
    "button": "submit"
])
```

### Screen Tracking

```swift
// Track screen view
AnalyticsService.shared.trackScreen("home")

// With custom class
AnalyticsService.shared.trackScreen("profile", screenClass: "UserProfileView")
```

### User Properties

```swift
// Set user ID
AnalyticsService.shared.setUserID("user123")

// Set user property
AnalyticsService.shared.setUserProperty("premium", forName: "user_type")

// Set multiple properties
AnalyticsService.shared.setUserProperties([
    "age_group": "25-34",
    "country": "US",
    "plan": "premium"
])
```

### E-commerce Tracking

```swift
// Track purchase
AnalyticsService.shared.trackPurchase(
    transactionID: "TXN123",
    value: 99.99,
    currency: "USD",
    items: [
        ["item_id": "SKU001", "item_name": "Premium Plan"]
    ]
)

// Track add to cart
AnalyticsService.shared.trackAddToCart(
    itemID: "SKU001",
    itemName: "Premium Plan",
    price: 99.99
)

// Track checkout
AnalyticsService.shared.trackBeginCheckout(
    value: 99.99,
    currency: "USD"
)
```

### Conversion Events

```swift
// Sign up
AnalyticsService.shared.trackSignUp(method: "email")

// Login
AnalyticsService.shared.trackLogin(method: "google")

// Search
AnalyticsService.shared.trackSearch(searchTerm: "ios development")

// Share
AnalyticsService.shared.trackShare(
    contentType: "article",
    itemID: "article_123",
    method: "twitter"
)
```

### TCA Integration

```swift
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Dependency(\.analyticsService) var analytics
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                analytics.trackScreen("home")
                return .none
                
            case .buttonTapped:
                analytics.logEvent(.featureUsed, parameters: ["feature": "new_design"])
                return .none
            }
        }
    }
}
```

---

## 💥 Crashlytics Service

### Basic Error Recording

```swift
// Record error
do {
    try someOperation()
} catch {
    CrashlyticsService.shared.recordError(error)
}

// With context
CrashlyticsService.shared.recordError(error, userInfo: [
    "screen": "checkout",
    "action": "process_payment"
])
```

### Custom Error

```swift
CrashlyticsService.shared.recordError(
    domain: "com.yourapp.payment",
    code: 1001,
    message: "Payment processing failed",
    userInfo: ["amount": 99.99]
)
```

### User Information

```swift
// Set user ID
CrashlyticsService.shared.setUserID("user123")

// Set user email
CrashlyticsService.shared.setUserEmail("user@example.com")

// Set user name
CrashlyticsService.shared.setUserName("John Doe")
```

### Custom Keys

```swift
// Single key
CrashlyticsService.shared.setCustomKey("cart_items", value: 5)

// Multiple keys
CrashlyticsService.shared.setCustomKeys([
    "user_type": "premium",
    "session_id": "ABC123",
    "api_version": "2.0"
])
```

### Breadcrumbs

```swift
// Log breadcrumb
CrashlyticsService.shared.log("User opened checkout screen")

// With timestamp
CrashlyticsService.shared.logWithTimestamp("Payment button tapped")

// Formatted log
CrashlyticsService.shared.logFormat("User selected %@ items", 5)
```

### Network Errors

```swift
CrashlyticsService.shared.recordNetworkError(
    error,
    url: "https://api.example.com/users",
    statusCode: 500,
    method: "POST"
)
```

### Testing

```swift
#if DEBUG
// Send test error (safe, doesn't crash)
CrashlyticsService.shared.testError()

// Force crash (for testing crash reports)
CrashlyticsService.shared.testCrash()
#endif
```

### TCA Integration

```swift
@Reducer
struct CheckoutFeature {
    @Dependency(\.crashlyticsService) var crashlytics
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .processPayment:
                return .run { send in
                    do {
                        let result = try await processPayment()
                        await send(.paymentSuccess(result))
                    } catch {
                        crashlytics.recordError(error, screen: "checkout", action: "process_payment")
                        await send(.paymentFailed(error))
                    }
                }
            }
        }
    }
}
```

---

## ⚙️ Remote Config Service

### Fetch and Activate

```swift
// Fetch and activate (recommended)
try await RemoteConfigService.shared.fetchAndActivate()

// Fetch only (activate later)
try await RemoteConfigService.shared.fetch()

// Activate previously fetched
let activated = try await RemoteConfigService.shared.activate()
```

### Get Values (Type-Safe)

```swift
// Bool
let showBanner = RemoteConfigService.shared.getBool(.showBanner)

// String
let apiURL = RemoteConfigService.shared.getString(.apiBaseURL)

// Int
let timeout = RemoteConfigService.shared.getInt(.apiTimeout)

// Double
let price = RemoteConfigService.shared.getDouble("special_price")

// URL
if let url = RemoteConfigService.shared.getURL(.termsURL) {
    print("Terms URL: \(url)")
}

// Color
if let color = RemoteConfigService.shared.getColor(.primaryColor) {
    view.backgroundColor = color
}
```

### JSON Decoding

```swift
struct FeatureFlags: Codable {
    let darkMode: Bool
    let newDesign: Bool
    let betaFeatures: Bool
}

// Get JSON object
if let flags = RemoteConfigService.shared.getJSON("feature_flags", as: FeatureFlags.self) {
    if flags.darkMode {
        enableDarkMode()
    }
}
```

### Default Values

```swift
// Set defaults
RemoteConfigService.shared.setDefaults([
    "show_banner": false,
    "api_base_url": "https://api.example.com",
    "api_timeout": 60
])

// From plist
RemoteConfigService.shared.setDefaultsFromPlist("RemoteConfigDefaults")
```

### Custom Keys

```swift
// Define your keys
extension RemoteConfigKey {
    static let showPromo: RemoteConfigKey = "show_promo"
    static let promoMessage: RemoteConfigKey = "promo_message"
}

// Use
let showPromo = RemoteConfigService.shared.getBool(.showPromo)
let message = RemoteConfigService.shared.getString(.promoMessage)
```

### TCA Integration

```swift
@Reducer
struct SettingsFeature {
    @Dependency(\.remoteConfigService) var remoteConfig
    
    struct State: Equatable {
        var biometricsEnabled: Bool = false
        var darkModeEnabled: Bool = false
    }
    
    enum Action {
        case loadRemoteConfig
        case remoteConfigLoaded
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadRemoteConfig:
                return .run { send in
                    try await remoteConfig.fetchAndActivate()
                    await send(.remoteConfigLoaded)
                }
                
            case .remoteConfigLoaded:
                state.biometricsEnabled = remoteConfig.getBool(.enableBiometrics)
                state.darkModeEnabled = remoteConfig.getBool(.enableDarkMode)
                return .none
            }
        }
    }
}
```

---

## 📲 Messaging Service

### Setup

```swift
// In AppDelegate or App init
MessagingService.shared.setup()

// Handle token updates
MessagingService.shared.onTokenUpdate = { token in
    print("FCM Token: \(token)")
    // Send to your backend
}

// Handle notifications
MessagingService.shared.onNotificationReceived = { userInfo in
    print("Notification received: \(userInfo)")
}
```

### Permissions

```swift
// Request permissions
MessagingService.shared.requestPermissions()

// Check authorization status
let status = await MessagingService.shared.checkAuthorizationStatus()
let authorized = await MessagingService.shared.isAuthorized()
```

### Token Management

```swift
// Get current token
if let token = MessagingService.shared.fcmToken {
    print("Token: \(token)")
}

// Fetch token manually
MessagingService.shared.fetchToken()

// Delete token (logout)
try await MessagingService.shared.deleteToken()

// Set APNs token (in AppDelegate)
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    MessagingService.shared.setAPNsToken(deviceToken)
}
```

### Topics

```swift
// Subscribe to topic
try await MessagingService.shared.subscribe(to: "news")

// Unsubscribe
try await MessagingService.shared.unsubscribe(from: "news")

// Multiple topics
try await MessagingService.shared.subscribe(to: ["news", "sports", "tech"])
```

### Handle Notifications

```swift
// In AppDelegate
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) {
    MessagingService.shared.handleNotification(userInfo)
    
    // Parse payload
    let payload = MessagingService.shared.parsePayload(userInfo)
    print("Title: \(payload.title ?? "")")
    print("Body: \(payload.body ?? "")")
}
```

---

## ⚡️ Performance Service

### Basic Traces

```swift
// Manual trace
let trace = PerformanceService.shared.startTrace(name: "image_load")
loadImage()
PerformanceService.shared.stopTrace(trace)

// With attributes
let trace = PerformanceService.shared.startTrace(name: "api_call")
PerformanceService.shared.setAttribute(trace, key: "endpoint", value: "/users")
PerformanceService.shared.incrementMetric(trace, name: "retry_count", by: 1)
fetchData()
PerformanceService.shared.stopTrace(trace)
```

### Measure Operations (Async)

```swift
// Simple measurement
let data = await PerformanceService.shared.measure(name: "fetch_data") {
    return try await fetchData()
}

// With attributes
let users = await PerformanceService.shared.measure(
    name: "api_call",
    attributes: ["endpoint": "/users", "method": "GET"]
) {
    return try await fetchUsers()
}
```

### Convenience Methods

```swift
// Measure API call
let users = await PerformanceService.shared.measureAPICall(
    endpoint: "/users",
    method: "GET"
) {
    try await fetchUsers()
}

// Measure view load
await PerformanceService.shared.measureViewLoad("HomeView") {
    await loadData()
}

// Measure DB operation
let results = await PerformanceService.shared.measureDBOperation(
    operation: "fetch",
    table: "users"
) {
    try await database.fetchUsers()
}

// Measure image load
let image = await PerformanceService.shared.measureImageLoad(source: "remote") {
    try await downloadImage(url)
}
```

### Performance Monitor

```swift
let monitor = PerformanceMonitor(name: "checkout_flow")
monitor.setAttribute(key: "user_type", value: "premium")
monitor.incrementMetric("items_count", by: 3)

// ... do checkout ...

monitor.stop()
```

---

## 🎯 TCA Integration

### With @Dependency

```swift
@Reducer
struct AppFeature {
    // Inject services
    @Dependency(\.analyticsService) var analytics
    @Dependency(\.crashlyticsService) var crashlytics
    @Dependency(\.remoteConfigService) var remoteConfig
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appLaunched:
                // Track app launch
                analytics.trackAppOpen()
                
                // Load remote config
                return .run { send in
                    try await remoteConfig.fetchAndActivate()
                    await send(.remoteConfigLoaded)
                }
                
            case .error(let error):
                // Record error
                crashlytics.recordError(error)
                return .none
            }
        }
    }
}
```

### Testing with Mocks

```swift
import Testing
import Dependencies

@Test
func testAnalyticsTracking() async throws {
    let mock = MockAnalyticsService()
    
    await withDependencies {
        $0.analyticsService = mock
    } operation: {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        
        await store.send(.viewAppeared)
        
        // Verify
        #expect(mock.trackedScreens.contains("home"))
    }
}
```

---

## ✨ SwiftUI Extensions

### Screen Tracking

```swift
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home")
        }
        .trackScreen("home")
    }
}
```

### Event Tracking

```swift
struct FeatureView: View {
    var body: some View {
        Button("Try Feature") {
            // action
        }
        .trackOnAppear(.featureUsed, parameters: ["feature": "new_design"])
    }
}
```

### Remote Config

```swift
struct BannerView: View {
    var body: some View {
        Text("Special Offer!")
            .padding()
            .background(Color.blue)
            .showIf(remoteConfigKey: .showBanner)
    }
}
```

### Performance

```swift
struct DataView: View {
    var body: some View {
        List {
            // data
        }
        .measurePerformance("data_view_load")
    }
}
```

### Global Helpers

```swift
Button("Login") {
    logEvent(.buttonTapped, parameters: ["button": "login"])
    handleLogin()
}

Button("Load Data") {
    Task {
        do {
            try await loadData()
        } catch {
            recordError(error, screen: "home", action: "load_data")
        }
    }
}
```

---

## 🧪 Testing

### Mock Services

```swift
let mockAnalytics = MockAnalyticsService()
let mockCrashlytics = MockCrashlyticsService()
let mockRemoteConfig = MockRemoteConfigService()

// Set mock values
mockRemoteConfig.mockValues = [
    "show_banner": true,
    "api_base_url": "https://test.example.com"
]
```

### TCA Tests

```swift
@Test
func testFeature() async {
    await withDependencies {
        $0.useMockAnalytics()
        $0.useMockRemoteConfig()
    } operation: {
        let store = TestStore(initialState: Feature.State()) {
            Feature()
        }
        
        await store.send(.buttonTapped)
    }
}
```

---

## 📝 Best Practices

1. **Analytics**: Track meaningful user interactions, not every tap
2. **Crashlytics**: Always add context (screen, action, user info)
3. **Remote Config**: Set default values, fetch early in app lifecycle
4. **Messaging**: Handle permissions gracefully, respect user choice
5. **Performance**: Focus on critical paths (API calls, screen loads)
6. **Testing**: Use mocks, verify tracking in tests
7. **Privacy**: Respect user privacy, anonymize data when needed

---

## 🔗 Resources

- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Analytics Events](https://firebase.google.com/docs/analytics/events)
- [Crashlytics Setup](https://firebase.google.com/docs/crashlytics/get-started)
- [Remote Config](https://firebase.google.com/docs/remote-config)
- [Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Performance Monitoring](https://firebase.google.com/docs/perf-mon)
