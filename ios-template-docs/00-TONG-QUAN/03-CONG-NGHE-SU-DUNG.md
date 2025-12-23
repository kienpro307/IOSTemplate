# 🛠️ Công Nghệ Sử Dụng (Technology Stack)

## 1. Tổng Quan Tech Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                      iOS TEMPLATE TECH STACK                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION                          │   │
│  │  SwiftUI • TCA Views • Custom Components                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ARCHITECTURE                          │   │
│  │  TCA (The Composable Architecture) • DI Container       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     SERVICES                             │   │
│  │  Firebase • StoreKit 2 • AdMob • AuthenticationServices │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   INFRASTRUCTURE                         │   │
│  │  Moya • Core Data • Keychain • NSCache                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      PLATFORM                            │   │
│  │  iOS 16+ • Swift 5.9+ • Xcode 15+                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Technologies

### 2.1 Language & Platform

| Technology | Version | Purpose | Documentation |
|------------|---------|---------|---------------|
| **Swift** | 5.9+ | Primary language | [swift.org](https://swift.org/documentation/) |
| **iOS** | 16.0+ | Target platform | [Apple Developer](https://developer.apple.com/documentation/) |
| **Xcode** | 15.0+ | IDE | [Xcode Help](https://help.apple.com/xcode/) |

**Tại sao Swift 5.9?**
- Macro support
- Parameter packs
- Improved concurrency
- Better Swift/Obj-C interop

**Tại sao iOS 16?**
- NavigationStack (SwiftUI)
- Charts framework
- WeatherKit
- ~95% market coverage

### 2.2 UI Framework

| Technology | Version | Purpose |
|------------|---------|---------|
| **SwiftUI** | 5.0 | UI framework |

**Tại sao SwiftUI only?**

```
┌────────────────────────────────────────────────────────────┐
│                  SwiftUI vs UIKit Decision                  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  SwiftUI Advantages:                                       │
│  ✓ Declarative syntax                                      │
│  ✓ Less boilerplate code                                   │
│  ✓ Better state management                                 │
│  ✓ Live previews                                           │
│  ✓ Future-proof                                            │
│  ✓ AI-friendly (easier to generate)                        │
│                                                            │
│  UIKit Still Needed For:                                   │
│  • Complex animations (rare)                               │
│  • Camera/Video capture                                    │
│  • WebView                                                 │
│  → Wrapped in UIViewRepresentable when needed              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 3. Architecture Framework

### 3.1 TCA (The Composable Architecture)

| Package | Version | Source |
|---------|---------|--------|
| **ComposableArchitecture** | 1.15.0+ | [GitHub](https://github.com/pointfreeco/swift-composable-architecture) |

**Core Concepts:**

```swift
// State - Dữ liệu của feature
@ObservableState
struct TrangThaiDangNhap {
    var email: String = ""
    var matKhau: String = ""
    var dangTai: Bool = false
    var loi: String?
}

// Action - Các sự kiện có thể xảy ra
enum HanhDongDangNhap {
    case emailThayDoi(String)
    case matKhauThayDoi(String)
    case nutDangNhapNhan
    case phanHoiDangNhap(Result<NguoiDung, Error>)
}

// Reducer - Logic xử lý
@Reducer
struct BoGiamDangNhap {
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .emailThayDoi(let email):
                state.email = email
                return .none
            // ... more cases
            }
        }
    }
}

// View - UI
struct DangNhapView: View {
    @Bindable var store: StoreOf<BoGiamDangNhap>
    
    var body: some View {
        // UI code
    }
}
```

**Tại sao TCA?**

| Tiêu chí | TCA | MVVM | VIPER |
|----------|-----|------|-------|
| Testability | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Predictability | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| SwiftUI Integration | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Learning Curve | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Boilerplate | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Composition | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

---

## 4. Networking

### 4.1 HTTP Client

| Package | Version | Source |
|---------|---------|--------|
| **Moya** | 15.0+ | [GitHub](https://github.com/Moya/Moya) |

**Tại sao Moya thay vì URLSession thuần?**

```swift
// URLSession thuần - Verbose
func layNguoiDung(id: String) async throws -> NguoiDung {
    var request = URLRequest(url: URL(string: "https://api.example.com/users/\(id)")!)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode else {
        throw APIError.invalidResponse
    }
    return try JSONDecoder().decode(NguoiDung.self, from: data)
}

