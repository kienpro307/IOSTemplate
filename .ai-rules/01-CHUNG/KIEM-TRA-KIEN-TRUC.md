# ⚠️ Kiểm Tra Kiến Trúc - Rule Quan Trọng

> **QUAN TRỌNG:** Trước khi làm BẤT CỨ việc gì, phải kiểm tra tương thích với kiến trúc dự án.

## Quy Tắc BẮT BUỘC

### 1. Kiểm Tra Trước Khi Code

```
Khi nhận task mới:
    1. Xác định module đang làm (Core/UI/Services/Features/App)
    2. Xác định tier của module đó (xem TIER-MAPPING.md)
    3. Nếu copy code từ ios-template-home:
       a. Xác định tier của code cũ
       b. So sánh với tier đang làm
       c. Nếu KHÔNG KHỚP → ⚠️ CẢNH BÁO và hỏi user
    4. KHÔNG ĐƯỢC im lặng và tự ý làm
```

### 2. Kiến Trúc 4-Tier

```
TIER 1: FOUNDATION  → Core, UI (không phụ thuộc gì)
TIER 2: SERVICES    → Services (phụ thuộc Foundation)
TIER 3: DOMAIN      → Features (phụ thuộc Foundation + Services)
TIER 4: APPS        → App (phụ thuộc tất cả)
```

### 3. Module → Tier Mapping

| Module | Tier | Dependencies |
|--------|------|--------------|
| `Core/` | TIER 1 | Không phụ thuộc gì |
| `UI/` | TIER 1 | Chỉ phụ thuộc Core |
| `Services/` | TIER 2 | Chỉ phụ thuộc Core |
| `Features/` | TIER 3 | Phụ thuộc Core, UI, Services |
| `App/` | TIER 4 | Phụ thuộc tất cả |

---

## Khi Nào Cần Cảnh Báo

### ⚠️ CẢNH BÁO khi:

1. **Tier không khớp:**
   - Code từ ios-template-home thuộc TIER 2
   - Nhưng đang làm ở TIER 1
   - → CẢNH BÁO và hỏi user

2. **Module dependencies sai:**
   - Tạo code ở Core nhưng import UI
   - → CẢNH BÁO và hỏi user

3. **Vi phạm dependency rules:**
   - Services import Features
   - → CẢNH BÁO và hỏi user

4. **Cần tạo ở module khác:**
   - Code thuộc Services nhưng đang làm ở Core
   - → CẢNH BÁO và đề xuất tạo ở Services

---

## Format Cảnh Báo

Khi phát hiện vấn đề kiến trúc, phải cảnh báo theo format:

```
⚠️ CẢNH BÁO KIẾN TRÚC - TIER/MODULE KHÔNG KHỚP:

- Code từ ios-template-home: `[đường dẫn file]`
- Tier của code cũ: [TIER X]
- Module đang làm: `[Module]` (TIER Y)
- Vấn đề: [Mô tả chi tiết vấn đề]

Giải pháp đề xuất:
1. [Option 1] - Tạo ở [module đúng] (✅ RECOMMENDED)
2. [Option 2] - Tạo ở [module hiện tại] (cần giải thích lý do)
3. [Option 3] - Bỏ qua task này

Bạn muốn chọn option nào? (A/B/C)
```

---

## Ví Dụ Cảnh Báo

### Ví dụ 1: Tier không khớp

```
⚠️ CẢNH BÁO KIẾN TRÚC - TIER KHÔNG KHỚP:

- Code từ ios-template-home: `Services/Firebase/FirebaseManager.swift`
- Tier của code cũ: TIER 2 (SERVICES)
- Module đang làm: `Core/` (TIER 1 - FOUNDATION)
- Vấn đề: Firebase Manager thuộc Services tier, không nên đặt ở Core

Giải pháp đề xuất:
1. Tạo ở `Sources/Services/Firebase/FirebaseManager.swift` (✅ RECOMMENDED)
2. Tạo ở `Sources/Core/` nhưng cần giải thích lý do đặc biệt
3. Bỏ qua task này

Bạn muốn chọn option nào? (A/B/C)
```

### Ví dụ 2: Dependency sai

```
⚠️ CẢNH BÁO KIẾN TRÚC - DEPENDENCY SAI:

- Code đang làm: `Sources/Core/Dependencies/SomeClient.swift`
- Import: `import UI` (❌ SAI)
- Vấn đề: Core không được phụ thuộc UI (Core là TIER 1, UI cũng TIER 1 nhưng độc lập)

Giải pháp đề xuất:
1. Loại bỏ import UI, tìm cách khác (✅ RECOMMENDED)
2. Di chuyển code sang UI module nếu cần UI components
3. Tạo protocol ở Core, implement ở UI

Bạn muốn chọn option nào? (A/B/C)
```

