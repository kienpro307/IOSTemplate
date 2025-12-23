# 🏗️ Multi-Module Architecture

## 1. Tổng Quan

### 1.1 Kiến Trúc 4 Tầng (4-Tier Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│                         APPS LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ XTranslate  │  │ BankingApp  │  │  HealthApp  │  ... 8+ apps│
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
├─────────┼────────────────┼────────────────┼─────────────────────┤
│         │                │                │                     │
│         ▼                ▼                ▼                     │
│                      DOMAIN LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │XTranslateKit│  │ BankingKit  │  │  HealthKit  │ App-specific│
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
├─────────┴────────────────┴────────────────┴─────────────────────┤
│                                                                 │
│                      SERVICES LAYER                             │
│  ┌───────────────────┐  ┌─────────────────┐  ┌───────────────┐ │
│  │iOSMonetizationKit │  │ iOSAnalyticsKit │  │  iOSAuthKit   │ │
│  │(Ads, IAP, Payment)│  │(Firebase, Custom)│ │ (OAuth, etc.) │ │
│  └─────────┬─────────┘  └────────┬────────┘  └───────┬───────┘ │
├────────────┴─────────────────────┴───────────────────┴──────────┤
│                                                                 │
│                     FOUNDATION LAYER                            │
│  ┌───────────────┐  ┌──────────────────┐  ┌────────────────┐   │
│  │iOSLocationKit │  │iOSRemoteConfigKit│  │ iOSConsentKit  │   │
│  │(Core Location)│  │ (Firebase RC)    │  │ (ATT, CMP)     │   │
│  └───────────────┘  └──────────────────┘  └────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Định Nghĩa Các Tầng

| Tầng | Mô tả | Ví dụ |
|------|-------|-------|
| **Foundation** | Modules cơ bản, không có dependencies ngoài Apple SDK | Location, RemoteConfig, Consent |
| **Services** | Modules dịch vụ, phụ thuộc Foundation | Monetization, Analytics, Auth |
| **Domain** | Business logic riêng từng app | XTranslateKit, BankingKit |
| **Apps** | Ứng dụng cuối cùng | XTranslate, BankingApp |

---

## 2. Hybrid Multi-Repo Strategy

### 2.1 Cấu Trúc Repository

```
GitHub Organization Structure:
────────────────────────────────────────────────────────
FOUNDATION (1 Mono-repo - update cùng nhau):
github.com/you/ios-foundation
    ├── Package.swift
    ├── Sources/
    │   ├── iOSLocationKit/
    │   ├── iOSRemoteConfigKit/
    │   └── iOSConsentKit/
    └── Tests/

SERVICES (Mỗi module 1 repo - update độc lập):
github.com/you/iOSMonetizationKit
github.com/you/iOSAnalyticsKit
github.com/you/iOSAuthKit

DOMAIN (Mỗi app 1 repo - update độc lập):
github.com/you/XTranslateKit
github.com/you/BankingKit

APPS (Mỗi app 1 repo - release độc lập):
github.com/you/XTranslate
github.com/you/BankingApp
────────────────────────────────────────────────────────
```

### 2.2 Tại Sao Hybrid?

| Approach | Pros | Cons | Khi nào dùng |
|----------|------|------|--------------|
| **Mono-repo** | Dễ refactor, atomic changes | Scale kém, build chậm | Team nhỏ, <5 apps |
| **Multi-repo** | Scale tốt, CI/CD độc lập | Khó sync, version hell | Team lớn, nhiều apps |
| **Hybrid** ✅ | Cân bằng cả hai | Setup phức tạp hơn | 8+ apps, cần scale |

**Hybrid Multi-Repo** = Foundation chung (mono) + Còn lại tách riêng (multi)

---

## 3. Dependency Management

### 3.1 Version Pinning Strategy

