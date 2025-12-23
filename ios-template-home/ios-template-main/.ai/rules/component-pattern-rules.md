# Component Pattern Rules

> **QUAN TRỌNG**: Đây là quy tắc BẮT BUỘC cho mọi AI agent khi build features trong iOS Template này.

## 🎯 Pattern Bắt Buộc

Template này sử dụng **Parameterized Component Pattern**. Mọi reusable component PHẢI follow pattern này.

## 📜 Rules Cơ Bản

### Rule 1: View + Config Structure

**BẮT BUỘC**: Mọi reusable component PHẢI có 2 phần:

1. **Config Model** ở `Sources/iOSTemplate/Core/ViewConfigs/`
2. **View Component** ở `Sources/iOSTemplate/Features/`

```swift
// ✅ CORRECT
// File 1: Sources/iOSTemplate/Core/ViewConfigs/MyFeatureConfig.swift
public struct MyFeatureConfig {
    public let title: String
    public let color: Color
    public let onComplete: () -> Void
}

// File 2: Sources/iOSTemplate/Features/MyFeature/MyFeatureView.swift
public struct MyFeatureView: View {
    let config: MyFeatureConfig
    // ...
}
```

```swift
// ❌ INCORRECT - Hardcoded values
public struct MyFeatureView: View {
    var body: some View {
        Text("Hardcoded Title")  // ❌ NO!
            .foregroundColor(.blue)  // ❌ NO!
    }
}
```

### Rule 2: NO Hardcoding

**BẮT BUỘC**: KHÔNG được hardcode values trong View.

```swift
// ❌ INCORRECT
struct MyView: View {
    var body: some View {
        Text("Welcome")  // ❌ Hardcoded
        Button("Click Me") {  // ❌ Hardcoded
            print("Hello")  // ❌ Hardcoded logic
        }
    }
}

// ✅ CORRECT
struct MyView: View {
    let config: MyConfig

    var body: some View {
        Text(config.title)  // ✅ From config
        Button(config.buttonText) {  // ✅ From config
            config.onButtonTap()  // ✅ Behavior from config
        }
    }
}
```

### Rule 3: Behavior Through Closures

**BẮT BUỘC**: App-specific logic PHẢI qua closures trong config.

```swift
// ❌ INCORRECT - View biết về app-specific logic
struct MyView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        Button("Complete") {
            // ❌ View should NOT know about specific actions
            store.send(AppAction.navigation(.navigateTo(.home)))
        }
    }
}

// ✅ CORRECT - Logic delegated to config
public struct MyConfig {
    public let onComplete: () -> Void
}

struct MyView: View {
    let config: MyConfig

    var body: some View {
        Button("Complete") {
            config.onComplete()  // ✅ App decides what happens
        }
    }
}
```

### Rule 4: Convenience Initializers

**BẮT BUỘC**: View PHẢI có 2 initializers:

1. **Primary init**: Nhận config
2. **Convenience init**: Dùng default config

```swift
// ✅ CORRECT
public struct MyView: View {
    let store: StoreOf<AppReducer>
    let config: MyConfig

    // Primary init
    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        self.store = store
        self.config = config
    }

    // Convenience init - REQUIRED!
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            // Default behavior
        }
    }
}
```

### Rule 5: Default Configs

**BẮT BUỘC**: Config PHẢI có `.default` static method.

```swift
// ✅ CORRECT
public extension MyConfig {
    static func `default`(onComplete: @escaping () -> Void) -> MyConfig {
        MyConfig(
            title: "Default Title",
            color: .blue,
            onComplete: onComplete
        )
    }
}
```

### Rule 6: Optional Features

**BẮT BUỘC**: Optional features dùng Bool flags và optional closures.

```swift
// ✅ CORRECT
public struct MyConfig {
    public let showCancelButton: Bool
    public let onCancel: (() -> Void)?  // Optional closure

    // In view
    if config.showCancelButton {
        Button("Cancel") {
            config.onCancel?()
        }
    }
}
```