---

## Checklist Bắt Buộc

Trước khi code, phải check:

### Bước 1: Đọc Docs (BẮT BUỘC)
- [ ] ✅ Đã đọc TẤT CẢ file HIGH priority trong `ios-template-docs/`?
- [ ] ✅ Đã đọc file liên quan đến task trong `ios-template-docs/`?
- [ ] ✅ Đã đọc `ios-template-docs/01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md`?
- [ ] ✅ Đã đọc `ios-template-docs/02-MO-DUN/00-TONG-QUAN-MO-DUN.md`?
- [ ] ✅ Đã đọc module README liên quan (Core/UI/Services/Features)?

### Bước 2: Kiểm tra Kiến trúc
- [ ] ✅ Đã xác định module đang làm?
- [ ] ✅ Đã xác định tier của module đó?
- [ ] ✅ Đã so sánh với cấu trúc trong `ios-template-docs/02-MO-DUN/`?
- [ ] ✅ Cấu trúc file/folder có đúng theo docs không?

### Bước 3: Kiểm tra Tier (nếu copy code)
- [ ] ✅ Nếu copy code → Đã kiểm tra tier của code cũ?
- [ ] ✅ Tier có khớp không?
- [ ] ✅ Nếu không khớp → Đã cảnh báo và hỏi user?
- [ ] ✅ Đã chờ user quyết định trước khi tiếp tục?

### Bước 4: Kiểm tra Dependencies
- [ ] ✅ Dependencies có đúng không? (không vi phạm dependency rules)
- [ ] ✅ Package.swift có đúng dependencies theo docs không?
- [ ] ✅ Module dependencies có đúng theo tier không?

### Bước 5: So sánh với Docs
- [ ] ✅ Code structure có khớp với `ios-template-docs/02-MO-DUN/[MODULE]/README.md`?
- [ ] ✅ Naming convention có đúng theo `ios-template-docs/04-HUONG-DAN-AI/03-QUY-TAC-DAT-TEN.md`?
- [ ] ✅ Code style có đúng theo `ios-template-docs/04-HUONG-DAN-AI/02-QUY-TAC-CODE.md`?

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **KHÔNG ĐƯỢC im lặng** và tự ý làm khi phát hiện vấn đề kiến trúc
2. **PHẢI cảnh báo** ngay khi tier/module không khớp
3. **PHẢI hỏi user** để quyết định trước khi tiếp tục
4. **KHÔNG được** tự quyết định tạo code ở tier/module sai
5. **LUÔN** giải thích rõ vấn đề và đề xuất giải pháp

---

## So sánh với Docs

### Kiểm tra Module Structure

Trước khi tạo/sửa code trong module, phải so sánh với docs:

#### Core Module (TIER 1)
- Xem: `ios-template-docs/02-MO-DUN/01-LOI/README.md`
- Cấu trúc phải khớp với docs

#### UI Module (TIER 1)
- Xem: `ios-template-docs/02-MO-DUN/02-GIAO-DIEN/README.md`
- Cấu trúc phải khớp với docs

#### Services Module (TIER 2)
- Xem: `ios-template-docs/02-MO-DUN/03-DICH-VU/README.md`
- **QUAN TRỌNG:** Phải có cấu trúc:
  ```
  Services/
  ├── Firebase/
  │   ├── Analytics.swift
  │   ├── Crashlytics.swift
  │   ├── RemoteConfig.swift
  │   └── PushNotification.swift
  ├── Payment/
  │   └── PaymentService.swift
  └── Ads/
      └── AdService.swift
  ```

#### Features Module (TIER 3)
- Xem: `ios-template-docs/02-MO-DUN/04-TINH-NANG/README.md`
- Cấu trúc phải khớp với docs

### Kiểm tra Package.swift

- Dependencies phải đúng theo `ios-template-docs/02-MO-DUN/03-DICH-VU/README.md`:
  - Firebase SDK 11.0+
  - StoreKit 2
  - Google Mobile Ads SDK

## Tài Liệu Tham Khảo

- [TIER-MAPPING.md](../04-CONTEXT/TIER-MAPPING.md) - Mapping tier chi tiết
- [08-MULTI-MODULE-ARCHITECTURE.md](../../ios-template-docs/01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md) - Kiến trúc 4-tier
- [01-KIEN-TRUC-TONG-THE.md](../../ios-template-docs/01-KIEN-TRUC/01-KIEN-TRUC-TONG-THE.md) - Kiến trúc tổng thể
- [DOC-READING-CHECKLIST.md](DOC-READING-CHECKLIST.md) - Checklist đọc docs

---

**Cập nhật lần cuối:** December 23, 2024

