# 📦 Chiến Lược Sử Dụng Code Có Sẵn

## 1. Nguyên Tắc Cốt Lõi

```
┌─────────────────────────────────────────────────────────────────┐
│                    NGUYÊN TẮC "KHÔNG LÀM LẠI"                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🎯 MỤC TIÊU: Tối ưu 60% thời gian development                 │
│                                                                 │
│  ✅ SỬ DỤNG CODE CÓ SẴN khi:                                   │
│  • Package đã được cộng đồng kiểm chứng (1000+ stars)          │
│  • Có documentation tốt                                        │
│  • Được maintain active (update trong 6 tháng gần nhất)        │
│  • Phù hợp với use case của mình                               │
│                                                                 │
│  ✅ TỰ VIẾT khi:                                                │
│  • Business logic riêng của app                                │
│  • Không có package phù hợp                                    │
│  • Package có quá nhiều features không cần                     │
│  • Cần kiểm soát hoàn toàn                                     │
│                                                                 │
│  ❌ TRÁNH:                                                      │
│  • Tự viết những gì đã có sẵn                                  │
│  • Dùng package không được maintain                            │
│  • Copy code không hiểu rõ                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Swift Packages Đã Được Chọn

### 2.1 Architecture & State Management

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **TCA** | 12k+ | State management, composition | 4-6 tuần |
| **swift-dependencies** | 1.5k+ | Dependency injection | 1-2 tuần |

```swift
// ✅ Dùng TCA thay vì tự viết Redux-like
// Tiết kiệm: 4-6 tuần development

// ❌ KHÔNG LÀM
class CustomStore<State, Action> {
    var state: State
    func dispatch(_ action: Action) { /* ... */ }
    // ... hàng nghìn dòng code
}

// ✅ DÙNG TCA
@Reducer
struct MyFeature {
    // Chỉ focus vào business logic
}
```

### 2.2 Networking

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **Moya** | 15k+ | Type-safe networking | 2-3 tuần |
| **Alamofire** | 41k+ | HTTP client (Moya dùng) | 2-3 tuần |

```swift
// ✅ Dùng Moya thay vì tự viết API layer
// Tiết kiệm: 2-3 tuần

// ❌ KHÔNG LÀM
class APIClient {
    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Tự xử lý URLSession, error handling, retry...
    }
}

// ✅ DÙNG MOYA
enum UserAPI: TargetType {
    case getUser(id: String)
    case updateUser(User)
    
    var path: String { /* ... */ }
    var method: Moya.Method { /* ... */ }
}
```

### 2.3 Image Loading

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **Kingfisher** | 23k+ | Async image + caching | 2 tuần |
| **SDWebImage** | 25k+ | Alternative | 2 tuần |

```swift
// ✅ Dùng Kingfisher thay vì tự viết image caching
// Tiết kiệm: 2 tuần

// ❌ KHÔNG LÀM
class ImageCache {
    private var memoryCache: NSCache<NSString, UIImage>
    private var diskCache: FileManager
    
    func loadImage(from url: URL) async -> UIImage? {
        // Check memory cache
        // Check disk cache
        // Download if needed
        // Cache to memory
        // Cache to disk
        // Handle errors
        // ...100+ dòng code
    }
}

// ✅ DÙNG KINGFISHER
KFImage(url)
    .placeholder { ProgressView() }
    .resizable()
```

### 2.4 Storage

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **KeychainAccess** | 8k+ | Secure storage | 1 tuần |
| **SwiftyUserDefaults** | 4.8k+ | UserDefaults wrapper | 3 ngày |

```swift
// ✅ Dùng KeychainAccess thay vì Security framework
// Tiết kiệm: 1 tuần

// ❌ KHÔNG LÀM
func saveToKeychain(key: String, value: String) throws {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: value.data(using: .utf8)!,
        // ... nhiều parameters phức tạp
    ]
    let status = SecItemAdd(query as CFDictionary, nil)
    // Handle status codes...
}

// ✅ DÙNG KEYCHAINACCESS
let keychain = Keychain(service: "com.app.ios")
keychain["token"] = "abc123"
```

### 2.5 Firebase

| Package | Mục đích | Tiết kiệm |
|---------|----------|-----------|
| **Firebase SDK** | Analytics, Crashlytics, RC, FCM | 3-4 tuần |

```swift
// ✅ Dùng Firebase SDK chính thức
// Tiết kiệm: 3-4 tuần cho mỗi service

// Analytics - Không cần tự build
Analytics.logEvent("purchase", parameters: ["item": "premium"])

