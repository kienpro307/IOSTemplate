# ĐỌC TRƯỚC KHI LÀM VIỆC

> File này là entry point. AI phải đọc file này đầu tiên khi bắt đầu session.

## ⭐⭐ QUAN TRỌNG: Liệt Kê Rules Đã Đọc

**BẮT BUỘC:** Mỗi khi trả lời, phải liệt kê các rules đã đọc ở đầu câu trả lời.

Xem chi tiết: [01-CHUNG/LIET-KE-RULES.md](01-CHUNG/LIET-KE-RULES.md)

## Quy tắc bắt buộc

### 1. Ngôn ngữ

- Code (hàm, biến, class, struct, enum): **TIẾNG ANH**
- Comment, documentation: **TIẾNG VIỆT**

### 2. Bảo vệ docs

- **KHÔNG ĐƯỢC SỬA** thư mục `ios-template-docs/`
- Chỉ sửa khi user nói rõ: "sửa docs" hoặc "cập nhật ios-template-docs"
- Chi tiết: [01-CHUNG/BAO-VE-DOCS.md](01-CHUNG/BAO-VE-DOCS.md)

### 3. Không có Authentication và Profile

- App **KHÔNG** có đăng nhập/đăng ký
- App **KHÔNG** có profile/user management
- Không tạo features liên quan user auth hoặc profile

### 4. Architecture

- Dùng **TCA** (The Composable Architecture)
- Tuân thủ **SOLID principles**
- Dùng **@Dependency** (không Singleton)
- Chi tiết: [02-CODE/TCA.md](02-CODE/TCA.md)

---

## ⚠️⚠️ BẮT BUỘC: ĐỌC TẤT CẢ FILE TRONG ios-template-docs

**QUAN TRỌNG NHẤT:** Trước khi bắt đầu MỌI session, AI PHẢI đọc TẤT CẢ file trong `ios-template-docs/`.

### Tại sao quan trọng?

- Kiến trúc dự án được định nghĩa trong `ios-template-docs/`
- Mọi quy tắc code, naming, structure đều ở đó
- Không đọc docs → Code sai kiến trúc → Phải sửa lại → Lãng phí thời gian

### Checklist đọc docs

Xem file: [01-CHUNG/DOC-READING-CHECKLIST.md](01-CHUNG/DOC-READING-CHECKLIST.md)

**Tóm tắt:** Có tổng cộng **44 file markdown** trong `ios-template-docs/` cần đọc.

### Thứ tự ưu tiên đọc:

1. **🔴 HIGH Priority (BẮT BUỘC đọc trước mỗi session):**

   - `ios-template-docs/README.md` - Tổng quan
   - `ios-template-docs/04-HUONG-DAN-AI/00-DOC-TRUOC.md` - Hướng dẫn AI
   - `ios-template-docs/01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md` - Kiến trúc 4-tier
   - `ios-template-docs/01-KIEN-TRUC/01-KIEN-TRUC-TONG-THE.md` - Kiến trúc tổng thể
   - `ios-template-docs/02-MO-DUN/00-TONG-QUAN-MO-DUN.md` - Tổng quan modules
   - `ios-template-docs/02-MO-DUN/01-LOI/README.md` - Core module
   - `ios-template-docs/02-MO-DUN/02-GIAO-DIEN/README.md` - UI module
   - `ios-template-docs/02-MO-DUN/03-DICH-VU/README.md` - Services module
   - `ios-template-docs/02-MO-DUN/04-TINH-NANG/README.md` - Features module

2. **🟡 MEDIUM Priority (Đọc khi làm task liên quan):**

   - `ios-template-docs/01-KIEN-TRUC/02-KIEN-TRUC-TCA.md` - TCA architecture
   - `ios-template-docs/01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md` - TCA patterns
   - `ios-template-docs/04-HUONG-DAN-AI/02-QUY-TAC-CODE.md` - Quy tắc code
   - `ios-template-docs/04-HUONG-DAN-AI/03-QUY-TAC-DAT-TEN.md` - Quy tắc đặt tên
   - `ios-template-docs/06-KE-HOACH/08-TASK-TRACKER.md` - Task tracker

3. **🟢 LOW Priority (Đọc khi cần):**
   - Các file còn lại trong `ios-template-docs/`

### Quy trình đọc docs:

```
Bắt đầu session mới
    ↓
1. Đọc file này (00-DOC-TRUOC.md)
    ↓
2. Đọc DOC-READING-CHECKLIST.md
    ↓
3. Đọc TẤT CẢ file HIGH priority (9 files)
    ↓
4. Xác định task cần làm
    ↓
5. Đọc file MEDIUM priority liên quan đến task
    ↓
6. Bắt đầu làm task (luôn bám sát theo docs)
```

### ⚠️ LƯU Ý QUAN TRỌNG:

