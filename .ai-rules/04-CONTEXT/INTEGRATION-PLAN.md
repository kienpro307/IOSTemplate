# Kế hoạch Tích hợp ios-template-home

> Chỉ Phase 1 (minimal). Các phase sau sẽ cập nhật sau.

## Mục tiêu

Sử dụng code từ `ios-template-home` làm reference để hoàn thành Phase 1 nhanh chóng, tiết kiệm token.

---

## Chiến lược

1. **Copy + Adapt**: Copy code từ template cũ, adapt theo conventions mới
2. **TCA @Dependency**: Chuyển từ Swinject/Singleton sang TCA DependencyKey
3. **Multi-module**: Đặt code vào đúng module (Core, UI, Services, Features)

---

## Phase 1 Tasks Chi tiết

### Task P1-004: Theme System

**Reference files:**
```
ios-template-home/ios-template-main/Sources/iOSTemplate/Theme/
├── Colors.swift          → Sources/UI/Theme/Colors.swift
├── Typography.swift      → Sources/UI/Theme/Typography.swift
├── Spacing.swift         → Sources/UI/Theme/Spacing.swift
```

**Cần adapt:**
- Giữ nguyên logic adaptive colors
- Đổi namespace `Color.theme` sang phù hợp
- Thêm comment tiếng Việt

**Output expected:**
```swift
// Sources/UI/Theme/Colors.swift
public extension Color {
    static var theme: Theme.Type { Theme.self }
    
    enum Theme {
        public static let primary = Color(light: ..., dark: ...)
        // ... các colors khác
    }
}
```

---

### Task P1-005: UI Components

**Reference files:**
```
ios-template-home/.../Theme/Components/
├── ButtonStyles.swift    → Sources/UI/Components/ButtonStyles.swift
```

**Cần tạo thêm:**
- `LoadingView.swift` (mới)
- `InputField.swift` (mới)

**Output expected:**
- PrimaryButtonStyle, SecondaryButtonStyle, TertiaryButtonStyle
- `.primaryButton()`, `.secondaryButton()` extensions

---

### Task P1-006: Storage Wrappers

**Reference files:**
```
ios-template-home/.../Storage/
├── UserDefaultsStorage.swift  → Enhance Sources/Core/Dependencies/StorageClient.swift
├── KeychainStorage.swift      → Enhance Sources/Core/Dependencies/KeychainClient.swift
```

**Cần adapt:**
- Giữ nguyên interface TCA @Dependency đã có
- Thêm `@UserDefault` property wrapper từ template cũ
- Thêm Biometric support cho Keychain

---

## Mapping Reference → Target

| Reference (ios-template-home) | Target (dự án hiện tại) | Action |
|-------------------------------|-------------------------|--------|
| `Theme/Colors.swift` | `Sources/UI/Theme/Colors.swift` | Copy + adapt |
| `Theme/Typography.swift` | `Sources/UI/Theme/Typography.swift` | Copy + adapt |
| `Theme/Spacing.swift` | `Sources/UI/Theme/Spacing.swift` | Copy + adapt |
| `Theme/Components/ButtonStyles.swift` | `Sources/UI/Components/ButtonStyles.swift` | Copy + adapt |
| `Storage/UserDefaultsStorage.swift` | `Sources/Core/Dependencies/StorageClient.swift` | Merge features |
| `Storage/KeychainStorage.swift` | `Sources/Core/Dependencies/KeychainClient.swift` | Merge features |

---

## Conventions Khi Copy

### 1. Imports
```swift
// ❌ Template cũ
import Swinject

// ✅ Dự án mới
import ComposableArchitecture
```

### 2. Dependency Injection
```swift
// ❌ Template cũ (Singleton)
public static let shared = KeychainStorage()

// ✅ Dự án mới (TCA DependencyKey)
public struct KeychainClientKey: DependencyKey {
    static let liveValue: KeychainClientProtocol = LiveKeychainClient()
}
```

### 3. Protocols
```swift
// ❌ Template cũ
public final class KeychainStorage: SecureStorageProtocol

// ✅ Dự án mới (Sendable compliance)
public actor LiveKeychainClient: KeychainClientProtocol
```

---

## Sau Phase 1

Khi Phase 1 hoàn thành, sẽ cập nhật file này với:
- Phase 2: Network Layer, Cache System
- Phase 3: Firebase (khi cần)
- Phase 4+: Features

---

**Cập nhật lần cuối:** December 23, 2024