### Rule 7: Documentation

**BẮT BUỘC**: Config và View PHẢI có comprehensive documentation.

```swift
// ✅ CORRECT
/// MyFeature view - Reusable component với configurable content
///
/// **Pattern: Parameterized Component**
///
/// View này được design để reuse cho nhiều apps khác nhau.
/// Mỗi app pass MyFeatureConfig riêng với content và logic customize.
///
/// ## Usage:
/// ```swift
/// let config = MyFeatureConfig(
///     title: "My Title",
///     onComplete: { /* custom logic */ }
/// )
/// MyFeatureView(store: store, config: config)
/// ```
///
/// ## Customization:
/// - **Content**: Title, description
/// - **Behavior**: onComplete closure
/// - **UI**: Colors, fonts
///
public struct MyFeatureView: View {
    // ...
}
```

### Rule 8: Previews

**BẮT BUỘC**: View PHẢI có ít nhất 3 previews:

1. Default config
2. Custom config example 1 (e.g., Banking)
3. Custom config example 2 (e.g., Fitness)

```swift
// ✅ CORRECT
#Preview("Default Config") {
    MyView(store: Store(initialState: AppState()) {
        AppReducer()
    })
}

#Preview("Custom Config - Banking") {
    MyView(
        store: Store(initialState: AppState()) {
            AppReducer()
        },
        config: MyConfig(
            title: "Banking Feature",
            color: .green,
            onComplete: { print("Banking logic") }
        )
    )
}

#Preview("Custom Config - Fitness") {
    MyView(
        store: Store(initialState: AppState()) {
            AppReducer()
        },
        config: MyConfig(
            title: "Fitness Feature",
            color: .orange,
            onComplete: { print("Fitness logic") }
        )
    )
}
```

## 📝 Checklist: Khi Tạo Component Mới

Khi AI agent được yêu cầu tạo một feature mới, PHẢI follow checklist này:

### ✅ Step 1: Tạo Config Model

**File**: `Sources/iOSTemplate/Core/ViewConfigs/XYZConfig.swift`

- [ ] Struct name: `XYZConfig`
- [ ] Public access control
- [ ] UI properties (colors, fonts, icons)
- [ ] Content properties (data to display)
- [ ] Behavior properties (closures với `@escaping`)
- [ ] Feature flags (Bool for optional features)
- [ ] Public init với default values
- [ ] `.default` static method
- [ ] Comprehensive documentation với Usage examples

**Template:**
```swift
import SwiftUI

/// Configuration cho XYZView - cho phép customize cho mỗi app
///
/// Pattern: Parameterized Component
///
/// Ví dụ:
/// ```swift
/// let config = XYZConfig(
///     title: "Custom Title",
///     onComplete: { /* logic */ }
/// )
/// XYZView(store: store, config: config)
/// ```
public struct XYZConfig {
    // MARK: - UI Properties
    public let title: String
    public let primaryColor: Color
    public let backgroundColor: Color

    // MARK: - Content Properties
    public let items: [Item]

    // MARK: - Behavior Properties
    public let onComplete: () -> Void
    public let onCancel: (() -> Void)?

    // MARK: - Feature Flags
    public let showCancelButton: Bool

