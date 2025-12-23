# Quy tắc Git

## Commit message format

```
<type>(<scope>): <mô tả tiếng Việt>

[optional body]
```

### Types
- `feat`: Tính năng mới
- `fix`: Sửa lỗi
- `refactor`: Refactor code
- `docs`: Cập nhật docs
- `test`: Thêm/sửa tests
- `chore`: Công việc khác

### ⚠️ QUAN TRỌNG: Commit message phải viết bằng TIẾNG VIỆT

### Ví dụ đúng ✅

```
feat(network): thêm NetworkClient với Moya và APITarget
fix(storage): sửa lỗi compile trong StorageClient
refactor(ui): cải thiện Colors.swift với comment tiếng Việt
docs(progress): cập nhật tiến độ Phase 1 hoàn thành
test(network): thêm unit tests cho NetworkClient
chore(deps): cập nhật Moya lên version 15.0.0
```

### Ví dụ sai ❌

```
feat(auth): add login screen  # ❌ Tiếng Anh
fix(home): resolve crash     # ❌ Tiếng Anh
refactor(network): simplify  # ❌ Tiếng Anh
```

## Branch naming

```
<type>/<short-description>
```

### Ví dụ
- `feat/login-screen`
- `fix/crash-home`
- `refactor/network-layer`

## Workflow

1. Tạo branch từ `main`
2. Commit theo convention (message tiếng Việt)
3. Push và tạo PR
4. Code review
5. Merge vào `main`

## Workflow sau khi AI hoàn thành task

**QUAN TRỌNG:** AI phải tuân thủ workflow sau:

1. ✅ Hoàn thành code
2. ⏸️ Để user run và review
3. ⏸️ Chờ user build success
4. ✅ Khi build success → Tạo câu lệnh git commit và push
5. ✅ Commit message phải tiếng Việt

Xem chi tiết: [03-TASK/WORKFLOW.md](../03-TASK/WORKFLOW.md)

## Chi tiết

Xem: `ios-template-docs/04-HUONG-DAN-AI/04-QUY-TAC-GIT.md`

