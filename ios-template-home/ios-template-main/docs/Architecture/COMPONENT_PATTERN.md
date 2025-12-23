# Parameterized Component Pattern

## 📋 Giới Thiệu

**Parameterized Component Pattern** là pattern chính được sử dụng trong iOS Template này để tạo reusable components. Pattern này cho phép một component có thể tái sử dụng cho nhiều apps khác nhau bằng cách pass configuration objects.

## 🎯 Nguyên Tắc Core

### 1. View + Config

Mỗi reusable component bao gồm 2 phần:

```swift
// 1. Config - Chứa data và behavior
public struct XYZConfig {
    let data: [Item]
    let colors: ColorScheme
    let onAction: () -> Void
}

// 2. View - Nhận config và render
public struct XYZView: View {
    let config: XYZConfig

    public var body: some View {
        // Use config.data, config.colors, config.onAction
    }
}
```

### 2. Separation of Concerns

- **Template** (Swift Package): Chứa View logic, UI rendering
- **App**: Chứa Config, app-specific data và behavior

## 🏗️ Cấu Trúc Chi Tiết

### File Organization

```
Sources/iOSTemplate/
├── Features/
│   └── Onboarding/
│       └── OnboardingView.swift          # View component
└── Core/
    └── ViewConfigs/
        └── OnboardingConfig.swift        # Config model
```

### Config Model Template

```swift
// Sources/iOSTemplate/Core/ViewConfigs/XYZConfig.swift
import SwiftUI

/// Configuration cho XYZView - cho phép customize cho mỗi app
///
/// Pattern: Parameterized Component
/// Cho phép reuse XYZView với branding và logic khác nhau
///
/// Ví dụ:
/// ```swift
/// let config = XYZConfig(
///     title: "Custom Title",
///     primaryColor: .blue,
///     onComplete: { /* custom logic */ }
/// )
/// XYZView(store: store, config: config)
/// ```
public struct XYZConfig {
    // MARK: - UI Properties

    /// Visual properties
    public let title: String
    public let subtitle: String
    public let icon: String?
    public let primaryColor: Color
    public let backgroundColor: Color

    // MARK: - Content Properties

    /// Data to display
    public let items: [Item]

    // MARK: - Behavior Properties

    /// Closures cho app-specific logic
    public let onComplete: () -> Void
    public let onCancel: (() -> Void)?

    // MARK: - Feature Flags

    /// Optional features
    public let showCancelButton: Bool

    // MARK: - Initialization

    /// Khởi tạo XYZConfig với đầy đủ tùy chỉnh
    public init(
        title: String = "Default Title",
        subtitle: String = "Default Subtitle",
        icon: String? = "star",
        primaryColor: Color = Color.theme.primary,
        backgroundColor: Color = Color.theme.background,
        items: [Item] = [],
        showCancelButton: Bool = true,
        onComplete: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.items = items
        self.showCancelButton = showCancelButton
        self.onComplete = onComplete
        self.onCancel = onCancel
    }
}

// MARK: - Default Configs

public extension XYZConfig {
    /// Default config cho template
    static func `default`(onComplete: @escaping () -> Void) -> XYZConfig {
        XYZConfig(
            title: "Default Title",
            subtitle: "Default Subtitle",
            onComplete: onComplete
        )
    }
}
```

### View Component Template

```swift
// Sources/iOSTemplate/Features/XYZ/XYZView.swift
import SwiftUI
import ComposableArchitecture

/// XYZ view - Reusable component với configurable content
///
/// **Pattern: Parameterized Component**
///
/// View này được design để reuse cho nhiều apps khác nhau.
/// Mỗi app pass XYZConfig riêng với content và logic customize.
///
/// ## Usage:
/// ```swift
/// // App A - Banking
/// let bankingConfig = XYZConfig(
///     title: "Banking Feature",
///     primaryColor: .green,
///     onComplete: { /* banking logic */ }
/// )
/// XYZView(store: store, config: bankingConfig)
///
/// // App B - Fitness
/// let fitnessConfig = XYZConfig(
///     title: "Fitness Feature",
///     primaryColor: .orange,
///     onComplete: { /* fitness logic */ }
/// )
/// XYZView(store: store, config: fitnessConfig)
/// ```
///
/// ## Customization:
/// - **Content**: Items, titles, icons
/// - **Behavior**: onComplete, onCancel closures
/// - **UI**: Colors, fonts
/// - **Features**: Show/hide optional elements
///
public struct XYZView: View {
    // MARK: - Properties

    let store: StoreOf<AppReducer>
    let config: XYZConfig

    @State private var internalState = false

    // MARK: - Initialization