```swift
// XTranslate/Package.swift

dependencies: [
    // ✅ EXACT VERSION - Kiểm soát hoàn toàn
    .package(
        url: "https://github.com/you/ios-foundation",
        exact: "1.5.2"
    ),
    
    // ✅ EXACT VERSION cho Services
    .package(
        url: "https://github.com/you/iOSMonetizationKit",
        exact: "2.3.0"
    ),
    
    // ⚠️ Third-party: Range nhưng kiểm soát
    .package(
        url: "https://github.com/firebase/firebase-ios-sdk",
        from: "11.0.0"
    )
]
```

### 3.2 Semantic Versioning

```
MAJOR.MINOR.PATCH
  │     │     │
  │     │     └── Bug fixes (không break)
  │     └──────── Features mới (không break)
  └────────────── Breaking changes

Ví dụ:
1.0.0 → 1.0.1  : Fix bug (update ngay OK)
1.0.1 → 1.1.0  : Feature mới (update khi muốn)
1.1.0 → 2.0.0  : Breaking (test kỹ trước)
```

### 3.3 Dependency Resolution

```
┌─────────────────────────────────────────────────────────────┐
│                 DEPENDENCY GRAPH                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  XTranslate (App)                                           │
│       │                                                     │
│       ├── XTranslateKit (Domain) @ 1.2.0                   │
│       │       │                                             │
│       │       ├── iOSMonetizationKit @ 2.3.0               │
│       │       │       │                                     │
│       │       │       ├── ios-foundation @ 1.5.2           │
│       │       │       └── Google-Mobile-Ads-SDK @ 11.0.0   │
│       │       │                                             │
│       │       └── ios-foundation @ 1.5.2 ✅ (same version) │
│       │                                                     │
│       └── iOSAnalyticsKit @ 1.1.0                          │
│               │                                             │
│               └── ios-foundation @ 1.5.2 ✅ (same version) │
│                                                             │
│  ✅ NO CONFLICT - All use foundation 1.5.2                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Module Communication

### 4.1 Communication Rules

```
┌─────────────────────────────────────────────────────────────┐
│                 MODULE COMMUNICATION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ ALLOWED:                                                │
│  • Upper layer → Lower layer (App → Domain → Service)       │
│  • Same layer via protocols (Service ↔ Service)             │
│  • Events/Delegates upward                                  │
│                                                             │
│  ❌ NOT ALLOWED:                                            │
│  • Lower layer → Upper layer directly                       │
│  • Circular dependencies                                    │
│  • Direct coupling between apps                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Protocol-Based Communication

```swift
// Foundation Layer - Protocol định nghĩa
public protocol LocationServiceProtocol {
    func getCurrentLocation() async throws -> Location
    func requestPermission() async -> PermissionStatus
}

// Foundation Layer - Implementation
public struct LiveLocationService: LocationServiceProtocol {
    public func getCurrentLocation() async throws -> Location {
        // Implementation
    }
}

// Services Layer - Sử dụng protocol
public struct MonetizationService {
    private let locationService: LocationServiceProtocol
    
    public init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }
    
    public func getLocalizedPricing() async throws -> Pricing {
        let location = try await locationService.getCurrentLocation()
        // Tính giá theo vùng
    }
}
```

---

## 5. Git Workflow

### 5.1 Branch Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                   GIT BRANCH STRATEGY                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  main ────●────●────●────●──── (releases only)              │
│            \                                                │
│  develop ───●──●──●──●──●──●── (integration branch)         │
│              \     \                                        │
│  feature/x ───●──●──┘     \                                │
│                            \                                │
│  feature/y ─────────────────●──●──┘                        │
│                                                             │
│  Naming:                                                    │
│  • feature/add-location-service                             │
│  • bugfix/fix-crash-on-permission                          │
│  • release/1.5.0                                           │
│  • hotfix/critical-payment-fix                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Release Process

```
1. Feature Complete
   └── Merge all features to develop

2. Create Release Branch
   └── git checkout -b release/1.5.0 develop

3. Testing & Bug Fixes
   └── Fix bugs directly on release branch

4. Finalize Release
   ├── Merge to main
   ├── Tag version: git tag 1.5.0
   └── Merge back to develop

5. Update Dependents
   └── Các apps update Package.swift nếu muốn
```