    // MARK: - Initialization
    public init(
        title: String = "Default Title",
        primaryColor: Color = Color.theme.primary,
        backgroundColor: Color = Color.theme.background,
        items: [Item] = [],
        showCancelButton: Bool = true,
        onComplete: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
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
    static func `default`(onComplete: @escaping () -> Void) -> XYZConfig {
        XYZConfig(onComplete: onComplete)
    }
}
```

### ✅ Step 2: Tạo View Component

**File**: `Sources/iOSTemplate/Features/XYZ/XYZView.swift`

- [ ] Struct name: `XYZView`
- [ ] Public access control
- [ ] Accept `store: StoreOf<AppReducer>` (nếu cần TCA)
- [ ] Accept `config: XYZConfig`
- [ ] Primary init với config
- [ ] Convenience init với `.default` config
- [ ] Wrap body trong `WithPerceptionTracking` (nếu dùng TCA)
- [ ] Render UI based on config properties
- [ ] Call config closures for behaviors
- [ ] Handle optional features với conditionals
- [ ] Comprehensive documentation
- [ ] Ít nhất 3 previews

**Template:**
```swift
import SwiftUI
import ComposableArchitecture

/// XYZ view - Reusable component với configurable content
///
/// **Pattern: Parameterized Component**
///
/// ## Usage:
/// ```swift
/// let config = XYZConfig(
///     title: "My Title",
///     onComplete: { /* logic */ }
/// )
/// XYZView(store: store, config: config)
/// ```
///
/// ## Customization:
/// - **Content**: Title, items
/// - **Behavior**: onComplete, onCancel
/// - **UI**: Colors, fonts
/// - **Features**: Show/hide cancel button
///
public struct XYZView: View {
    // MARK: - Properties
    let store: StoreOf<AppReducer>
    let config: XYZConfig

    @State private var internalState = false

    // MARK: - Initialization

    /// Khởi tạo XYZView với custom config
    public init(store: StoreOf<AppReducer>, config: XYZConfig) {
        self.store = store
        self.config = config
    }

    /// Convenience init với default config
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            print("XYZ completed")
        }
    }

    // MARK: - Body
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: Spacing.xl) {
                Text(config.title)
                    .font(.theme.title)
                    .foregroundColor(config.primaryColor)

                Button("Complete") {
                    handleComplete()
                }
                .primaryButton()

                if config.showCancelButton {
                    Button("Cancel") {
                        handleCancel()
                    }
                }
            }
            .padding()
            .background(config.backgroundColor)
        }
    }

    // MARK: - Private Methods
    private func handleComplete() {
        config.onComplete()
    }

    private func handleCancel() {
        config.onCancel?()
    }
}

// MARK: - Preview
#Preview("Default Config") {
    XYZView(store: Store(initialState: AppState()) {
        AppReducer()
    })
}

#Preview("Custom Config - Banking") {
    XYZView(
        store: Store(initialState: AppState()) {
            AppReducer()
        },
        config: XYZConfig(
            title: "Banking Feature",
            primaryColor: .green,
            onComplete: { print("Banking") }
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
            onComplete: { print("Fitness") }
        )
    )
}
```

### ✅ Step 3: Verify Build

- [ ] Run `swift build` và verify no errors
- [ ] Run previews và verify visual appearance
- [ ] Test default config
- [ ] Test custom configs

## 🚫 Common Mistakes

### ❌ Mistake 1: Hardcoding trong View

```swift
// ❌ WRONG
struct MyView: View {
    var body: some View {
        Text("Hardcoded")
            .foregroundColor(.blue)
    }
}
```

### ❌ Mistake 2: App Logic trong View

```swift
// ❌ WRONG
struct MyView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        Button("Complete") {
            store.send(AppAction.navigation(.navigateTo(.home)))  // ❌
        }
    }
}
```

### ❌ Mistake 3: Quên Convenience Init

```swift
// ❌ WRONG - Breaking change
public struct MyView: View {
    public init(store: StoreOf<AppReducer>, config: MyConfig) {
        // Only primary init, no convenience init
    }
}
```

### ❌ Mistake 4: Config trong App Folder

```swift
// ❌ WRONG location
// App/BankingApp/Configs/MyFeatureConfig.swift  // ❌ NO!

