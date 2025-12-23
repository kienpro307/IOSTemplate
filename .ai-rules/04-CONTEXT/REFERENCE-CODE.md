# Code Reference từ ios-template-home

> Quick lookup cho các code snippet cần copy/paste

## Đường dẫn gốc

```
ios-template-home/ios-template-main/Sources/iOSTemplate/
```

---

## Phase 1 References

### Colors.swift
**File:** `Theme/Colors.swift`

**Key patterns cần copy:**
```swift
// Adaptive color helper
public extension Color {
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(dark)
            default: return UIColor(light)
            }
        })
        #else
        self = light
        #endif
    }
}

// Theme namespace
public extension Color {
    static var theme: Theme.Type { Theme.self }
    
    enum Theme {
        public static let primary = Color(
            light: Color(red: 0.0, green: 0.48, blue: 1.0),
            dark: Color(red: 0.04, green: 0.52, blue: 1.0)
        )
        // ...
    }
}

// Hex color init
init(hex: String) { ... }

// Color utilities
func lighter(by percentage: Double) -> Color { ... }
func darker(by percentage: Double) -> Color { ... }
```

---

### Typography.swift
**File:** `Theme/Typography.swift`

**Key patterns:**
```swift
public extension Font {
    static var theme: Theme.Type { Theme.self }
    
    enum Theme {
        // Display
        public static let displayLarge = Font.system(size: 57, weight: .bold)
        
        // Headline
        public static let headlineLarge = Font.system(size: 32, weight: .semibold)
        
        // Body
        public static let bodyLarge = Font.system(size: 16, weight: .regular)
        
        // Label
        public static let labelLarge = Font.system(size: 14, weight: .medium)
    }
}

// TextStyle struct
public struct TextStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    let kerning: CGFloat
}

// View extension
public extension View {
    func textStyle(_ style: TextStyle) -> some View { ... }
}
```

---

### Spacing.swift
**File:** `Theme/Spacing.swift`

**Key patterns:**
```swift
public enum Spacing {
    // Base values (4pt grid)
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 48
    
    // Semantic
    public static let viewPadding: CGFloat = lg
    public static let cardPadding: CGFloat = lg
    
    // Component-specific
    public static let buttonPadding = EdgeInsets(top: md, leading: xl, bottom: md, trailing: xl)
}

// CornerRadius
public enum CornerRadius {
    public static let sm: CGFloat = 4
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 12
    public static let button: CGFloat = md
    public static let card: CGFloat = lg
}

// ShadowStyle
public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    public static let sm = ShadowStyle(...)
    public static let md = ShadowStyle(...)
    public static let lg = ShadowStyle(...)
}

public extension View {
    func shadow(_ style: ShadowStyle) -> some View { ... }
}
```

---

### ButtonStyles.swift
**File:** `Theme/Components/ButtonStyles.swift`

**Key patterns:**
```swift
public struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isLoading: Bool
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            configuration.label
                .font(.theme.labelLarge)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.buttonPadding)
        .background(backgroundColor(configuration: configuration))
        .cornerRadius(CornerRadius.button)
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Extensions
public extension Button {
    func primaryButton(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading))
    }
}
```

---

### UserDefaultsStorage.swift
**File:** `Storage/UserDefaultsStorage.swift`

**Key patterns:**
```swift
// Property wrapper
@propertyWrapper
public struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    
    public var wrappedValue: T {
        get {
            (try? storage.load(T.self, forKey: key)) ?? defaultValue
        }
        set {
            try? storage.save(newValue, forKey: key)
        }
    }
}

// Storage keys
public enum StorageKey {
    public static let hasCompletedOnboarding = "onboarding.completed"
    public static let themeMode = "settings.theme_mode"
    public static let languageCode = "settings.language_code"
}
```

---

### KeychainStorage.swift
**File:** `Storage/KeychainStorage.swift`

**Key patterns:**
```swift
// Biometric support
#if canImport(LocalAuthentication)
extension KeychainStorage {
    public func saveBiometric(_ value: String, forKey key: String) throws {
        let protectedKeychain = Keychain(service: keychain.service)
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
        try protectedKeychain.set(value, key: key)
    }
    
    public func loadBiometric(forKey key: String, prompt: String) throws -> String? {
        let protectedKeychain = Keychain(service: keychain.service)
            .authenticationPrompt(prompt)
        return try protectedKeychain.getString(key)
    }
}
#endif

// Secure storage keys
public enum SecureStorageKey {
    public static let accessToken = "auth.access_token"
    public static let refreshToken = "auth.refresh_token"
    public static let apiKey = "api.key"
}
```

---

## Phase 2 References (Sau này)

| File | Mô tả |
|------|-------|
| `Network/NetworkService.swift` | Moya-based network client |
| `Network/APITarget.swift` | API endpoints definition |
| `Utilities/Cache/MemoryCache.swift` | NSCache wrapper |
| `Utilities/Cache/DiskCache.swift` | File-based cache |
| `Utilities/Logger.swift` | OSLog-based logging |

---

## Phase 3+ References (Sau này)

| File | Mô tả |
|------|-------|
| `Services/Firebase/FirebaseManager.swift` | Firebase initialization |
| `Services/Firebase/FirebaseConfig.swift` | Firebase configuration |
| `Monetization/IAP/IAPService.swift` | StoreKit 2 service |

---

**Cập nhật lần cuối:** December 23, 2024