---

## 6. CI/CD Pipeline (Roadmap)

### 6.1 Phase 1: Basic CI

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: swift build
      - name: Test
        run: swift test
```

### 6.2 Phase 2: Full Pipeline (Future)

```
┌─────────────────────────────────────────────────────────────┐
│                   CI/CD PIPELINE (Future)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PR Created                                                 │
│       │                                                     │
│       ├── SwiftLint                                        │
│       ├── Build (Debug)                                    │
│       ├── Unit Tests                                       │
│       └── Code Coverage                                    │
│              │                                              │
│              ▼                                              │
│  PR Merged to develop                                       │
│       │                                                     │
│       ├── Build (Release)                                  │
│       ├── Integration Tests                                │
│       └── Deploy to TestFlight (internal)                  │
│              │                                              │
│              ▼                                              │
│  Merged to main                                             │
│       │                                                     │
│       ├── Tag version                                      │
│       ├── Generate changelog                               │
│       └── Deploy to App Store                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Build Optimization

### 7.1 Build Time Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                 BUILD OPTIMIZATION                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Development:                                               │
│  ✅ Xcode cache enabled (incremental builds)               │
│  ✅ Debug configuration                                     │
│  ✅ Only build active architecture                         │
│                                                             │
│  CI/CD:                                                     │
│  ✅ Clean build (đảm bảo reproducible)                     │
│  ✅ Release configuration                                   │
│  ✅ Build all architectures                                │
│                                                             │
│  Future (khi cần):                                          │
│  ⏳ Binary frameworks (XCFramework)                        │
│  ⏳ Distributed builds                                     │
│  ⏳ Build cache sharing                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Binary Framework (Khi Cần)

```
Source Code:
├── Xcode compile mỗi lần (chậm khi module lớn)
├── Xem được code (dễ debug)
└── Dùng khi: Module đang thay đổi nhiều ✅ HIỆN TẠI

Binary (XCFramework):
├── Pre-compiled (nhanh)
├── Không xem được code
└── Dùng khi: Module ổn định, hiếm khi đổi ⏳ TƯƠNG LAI
```

---

## 8. Package.swift Examples

### 8.1 Foundation Package

```swift
// ios-foundation/Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ios-foundation",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "iOSLocationKit", targets: ["iOSLocationKit"]),
        .library(name: "iOSRemoteConfigKit", targets: ["iOSRemoteConfigKit"]),
        .library(name: "iOSConsentKit", targets: ["iOSConsentKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    ],
    targets: [
        // Location - Không dependencies
        .target(
            name: "iOSLocationKit",
            dependencies: []
        ),
        
        // RemoteConfig - Phụ thuộc Firebase
        .target(
            name: "iOSRemoteConfigKit",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ]
        ),
        
        // Consent - Phụ thuộc Location
        .target(
            name: "iOSConsentKit",
            dependencies: ["iOSLocationKit"]
        ),
        
        // Tests
        .testTarget(name: "iOSLocationKitTests", dependencies: ["iOSLocationKit"]),
        .testTarget(name: "iOSRemoteConfigKitTests", dependencies: ["iOSRemoteConfigKit"]),
        .testTarget(name: "iOSConsentKitTests", dependencies: ["iOSConsentKit"]),
    ]
)
```

### 8.2 Service Package

```swift
// iOSMonetizationKit/Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "iOSMonetizationKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "iOSMonetizationKit", targets: ["iOSMonetizationKit"]),
    ],
    dependencies: [
        // Foundation - Exact version
        .package(url: "https://github.com/you/ios-foundation", exact: "1.5.2"),
        
        // Third-party
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "iOSMonetizationKit",
            dependencies: [
                .product(name: "iOSLocationKit", package: "ios-foundation"),
                .product(name: "iOSRemoteConfigKit", package: "ios-foundation"),
                .product(name: "iOSConsentKit", package: "ios-foundation"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .testTarget(
            name: "iOSMonetizationKitTests",
            dependencies: ["iOSMonetizationKit"]
        ),
    ]
)
```