// Crashlytics - Không cần tự build crash reporting
Crashlytics.crashlytics().record(error: error)

// Remote Config - Không cần tự build feature flags
RemoteConfig.remoteConfig().fetchAndActivate()
```

### 2.6 Monetization

| Package | Mục đích | Tiết kiệm |
|---------|----------|-----------|
| **Google Mobile Ads** | AdMob integration | 2 tuần |
| **StoreKit 2** (Native) | In-App Purchase | Native |
| **RevenueCat** (Optional) | IAP management | 2-3 tuần |

### 2.7 UI Components

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **SwiftUI-Introspect** | 5k+ | Access UIKit từ SwiftUI | 1 tuần |
| **Lottie** | 25k+ | Animation | 2 tuần |
| **ConfettiSwiftUI** | 1.5k+ | Celebration effects | 2 ngày |

### 2.8 Code Quality

| Package | Stars | Mục đích | Tiết kiệm |
|---------|-------|----------|-----------|
| **SwiftLint** | 18k+ | Linting | Ongoing |
| **SwiftFormat** | 8k+ | Formatting | Ongoing |
| **swift-snapshot-testing** | 3.7k+ | UI testing | 1 tuần |

---

## 3. Quy Trình Đánh Giá Package

### 3.1 Checklist Trước Khi Chọn

```
┌─────────────────────────────────────────────────────────────────┐
│                    PACKAGE EVALUATION CHECKLIST                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  □ GitHub Stars > 1,000                                        │
│  □ Last commit < 6 tháng                                       │
│  □ Issues được respond                                         │
│  □ Documentation đầy đủ                                        │
│  □ Swift 5.9+ compatible                                       │
│  □ iOS 16+ support                                             │
│  □ SPM support (không chỉ CocoaPods)                           │
│  □ License phù hợp (MIT, Apache 2.0)                           │
│  □ Không có known security issues                              │
│  □ Size hợp lý (không quá bloated)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Ví Dụ Đánh Giá

```
Package: Kingfisher
────────────────────────────────────
✅ Stars: 23k+
✅ Last commit: 2 tuần trước
✅ Issues: Active response
✅ Documentation: Xuất sắc
✅ Swift: 5.9 compatible
✅ iOS: 13+ (cover iOS 16)
✅ SPM: Yes
✅ License: MIT
✅ Security: No issues
✅ Size: Reasonable

VERDICT: ✅ SỬ DỤNG
```

---

## 4. Package.swift Mẫu

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSTemplate",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "UI", targets: ["UI"]),
        .library(name: "Services", targets: ["Services"]),
    ],
    dependencies: [
        // ═══════════════════════════════════════════════════════════
        // ARCHITECTURE - Tiết kiệm 4-6 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // NETWORKING - Tiết kiệm 2-3 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/Moya/Moya",
            from: "15.0.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // IMAGE LOADING - Tiết kiệm 2 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/onevcat/Kingfisher",
            from: "8.0.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // STORAGE - Tiết kiệm 1 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            from: "4.2.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // FIREBASE - Tiết kiệm 3-4 tuần (mỗi service)
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "11.0.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // ADS - Tiết kiệm 2 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
            from: "11.0.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // UI - Tiết kiệm 2-3 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            from: "4.4.0"
        ),
        
        // ═══════════════════════════════════════════════════════════
        // TESTING - Tiết kiệm 1 tuần
        // ═══════════════════════════════════════════════════════════
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.17.0"
        ),
    ],
    targets: [
        // ... targets
    ]
)
```

---

## 5. ROI Analysis

### 5.1 Thời Gian Tiết Kiệm

| Category | Package | Thời gian tiết kiệm |
|----------|---------|---------------------|
| Architecture | TCA | 4-6 tuần |
| Networking | Moya | 2-3 tuần |
| Image | Kingfisher | 2 tuần |
| Storage | KeychainAccess | 1 tuần |
| Analytics | Firebase | 3 tuần |
| Crash | Crashlytics | 2 tuần |
| Remote Config | Firebase RC | 2 tuần |
| Ads | AdMob SDK | 2 tuần |
| Animation | Lottie | 2 tuần |
| Testing | Snapshot | 1 tuần |
| **TỔNG** | | **~20-24 tuần** |

### 5.2 So Sánh

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT TIME COMPARISON                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TỰ VIẾT TẤT CẢ:                                               │
│  ├── State management: 6 tuần                                  │
│  ├── Networking layer: 3 tuần                                  │
│  ├── Image caching: 2 tuần                                     │
│  ├── Secure storage: 1 tuần                                    │
│  ├── Analytics: 3 tuần                                         │
│  ├── Crash reporting: 2 tuần                                   │
│  ├── Feature flags: 2 tuần                                     │
│  ├── Ad integration: 2 tuần                                    │
│  └── Business logic: 4 tuần                                    │
│  TOTAL: ~25 tuần                                                │
│                                                                 │
│  DÙNG PACKAGES + TẬP TRUNG BUSINESS LOGIC:                     │
│  ├── Setup packages: 1 tuần                                    │
│  ├── Configuration: 1 tuần                                     │
│  ├── Integration: 2 tuần                                       │
│  └── Business logic: 4 tuần                                    │
│  TOTAL: ~8 tuần                                                 │
│                                                                 │
│  TIẾT KIỆM: 17 tuần (~68%)                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Version Pinning Strategy

### 6.1 Exact vs Range

```swift
// ✅ RECOMMENDED: Exact version cho production
.package(url: "...", exact: "1.15.0")

