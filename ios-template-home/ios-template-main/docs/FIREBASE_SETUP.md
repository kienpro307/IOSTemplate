# Firebase Setup Guide

## 📋 Tổng Quan

iOS Template này đã integrate sẵn Firebase với các services:
- ✅ Firebase Analytics
- ✅ Firebase Crashlytics
- ✅ Firebase Cloud Messaging (Push Notifications)
- ✅ Firebase Remote Config
- ✅ Firebase Performance Monitoring

## 🚀 Quick Start

### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** hoặc chọn existing project
3. Nhập project name (ví dụ: "My Banking App")
4. Enable Google Analytics (recommended)
5. Chọn Analytics account hoặc tạo mới
6. Click **Create project**

### Bước 2: Add iOS App to Firebase

1. Trong Firebase Console, click vào **iOS** icon
2. Nhập **iOS bundle ID** (ví dụ: `com.yourcompany.bankingapp`)
   - **Lưu ý**: Bundle ID phải match với Xcode project
3. Nhập **App nickname** (optional)
4. Nhập **App Store ID** (optional, có thể bỏ qua lúc development)
5. Click **Register app**

### Bước 3: Download GoogleService-Info.plist

1. Click **Download GoogleService-Info.plist**
2. Save file này vào máy

### Bước 4: Add Plist to Xcode Project

**Option 1: Default Configuration (Recommended)**

1. Rename file thành `GoogleService-Info.plist` (nếu chưa đúng tên)
2. Drag file vào Xcode project: `App/iOSTemplateApp/`
3. ✅ Check **"Copy items if needed"**
4. ✅ Check target: **iOSTemplateApp**
5. Click **Finish**

**Option 2: Custom Configuration (Multi-App)**

Nếu bạn có nhiều apps (Banking, Fitness, etc.), mỗi app có Firebase project riêng:

1. Rename file theo pattern: `GoogleService-Info-{AppName}.plist`
   - Ví dụ: `GoogleService-Info-Banking.plist`
   - Ví dụ: `GoogleService-Info-Fitness.plist`
2. Drag file vào Xcode project
3. Update `FirebaseConfig` với custom plist name (xem Usage bên dưới)

### Bước 5: Configure Firebase trong App

Mở `App/iOSTemplateApp/iOSTemplateApp.swift` và configure Firebase:

```swift
import iOSTemplate
import SwiftUI

@main
struct iOSTemplateApp: App {
    let store: StoreOf<AppReducer>

    init() {
        // Setup DI
        _ = DIContainer.shared

        // ⭐ Configure Firebase
        do {
            let firebaseConfig = FirebaseConfig.auto  // Auto detect Debug/Release
            try FirebaseManager.shared.configure(with: firebaseConfig)
        } catch {
            print("Firebase configuration failed: \(error)")
        }

        // Setup TCA Store
        self.store = Store(initialState: AppState()) {
            AppReducer()._printChanges()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

### Bước 6: Verify Setup

1. Build và run app (⌘R)
2. Check console log, bạn sẽ thấy:
   ```
   [FirebaseManager] ✅ Firebase configured successfully
   ```
3. Truy cập Firebase Console → Analytics
4. Sau vài phút, bạn sẽ thấy real-time users

## 🎨 Firebase Configuration Options

### Sử Dụng Default Config

```swift
// Auto detect environment (Debug = development, Release = production)
let config = FirebaseConfig.auto
try FirebaseManager.shared.configure(with: config)
```

### Development Config

```swift
let config = FirebaseConfig.development
// - Debug mode enabled
// - Verbose logging
// - No cache for Remote Config
try FirebaseManager.shared.configure(with: config)
```

### Production Config

```swift
let config = FirebaseConfig.production
// - Debug mode disabled
// - Error logging only
// - 12 hour cache for Remote Config
try FirebaseManager.shared.configure(with: config)
```

### Custom Config

```swift
let config = FirebaseConfig(
    plistName: "GoogleService-Info-Banking",  // Custom plist
    isAnalyticsEnabled: true,
    isCrashlyticsEnabled: true,
    isMessagingEnabled: false,  // Disable push notifications
    isRemoteConfigEnabled: true,
    isPerformanceEnabled: false,  // Disable performance monitoring
    analyticsLogLevel: .info,
    remoteConfigCacheExpiration: 3600,
    isDebugMode: false
)
try FirebaseManager.shared.configure(with: config)
```

### Minimal Config (Chỉ Analytics)

```swift
let config = FirebaseConfig.minimal
// Chỉ enable Analytics, disable các services khác
try FirebaseManager.shared.configure(with: config)
```

## 🔧 Service-Specific Setup

### Analytics

Analytics được enable tự động. Không cần setup thêm.

**Track custom events:**
```swift
@Injected var analyticsService: AnalyticsServiceProtocol

