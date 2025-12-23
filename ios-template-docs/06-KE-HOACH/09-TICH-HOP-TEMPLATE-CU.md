# Kế hoạch Tích hợp ios-template-home

> Chi tiết kế hoạch tích hợp code từ template cũ vào dự án hiện tại

## 1. Tổng quan

### 1.1 So sánh hai dự án

| Khía cạnh | ios-template-home (cũ) | Dự án hiện tại |
|-----------|------------------------|----------------|
| Structure | Flat (1 target) | Multi-module (Core, UI, Services, Features) |
| DI Pattern | Swinject + Singleton | TCA @Dependency |
| Progress | ~90% hoàn thành | ~20% hoàn thành |
| Firebase | Tích hợp sẵn | Chưa có |
| Naming | Tiếng Anh | Tiếng Anh (code), Tiếng Việt (comment) |

### 1.2 Mục tiêu

- Tái sử dụng code đã làm từ template cũ
- Tiết kiệm thời gian phát triển
- Giữ consistency với kiến trúc mới
- Không break existing code

---

## 2. Chiến lược Tích hợp

### 2.1 Approach

```
┌─────────────────────────────────────────────────────────────┐
│                    INTEGRATION APPROACH                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ios-template-home                    Dự án hiện tại        │
│  ┌─────────────────┐                 ┌─────────────────┐   │
│  │  Source Code    │──── ANALYZE ───▶│                 │   │
│  │                 │                 │                 │   │
│  │  • Theme/       │──── ADAPT ─────▶│  Sources/UI/    │   │
│  │  • Storage/     │──── ADAPT ─────▶│  Sources/Core/  │   │
│  │  • Network/     │──── ADAPT ─────▶│  Sources/Svc/   │   │
│  │  • Features/    │──── LATER ─────▶│  Sources/Feat/  │   │
│  └─────────────────┘                 └─────────────────┘   │
│                                                             │
│  Key: ADAPT = Copy + Refactor for TCA @Dependency pattern  │
│       LATER = Save for Phase 3+                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Quy tắc Khi Adapt

1. **Không copy nguyên** - Đọc hiểu, viết lại
2. **Dùng TCA @Dependency** - Không Singleton, không Swinject
3. **Async/await** - Không callback
4. **Sendable compliance** - Cho Swift Concurrency
5. **Multi-module** - Đặt đúng module (Core/UI/Services/Features)

---

## 3. Chi tiết Phase 1: Nền tảng

### 3.1 Theme System (P1-004)

**Reference location:**
```
ios-template-home/ios-template-main/Sources/iOSTemplate/Theme/
├── Colors.swift        # 322 lines
├── Typography.swift    # 233 lines
├── Spacing.swift       # 306 lines
└── README.md
```

**Target location:**
```
Sources/UI/Theme/
├── Colors.swift
├── Typography.swift
└── Spacing.swift
```

**Key features to preserve:**
- Adaptive colors với `Color(light:dark:)` helper
- Material Design 3 typography scale
- 4pt grid spacing system
- `CornerRadius`, `BorderWidth`, `ShadowStyle` enums
- View extensions: `.standardPadding()`, `.cardPadding()`

**Adaptation notes:**
- Giữ nguyên logic, chỉ thay đổi naming nếu cần
- Thêm `public` modifier cho multi-module access
- Đảm bảo Dark mode support

---

### 3.2 UI Components (P1-005)

**Reference location:**
```
ios-template-home/.../Theme/Components/
└── ButtonStyles.swift   # 227 lines
```

**Target location:**
```
Sources/UI/Components/
├── ButtonStyles.swift
└── LoadingView.swift
```

**Key features to preserve:**
- `PrimaryButtonStyle`, `SecondaryButtonStyle`, `TertiaryButtonStyle`
- `DestructiveButtonStyle`, `SmallButtonStyle`, `IconButtonStyle`
- Loading state với ProgressView
- Scale animation khi pressed
- Disabled state handling

**Button extension pattern:**
```swift
// Giữ pattern này
extension Button {
    func primaryButton(isEnabled: Bool = true, isLoading: Bool = false) -> some View
    func secondaryButton(isEnabled: Bool = true) -> some View
}
```

---

### 3.3 Storage Enhancement (P1-006)

**Reference location:**
```
ios-template-home/.../Storage/
├── UserDefaultsStorage.swift   # 166 lines
└── KeychainStorage.swift       # 201 lines
```

**Current files to enhance:**
```
Sources/Core/Dependencies/
├── StorageClient.swift     # Add @UserDefault wrapper
└── KeychainClient.swift    # Add Biometric support
```

**Features to add:**

1. **@UserDefault property wrapper:**
```swift
@propertyWrapper
public struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    // ...
}
```

2. **StorageKey enum:**
```swift
public enum StorageKey {
    public static let hasCompletedOnboarding = "onboarding.completed"
    public static let themeMode = "settings.theme_mode"
    // ...
}
```

3. **Biometric authentication cho Keychain:**
```swift
extension KeychainClient {
    func saveBiometric(_ value: String, forKey key: String) async throws
    func loadBiometric(forKey key: String, prompt: String) async throws -> String?
}
```

---

## 4. Chi tiết Phase 2: Core Services

### 4.1 Logger (Bonus)

**Reference:** `ios-template-home/.../Utilities/Logger.swift` (253 lines)

**Target:** `Sources/Core/Utilities/Logger.swift`

**Key features:**
- OSLog integration
- Log levels: verbose, debug, info, warning, error
- File logging với auto cleanup (7 days)
- Global log functions: `logInfo()`, `logError()`, etc.

**TCA Adaptation:**
```swift
// Thay Singleton thành DependencyKey
public protocol LoggerClientProtocol: Sendable {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

private enum LoggerClientKey: DependencyKey {
    static let liveValue: LoggerClientProtocol = LiveLoggerClient()
}
```

---

### 4.2 Cache System (P2-003)

**Reference:**
```
ios-template-home/.../Utilities/Cache/
├── MemoryCache.swift   # 175 lines
└── DiskCache.swift     # 250 lines
```

**Target:**
```
Sources/Services/Cache/
├── MemoryCache.swift
├── DiskCache.swift
└── CacheClient.swift   # TCA Dependency wrapper
```

**Key features:**
- `MemoryCache<Key, Value>` với NSCache
- `DiskCache<Key, Value>` với FileManager
- `CacheManager` combining both
- Expiration handling
- Codable support

---

### 4.3 Network Layer (P2-001)

**Reference:**
```
ios-template-home/.../Network/
├── NetworkService.swift   # 254 lines
├── APITarget.swift        # ~100 lines
└── Models/APIModels.swift
```

**Target:**
```
Sources/Services/Network/
├── NetworkClient.swift    # TCA Dependency
├── APITarget.swift
└── NetworkError.swift
```

**Adaptation notes:**
- Chuyển class → TCA DependencyKey
- Giữ Moya integration
- async/await cho tất cả methods
- Error mapping giữ nguyên

---

## 5. Phase 3+ (Đợi sau)

Các components sau đợi đến Phase tương ứng:

| Phase | Components | Notes |
|-------|------------|-------|
| Phase 3 | Firebase (Analytics, Crashlytics, etc.) | Thêm Firebase vào Package.swift trước |
| Phase 4 | Onboarding, Settings, Profile | Cần TCA Reducer cho mỗi feature |
| Phase 5 | IAP, AdMob | Phụ thuộc Firebase |

---

## 6. Validation Checklist

Mỗi component sau khi adapt:

- [ ] Build thành công (`swift build`)
- [ ] Import đúng module
- [ ] Public API accessible
- [ ] Dark mode tested
- [ ] Preview hoạt động
- [ ] Không có Singleton/global state
- [ ] Sendable compliance

---

## 7. Related Documents

| Document | Mô tả |
|----------|-------|
| [08-TASK-TRACKER.md](08-TASK-TRACKER.md) | Chi tiết 30 tasks |
| [01-ROADMAP.md](01-ROADMAP.md) | Timeline tổng quan |
| `.ai-rules/04-CONTEXT/` | Context cho AI handoff |
| `progress/DANG-LAM.md` | Task đang thực hiện |

---

**Tạo:** December 23, 2024
**Cập nhật:** December 23, 2024

