# Kiến Trúc Template iOS

## 📋 Tổng Quan

iOS Template này được xây dựng theo kiến trúc **modular** (module hoá) sử dụng **Swift Package Manager (SPM)**. Template là một Swift Package có thể tái sử dụng, không phải là một app độc lập.

### 🎨 Design Philosophy

**UI/UX:** Template sử dụng **Liquid Glass** design language - design system hiện đại của Apple với glass materials, fluid animations, và dynamic light reflections.

**Technology:** Luôn sử dụng **công nghệ iOS mới nhất** (hiện tại: iOS 18+). Khi có phiên bản iOS mới, template sẽ được cập nhật để leverage các APIs và features mới nhất.

**Principles:**
- ✨ Modern, fluid, glass-based UI
- 🚀 Latest iOS APIs và Swift features
- ♿️ Accessibility-first design
- 🎯 Performance-optimized
- 🔄 Future-proof architecture

## 🏗️ Cấu Trúc Project

```
ios-template/
├── Sources/iOSTemplate/          # Swift Package - Template library
│   ├── Core/                     # Core components (TCA, Theme, DI)
│   ├── Features/                 # Feature modules (Onboarding, Auth, etc.)
│   ├── Services/                 # Services (Network, Storage, etc.)
│   └── iOSTemplate.swift         # Module entry point
│
├── App/iOSTemplateApp/           # App wrapper - Ví dụ sử dụng template
│   └── iOSTemplateApp.swift      # iOS App entry point
│
├── Package.swift                 # Swift Package definition
└── docs/                         # Documentation
```

## 🎯 Kiến Trúc Modular vs Monolithic

### Monolithic Architecture (Kiến trúc nguyên khối)

```
MyApp/
└── MyApp/
    ├── Onboarding/
    ├── Login/
    ├── Home/
    └── ...
```

**Đặc điểm:**
- Tất cả code trong 1 app target
- Code gắn chặt với app cụ thể
- **Không thể** tái sử dụng cho app khác
- Phù hợp cho app độc lập, không có kế hoạch tái sử dụng

### Modular Architecture (Kiến trúc module hoá) ⭐

```
iOSTemplate Package (Library)
├── Core modules
├── Feature modules
└── Service modules

BankingApp                  FitnessApp                  EcommerceApp
└── Uses iOSTemplate        └── Uses iOSTemplate        └── Uses iOSTemplate
```

**Đặc điểm:**
- Code được tách thành Swift Package độc lập
- Template có thể tái sử dụng cho nhiều apps
- Mỗi app "wrap" template và customize qua configs
- Dễ bảo trì, test, và mở rộng
- **Đây là cách mà template này được thiết kế**

## 📦 Tại Sao Là Swift Package?

### Lợi Ích

1. **Tái Sử Dụng (Reusability)**
   ```swift
   // Banking App
   dependencies: [
       .package(url: "ios-template", from: "1.0.0")
   ]

   // Fitness App
   dependencies: [
       .package(url: "ios-template", from: "1.0.0")
   ]

   // E-commerce App
   dependencies: [
       .package(url: "ios-template", from: "1.0.0")
   ]
   ```

2. **Separation of Concerns (Tách biệt rõ ràng)**
   - Template chứa business logic, UI components
   - App chỉ chứa configuration và customization
   - Giảm duplicate code giữa các apps

3. **Easy Testing**
   - Test template độc lập
   - Mock dependencies dễ dàng
   - CI/CD cho từng module

4. **Version Control**
   - Template có version riêng
   - Apps có thể dùng version khác nhau
   - Update template không ảnh hưởng app đang chạy

5. **Team Collaboration**
   - Team có thể chia việc: người làm template, người làm apps
   - Pull Request rõ ràng: template changes vs app changes

## 🔧 Cách Sử Dụng Template

### 1. Template (Swift Package)

**Nơi code:** `Sources/iOSTemplate/`

**Chứa:**
- Core components (TCA, Theme, DI)
- Reusable features (Onboarding, Login, etc.)
- Services (Network, Storage, Logging)
- **Parameterized Components** (View + Config)

**Lưu ý:**
- ✅ Code ở đây khi muốn cải thiện/thêm feature cho template
- ✅ Code có thể tái sử dụng cho nhiều apps
- ❌ Không code app-specific logic ở đây

### 2. App Wrapper

**Nơi code:** `App/iOSTemplateApp/` (hoặc app riêng của bạn)

**Chứa:**
- App entry point (`@main`)
- **App-specific configurations**
- Custom app logic nếu cần

**Ví dụ:**