### 8.3 App Package

```swift
// XTranslate/Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "XTranslate",
    platforms: [.iOS(.v16)],
    dependencies: [
        // Domain
        .package(url: "https://github.com/you/XTranslateKit", exact: "1.2.0"),
        
        // Services - Chọn version cụ thể
        .package(url: "https://github.com/you/iOSMonetizationKit", exact: "2.3.0"),
        .package(url: "https://github.com/you/iOSAnalyticsKit", exact: "1.1.0"),
        
        // TCA
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
    ],
    targets: [
        .executableTarget(
            name: "XTranslate",
            dependencies: [
                "XTranslateKit",
                "iOSMonetizationKit",
                "iOSAnalyticsKit",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
```

---

## 9. ROI Analysis

### 9.1 Thời Gian Tiết Kiệm

| Hoạt động | Trước | Sau | Tiết kiệm |
|-----------|-------|-----|-----------|
| Setup app mới | 2 tuần | 2 ngày | 80% |
| Update SDK | 8 apps × 2h = 16h | 1 module × 2h = 2h | 87% |
| Bug fix core | 8 apps × 4h = 32h | 1 module × 4h = 4h | 87% |
| Feature mới | 8 apps × 8h = 64h | 1 module × 8h = 8h | 87% |

### 9.2 Tổng ROI

```
┌─────────────────────────────────────────────────────────────┐
│                    ROI CALCULATION                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Initial Investment:                                        │
│  • Setup multi-module: 2 tuần                              │
│  • Documentation: 1 tuần                                    │
│  • CI/CD setup: 1 tuần                                     │
│  Total: 4 tuần                                              │
│                                                             │
│  Monthly Savings (với 8 apps):                              │
│  • SDK updates: 14h/tháng                                  │
│  • Bug fixes: 28h/tháng                                    │
│  • Features: 56h/tháng                                     │
│  Total: 98h/tháng ≈ 2.5 tuần/tháng                         │
│                                                             │
│  Breakeven: ~2 tháng                                       │
│  Year 1 ROI: 54% thời gian tiết kiệm                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. Migration Guide

### 10.1 Từ Monolith sang Multi-Module

```
Phase 1: Tách Foundation (2 tuần)
├── Extract LocationKit
├── Extract RemoteConfigKit
├── Extract ConsentKit
└── Publish ios-foundation repo

Phase 2: Tách Services (2 tuần)
├── Extract MonetizationKit
├── Extract AnalyticsKit
└── Publish từng repo

Phase 3: Tách Domain (1 tuần/app)
├── Extract XTranslateKit
└── Update XTranslate app

Phase 4: Cleanup (1 tuần)
├── Remove duplicated code
├── Update documentation
└── Setup CI/CD
```

### 10.2 Checklist Migration

- [ ] Định nghĩa module boundaries
- [ ] Tạo Package.swift cho mỗi module
- [ ] Di chuyển code theo thứ tự: Foundation → Services → Domain
- [ ] Update import statements
- [ ] Chạy tests sau mỗi step
- [ ] Tạo repo mới và push
- [ ] Update apps để dùng packages

---

## 11. Summary

### Key Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Architecture | 4-tier | Clear separation, scalable |
| Repo Strategy | Hybrid Multi-Repo | Balance control & independence |
| Versioning | Semantic + Exact Pin | Stability + Control |
| Communication | Protocol-based | Loose coupling |
| Build | Source code (now) | Still iterating quickly |

### Benefits

- ✅ **Reusability**: Code dùng lại cho 8+ apps
- ✅ **Independence**: Apps release độc lập
- ✅ **Scalability**: Sẵn sàng cho team 10+ người
- ✅ **Maintainability**: Bug fix một chỗ, apply nhiều apps
- ✅ **Testability**: Module nhỏ, dễ test

---

*Multi-Module Architecture là nền tảng cho việc scale development từ 1 app lên 8+ apps với team từ solo lên 10+ người.*
