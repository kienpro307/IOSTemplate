# Bảo vệ thư mục ios-template-docs

## Quy tắc

**KHÔNG ĐƯỢC SỬA** bất kỳ file nào trong `ios-template-docs/`

## Khi nào được sửa?

Chỉ khi user **chủ động yêu cầu** với các keyword:
- "sửa docs"
- "cập nhật ios-template-docs"
- "edit ios-template-docs"
- "thay đổi tài liệu"

## Ví dụ

```
❌ User: "Tạo feature mới cho app"
   → KHÔNG sửa ios-template-docs

❌ User: "Cập nhật code theo docs"
   → KHÔNG sửa ios-template-docs, chỉ đọc

✅ User: "Sửa docs để thêm quy tắc mới"
   → ĐƯỢC sửa ios-template-docs

✅ User: "Cập nhật ios-template-docs với thông tin mới"
   → ĐƯỢC sửa ios-template-docs
```

## Lý do

- `ios-template-docs/` là **source of truth**
- Tránh thay đổi không mong muốn
- Giữ docs ổn định và nhất quán

## Nếu cần tham khảo docs

Đọc file tương ứng, ví dụ:
- Kiến trúc: `ios-template-docs/01-KIEN-TRUC/`
- Code templates: `ios-template-docs/05-CODE-TEMPLATES/`
- Kế hoạch: `ios-template-docs/06-KE-HOACH/`