```swift
// App/BankingApp/BankingApp.swift
import iOSTemplate

@main
struct BankingApp: App {
    let store: StoreOf<AppReducer>

    init() {
        _ = DIContainer.shared
        self.store = Store(initialState: AppState()) {
            AppReducer()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

## 🎨 Parameterized Component Pattern

Template sử dụng **Parameterized Component Pattern** (Cách 1) để cho phép customization.

### Cách Hoạt Động

```
┌─────────────────────────────────────────────┐
│  Template Package (iOSTemplate)             │
│                                             │
│  ┌────────────────┐    ┌─────────────────┐ │
│  │ OnboardingView │◄───│ OnboardingConfig│ │
│  │  (Reusable)    │    │  (Customizable) │ │
│  └────────────────┘    └─────────────────┘ │
│                                             │
│  ┌────────────────┐    ┌─────────────────┐ │
│  │   LoginView    │◄───│   LoginConfig   │ │
│  │  (Reusable)    │    │  (Customizable) │ │
│  └────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────┘
                     │
                     │ Used by
                     ▼
         ┌───────────────────────┐
         │   Banking App         │
         │                       │
         │  bankingConfig = ...  │
         │  OnboardingView(      │
         │    config: bankingConfig│
         │  )                    │
         └───────────────────────┘
```

### Ví Dụ Cụ Thể

#### Template Cung Cấp:

```swift
// Sources/iOSTemplate/Features/Onboarding/OnboardingView.swift
public struct OnboardingView: View {
    let config: OnboardingConfig  // Nhận config từ bên ngoài

    public init(store: StoreOf<AppReducer>, config: OnboardingConfig) {
        self.config = config
    }

    public var body: some View {
        // Sử dụng config.pages, config.colors, config.onComplete
    }
}

// Sources/iOSTemplate/Core/ViewConfigs/OnboardingConfig.swift
public struct OnboardingConfig {
    public let pages: [OnboardingPage]
    public let backgroundColor: Color
    public let finalButtonText: String
    public let onComplete: () -> Void
}
```

#### App A - Banking:

```swift
// App/BankingApp/BankingApp.swift
let bankingConfig = OnboardingConfig(
    pages: [
        OnboardingPage(icon: "banknote", title: "Secure Banking", ...),
        OnboardingPage(icon: "chart.line", title: "Track Expenses", ...)
    ],
    backgroundColor: .green.opacity(0.05),
    finalButtonText: "Start Banking",
    onComplete: {
        // Banking-specific logic
        analytics.track("banking_onboarding_completed")
        navigateToKYC()
    }
)

OnboardingView(store: store, config: bankingConfig)
```

#### App B - Fitness:

```swift
// App/FitnessApp/FitnessApp.swift
let fitnessConfig = OnboardingConfig(
    pages: [
        OnboardingPage(icon: "figure.run", title: "Get Fit", ...),
        OnboardingPage(icon: "heart.fill", title: "Stay Healthy", ...)
    ],
    backgroundColor: .black,
    finalButtonText: "Let's Go!",
    onComplete: {
        // Fitness-specific logic
        healthKit.requestPermissions()
        navigateToWorkoutSelection()
    }
)

OnboardingView(store: store, config: fitnessConfig)
```

**Kết quả:** Cùng 1 `OnboardingView` từ template, nhưng:
- Banking App: Màu xanh lá, nội dung banking, navigate to KYC
- Fitness App: Màu đen, nội dung fitness, navigate to workout

## 🚀 Workflow Phát Triển

### Scenario 1: Cải Thiện Template

**Mục tiêu:** Thêm animation vào OnboardingView

**Nơi code:**
```
Sources/iOSTemplate/Features/Onboarding/OnboardingView.swift ✅
```

**Lợi ích:** Tất cả apps sử dụng template đều được cải thiện

### Scenario 2: Tạo App Mới

**Bước 1:** Tạo app target mới (hoặc project riêng)
```swift
// App/MyNewApp/MyNewApp.swift
import iOSTemplate

@main
struct MyNewApp: App {
    let store: StoreOf<AppReducer>

