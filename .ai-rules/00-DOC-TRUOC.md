# ĐỌC TRƯỚC KHI LÀM VIỆC

> File này là entry point. AI phải đọc file này đầu tiên khi bắt đầu session.

## Quy tắc bắt buộc

### 1. Ngôn ngữ
- Code (hàm, biến, class, struct, enum): **TIẾNG ANH**
- Comment, documentation: **TIẾNG VIỆT**

### 2. Bảo vệ docs
- **KHÔNG ĐƯỢC SỬA** thư mục `ios-template-docs/`
- Chỉ sửa khi user nói rõ: "sửa docs" hoặc "cập nhật ios-template-docs"
- Chi tiết: [01-CHUNG/BAO-VE-DOCS.md](01-CHUNG/BAO-VE-DOCS.md)

### 3. Không có Authentication
- App **KHÔNG** có đăng nhập/đăng ký
- Không tạo features liên quan user auth

### 4. Architecture
- Dùng **TCA** (The Composable Architecture)
- Tuân thủ **SOLID principles**
- Dùng **@Dependency** (không Singleton)
- Chi tiết: [02-CODE/TCA.md](02-CODE/TCA.md)

---

## Context Dự án ⭐ QUAN TRỌNG

Trước khi làm task, đọc context hiện tại:

| File | Mô tả |
|------|-------|
| [04-CONTEXT/CURRENT-STATUS.md](04-CONTEXT/CURRENT-STATUS.md) | Tình trạng dự án (tiến độ, đã làm gì) |
| [04-CONTEXT/INTEGRATION-PLAN.md](04-CONTEXT/INTEGRATION-PLAN.md) | Kế hoạch tích hợp ios-template-home |
| [04-CONTEXT/REFERENCE-CODE.md](04-CONTEXT/REFERENCE-CODE.md) | Code snippets để copy |

---

## Cách đọc rules

```
Bắt đầu session mới
    ↓
Đọc file này (00-DOC-TRUOC.md)
    ↓
Đọc 04-CONTEXT/CURRENT-STATUS.md (biết tình trạng dự án)
    ↓
Xem task cần làm từ progress/CHO-XU-LY.md
    ↓
Nếu task Phase 1 (Theme, UI, Storage):
├── Đọc 04-CONTEXT/INTEGRATION-PLAN.md
└── Copy code từ 04-CONTEXT/REFERENCE-CODE.md
    ↓
Xác định loại task:
├── Tạo feature → Đọc 03-TASK/TAO-FEATURE.md
├── Sửa lỗi    → Đọc 03-TASK/SUA-LOI.md
└── Viết test  → Đọc 03-TASK/TESTING.md
    ↓
Thực hiện task
    ↓
Cập nhật progress/DANG-LAM.md và 04-CONTEXT/CURRENT-STATUS.md
```

---

## Quick links

| Loại | File |
|------|------|
| Danh mục rules | [INDEX.md](INDEX.md) |
| Context dự án | [04-CONTEXT/](04-CONTEXT/) |
| Quy tắc code | [02-CODE/](02-CODE/) |
| Quy tắc task | [03-TASK/](03-TASK/) |
| Tiến độ | [../progress/TIEN-DO.md](../progress/TIEN-DO.md) |
| Đang làm | [../progress/DANG-LAM.md](../progress/DANG-LAM.md) |
| Docs chi tiết | [../ios-template-docs/](../ios-template-docs/) |

---

## Reference Code từ ios-template-home

Dự án có template cũ ở `ios-template-home/` chứa code đã implement:
- Theme System, UI Components
- Network, Cache, Logger
- Firebase, Features, Monetization

**QUAN TRỌNG:** Dùng làm reference để copy/paste, viết lại theo TCA @Dependency pattern.

Xem: [04-CONTEXT/REFERENCE-CODE.md](04-CONTEXT/REFERENCE-CODE.md)

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
