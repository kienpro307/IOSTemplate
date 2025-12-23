# Workflow Sau Khi Hoàn Thành Task

> Quy trình bắt buộc sau khi AI hoàn thành một task

## Quy trình

### 1. Sau khi code xong

```
✅ Hoàn thành code
✅ Kiểm tra linter errors (nếu có)
✅ Cập nhật progress files
↓
📢 Thông báo cho user:
   "Đã hoàn thành task [TASK_ID]. 
    Vui lòng run và review code để kiểm tra build."
↓
⏸️ DỪNG LẠI - Chờ user review và build
```

**QUAN TRỌNG:**
- ❌ KHÔNG tự động commit/push
- ❌ KHÔNG tự động tạo git commands
- ✅ Chờ user xác nhận build success

---

### 2. Khi user báo build success

```
✅ User xác nhận: "Build success" hoặc "OK"
↓
📝 Tạo câu lệnh git commit và push
↓
💬 Hiển thị câu lệnh cho user chạy
```

---

## Format Commit Message

### Cấu trúc

```
<type>(<scope>): <mô tả ngắn>

[optional body - mô tả chi tiết]
```

### Types (bằng tiếng Việt trong mô tả)

| Type | Khi nào dùng | Ví dụ |
|------|--------------|-------|
| `feat` | Tính năng mới | `feat(network): thêm NetworkClient với Moya` |
| `fix` | Sửa lỗi | `fix(network): sửa lỗi compile trong NetworkClient` |
| `refactor` | Refactor code | `refactor(storage): cải thiện StorageClient với primitive types` |
| `docs` | Cập nhật docs | `docs(progress): cập nhật tiến độ Phase 1` |
| `test` | Thêm/sửa tests | `test(network): thêm unit tests cho NetworkClient` |
| `chore` | Công việc khác | `chore(deps): cập nhật dependencies` |

### Scope

- Module hoặc component bị ảnh hưởng
- Ví dụ: `network`, `storage`, `ui`, `core`, `progress`

### Mô tả

- **Bắt buộc:** Viết bằng **TIẾNG VIỆT**
- Ngắn gọn, rõ ràng
- Không có dấu chấm ở cuối
- Viết thường (không viết hoa chữ cái đầu)

---

## Ví dụ Commit Messages

### ✅ Đúng

```bash
feat(network): thêm NetworkClient với Moya và APITarget
fix(storage): sửa lỗi compile trong StorageClient
refactor(ui): cải thiện Colors.swift với comment tiếng Việt
docs(progress): cập nhật tiến độ Phase 1 hoàn thành
test(network): thêm unit tests cho NetworkClient
chore(deps): cập nhật Moya lên version 15.0.0
```

### ❌ Sai

```bash
# Sai: Không có scope
feat: add NetworkClient

# Sai: Viết tiếng Anh
feat(network): add NetworkClient with Moya

# Sai: Có dấu chấm
feat(network): thêm NetworkClient với Moya.

# Sai: Viết hoa chữ cái đầu
feat(network): Thêm NetworkClient với Moya
```

---

## Câu lệnh Git

### Format chuẩn

```bash
# 1. Add files
git add .

# 2. Commit với message tiếng Việt
git commit -m "<type>(<scope>): <mô tả tiếng Việt>"

# 3. Push lên remote
git push origin <branch-name>
```

### Ví dụ đầy đủ

```bash
# Sau khi build success
git add .
git commit -m "feat(network): thêm NetworkClient với Moya và APITarget"
git push origin main
```

Hoặc nếu đang ở branch:

```bash
git add .
git commit -m "feat(network): thêm NetworkClient với Moya và APITarget"
git push origin feat/network-layer
```

---

## Checklist cho AI

Khi user báo build success, AI phải:

- [ ] Xác định type phù hợp (feat/fix/refactor/docs/test/chore)
- [ ] Xác định scope (module/component)
- [ ] Viết mô tả bằng **TIẾNG VIỆT**
- [ ] Tạo câu lệnh git đầy đủ (add, commit, push)
- [ ] Hiển thị câu lệnh cho user chạy

---

## Lưu ý

1. **KHÔNG tự động chạy git commands** - Chỉ tạo câu lệnh cho user
2. **Commit message phải tiếng Việt** - Tuân thủ nghiêm ngặt
3. **Chờ user xác nhận build success** - Không tự động commit
4. **Kiểm tra branch hiện tại** - Push đúng branch

---

**Cập nhật:** December 23, 2024

