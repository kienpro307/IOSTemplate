# 🔄 Kế hoạch Tích hợp ios-template-home

## 1. Tổng Quan

### 1.1 Mục đích

Sử dụng code đã làm sẵn từ `ios-template-home` để tăng tốc development, tiết kiệm token AI.

### 1.2 So sánh

| Khía cạnh | ios-template-home (cũ) | Dự án hiện tại |
|-----------|------------------------|----------------|
| Structure | Flat (1 target) | Multi-module (Core, UI, Services, Features) |
| DI Pattern | Swinject + Singleton | TCA @Dependency |
| Completion | ~90% | ~20% |
| Firebase | Có | Chưa có |

### 1.3 Chiến lược

```
ios-template-home (Reference)
        │
        ▼
    Copy Code
        │
        ▼
    Adapt theo:
    ├── TCA @Dependency pattern
    ├── Multi-module structure
    ├── Sendable compliance
    └── Async/await APIs
        │
        ▼
    Dự án hiện tại
```

---

## 2. Mapping Chi tiết

### 2.1 Phase 1: Nền tảng

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1 MAPPING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ios-template-home/                    Dự án hiện tại/         │
│  └── Sources/iOSTemplate/              └── Sources/            │
│                                                                 │
│  Theme/                          →     UI/Theme/               │
│  ├── Colors.swift                →     ├── Colors.swift        │
│  ├── Typography.swift            →     ├── Typography.swift    │
│  └── Spacing.swift               →     └── Spacing.swift       │
│                                                                 │
│  Theme/Components/               →     UI/Components/          │
│  └── ButtonStyles.swift          →     └── ButtonStyles.swift  │
│                                                                 │
│  Storage/                        →     Core/Dependencies/      │
│  ├── UserDefaultsStorage.swift   →     ├── StorageClient.swift │
│  └── KeychainStorage.swift       →     └── KeychainClient.swift│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Phase 2: Core Services

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2 MAPPING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Network/                        →     Services/Network/       │
│  ├── NetworkService.swift        →     ├── NetworkClient.swift │
│  ├── APITarget.swift             →     ├── APITarget.swift     │
│  └── Models/                     →     └── Models/             │
│                                                                 │
│  Utilities/Cache/                →     Services/Cache/         │
│  ├── MemoryCache.swift           →     ├── MemoryCache.swift   │
│  └── DiskCache.swift             →     └── DiskCache.swift     │
│                                                                 │
│  Utilities/                      →     Core/Utilities/         │
│  └── Logger.swift                →     └── Logger.swift        │
│                                                                 │
│  Services/ServiceProtocols.swift →     Core/Protocols.swift    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Phase 3+: Firebase & Features

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3+ MAPPING                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Services/Firebase/              →     Services/Firebase/      │
│  ├── FirebaseManager.swift       →     ├── FirebaseClient.swift│
│  ├── FirebaseConfig.swift        →     ├── FirebaseConfig.swift│
│  └── ...                         →     └── ...                 │
│                                                                 │
│  Features/Onboarding/            →     Features/Onboarding/    │
│  ├── OnboardingView.swift        →     ├── OnboardingView.swift│
│  └── OnboardingConfig.swift      →     └── OnboardingReducer.swift│
│                                                                 │
│  Features/Settings/              →     Features/Settings/      │
│  └── SettingsView.swift          →     ├── SettingsView.swift  │
│                                        └── SettingsReducer.swift│
│                                                                 │
│  Monetization/IAP/               →     Features/IAP/           │
│  ├── IAPService.swift            →     ├── IAPClient.swift     │
│  └── StoreKitManager.swift       →     └── IAPReducer.swift    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Quy tắc Adapt Code

### 3.1 Dependency Injection

```swift
// ❌ CŨ: Singleton
public final class KeychainStorage {
    public static let shared = KeychainStorage()
}

// ✅ MỚI: TCA DependencyKey
public struct KeychainClientKey: DependencyKey {
    static let liveValue: KeychainClientProtocol = LiveKeychainClient()
    static let testValue: KeychainClientProtocol = MockKeychainClient()
}

extension DependencyValues {
    public var keychainClient: KeychainClientProtocol {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}
```

### 3.2 Protocol Compliance

```swift
// ❌ CŨ: Non-Sendable class
public final class NetworkService: NetworkServiceProtocol {
    // ...
}

// ✅ MỚI: Sendable actor
public actor LiveNetworkClient: NetworkClientProtocol, Sendable {
    // ...
}
```

### 3.3 Async/Await

```swift
// ❌ CŨ: Callback
func request(completion: @escaping (Result<T, Error>) -> Void)

// ✅ MỚI: Async
func request() async throws -> T
```

---

## 4. Files Quan trọng trong ios-template-home

### 4.1 Protocols (PHẢI ĐỌC)

```
Services/ServiceProtocols.swift
```

Chứa tất cả protocols:
- `StorageServiceProtocol`
- `SecureStorageProtocol`
- `NetworkServiceProtocol`
- `AnalyticsServiceProtocol`
- `LoggingServiceProtocol`
- `CrashlyticsServiceProtocol`

### 4.2 Error Types

```swift
// Từ ServiceProtocols.swift
public enum StorageError: Error { ... }
public enum ServiceError: Error { ... }
public enum NetworkError: Error { ... }
```

### 4.3 Configs

```
Core/ViewConfigs/OnboardingConfig.swift  // Parameterized onboarding
Services/Firebase/FirebaseConfig.swift   // Firebase configuration
```

---

## 5. Checklist Tích hợp

### Phase 1

- [ ] **P1-004 Theme System**
  - [ ] Copy Colors.swift → UI/Theme/
  - [ ] Copy Typography.swift → UI/Theme/
  - [ ] Copy Spacing.swift → UI/Theme/
  - [ ] Test dark mode

- [ ] **P1-005 UI Components**
  - [ ] Copy ButtonStyles.swift → UI/Components/
  - [ ] Tạo LoadingView.swift
  - [ ] Tạo InputField.swift

- [ ] **P1-006 Storage**
  - [ ] Merge UserDefaultsStorage features → StorageClient
  - [ ] Merge KeychainStorage features → KeychainClient
  - [ ] Thêm Biometric support

### Phase 2

- [ ] **P2-001 Network**
  - [ ] Adapt NetworkService → NetworkClient
  - [ ] Copy APITarget
  - [ ] Implement với TCA @Dependency

- [ ] **P2-003 Cache**
  - [ ] Copy MemoryCache
  - [ ] Copy DiskCache
  - [ ] Wrap với CacheClient

### Phase 3+

- [ ] Firebase Setup (khi cần)
- [ ] Features (Onboarding, Settings)
- [ ] Monetization (IAP, AdMob)

---

## 6. Related Documents

| Document | Mô tả |
|----------|-------|
| `.ai-rules/04-CONTEXT/CURRENT-STATUS.md` | Tình trạng hiện tại |
| `.ai-rules/04-CONTEXT/INTEGRATION-PLAN.md` | Kế hoạch tích hợp ngắn |
| `.ai-rules/04-CONTEXT/REFERENCE-CODE.md` | Code snippets |
| `progress/CHO-XU-LY.md` | Task backlog |
| `08-TASK-TRACKER.md` | Chi tiết 30 tasks |

---

**📅 Cập nhật lần cuối:** December 23, 2024
**🎯 Phạm vi hiện tại:** Phase 1 (minimal)