    /// Khởi tạo XYZView với custom config
    ///
    /// - Parameters:
    ///   - store: TCA Store
    ///   - config: XYZConfig customize cho app
    public init(store: StoreOf<AppReducer>, config: XYZConfig) {
        self.store = store
        self.config = config
    }

    /// Convenience init với default config
    ///
    /// Dùng khi không cần customize, sử dụng template default
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            // Default behavior
            print("XYZ completed")
        }
    }

    // MARK: - Body

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: Spacing.xl) {
                // Title từ config
                Text(config.title)
                    .font(.theme.title)
                    .foregroundColor(config.primaryColor)

                // Items từ config
                ForEach(config.items) { item in
                    ItemView(item: item)
                }

                // Button với behavior từ config
                Button(action: handleComplete) {
                    Text("Complete")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(config.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(CornerRadius.md)
                }

                // Optional cancel button (theo config)
                if config.showCancelButton {
                    Button(action: handleCancel) {
                        Text("Cancel")
                            .foregroundColor(config.primaryColor)
                    }
                }
            }
            .padding()
            .background(config.backgroundColor)
        }
    }

    // MARK: - Private Methods

    private func handleComplete() {
        // Gọi closure từ config - mỗi app có logic riêng
        config.onComplete()
    }

    private func handleCancel() {
        config.onCancel?()
    }
}

// MARK: - Preview

#Preview("Default Config") {
    XYZView(
        store: Store(initialState: AppState()) {
            AppReducer()
        }
    )
}

#Preview("Custom Config - Banking") {
    XYZView(
        store: Store(initialState: AppState()) {
            AppReducer()
        },
        config: XYZConfig(
            title: "Banking Feature",
            primaryColor: .green,
            items: [/* custom items */],
            onComplete: {
                print("Banking logic")
            }
        )
    )
}

#Preview("Custom Config - Fitness") {
    XYZView(
        store: Store(initialState: AppState()) {
            AppReducer()
        },
        config: XYZConfig(
            title: "Fitness Feature",
            primaryColor: .orange,
            backgroundColor: .black,
            showCancelButton: false,
            items: [/* custom items */],
            onComplete: {
                print("Fitness logic")
            }
        )
    )
}
```

## 📖 Ví Dụ Thực Tế

### OnboardingView Implementation

#### 1. Config Model

```swift
// Sources/iOSTemplate/Core/ViewConfigs/OnboardingConfig.swift
public struct OnboardingConfig {
    // Content
    public let pages: [OnboardingPage]

    // UI
    public let backgroundColor: Color
    public let showSkipButton: Bool
    public let skipButtonText: String
    public let continueButtonText: String
    public let finalButtonText: String

    // Behavior
    public let onComplete: () -> Void

    public init(
        pages: [OnboardingPage],
        backgroundColor: Color = Color.theme.background,
        showSkipButton: Bool = true,
        skipButtonText: String = "Skip",
        continueButtonText: String = "Continue",
        finalButtonText: String = "Get Started",
        onComplete: @escaping () -> Void
    ) {
        self.pages = pages
        self.backgroundColor = backgroundColor
        self.showSkipButton = showSkipButton
        self.skipButtonText = skipButtonText
        self.continueButtonText = continueButtonText
        self.finalButtonText = finalButtonText
        self.onComplete = onComplete
    }
}

public struct OnboardingPage: Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let description: String
    public let color: Color

    public init(icon: String, title: String, description: String, color: Color) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
    }
}

public extension OnboardingConfig {
    static func `default`(onComplete: @escaping () -> Void) -> OnboardingConfig {
        OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "sparkles",
                    title: "Welcome",
                    description: "Welcome to the app",
                    color: .blue
                ),
                OnboardingPage(
                    icon: "star.fill",
                    title: "Features",
                    description: "Discover amazing features",
                    color: .purple
                ),
                OnboardingPage(
                    icon: "checkmark.circle.fill",
                    title: "Get Started",
                    description: "Let's begin your journey",
                    color: .green
                )
            ],
            onComplete: onComplete
        )
    }
}
```

#### 2. View Component

```swift
// Sources/iOSTemplate/Features/Onboarding/OnboardingView.swift
public struct OnboardingView: View {
    let store: StoreOf<AppReducer>
    let config: OnboardingConfig

    @State private var currentPage = 0

