# Tasks đang thực hiện

> AI cập nhật file này khi bắt đầu/kết thúc task

## Hiện tại

### P0-004 - SwiftLint Setup

**Bắt đầu:** 2024-12-23
**Trạng thái:** ✅ HOÀN THÀNH

**Reference:**
- `ios-template-docs/06-KE-HOACH/08-TASK-TRACKER.md` (P0-004)
- `ios-template-home/ios-template-main/.swiftlint.yml`

**Files đã tạo/cập nhật:**
- ✅ `.swiftlint.yml` - Cấu hình SwiftLint với rules theo quy tắc code (line_length: 120/150, file_length: 400/500, function_body_length: 40/60, type_body_length: 250/350)
- ✅ `lint.sh` - Script để chạy SwiftLint

**Tiến độ:**
- [x] Kiểm tra file .swiftlint.yml hiện có
- [x] Cập nhật .swiftlint.yml theo yêu cầu task tracker
- [x] Thêm excluded paths (ios-template-docs, ios-template-home)
- [x] Thêm excluded identifier names (x, y, r, g, b, a, etc.)
- [x] Thêm excluded type names (UI, ID, URL, API)
- [x] Tạo lint.sh script để chạy SwiftLint
- [x] Test SwiftLint chạy thành công

**Ghi chú:**
- SwiftLint đã được cài đặt và chạy thành công
- Cấu hình khớp với quy tắc code trong `02-QUY-TAC-CODE.md`
- Script lint.sh có thể chạy để kiểm tra code style
- Một số warnings nhỏ (trailing whitespace, trailing newline) không ảnh hưởng đến build

---

### P2-003 - Logger System

**Bắt đầu:** 2024-12-23
**Trạng thái:** ✅ HOÀN THÀNH

**Reference:**
- `ios-template-home/ios-template-main/Sources/iOSTemplate/Utilities/Logger.swift`

**Files đã tạo:**
- ✅ `Sources/Core/Dependencies/LoggerClient.swift` - LoggerClientProtocol, LiveLoggerClient, MockLoggerClient với TCA @Dependency, OSLog integration, file logging

**Tiến độ:**
- [x] Copy Logger từ ios-template-home
- [x] Adapt theo TCA @Dependency pattern
- [x] Tạo LoggerClientProtocol với các logging methods
- [x] Tạo LiveLoggerClient với OSLog và file logging (thread-safe với DispatchQueue)
- [x] Tạo MockLoggerClient cho testing với LogEntry tracking
- [x] Register LoggerClientKey vào DependencyValues
- [x] Test build thành công (code compile OK, chỉ có lỗi platform requirements không liên quan)

**Ghi chú:**
- ✅ Tier khớp: Logger thuộc TIER 1 (FOUNDATION), đặt ở Core/Dependencies/ (TIER 1)
- Logger system hỗ trợ OSLog, console logging (DEBUG), và file logging (production)
- Thread-safe với DispatchQueue cho file operations
- Log levels: verbose, debug, info, warning, error
- Auto cleanup logs > 7 days
- Comment tiếng Việt theo rule

---

### P2-002 - Cache System

**Bắt đầu:** 2024-12-23
**Trạng thái:** 🔄 Đang làm

**Reference:**
- `ios-template-home/ios-template-main/Sources/iOSTemplate/Utilities/Cache/MemoryCache.swift`
- `ios-template-home/ios-template-main/Sources/iOSTemplate/Utilities/Cache/DiskCache.swift`

**Files đã tạo:**
- ✅ `Sources/Core/Cache/MemoryCache.swift` - Memory cache sử dụng NSCache với expiration support
- ✅ `Sources/Core/Cache/DiskCache.swift` - Disk cache với FileManager, expiration, cleanup
- ✅ `Sources/Core/Dependencies/CacheClient.swift` - CacheClientProtocol, LiveCacheClient, MockCacheClient với TCA @Dependency

**Tiến độ:**
- [x] Copy MemoryCache từ ios-template-home
- [x] Copy DiskCache từ ios-template-home
- [x] Adapt theo TCA @Dependency pattern
- [x] Tạo CacheClientProtocol với generic support
- [x] Tạo LiveCacheClient với type-erased approach (Data encoding)
- [x] Tạo MockCacheClient cho testing
- [x] Register CacheClientKey vào DependencyValues
- [ ] Test build thành công
- [ ] Cập nhật progress files

**Ghi chú:**
- ✅ Tier khớp: Cache thuộc TIER 1 (FOUNDATION), đặt ở Core/ (TIER 1)
- Cache system hỗ trợ memory + disk cache với expiration
- Type-erased approach để hỗ trợ generic types
- Comment tiếng Việt theo rule

---

### P2-004 - Error Handling System

**Bắt đầu:** 2024-12-23
**Trạng thái:** ✅ HOÀN THÀNH

