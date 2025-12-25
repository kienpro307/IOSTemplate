# Firebase Integration

Hướng dẫn sử dụng Firebase services trong iOS Template.

---

## Tổng Quan

Template tích hợp sẵn các Firebase services:

- ✅ **Analytics** - Event tracking
- ✅ **Crashlytics** - Crash reporting
- ✅ **Remote Config** - Feature flags
- ✅ **Cloud Messaging** - Push notifications

---

## Setup

### 1. Tạo Firebase Project

1. [Firebase Console](https://console.firebase.google.com) → Add Project
2. Nhập project name → Create
3. Add iOS app → Bundle ID: `com.yourcompany.yourapp`
4. Download `GoogleService-Info.plist`
5. Add vào Xcode project

### 2. Initialize Firebase

Firebase tự động initialize trong `Main.swift`:

```swift
@main
struct Main: App {
    init() {
        FirebaseManager.shared.configure()
    }
}
```

---

## Analytics

### Track Events

**Trong Reducer:**

```swift
@Dependency(\.analytics) var analytics

case .buttonTapped:
    return .run { _ in
        await analytics.trackEvent("button_tapped", parameters: [
            "screen": "home",
            "button_id": "premium"
        ])
    }
```

**Screen Tracking:**

```swift
case .onAppear:
    return .run { _ in
        await analytics.trackScreen("Home")
    }
```

### Custom Parameters

```swift
await analytics.trackEvent("purchase_completed", parameters: [
    "product_id": "premium_monthly",
    "price": 9.99,
    "currency": "USD"
])
```

---

## Crashlytics

### Automatic Crash Reporting

Crashes tự động được report. Không cần code thêm.

### Custom Logging

```swift
@Dependency(\.logger) var logger

case .error(let error):
    return .run { _ in
        await logger.error("Failed to load data: \(error)")
        // Crashlytics automatically logs errors
    }
```

### User Identifiers

```swift
Crashlytics.crashlytics().setUserID("user_123")
```

---

## Remote Config

### Feature Flags

**Setup default values:**

```swift
// FeatureFlags.swift
public enum FeatureFlag: String {
    case enableNewFeature = "enable_new_feature"
    case maxRetryCount = "max_retry_count"
}
```

**Fetch values:**

```swift
@Dependency(\.remoteConfig) var remoteConfig

case .onAppear:
    return .run { _ in
        try? await remoteConfig.fetch()
        await remoteConfig.activate()
    }
```

**Read values:**

```swift
let enabled = remoteConfig.boolValue(forKey: "enable_new_feature")
let count = remoteConfig.intValue(forKey: "max_retry_count")
```

---

## Push Notifications

### Request Permission

```swift
case .requestNotificationPermission:
    return .run { send in
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
        await send(.permissionResult(granted))
    }
```

### Handle Notifications

**Foreground:**

```swift
// Handled by NotificationDelegate
```

**Background:**

```swift
case .notificationReceived(let userInfo):
    // Process notification
    return .none
```

---

## Xem Thêm

- [Cài Đặt](../01-BAT-DAU/01-CAI-DAT.md)
- [Services Usage](../02-HUONG-DAN-SU-DUNG/02-SU-DUNG-SERVICES.md)