// Moya - Clean & Type-safe
enum NguoiDungAPI {
    case layNguoiDung(id: String)
    case capNhatNguoiDung(NguoiDung)
}

extension NguoiDungAPI: TargetType {
    var path: String {
        switch self {
        case .layNguoiDung(let id): return "/users/\(id)"
        case .capNhatNguoiDung: return "/users"
        }
    }
    // ... more config
}

// Usage
let nguoiDung = try await provider.request(.layNguoiDung(id: "123"))
```

### 4.2 Image Loading

| Package | Version | Source |
|---------|---------|--------|
| **Kingfisher** | 8.0+ | [GitHub](https://github.com/onevcat/Kingfisher) |

**Features:**
- Async image downloading
- Memory & disk caching
- Image processing
- Placeholder support
- Progressive loading

```swift
// Usage
KFImage(URL(string: imageURL))
    .placeholder {
        ProgressView()
    }
    .resizable()
    .aspectRatio(contentMode: .fill)
```

---

## 5. Data Persistence

### 5.1 Local Storage Matrix

| Data Type | Storage Solution | When to Use |
|-----------|------------------|-------------|
| User preferences | UserDefaults | Small key-value pairs |
| Sensitive data | Keychain | Tokens, passwords |
| Structured data | Core Data / SwiftData | Complex objects |
| Cache | NSCache + Disk | Temporary data |
| Files | FileManager | Documents, images |

### 5.2 Core Data / SwiftData

```swift
// Core Data Entity
@objc(NguoiDungEntity)
public class NguoiDungEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var ten: String
    @NSManaged public var email: String
    @NSManaged public var ngayTao: Date
}

// SwiftData Model (iOS 17+)
@Model
final class NguoiDung {
    @Attribute(.unique) var id: String
    var ten: String
    var email: String
    var ngayTao: Date
    
    init(id: String, ten: String, email: String) {
        self.id = id
        self.ten = ten
        self.email = email
        self.ngayTao = Date()
    }
}
```

### 5.3 Keychain

| Package | Version | Source |
|---------|---------|--------|
| **KeychainAccess** | 4.2+ | [GitHub](https://github.com/kishikawakatsumi/KeychainAccess) |

```swift
// Usage
let keychain = Keychain(service: "com.template.ios")

// Save
keychain["accessToken"] = token

// Read
let token = keychain["accessToken"]

// Delete
keychain["accessToken"] = nil
```

---

## 6. Firebase Services

### 6.1 Firebase SDKs

| Service | Package | Version | Purpose |
|---------|---------|---------|---------|
| **Analytics** | FirebaseAnalytics | 11.0+ | Event tracking |
| **Crashlytics** | FirebaseCrashlytics | 11.0+ | Crash reporting |
| **Remote Config** | FirebaseRemoteConfig | 11.0+ | Feature flags |
| **Cloud Messaging** | FirebaseMessaging | 11.0+ | Push notifications |
| **Performance** | FirebasePerformance | 11.0+ | Performance monitoring |

### 6.2 Firebase Setup

```swift
// AppDelegate or App init
import FirebaseCore

@main
struct TemplateApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 6.3 Analytics Events

```swift
// Tracking events
Analytics.logEvent("dang_nhap_thanh_cong", parameters: [
    "phuong_thuc": "email",
    "thoi_gian": Date().timeIntervalSince1970
])

// User properties
Analytics.setUserProperty("premium", forName: "loai_tai_khoan")
```

---

## 7. Monetization

### 7.1 In-App Purchase

| Technology | Version | Purpose |
|------------|---------|---------|
| **StoreKit 2** | Native | IAP transactions |

```swift
// Product loading
let products = try await Product.products(for: ["premium_monthly", "premium_yearly"])

// Purchase
let result = try await product.purchase()

switch result {
case .success(let verification):
    let transaction = try checkVerified(verification)
    await transaction.finish()
case .userCancelled:
    break
case .pending:
    break
@unknown default:
    break
}
```