    public init(store: StoreOf<AppReducer>, config: OnboardingConfig) {
        self.store = store
        self.config = config
    }

    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            store.send(AppAction.config(.updateFeatureFlag(key: "showOnboarding", value: false)))
        }
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // Skip button (optional)
                if config.showSkipButton {
                    HStack {
                        Spacer()
                        Button(config.skipButtonText) {
                            completeOnboarding()
                        }
                        .tertiaryButton()
                    }
                    .padding()
                }

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(config.pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                // Continue/Get Started button
                Button(currentPage == config.pages.count - 1
                       ? config.finalButtonText
                       : config.continueButtonText) {
                    if currentPage < config.pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .primaryButton()
                .padding()
            }
            .background(config.backgroundColor)
        }
    }

    private func completeOnboarding() {
        config.onComplete()
    }
}
```

#### 3. App Usage - Banking

```swift
// App/BankingApp/Configs/BankingOnboardingConfig.swift
extension OnboardingConfig {
    static var banking: OnboardingConfig {
        OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "banknote",
                    title: "Secure Banking",
                    description: "Your money is safe with bank-grade security",
                    color: .green
                ),
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Expenses",
                    description: "Monitor your spending in real-time",
                    color: .blue
                ),
                OnboardingPage(
                    icon: "dollarsign.circle.fill",
                    title: "Save More",
                    description: "Automated savings to reach your goals",
                    color: .orange
                )
            ],
            backgroundColor: Color.green.opacity(0.05),
            finalButtonText: "Start Banking",
            onComplete: {
                // Banking-specific logic
                AnalyticsService.track("banking_onboarding_completed")
                NavigationService.navigate(to: .kyc)
            }
        )
    }
}

// Usage
OnboardingView(store: store, config: .banking)
```

#### 4. App Usage - Fitness

```swift
// App/FitnessApp/Configs/FitnessOnboardingConfig.swift
extension OnboardingConfig {
    static var fitness: OnboardingConfig {
        OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "figure.run",
                    title: "Get Fit",
                    description: "Track your daily workouts and progress",
                    color: .orange
                ),
                OnboardingPage(
                    icon: "heart.fill",
                    title: "Stay Healthy",
                    description: "Monitor your heart rate and health metrics",
                    color: .red
                ),
                OnboardingPage(
                    icon: "trophy.fill",
                    title: "Achieve Goals",
                    description: "Set and crush your fitness goals",
                    color: .yellow
                )
            ],
            backgroundColor: .black,
            showSkipButton: false,
            finalButtonText: "Let's Go!",
            onComplete: {
                // Fitness-specific logic
                HealthKitService.requestPermissions()
                NavigationService.navigate(to: .workoutSelection)
            }
        )
    }
}

// Usage
OnboardingView(store: store, config: .fitness)
```

## 🎨 Design Principles

### 1. Single Responsibility

**Config:** Chỉ chứa data và behavior specifications
**View:** Chỉ chứa UI rendering logic

```swift
// ✅ Good
struct MyConfig {
    let title: String
    let onTap: () -> Void  // Behavior specification
}

struct MyView: View {
    let config: MyConfig

    var body: some View {
        Button(config.title) {
            config.onTap()  // Execute behavior từ config
        }
    }
}

// ❌ Bad - View chứa app-specific logic
struct MyView: View {
    var body: some View {
        Button("Title") {
            // ❌ App-specific logic trong view
            BankingAPIService.login()
        }
    }
}
```

### 2. Flexibility with Defaults

Provide default values cho most common use cases:

```swift
public init(
    title: String = "Default Title",           // Default value
    showCancelButton: Bool = true,             // Default behavior
    primaryColor: Color = Color.theme.primary, // Default styling
    onComplete: @escaping () -> Void           // Required behavior
) {
    // ...
}
```

### 3. Optional Features

Use optionals và booleans cho optional features:

```swift
public struct MyConfig {
    public let showCancelButton: Bool      // Feature flag
    public let onCancel: (() -> Void)?     // Optional behavior