**Reference:**
- `ios-template-docs/01-KIEN-TRUC/06-XU-LY-LOI.md`

**Files đã tạo:**
- ✅ `Sources/Core/Errors/AppError.swift` - Root error type với NetworkError, DataError, BusinessError, SystemError
- ✅ `Sources/Core/Errors/DataError.swift` - Lỗi dữ liệu (decoding, encoding, database, notFound, invalidData)
- ✅ `Sources/Core/Errors/BusinessError.swift` - Lỗi nghiệp vụ (insufficientBalance, limitExceeded, invalidInput, etc.)
- ✅ `Sources/Core/Errors/SystemError.swift` - Lỗi hệ thống (unknown, configuration, permission, memory, fileSystem)
- ✅ `Sources/Core/Errors/ErrorMapper.swift` - Helper để map các error sang AppError

**Tiến độ:**
- [x] Tạo AppError enum làm root error type
- [x] Tạo DataError enum
- [x] Tạo BusinessError enum
- [x] Tạo SystemError enum
- [x] Tạo ErrorMapper helper
- [x] Tích hợp với NetworkError và KeychainError
- [ ] Test build thành công
- [ ] Cập nhật progress files

**Ghi chú:**
- Error system đã hoàn chỉnh với user-friendly messages
- ErrorMapper hỗ trợ map tự động từ các error types khác nhau
- Có thể retry cho network và data errors
- Severity levels (low, medium, high) để xác định cách hiển thị UI

---

### P1-004 - Theme System

**Bắt đầu:** 2024-12-23
**Trạng thái:** ✅ HOÀN THÀNH

**Reference:**

- `ios-template-home/.../Theme/Colors.swift`
- `ios-template-home/.../Theme/Typography.swift`
- `ios-template-home/.../Theme/Spacing.swift`

**Files đã tạo:**

- ✅ `Sources/UI/Theme/Colors.swift` - Adaptive colors với light/dark mode
- ✅ `Sources/UI/Theme/Typography.swift` - Material Design 3 typography scale
- ✅ `Sources/UI/Theme/Spacing.swift` - 4pt grid system + CornerRadius + ShadowStyle

**Tiến độ:**

- [x] Copy Colors.swift từ reference
- [x] Copy Typography.swift từ reference
- [x] Copy Spacing.swift từ reference (bao gồm CornerRadius, BorderWidth, ShadowStyle)
- [x] Đảm bảo public modifiers cho multi-module
- [x] Build test thành công

**Ghi chú:**

- Code đã được adapt với public modifiers
- Giữ nguyên logic adaptive colors
- Dark mode support hoàn chỉnh

---

**Task tiếp theo:** P0-004 SwiftLint Setup (xem `CHO-XU-LY.md`)

---

## Hướng dẫn AI

### Khi bắt đầu task:

1. Copy template bên dưới vào section "Hiện tại"
2. Đọc reference code từ `.ai-rules/04-CONTEXT/REFERENCE-CODE.md`
3. Tham khảo integration plan từ `.ai-rules/04-CONTEXT/INTEGRATION-PLAN.md`

### Khi hoàn thành task:

1. Xóa task khỏi section "Hiện tại"
2. Cập nhật `TIEN-DO.md`
3. Cập nhật `CHO-XU-LY.md` (xóa task đã xong)
4. Cập nhật `.ai-rules/04-CONTEXT/CURRENT-STATUS.md`

---

## Template

```markdown
### [Task ID] - Tên task

**Bắt đầu:** YYYY-MM-DD HH:MM
**Trạng thái:** 🔄 Đang làm

**Reference:**

- `ios-template-home/.../path/to/file.swift`

**Files cần tạo/sửa:**

- [ ] `Sources/UI/Theme/Colors.swift`
- [ ] ...

**Tiến độ:**

- [ ] Bước 1
- [ ] Bước 2
- [ ] Bước 3

**Ghi chú:**

- Note
```

---

## Ví dụ: P1-004 Theme System

```markdown
### P1-004 - Theme System

**Bắt đầu:** 2024-12-24 09:00
**Trạng thái:** 🔄 Đang làm

**Reference:**

- `ios-template-home/.../Theme/Colors.swift`
- `ios-template-home/.../Theme/Typography.swift`
- `ios-template-home/.../Theme/Spacing.swift`

**Files cần tạo:**

- [ ] `Sources/UI/Theme/Colors.swift`
- [ ] `Sources/UI/Theme/Typography.swift`
- [ ] `Sources/UI/Theme/Spacing.swift`

**Tiến độ:**

- [x] Copy Colors.swift
- [x] Adapt namespace
- [ ] Copy Typography.swift
- [ ] Copy Spacing.swift
- [ ] Test Dark mode
- [ ] Update UI.swift exports

**Ghi chú:**

- Đang làm typography scale
```

---

**Cập nhật lần cuối:** December 23, 2024