### 7.2 Advertising

| Package | Version | Source |
|---------|---------|--------|
| **Google-Mobile-Ads-SDK** | 11.0+ | [Google](https://developers.google.com/admob/ios/quick-start) |

```swift
// Banner Ad
struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-xxxxx/xxxxx"
        bannerView.load(GADRequest())
        return bannerView
    }
}

// Interstitial Ad
class InterstitialAdManager: NSObject {
    private var interstitial: GADInterstitialAd?
    
    func loadAd() async {
        interstitial = try? await GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-xxxxx/xxxxx",
            request: GADRequest()
        )
    }
}
```

---

## 8. Authentication

### 8.1 Auth Providers

| Provider | SDK | Purpose |
|----------|-----|---------|
| **Email/Password** | Firebase Auth | Basic auth |
| **Google Sign-In** | GoogleSignIn | Social auth |
| **Sign in with Apple** | AuthenticationServices | Social auth |
| **Biometric** | LocalAuthentication | Face ID / Touch ID |

### 8.2 Sign in with Apple

```swift
import AuthenticationServices

struct SignInWithAppleButton: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                handleAuth(auth)
            case .failure(let error):
                handleError(error)
            }
        }
        .frame(height: 50)
    }
}
```

---

## 9. Development Tools

### 9.1 Code Quality

| Tool | Purpose | Configuration |
|------|---------|---------------|
| **SwiftLint** | Linting | `.swiftlint.yml` |
| **SwiftFormat** | Formatting | `.swiftformat` |

### 9.2 Testing

| Framework | Purpose |
|-----------|---------|
| **XCTest** | Unit testing |
| **swift-snapshot-testing** | Snapshot testing |
| **XCUITest** | UI testing |

### 9.3 CI/CD

| Tool | Purpose |
|------|---------|
| **GitHub Actions** | CI pipeline |
| **Fastlane** | Deployment |
| **TestFlight** | Beta distribution |

---

## 10. Package.swift Example

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSTemplate",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "Loi", targets: ["Loi"]),
        .library(name: "GiaoDien", targets: ["GiaoDien"]),
        .library(name: "DichVu", targets: ["DichVu"]),
        .library(name: "TinhNang", targets: ["TinhNang"]),
    ],
    dependencies: [
        // Architecture
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
        
        // Networking
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0"),
        
        // Storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
        
        // Firebase
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
    ],
    targets: [
        // Core module - No dependencies
        .target(
            name: "Loi",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources/Loi"
        ),
        
        // UI module
        .target(
            name: "GiaoDien",
            dependencies: [
                "Loi",
                .product(name: "Kingfisher", package: "Kingfisher"),
            ],
            path: "Sources/GiaoDien"
        ),
        
        // Services module
        .target(
            name: "DichVu",
            dependencies: [
                "Loi",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            path: "Sources/DichVu"
        ),
        
        // Features module
        .target(
            name: "TinhNang",
            dependencies: [
                "Loi",
                "GiaoDien",
                "DichVu",
            ],
            path: "Sources/TinhNang"
        ),
        
        // Tests
        .testTarget(
            name: "LoiTests",
            dependencies: [
                "Loi",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
```

---

## 11. Version Compatibility Matrix

| Dependency | Min Version | Max Tested | Notes |
|------------|-------------|------------|-------|
| ComposableArchitecture | 1.15.0 | 1.17.0 | Stable |
| Moya | 15.0.0 | 15.0.3 | Stable |
| Kingfisher | 8.0.0 | 8.1.0 | Stable |
| KeychainAccess | 4.2.0 | 4.2.2 | Stable |
| Firebase | 11.0.0 | 11.5.0 | Update frequently |

---

## 12. Migration Notes

### From React Native

| React Native | iOS Native |
|--------------|------------|
| Redux | TCA |
| AsyncStorage | UserDefaults + Keychain |
| Axios | Moya |
| React Navigation | NavigationStack |
| StyleSheet | Theme System |
| Context | TCA Dependencies |

---

*Tech stack này được chọn lựa cẩn thận để cân bằng giữa productivity, maintainability, và performance.*