// ⚠️ Development: Range version OK
.package(url: "...", from: "1.15.0")

// ❌ AVOID: Không dùng branch
.package(url: "...", branch: "main")
```

### 6.2 Update Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    PACKAGE UPDATE STRATEGY                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PATCH (1.0.x):                                                 │
│  • Auto update OK                                               │
│  • Bug fixes only                                               │
│  • Test after update                                            │
│                                                                 │
│  MINOR (1.x.0):                                                 │
│  • Review changelog                                             │
│  • Test trong development                                       │
│  • Update khi có time                                           │
│                                                                 │
│  MAJOR (x.0.0):                                                 │
│  • Plan migration                                               │
│  • Review breaking changes                                      │
│  • Test kỹ trước release                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Packages Nên Tránh

### 7.1 Red Flags

```
❌ TRÁNH packages có:
• Last commit > 1 năm
• Nhiều open issues không được trả lời
• Không support SPM
• Không support iOS 16+
• License không rõ ràng
• Quá nhiều dependencies
• Size quá lớn cho feature đơn giản
```

### 7.2 Alternatives Table

| Thay vì | Dùng | Lý do |
|---------|------|-------|
| ~~Alamofire trực tiếp~~ | Moya (wrap Alamofire) | Type-safe, testable |
| ~~SDWebImage~~ | Kingfisher | Better SwiftUI support |
| ~~Realm~~ | Core Data / SwiftData | Native, no extra dependencies |
| ~~RxSwift~~ | Combine + TCA | Native, less dependencies |
| ~~CocoaPods only~~ | SPM | Native package manager |

---

## 8. Tạo Wrappers

### 8.1 Khi Nào Cần Wrapper

```
✅ TẠO WRAPPER khi:
• Cần abstract away implementation details
• Muốn dễ swap packages sau này
• Cần thêm custom logic
• Cần mock cho testing

❌ KHÔNG CẦN WRAPPER khi:
• Package API đã clean
• Chỉ dùng 1-2 methods
• Không cần mock
```

### 8.2 Ví Dụ Wrapper

```swift
// ImageService wrapper cho Kingfisher
// Dễ swap sang SDWebImage nếu cần

protocol ImageServiceProtocol {
    func loadImage(from url: URL) async throws -> UIImage
    func prefetch(urls: [URL])
    func clearCache()
}

struct KingfisherImageService: ImageServiceProtocol {
    func loadImage(from url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func prefetch(urls: [URL]) {
        ImagePrefetcher(urls: urls).start()
    }
    
    func clearCache() {
        ImageCache.default.clearCache()
    }
}

// Mock cho testing
struct MockImageService: ImageServiceProtocol {
    var mockImage: UIImage = UIImage()
    
    func loadImage(from url: URL) async throws -> UIImage {
        return mockImage
    }
    
    func prefetch(urls: [URL]) { }
    func clearCache() { }
}
```

---

## 9. Summary

### Key Takeaways

1. **Dùng packages có sẵn** cho infrastructure (networking, storage, analytics)
2. **Tự viết** business logic riêng của app
3. **Tiết kiệm ~68% thời gian** development
4. **Đánh giá kỹ** trước khi adopt package mới
5. **Pin versions** cho production stability

### Golden Rule

```
"Đừng phát minh lại bánh xe.
 Tập trung vào những gì tạo nên giá trị unique cho app của bạn."
```

---

*Document này giúp team đưa ra quyết định đúng đắn về việc build vs buy.*
