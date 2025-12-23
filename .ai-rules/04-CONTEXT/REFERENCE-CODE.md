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

---

## ⭐ CHIẾN LƯỢC SỬ DỤNG REFERENCE CODE

### Quy tắc BẮT BUỘC khi làm task:

```
Bước 1: Kiểm tra ios-template-home
    ├── Có code tương tự? → Copy và adapt
    └── Không có? → Bước 2

Bước 2: Kiểm tra ios-template-docs
    ├── Có spec? → Tự tạo theo spec
    └── Không có? → Tự tạo theo best practices
```

### 1. Khi CÓ Reference Code (Copy & Adapt)

**Ví dụ:**
- Theme System → Copy từ `ios-template-home/Theme/`
- Network Layer → Copy từ `ios-template-home/Network/`
- Storage → Copy từ `ios-template-home/Storage/`

**Quy trình:**
1. Tìm file trong `ios-template-home/ios-template-main/Sources/iOSTemplate/`
2. Copy code
3. **Adapt bắt buộc:**
   - Thay Singleton → @Dependency
   - Thay Combine → TCA Effect
   - Đảm bảo `public` modifiers cho multi-module
   - Sửa comment sang tiếng Việt
4. Test và update progress

**KHÔNG BAO GIỜ copy nguyên code mà không adapt!**

### 2. Khi KHÔNG có Reference Code (Tự Tạo)

**Ví dụ:**
- Error Handling System → Tự tạo theo spec trong `ios-template-docs/01-KIEN-TRUC/06-XU-LY-LOI.md`
- Navigation System → Tự tạo theo spec trong docs

**Quy trình:**
1. Đọc spec trong `ios-template-docs/`
2. Tự implement theo spec đó
3. Tuân thủ TCA pattern và SOLID principles
4. Comment tiếng Việt
5. Test và update progress

### Checklist trước khi code:

- [ ] ✅ Đã kiểm tra `ios-template-home/` có code tương tự?
- [ ] ✅ Nếu có → Copy và adapt theo TCA pattern
- [ ] ✅ Nếu không → Đọc spec trong `ios-template-docs/`
- [ ] ✅ Tự tạo theo spec hoặc best practices
- [ ] ✅ Tuân thủ TCA @Dependency pattern
- [ ] ✅ Comment tiếng Việt

### ⚠️ LƯU Ý QUAN TRỌNG:

1. **LUÔN kiểm tra ios-template-home TRƯỚC** khi tự tạo code
2. **KHÔNG BAO GIỜ** tự tạo nếu có reference code sẵn
3. **LUÔN** adapt code từ ios-template-home (không copy nguyên)
4. **LUÔN** đọc spec trong ios-template-docs nếu không có reference code

---

**Cập nhật lần cuối:** December 23, 2024