    // In view
    if config.showCancelButton {
        Button("Cancel") {
            config.onCancel?()
        }
    }
}
```

### 4. Convenience Initializers

Provide convenience init cho backward compatibility:

```swift
public struct MyView: View {
    // Full init
    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        self.store = store
        self.config = config
    }

    // Convenience init - backward compatible
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            // Default behavior
        }
    }
}
```

## 📝 Checklist: Tạo Mới Component

Khi tạo một reusable component mới, follow checklist này:

### [ ] 1. Tạo Config Model

```
Sources/iOSTemplate/Core/ViewConfigs/XYZConfig.swift
```

- [ ] Define UI properties (colors, fonts, icons)
- [ ] Define content properties (data to display)
- [ ] Define behavior properties (closures)
- [ ] Define feature flags (optional features)
- [ ] Add default init với sensible defaults
- [ ] Add `.default` static factory method
- [ ] Add comprehensive documentation

### [ ] 2. Tạo View Component

```
Sources/iOSTemplate/Features/XYZ/XYZView.swift
```

- [ ] Accept `config` parameter
- [ ] Add convenience init với `.default` config
- [ ] Use `WithPerceptionTracking` nếu dùng TCA
- [ ] Render UI based on config properties
- [ ] Call config closures cho behaviors
- [ ] Handle optional features with conditionals
- [ ] Add comprehensive documentation

### [ ] 3. Add Previews

- [ ] Default config preview
- [ ] Custom config preview 1 (e.g., Banking)
- [ ] Custom config preview 2 (e.g., Fitness)
- [ ] Edge case previews (no data, minimal config, etc.)

### [ ] 4. Documentation

- [ ] Usage examples trong comments
- [ ] Customization options documented
- [ ] Update COMPONENT_PATTERN.md nếu cần

### [ ] 5. Testing

- [ ] Unit tests cho config model
- [ ] Snapshot tests cho view variants
- [ ] Integration tests nếu có TCA interaction

## ⚠️ Common Pitfalls

### 1. Hardcoding Values

```swift
// ❌ Bad
struct MyView: View {
    var body: some View {
        Text("Welcome")  // Hardcoded
            .foregroundColor(.blue)  // Hardcoded
    }
}

// ✅ Good
struct MyView: View {
    let config: MyConfig

    var body: some View {
        Text(config.title)  // From config
            .foregroundColor(config.primaryColor)  // From config
    }
}
```

### 2. Tight Coupling với TCA Store

```swift
// ❌ Bad - View biết quá nhiều về store
struct MyView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        Button("Complete") {
            store.send(AppAction.navigation(.navigateTo(.home)))  // ❌
        }
    }
}

// ✅ Good - View delegate behavior cho config
struct MyView: View {
    let config: MyConfig

    var body: some View {
        Button("Complete") {
            config.onComplete()  // ✅ App decides behavior
        }
    }
}
```

### 3. Quên Convenience Init

```swift
// ⚠️ Breaking change - users must provide config
public struct MyView: View {
    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        // ...
    }
}

// ✅ Backward compatible - convenience init
public struct MyView: View {
    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        // ...
    }

    public init(store: StoreOf<AppReducer>) {
        self.init(store: store, config: .default { })
    }
}
```

## 🔄 Migration Guide

### Migrating Hardcoded Component to Parameterized

**Before:**

```swift
// Hardcoded component
public struct MyView: View {
    let store: StoreOf<AppReducer>

    public var body: some View {
        VStack {
            Text("Hardcoded Title")
                .foregroundColor(.blue)

            Button("Hardcoded Button") {
                // Hardcoded logic
                store.send(AppAction.someAction)
            }
        }
        .background(.white)
    }
}
```

**After:**

```swift
// 1. Create config
public struct MyConfig {
    public let title: String
    public let primaryColor: Color
    public let backgroundColor: Color
    public let buttonText: String
    public let onButtonTap: () -> Void

    public init(
        title: String = "Default Title",
        primaryColor: Color = .blue,
        backgroundColor: Color = .white,
        buttonText: String = "Default Button",
        onButtonTap: @escaping () -> Void
    ) {
        self.title = title
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.buttonText = buttonText
        self.onButtonTap = onButtonTap
    }
}

public extension MyConfig {
    static func `default`(onButtonTap: @escaping () -> Void) -> MyConfig {
        MyConfig(onButtonTap: onButtonTap)
    }
}

// 2. Refactor view
public struct MyView: View {
    let store: StoreOf<AppReducer>
    let config: MyConfig

    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        self.store = store
        self.config = config
    }

    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            store.send(AppAction.someAction)
        }
    }

    public var body: some View {
        VStack {
            Text(config.title)
                .foregroundColor(config.primaryColor)

            Button(config.buttonText) {
                config.onButtonTap()
            }
        }
        .background(config.backgroundColor)
    }
}
```

## 🎓 Kết Luận

**Parameterized Component Pattern** là foundation của iOS Template này.

**Key Points:**
- View + Config = Reusable Component
- Template chứa View logic
- App chứa Config data
- Closures cho app-specific behavior
- Default configs cho ease of use
- Comprehensive documentation

**Benefits:**
- ✅ Highly reusable
- ✅ Type-safe
- ✅ SwiftUI-native
- ✅ Easy to test
- ✅ Clear separation of concerns

**Rules:**
1. Mọi reusable component PHẢI có Config model
2. Config PHẢI ở `Core/ViewConfigs/`
3. View PHẢI accept config parameter
4. View PHẢI có convenience init với default config
5. Behavior PHẢI qua closures, KHÔNG hardcode logic

---

Xem thêm về kiến trúc tổng thể tại [ARCHITECTURE.md](./ARCHITECTURE.md)
