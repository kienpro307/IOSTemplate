# Backlog - Tasks chờ xử lý

> Danh sách tasks theo thứ tự ưu tiên

## Ưu tiên P0 (Critical) - Đang Tích hợp

| ID | Task | Phase | Reference từ ios-template-home | Trạng thái |
|----|------|-------|--------------------------------|------------|
| P1-004 | Theme System (Colors, Typography, Spacing) | 1 | `Theme/*.swift` | ✅ Hoàn thành |
| P1-005 | UI Components (ButtonStyles) | 1 | `Theme/Components/` | ✅ Hoàn thành |
| P1-006 | Storage Enhancement | 1 | `Storage/*.swift` | ✅ Hoàn thành |

## Ưu tiên P1 (High)

| ID | Task | Phase | Dependencies |
|----|------|-------|--------------|
| P4-001 | Onboarding Feature | 4 | P1-005 | ✅ Hoàn thành |
| P4-002 | Home Feature | 4 | P1-003 | ✅ Hoàn thành |
| P4-003 | Settings Feature | 4 | P1-006 | ✅ Hoàn thành |

## Đợi Phase sau

| ID | Task | Phase | Notes |
|----|------|-------|-------|
| P3-004 | Remote Config | 3 | ✅ Hoàn thành |
| P3-005 | Push Notifications | 3 | ✅ Hoàn thành |
| P4-002 | Onboarding Feature | 4 | ✅ Hoàn thành |
| P4-003 | Home Feature | 4 | ✅ Hoàn thành |
| P4-004 | Settings Feature | 4 | ✅ Hoàn thành |
| P5-001 | In-App Purchase | 5 | ✅ Hoàn thành |
| P5-002 | AdMob Integration | 5 | Phụ thuộc P3-001 |

---

## Ghi chú

- **Authentication**: App **KHÔNG** có auth, bỏ qua task này
- **Profile**: App **KHÔNG** có profile, bỏ qua task này
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
