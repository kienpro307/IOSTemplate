# Backlog - Tasks chờ xử lý

> Danh sách tasks theo thứ tự ưu tiên

## Ưu tiên P0 (Critical) - Đang Tích hợp

| ID | Task | Phase | Reference từ ios-template-home |
|----|------|-------|--------------------------------|
| P1-004 | Theme System (Colors, Typography, Spacing) | 1 | `Theme/*.swift` |
| P1-005 | UI Components (ButtonStyles) | 1 | `Theme/Components/` |
| P1-006 | Storage Enhancement | 1 | `Storage/*.swift` |

## Ưu tiên P1 (High)

| ID | Task | Phase | Dependencies |
|----|------|-------|--------------|
| P0-004 | SwiftLint Setup | 0 | P0-001 |
| P2-003 | Logger System | 2 | - |

## Ưu tiên P2 (Medium)

| ID | Task | Phase | Dependencies |
|----|------|-------|--------------|
| Logger | Logger System (Bonus) | 2 | - |

## Đợi Phase sau

| ID | Task | Phase | Notes |
|----|------|-------|-------|
| P3-001 | Firebase Setup | 3 | Cần thêm Firebase vào Package.swift |
| P3-002 | Analytics Service | 3 | Phụ thuộc P3-001 |
| P3-003 | Crashlytics | 3 | Phụ thuộc P3-001 |
| P4-002 | Onboarding Feature | 4 | Phụ thuộc P1-005 |
| P4-003 | Home Feature | 4 | Phụ thuộc P1-003 |
| P4-004 | Settings Feature | 4 | Phụ thuộc P1-006 |
| P5-001 | In-App Purchase | 5 | Phụ thuộc P4-001 |
| P5-002 | AdMob Integration | 5 | Phụ thuộc P3-001 |

---

## Ghi chú

- **P4-001 (Auth)**: App không có auth, bỏ qua task này
- **ios-template-home**: Dùng làm reference, không copy nguyên
- **TCA pattern**: Tất cả code mới phải dùng @Dependency

---

## Chi tiết tích hợp

### P1-004: Theme System

**Reference files:**
```
ios-template-home/ios-template-main/Sources/iOSTemplate/Theme/
├── Colors.swift        # Adaptive colors
├── Typography.swift    # Material Design 3
└── Spacing.swift       # 4pt grid system
```

**Output:**
```
Sources/UI/Theme/
├── Colors.swift
├── Typography.swift
└── Spacing.swift
```

### P1-005: UI Components

**Reference files:**
```
ios-template-home/.../Theme/Components/
└── ButtonStyles.swift
```

**Output:**
```
Sources/UI/Components/
├── ButtonStyles.swift
└── LoadingView.swift
```

### P1-006: Storage Enhancement

**Cần thêm vào:**
- `@UserDefault` property wrapper
- `StorageKey` enum
- Biometric support cho KeychainClient

---

## Links

| File | Mô tả |
|------|-------|
| `ios-template-docs/06-KE-HOACH/08-TASK-TRACKER.md` | Chi tiết 30 tasks |
| `ios-template-docs/06-KE-HOACH/09-TICH-HOP-TEMPLATE-CU.md` | Kế hoạch tích hợp |
| `.ai-rules/04-CONTEXT/REFERENCE-MAP.md` | Mapping code reference |