// ✅ CORRECT location
// Sources/iOSTemplate/Core/ViewConfigs/MyFeatureConfig.swift  // ✅ YES!
```

## 💡 When to Apply This Pattern

**Apply pattern khi:**
- ✅ Tạo feature screen mới (Onboarding, Login, Profile, etc.)
- ✅ Tạo reusable component có thể dùng cho nhiều apps
- ✅ Component có customizable content hoặc behavior
- ✅ Component sẽ được sử dụng nhiều lần

**KHÔNG cần apply khi:**
- ❌ App-specific feature (chỉ dùng cho 1 app duy nhất)
- ❌ Simple utility functions
- ❌ Internal helpers không exposed ra ngoài

## 📖 Reference Documents

Khi AI agent được yêu cầu build feature mới, PHẢI đọc:

1. **[ARCHITECTURE.md](../../ARCHITECTURE.md)**: Hiểu modular architecture
2. **[COMPONENT_PATTERN.md](../../COMPONENT_PATTERN.md)**: Chi tiết về pattern
3. **Existing examples**:
   - `Sources/iOSTemplate/Core/ViewConfigs/OnboardingConfig.swift`
   - `Sources/iOSTemplate/Features/Onboarding/OnboardingView.swift`
   - `Sources/iOSTemplate/Core/ViewConfigs/LoginConfig.swift`
   - `Sources/iOSTemplate/Features/Auth/LoginView.swift`

## 🎯 Success Criteria

Feature được coi là "done" khi:

- [x] Config model tồn tại ở `Core/ViewConfigs/`
- [x] View component tồn tại ở `Features/`
- [x] KHÔNG có hardcoded values trong view
- [x] Behavior qua closures trong config
- [x] Có convenience init với default config
- [x] Có comprehensive documentation
- [x] Có ít nhất 3 previews
- [x] Build successful
- [x] Previews work correctly

## 🔴 Breaking These Rules

**WARNING**: Breaking these rules sẽ làm template KHÔNG reusable!

Nếu AI agent phát hiện yêu cầu của user conflict với pattern này, AI PHẢI:

1. **Explain** why the pattern is important
2. **Propose** alternative approach following the pattern
3. **Only proceed** nếu user explicitly confirms họ muốn break pattern

**Example:**

```
User: "Thêm màn Profile nhưng hardcode title là 'My Profile'"

AI: "Theo Component Pattern Rules của template, tôi không thể hardcode 'My Profile'
vì điều này sẽ làm component không reusable. Thay vào đó, tôi sẽ:

1. Tạo ProfileConfig với title parameter
2. Default config sẽ có title = 'My Profile'
3. Apps khác có thể override với title riêng

Điều này giữ component reusable mà vẫn đáp ứng yêu cầu của bạn. Có đồng ý không?"
```

## 📊 Examples

### Example 1: OnboardingView (Reference Implementation)

**Perfect example** của pattern này:

- ✅ Config: `Core/ViewConfigs/OnboardingConfig.swift`
- ✅ View: `Features/Onboarding/OnboardingView.swift`
- ✅ No hardcoded values
- ✅ Behavior qua `onComplete` closure
- ✅ Convenience init
- ✅ Default config
- ✅ 3 previews
- ✅ Comprehensive docs

### Example 2: LoginView (Reference Implementation)

**Perfect example** của pattern này:

- ✅ Config: `Core/ViewConfigs/LoginConfig.swift`
- ✅ View: `Features/Auth/LoginView.swift`
- ✅ Optional features: `showSocialLogin`, `showSignUpLink`
- ✅ Multiple behaviors: `onLogin`, `onSignUp`, `onSocialLogin`
- ✅ Type-safe với `SocialProvider` enum

## 🎓 Training Checklist for AI Agents

Trước khi build feature mới, AI agent PHẢI confirm:

- [ ] Đã đọc ARCHITECTURE.md
- [ ] Đã đọc COMPONENT_PATTERN.md
- [ ] Đã đọc component-pattern-rules.md (file này)
- [ ] Đã review OnboardingView và OnboardingConfig
- [ ] Đã review LoginView và LoginConfig
- [ ] Hiểu rõ Parameterized Component Pattern
- [ ] Biết cách tạo Config model
- [ ] Biết cách tạo View component
- [ ] Biết cách handle optional features
- [ ] Biết cách document code

---

**Version**: 1.0.0
**Last Updated**: November 2024
**Status**: ✅ Active - PHẢI tuân thủ cho mọi feature mới