    init() {
        _ = DIContainer.shared
        self.store = Store(initialState: AppState()) {
            AppReducer()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

**Bước 2:** Tạo configs cho app
```swift
// App/MyNewApp/Configs/MyAppOnboardingConfig.swift
extension OnboardingConfig {
    static var myApp: OnboardingConfig {
        OnboardingConfig(
            pages: [/* custom pages */],
            backgroundColor: /* custom color */,
            onComplete: { /* custom logic */ }
        )
    }
}
```

**Bước 3:** Sử dụng template với configs
```swift
OnboardingView(store: store, config: .myApp)
LoginView(store: store, config: .myApp)
```

### Scenario 3: App-Specific Feature

**Mục tiêu:** Banking app cần thêm màn KYC (Know Your Customer)

**Nơi code:**
```
App/BankingApp/Features/KYC/KYCView.swift ✅
```

**Lý do:** KYC chỉ dành riêng cho banking, không phải template feature

## 🎨 UI Design Guidelines

### Liquid Glass Design System

Template này sử dụng **Liquid Glass** design language - thiết kế hiện đại của Apple kết hợp:

- **Glass effect:** Blur và transparency cho depth
- **Fluidity:** Smooth transitions và animations
- **Light reflection:** Dynamic colors phản chiếu từ content xung quanh
- **Interactive feedback:** Real-time response với touch và gestures

**Tài liệu tham khảo:**
- [Apple Design Resources - Liquid Glass](https://developer.apple.com/design/)
- SwiftUI `.glass` modifier và Material effects
- Live Activities với Dynamic Island integration

### iOS Version & Technology Strategy

**Nguyên tắc:** Luôn sử dụng công nghệ mới nhất của iOS hiện tại

- **iOS 18 (Current):** Sử dụng tất cả APIs mới nhất
  - Swift 6 features (strict concurrency, typed throws)
  - SwiftUI latest features (animations, gestures, materials)
  - SwiftData với advanced querying
  - App Intents integration
  - Live Activities & Dynamic Island
  - WidgetKit enhancements
  
- **Future iOS versions:** Khi có phiên bản mới, ưu tiên adopt ngay:
  - Review release notes cho new APIs
  - Update minimum deployment target nếu cần
  - Refactor code để leverage new features
  - Update documentation với new capabilities

**⚠️ Deployment Target:**
```swift
// Package.swift hoặc Project Settings
platforms: [
    .iOS(.v18)  // ✅ Latest
    // .iOS(.v17)  // ❌ Avoid unless necessary
]
```

**📝 Khi iOS 19+ ra mắt:**
1. Review [Apple Developer Release Notes](https://developer.apple.com/documentation/)
2. Identify relevant new features cho template
3. Update deployment target
4. Adopt new APIs và deprecate old workarounds
5. Update docs và examples

## 📚 Best Practices

### ✅ DO

1. **Template:**
   - Code generic, reusable components
   - Use Parameterized Component Pattern
   - Document all public APIs
   - Write unit tests
   - **Design UI theo Liquid Glass principles**
   - **Sử dụng latest iOS APIs và features**
   - **Stay updated với Apple design guidelines**

2. **App:**
   - Create specific configs
   - Implement app-specific logic
   - Override theme nếu cần
   - Add app-specific features
   - **Customize Liquid Glass effects cho brand**

3. **UI/UX:**
   - Implement glass materials và blur effects
   - Add fluid animations và transitions
   - Use SF Symbols với variable colors
   - Support Dynamic Type và accessibility
   - Optimize cho Dark Mode
   - Consider spatial design principles

### ❌ DON'T

1. **Template:**
   - Hardcode app-specific values
   - Add dependencies on app-specific libraries
   - Break public APIs without version bump
   - **Sử dụng deprecated APIs khi có alternatives mới**
   - **Ignore Apple design guidelines**

2. **App:**
   - Modify template code directly (fork nếu thật sự cần)
   - Duplicate template features

3. **UI/UX:**
   - Create custom designs trái với iOS HIG
   - Over-complicate animations (keep it smooth & purposeful)
   - Ignore accessibility requirements

## 🔄 So Sánh Với Các Pattern Khác

### vs. Inheritance

```swift
// ❌ Inheritance approach
class BaseOnboardingViewController: UIViewController {
    func configure() { }  // Override trong subclass
}

class BankingOnboardingViewController: BaseOnboardingViewController {
    override func configure() { /* banking logic */ }
}
```

**Nhược điểm:**
- Tight coupling
- Khó test
- Không SwiftUI-friendly

### vs. Protocol-Based

```swift
// ❌ Protocol approach
protocol OnboardingConfigurable {
    var pages: [OnboardingPage] { get }
    var backgroundColor: Color { get }
}

struct BankingOnboarding: OnboardingConfigurable { }
```

**Nhược điểm:**
- Verbose
- Không type-safe cho closures
- Khó truyền dynamic behavior (onComplete)

### ✅ Parameterized Component (Template sử dụng)

```swift
// ✅ Parameterized approach
struct OnboardingConfig {
    let pages: [OnboardingPage]
    let backgroundColor: Color
    let onComplete: () -> Void  // Dynamic behavior!
}

OnboardingView(config: bankingConfig)
```

**Ưu điểm:**
- Simple, clean
- Type-safe
- SwiftUI-native
- Flexible với closures

## 🎓 Kết Luận

**Template iOS này là một Swift Package (library), không phải app.**

**Mục đích:** Cung cấp reusable components cho nhiều apps khác nhau.

**Cách sử dụng:** Mỗi app tạo app wrapper, import template, và customize qua configs.

**Pattern:** Parameterized Component Pattern - pass configuration objects để customize behavior.

**Lợi ích:** Reusability, maintainability, testability, separation of concerns.

---

## 📊 Quick Reference

| Aspect | Approach | Notes |
|--------|----------|-------|
| **Architecture** | Modular (Swift Package) | Reusable across multiple apps |
| **State Management** | TCA (Composable Architecture) | Predictable, testable state |
| **UI Design** | **Liquid Glass** | Apple's modern design language |
| **iOS Target** | **iOS 18+** (latest) | Update when new iOS releases |
| **Component Pattern** | Parameterized Components | Config-based customization |
| **DI** | DIContainer | Centralized dependency management |
| **Firebase** | Optional, configurable | Auto environment detection |
| **Testing** | Unit + Swift Testing | Comprehensive test coverage |

---

Chi tiết về Parameterized Component Pattern xem [COMPONENT_PATTERN.md](./COMPONENT_PATTERN.md)