- **KHÔNG ĐƯỢC** bỏ qua việc đọc docs
- **KHÔNG ĐƯỢC** tự ý làm theo cách khác với docs
- **PHẢI** bám sát theo kiến trúc trong `ios-template-docs/01-KIEN-TRUC/`
- **PHẢI** kiểm tra tier mapping trước khi copy code
- **PHẢI** tuân thủ cấu trúc module trong `ios-template-docs/02-MO-DUN/`

---

## Context Dự án ⭐ QUAN TRỌNG

Trước khi làm task, đọc context hiện tại:

| File                                                             | Mô tả                                              |
| ---------------------------------------------------------------- | -------------------------------------------------- |
| [04-CONTEXT/CURRENT-STATUS.md](04-CONTEXT/CURRENT-STATUS.md)     | Tình trạng dự án (tiến độ, đã làm gì)              |
| [04-CONTEXT/INTEGRATION-PLAN.md](04-CONTEXT/INTEGRATION-PLAN.md) | Kế hoạch tích hợp ios-template-home                |
| [04-CONTEXT/REFERENCE-CODE.md](04-CONTEXT/REFERENCE-CODE.md)     | Code snippets để copy                              |
| [04-CONTEXT/TIER-MAPPING.md](04-CONTEXT/TIER-MAPPING.md)         | **⭐ Tier mapping - Kiểm tra tier trước khi copy** |

---

## Cách đọc rules

```
Bắt đầu session mới
    ↓
Đọc file này (00-DOC-TRUOC.md)
    ↓
Đọc 04-CONTEXT/CURRENT-STATUS.md (biết tình trạng dự án)
    ↓
⭐ Đọc 01-CHUNG/KIEM-TRA-KIEN-TRUC.md (QUAN TRỌNG)
    ↓
Xem task cần làm từ progress/CHO-XU-LY.md
    ↓
Nếu copy code từ ios-template-home:
├── Đọc 04-CONTEXT/TIER-MAPPING.md (kiểm tra tier)
├── Kiểm tra tier có khớp không?
│   ├── KHỚP → Tiếp tục
│   └── KHÔNG KHỚP → ⚠️ CẢNH BÁO và hỏi user
└── Copy code và adapt
    ↓
Xác định loại task:
├── Tạo feature → Đọc 03-TASK/TAO-FEATURE.md
├── Sửa lỗi    → Đọc 03-TASK/SUA-LOI.md
└── Viết test  → Đọc 03-TASK/TESTING.md
    ↓
Thực hiện task (luôn kiểm tra kiến trúc)
    ↓
Cập nhật progress/DANG-LAM.md và 04-CONTEXT/CURRENT-STATUS.md
```

---

## Quick links

| Loại           | File                                               |
| -------------- | -------------------------------------------------- |
| Danh mục rules | [INDEX.md](INDEX.md)                               |
| Context dự án  | [04-CONTEXT/](04-CONTEXT/)                         |
| Quy tắc code   | [02-CODE/](02-CODE/)                               |
| Quy tắc task   | [03-TASK/](03-TASK/)                               |
| Tiến độ        | [../progress/TIEN-DO.md](../progress/TIEN-DO.md)   |
| Đang làm       | [../progress/DANG-LAM.md](../progress/DANG-LAM.md) |
| Docs chi tiết  | [../ios-template-docs/](../ios-template-docs/)     |

---

## Reference Code từ ios-template-home

Dự án có template cũ ở `ios-template-home/` chứa code đã implement:

- Theme System, UI Components
- Network, Cache, Logger
- Firebase, Features, Monetization

**QUAN TRỌNG:** Dùng làm reference để copy/paste, viết lại theo TCA @Dependency pattern.

Xem: [04-CONTEXT/REFERENCE-CODE.md](04-CONTEXT/REFERENCE-CODE.md)

---

## ⭐ CHIẾN LƯỢC CODE: Khi nào Copy vs Tự Tạo

### Quy tắc BẮT BUỘC:

```
Khi làm task mới:
    1. Kiểm tra ios-template-home có code tương tự không?
        ├── CÓ → Bước 2: Kiểm tra Tier
        └── KHÔNG → Kiểm tra ios-template-docs có spec không?
            ├── CÓ → Tự tạo theo spec trong docs
            └── KHÔNG → Tự tạo theo best practices

    2. Kiểm tra Tier (QUAN TRỌNG):
        ├── Tier của code cũ KHỚP với tier đang làm?
        │   ├── CÓ → Copy và adapt theo TCA @Dependency pattern
        │   └── KHÔNG → ⚠️ CẢNH BÁO và hỏi user (KHÔNG được tự ý làm)
        └── Xem: 04-CONTEXT/TIER-MAPPING.md
```

### Chi tiết:

#### 1. **CÓ Reference Code trong ios-template-home** → KIỂM TRA TIER TRƯỚC

**⚠️ QUAN TRỌNG:** Code cũ tập trung ở 1 template, code mới chia thành 4-tier. Phải kiểm tra tier trước khi copy!

**Quy trình BẮT BUỘC:**

