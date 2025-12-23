# Tình trạng Hiện tại của Dự án

> File này AI ĐỌC ĐẦU TIÊN để biết context. AI CÓ QUYỀN cập nhật file này.

## Tóm tắt Nhanh

```
Dự án: iOS Template (TCA-based)
Tiến độ: Phase 1 - 100% ✅ (6/6 tasks done) → Phase 2 - 0% (0/4 tasks)
Task tiếp theo: P2-001 Network Layer với Moya
Có code reference: ios-template-home (chỉ copy/paste, không viết từ đầu)
```

---

## Tiến độ Chi tiết

### Đã hoàn thành (12/30 tasks)

| ID | Task | Phase | Deliverables |
|----|------|-------|--------------|
| P0-001 | Xcode Project | 0 | IOSTemplate.xcodeproj |
| P0-002 | Git Setup | 0 | .gitignore, README.md |
| P0-003 | SPM Setup | 0 | Package.swift với 4 modules |
| P1-001 | TCA Core | 1 | AppState, AppAction, AppReducer |
| P1-002 | DI Setup | 1 | Dependencies với @Dependency |
| P1-003 | Navigation | 1 | Destination.swift, DeepLink.swift |
| P1-004 | Theme System | 1 | Colors.swift, Typography.swift, Spacing.swift (comment tiếng Việt) |
| P1-005 | UI Components | 1 | ButtonStyles.swift |
| P1-006 | Storage Enhancement | 1 | StorageClient.swift, KeychainClient.swift với primitive types, Codable, Biometric (comment tiếng Việt) |
| P2-001 | Network Layer với Moya | 2 | NetworkClient.swift, APITarget.swift với Moya, plugins, TokenProvider, error mapping (comment tiếng Việt) |
| P2-002 | Cache System | 2 | MemoryCache.swift, DiskCache.swift, CacheClient.swift với TCA @Dependency, type-erased approach, memory + disk cache |
| P2-004 | Error Handling System | 2 | AppError.swift, DataError.swift, BusinessError.swift, SystemError.swift, ErrorMapper.swift với user-friendly messages, retry support, severity levels |

### Đang làm / Tiếp theo

| ID | Task | Ưu tiên | Reference từ ios-template-home |
|----|------|---------|-------------------------------|
| P2-003 | Logger System | MEDIUM | `Utilities/Logger.swift` |
| P0-004 | SwiftLint Setup | MEDIUM | - |

---

## Kiến trúc Hiện tại

```
Sources/
├── App/                    # Entry point
│   ├── Main.swift
│   └── RootView.swift
├── Core/                   # Module Core (đã có)
│   ├── Architecture/       # TCA setup ✅
│   ├── Cache/             # Cache System ✅
│   ├── Dependencies/       # DI keys ✅
│   ├── Errors/            # Error Handling System ✅
│   └── Navigation/         # Navigation ✅
├── Features/               # Module Features (skeleton)
│   └── Features.swift
├── Services/               # Module Services (skeleton)
│   └── Services.swift
└── UI/                     # Module UI ✅
    ├── Theme/              # Colors, Typography, Spacing ✅
    └── Components/         # ButtonStyles ✅
```

---

## Code Reference: ios-template-home

> QUAN TRỌNG: Sử dụng làm reference để copy/paste, KHÔNG viết từ đầu.

### Vị trí: `ios-template-home/ios-template-main/Sources/iOSTemplate/`

| Thư mục | Nội dung | Sử dụng cho Task |
|---------|----------|------------------|
| `Theme/` | Colors, Typography, Spacing, ButtonStyles | P1-004, P1-005 |
| `Storage/` | UserDefaultsStorage, KeychainStorage | P1-006 |
| `Network/` | NetworkService, APITarget | P2-001 |
| `Utilities/Cache/` | MemoryCache, DiskCache | P2-003 |
| `Utilities/Logger.swift` | Logging system | Bonus |
| `Services/ServiceProtocols.swift` | Tất cả protocols | Reference |

---

## Quy tắc Quan trọng

### 1. Không có Authentication
- App KHÔNG có đăng nhập/đăng ký
- Task P4-001 (Auth Feature) - BỎ QUA

### 2. Bám sát Kiến trúc
- Xem: `ios-template-docs/01-KIEN-TRUC/`
- Module dependencies: Core → UI/Services → Features → App

### 3. TCA Pattern
- Sử dụng TCA @Dependency (không Swinject/Singleton)
- Xem: `.ai-rules/02-CODE/TCA.md`

### 4. Ngôn ngữ
- Code: TIẾNG ANH
- Comment: TIẾNG VIỆT

---

## Khi AI Bắt đầu Task Mới

1. Đọc file này
2. Xem task cần làm trong `progress/CHO-XU-LY.md`
3. Tìm code reference trong `ios-template-home/`
4. Copy/adapt code theo conventions mới
5. Cập nhật `progress/DANG-LAM.md`
6. Sau khi xong, cập nhật file này

---

**Cập nhật lần cuối:** December 23, 2024
**Ghi chú:** Đã hoàn thành Phase 1 và P2-001, P2-002, P2-004. Cache System đã hoàn chỉnh với MemoryCache, DiskCache và CacheClient theo TCA @Dependency pattern.