analyticsService.trackEvent(AnalyticsEvent(
    name: "user_logged_in",
    parameters: ["method": "email"]
))
```

### Crashlytics

**Enable trong Firebase Console:**
1. Firebase Console → Crashlytics
2. Enable Crashlytics
3. Follow setup instructions

**Test crash (Debug only):**
```swift
#if DEBUG
fatalError("Test crash")
#endif
```

### Cloud Messaging (Push Notifications)

Xem chi tiết tại [PUSH_NOTIFICATIONS_SETUP.md](./PUSH_NOTIFICATIONS_SETUP.md)

**Quick setup:**
1. Enable Push Notifications capability trong Xcode
2. Upload APNs certificate to Firebase
3. Request notification permission trong app

### Remote Config

**Set default values trong Firebase Console:**
1. Firebase Console → Remote Config
2. Add parameters (ví dụ: `feature_enabled`, `welcome_message`)
3. Publish changes

**Fetch và sử dụng:**
```swift
@Injected var remoteConfig: RemoteConfigServiceProtocol

// Fetch config
try await remoteConfig.fetch()

// Get values
let isFeatureEnabled = remoteConfig.getBool(forKey: "feature_enabled", defaultValue: false)
let message = remoteConfig.getString(forKey: "welcome_message", defaultValue: "Welcome!")
```

### Performance Monitoring

Performance được enable tự động khi bạn enable trong config.

**Custom traces:**
```swift
let trace = Performance.startTrace(name: "custom_operation")
// Perform operation
trace?.stop()
```

## 🌍 Environment-Specific Configuration

### Multiple Environments (Dev, Staging, Prod)

**Option 1: Multiple Plist Files**

```
App/iOSTemplateApp/
├── GoogleService-Info-Dev.plist
├── GoogleService-Info-Staging.plist
└── GoogleService-Info-Prod.plist
```

**Usage:**
```swift
let plistName: String
#if DEBUG
plistName = "GoogleService-Info-Dev"
#elseif STAGING
plistName = "GoogleService-Info-Staging"
#else
plistName = "GoogleService-Info-Prod"
#endif

let config = FirebaseConfig(plistName: plistName)
try FirebaseManager.shared.configure(with: config)
```

**Option 2: Build Configurations**

1. Xcode → Project Settings → Configurations
2. Duplicate "Debug" → "Staging"
3. Thêm custom flag trong Build Settings
4. Sử dụng như Option 1

### Multiple Apps (Banking, Fitness, E-commerce)

Mỗi app có Firebase project riêng:

```swift
// Banking App
let bankingConfig = FirebaseConfig(
    plistName: "GoogleService-Info-Banking",
    isAnalyticsEnabled: true,
    isCrashlyticsEnabled: true
)
try FirebaseManager.shared.configure(with: bankingConfig)

// Fitness App
let fitnessConfig = FirebaseConfig(
    plistName: "GoogleService-Info-Fitness",
    isAnalyticsEnabled: true,
    isCrashlyticsEnabled: false  // Không dùng Crashlytics
)
try FirebaseManager.shared.configure(with: fitnessConfig)
```

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] iOS app added to Firebase
- [ ] GoogleService-Info.plist downloaded
- [ ] Plist added to Xcode project với correct target
- [ ] Firebase configured trong App init
- [ ] App builds successfully
- [ ] Console log shows "Firebase configured successfully"
- [ ] Firebase Console shows app connected
- [ ] Analytics events appear in Firebase Console (after ~5 minutes)

## 🚨 Troubleshooting

### Error: "Plist not found"

**Solution:**
1. Check plist file name matches `config.plistName`
2. Verify file added to correct target trong Xcode
3. Clean build folder (Shift+⌘+K) và rebuild

### Error: "Firebase already configured"

**Solution:**
- `FirebaseManager.configure()` chỉ nên được gọi 1 lần
- Check if đang gọi nhiều lần trong app lifecycle

### Analytics events không appear

**Solution:**
1. Wait 5-10 minutes (Analytics có delay)
2. Check internet connection
3. Verify `isAnalyticsEnabled = true` trong config
4. Check Firebase Console → DebugView (for debug builds)

### Crashlytics crashes không appear

**Solution:**
1. Verify Crashlytics enabled trong Firebase Console
2. Upload dSYM files (Release builds)
3. Force quit app sau crash (crashes send on next app launch)
4. Wait 5-10 minutes

### Build failed: "Module 'Firebase...' not found"

**Solution:**
1. Clean build folder (Shift+⌘+K)
2. Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Resolve package dependencies: File → Packages → Resolve Package Versions
4. Rebuild project

## 📚 Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase iOS SDK GitHub](https://github.com/firebase/firebase-ios-sdk)
- [Analytics Events Reference](https://firebase.google.com/docs/analytics/events)
- [Remote Config Best Practices](https://firebase.google.com/docs/remote-config/propagate-updates-realtime)

## 🆘 Support

Nếu gặp vấn đề, check:
1. Firebase Console → Project Settings → Your Apps
2. Verify bundle ID matches
3. Download plist lại nếu cần
4. Check Firebase Status: [status.firebase.google.com](https://status.firebase.google.com/)

---

**Last Updated**: November 2024
**Firebase SDK Version**: 10.19.0+