1. Tìm file tương ứng trong `ios-template-home/ios-template-main/Sources/iOSTemplate/`
2. **KIỂM TRA TIER:**
   - Xác định tier của code cũ (xem `04-CONTEXT/TIER-MAPPING.md`)
   - Xác định tier của module đang làm (Core=TIER1, UI=TIER1, Services=TIER2, Features=TIER3)
   - **Nếu KHÔNG KHỚP → CẢNH BÁO và hỏi user (KHÔNG được tự ý làm)**
3. Nếu tier khớp → Copy code
4. Adapt theo TCA @Dependency pattern:
   - Thay Singleton → @Dependency
   - Thay Combine → TCA Effect
   - Đảm bảo public modifiers cho multi-module
5. Sửa comment sang tiếng Việt
6. Test và update progress

**Ví dụ đã làm (tier khớp):**

- ✅ Theme System (TIER 1) → Copy vào `UI/Theme/` (TIER 1) ✅
- ✅ Network Layer (TIER 1) → Copy vào `Core/Dependencies/` (TIER 1) ✅
- ✅ Storage (TIER 1) → Copy vào `Core/Dependencies/` (TIER 1) ✅

#### 2. **KHÔNG có Reference Code** → TỰ TẠO theo Spec

**Ví dụ đã làm:**

- ✅ Error Handling System → Tự tạo theo spec trong `ios-template-docs/01-KIEN-TRUC/06-XU-LY-LOI.md`
- ✅ Navigation System → Tự tạo theo spec trong docs

**Quy trình:**

1. Đọc spec trong `ios-template-docs/`
2. Tự implement theo spec đó
3. Tuân thủ TCA pattern và SOLID principles
4. Comment tiếng Việt
5. Test và update progress

### Checklist trước khi code:

- [ ] Đã kiểm tra `ios-template-home/` có code tương tự?
- [ ] Nếu có → **KIỂM TRA TIER** (xem `04-CONTEXT/TIER-MAPPING.md`)
  - [ ] Tier của code cũ?
  - [ ] Tier của module đang làm?
  - [ ] Khớp hay không khớp?
  - [ ] Nếu không khớp → **CẢNH BÁO và hỏi user**
- [ ] Nếu không có → Đọc spec trong `ios-template-docs/`
- [ ] Tự tạo theo spec hoặc best practices
- [ ] Tuân thủ TCA @Dependency pattern
- [ ] Comment tiếng Việt

### ⚠️ LƯU Ý QUAN TRỌNG:

- **KHÔNG BAO GIỜ** tự tạo code nếu có reference code sẵn trong ios-template-home
- **LUÔN** kiểm tra ios-template-home TRƯỚC khi tự tạo
- **⭐ LUÔN KIỂM TRA TIER TRƯỚC KHI COPY** - Code cũ tập trung 1 template, code mới chia 4-tier
- **KHÔNG ĐƯỢC** tự ý copy code vào tier sai - Phải cảnh báo và hỏi user
- **LUÔN** adapt code từ ios-template-home theo TCA pattern (không copy nguyên)
- **LUÔN** đọc spec trong ios-template-docs nếu không có reference code

---

## Checklist trước khi code

- [ ] Đọc context dự án (04-CONTEXT/)
- [ ] Code dùng tiếng Anh
- [ ] Comment dùng tiếng Việt
- [ ] Follow TCA pattern
- [ ] Dùng @Dependency (không Singleton)
- [ ] Không sửa ios-template-docs (trừ khi được yêu cầu)
- [ ] Cập nhật progress khi xong task

---

## Workflow sau khi hoàn thành task ⭐ QUAN TRỌNG

### Quy trình bắt buộc:

```
1. Hoàn thành code
   ↓
2. Để user run và review
   ↓
3. Chờ user build success
   ↓
4. Khi build success → Tạo câu lệnh git commit và push
   ↓
5. Commit message phải theo convention và viết bằng TIẾNG VIỆT
```

### Chi tiết:

1. **Sau khi code xong:**

   - Thông báo: "Đã hoàn thành task. Vui lòng run và review code."
   - KHÔNG tự động commit/push
   - Chờ user xác nhận build success

2. **Khi user báo build success:**

   - Tạo câu lệnh git commit theo convention
   - Commit message viết bằng **TIẾNG VIỆT**
   - Format: `<type>(<scope>): <mô tả ngắn>`
   - Ví dụ: `feat(network): thêm NetworkClient với Moya`

3. **Commit message convention:**

   - `feat`: Tính năng mới
   - `fix`: Sửa lỗi
   - `refactor`: Refactor code
   - `docs`: Cập nhật docs
   - `test`: Thêm/sửa tests
   - `chore`: Công việc khác

4. **Câu lệnh git:**
   ```bash
   git add .
   git commit -m "<type>(<scope>): <mô tả tiếng Việt>"
   git push origin <branch>
   ```

Xem chi tiết: [03-TASK/WORKFLOW.md](03-TASK/WORKFLOW.md) và [01-CHUNG/GIT.md](01-CHUNG/GIT.md)
