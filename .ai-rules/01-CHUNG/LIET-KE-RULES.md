# 📋 Liệt Kê Rules Đã Đọc - Rule Quan Trọng

> **QUAN TRỌNG:** Mỗi khi trả lời, AI PHẢI liệt kê các rules đã đọc trước, sau đó mới đến câu trả lời.

## Quy Tắc BẮT BUỘC

### Format Trả Lời

```
Mỗi khi trả lời user, phải theo format:

┌─────────────────────────────────────────────────────────┐
│ 📋 RULES ĐÃ ĐỌC                                         │
├─────────────────────────────────────────────────────────┤
│ ✅ 00-DOC-TRUOC.md - Entry point                        │
│ ✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md - Kiểm tra kiến trúc │
│ ✅ 04-CONTEXT/CURRENT-STATUS.md - Tình trạng dự án     │
│ ✅ 04-CONTEXT/TIER-MAPPING.md - Tier mapping           │
│ ... (liệt kê tất cả rules liên quan)                   │
└─────────────────────────────────────────────────────────┘

[Sau đó mới đến câu trả lời chính]
```

### Khi Nào Cần Liệt Kê

**BẮT BUỘC liệt kê rules khi:**

1. **Bắt đầu session mới** - Liệt kê tất cả rules cơ bản
2. **Nhận task mới** - Liệt kê rules liên quan đến task
3. **Copy code từ ios-template-home** - Liệt kê rules về tier mapping, kiến trúc
4. **Tạo feature mới** - Liệt kê rules về TCA, structure
5. **Sửa lỗi** - Liệt kê rules về debugging, testing
6. **Bất kỳ câu hỏi nào** - Liệt kê rules liên quan

### Rules Cơ Bản (Luôn Đọc)

| Rule | Khi nào đọc |
|------|-------------|
| `00-DOC-TRUOC.md` | **LUÔN** - Mỗi session |
| `01-CHUNG/KIEM-TRA-KIEN-TRUC.md` | **LUÔN** - Trước khi code |
| `04-CONTEXT/CURRENT-STATUS.md` | **LUÔN** - Mỗi session |
| `04-CONTEXT/TIER-MAPPING.md` | Khi copy code từ ios-template-home |
| `04-CONTEXT/REFERENCE-CODE.md` | Khi copy code |
| `02-CODE/TCA.md` | Khi tạo reducer/feature |
| `02-CODE/STRUCTURE.md` | Khi tạo file mới |
| `02-CODE/NAMING.md` | Khi đặt tên biến/hàm/class |
| `03-TASK/WORKFLOW.md` | Sau khi hoàn thành task |

### Rules Theo Loại Task

#### Khi Copy Code từ ios-template-home:
```
✅ 00-DOC-TRUOC.md
✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md
✅ 04-CONTEXT/TIER-MAPPING.md
✅ 04-CONTEXT/REFERENCE-CODE.md
✅ 04-CONTEXT/INTEGRATION-PLAN.md
```

#### Khi Tạo Feature:
```
✅ 00-DOC-TRUOC.md
✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md
✅ 02-CODE/TCA.md
✅ 02-CODE/STRUCTURE.md
✅ 03-TASK/TAO-FEATURE.md
```

#### Khi Sửa Lỗi:
```
✅ 00-DOC-TRUOC.md
✅ 03-TASK/SUA-LOI.md
✅ 02-CODE/TCA.md (nếu liên quan TCA)
```

---

## Ví Dụ Format

### Ví dụ 1: Bắt đầu session

```
📋 RULES ĐÃ ĐỌC:
✅ 00-DOC-TRUOC.md - Entry point, chiến lược code
✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md - Kiểm tra kiến trúc
✅ 01-CHUNG/LIET-KE-RULES.md - Rule này
✅ 04-CONTEXT/CURRENT-STATUS.md - Tình trạng dự án hiện tại
✅ 04-CONTEXT/TIER-MAPPING.md - Tier mapping

---

[Trả lời câu hỏi của user]
```

### Ví dụ 2: Copy code từ ios-template-home

```
📋 RULES ĐÃ ĐỌC:
✅ 00-DOC-TRUOC.md - Chiến lược copy vs tự tạo
✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md - Kiểm tra tier trước khi copy
✅ 04-CONTEXT/TIER-MAPPING.md - Xác định tier của code
✅ 04-CONTEXT/REFERENCE-CODE.md - Code snippets
✅ 02-CODE/TCA.md - Adapt theo TCA pattern

---

⚠️ CẢNH BÁO KIẾN TRÚC - TIER KHÔNG KHỚP:
[Chi tiết cảnh báo...]
```

### Ví dụ 3: Tạo feature mới

```
📋 RULES ĐÃ ĐỌC:
✅ 00-DOC-TRUOC.md - Quy tắc cơ bản
✅ 01-CHUNG/KIEM-TRA-KIEN-TRUC.md - Kiểm tra module/tier
✅ 02-CODE/TCA.md - TCA pattern
✅ 02-CODE/STRUCTURE.md - Cấu trúc file
✅ 02-CODE/NAMING.md - Quy tắc đặt tên
✅ 03-TASK/TAO-FEATURE.md - Quy trình tạo feature

---

[Thực hiện tạo feature]
```

---

## Checklist Bắt Buộc

Trước khi trả lời, phải check:

- [ ] ✅ Đã đọc rules liên quan?
- [ ] ✅ Đã liệt kê rules đã đọc ở đầu câu trả lời?
- [ ] ✅ Format rõ ràng với box "📋 RULES ĐÃ ĐỌC"?
- [ ] ✅ Đã tuân thủ các rules đã đọc khi trả lời?

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **KHÔNG ĐƯỢC** bỏ qua việc liệt kê rules
2. **PHẢI** liệt kê đầy đủ rules liên quan đến câu hỏi/task
3. **PHẢI** đặt phần liệt kê rules ở **ĐẦU** câu trả lời
4. **PHẢI** tuân thủ các rules đã liệt kê trong câu trả lời
5. **KHÔNG ĐƯỢC** chỉ liệt kê mà không áp dụng

---

## Tài Liệu Tham Khảo

- [INDEX.md](../INDEX.md) - Danh mục tất cả rules
- [00-DOC-TRUOC.md](../00-DOC-TRUOC.md) - Entry point, cách đọc rules

---

**Cập nhật lần cuối:** December 23, 2024

