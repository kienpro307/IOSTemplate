# Context Hub - Hệ thống Quản lý Ngữ cảnh cho Multi-AI

> Quản lý ngữ cảnh local cho phát triển iOS với Claude & Cursor

## 🎯 Tổng quan

Context Hub giải quyết các vấn đề:
- ❌ AI thiếu ngữ cảnh về dự án → code sai patterns
- ❌ Claude và Cursor làm việc độc lập → xung đột code
- ❌ Token usage cao (15K-20K tokens/prompt) → tốn chi phí

Giải pháp:
- ✅ Quản lý ngữ cảnh local (JSON files)
- ✅ Lọc thông minh: Chỉ gửi ngữ cảnh liên quan (6-8K tokens)
- ✅ Tự động index: Theo dõi cấu trúc dự án và quy tắc
- ✅ 100% local, không cần database

## 📊 Kết quả từ Dự án iOS Template

**Kết quả Indexing**:
- ✅ 9 modules đã được index (Core, Features, Services, Theme, v.v.)
- ✅ 74 files đã xử lý
- ✅ 13,466 dòng code
- ✅ 786 symbols được map
- ✅ 20 quy tắc được trích xuất
- ⏱️ Thời gian indexing: 0.07 giây

**Tiết kiệm Token**:
- **Trước đây**: 15,000-20,000 tokens (dump tất cả files liên quan)
- **Bây giờ**: ~800-3,000 tokens (ngữ cảnh đã lọc)
- **Tiết kiệm**: 70-85% 🎉

## 🚀 Cách sử dụng

### 1. Tạo ngữ cảnh cho Claude

```bash
# Với task cụ thể
python3 .context/scripts/generate_claude_context.py "Thêm dark mode vào màn Settings"

# Chế độ tương tác
python3 .context/scripts/generate_claude_context.py
```

Tạo file `.context/generated/.claude_context.md` với:
- Các modules liên quan dựa trên task của bạn
- Các files và symbols quan trọng
- Quy tắc cần tuân theo
- Hướng dẫn thực hiện

### 2. Sử dụng với Claude

```bash
# Xem ngữ cảnh đã tạo
cat .context/generated/.claude_context.md

# Copy và paste vào Claude
# Sau đó thêm mô tả task của bạn
```

### 3. Re-index sau khi thay đổi lớn

Khi bạn thêm files mới hoặc sửa đổi đáng kể dự án:

```bash
python3 .context/scripts/master_indexer.py
```

## 📁 Cấu trúc

```
.context/
├── README.md               # File này
├── config.json            # Cấu hình
├── index.json            # Index chính
├── rules.json            # Quy tắc coding
├── patterns.json         # Patterns kiến trúc
├── quick_reference.json  # Tham khảo nhanh
├── docs/                 # 📚 Documentation
│   ├── HUONG-DAN-SU-DUNG.md
│   ├── CAU-TRUC-DU-LIEU.md
│   ├── VI-DU.md
│   └── README-EN.md (English version)
├── modules/              # Data từng module
│   ├── Core.json
│   ├── Features.json
│   └── ...
├── cache/                # Cache symbols
├── generated/            # Ngữ cảnh tự động tạo
└── scripts/              # Python scripts
    ├── scanner.py
    ├── rules_indexer.py
    ├── master_indexer.py
    └── generate_claude_context.py
```

## 📚 Tài liệu

- 📖 [Hướng dẫn sử dụng chi tiết](docs/HUONG-DAN-SU-DUNG.md)
- 🏗️ [Cấu trúc dữ liệu](docs/CAU-TRUC-DU-LIEU.md)
- 💡 [Ví dụ và use cases](docs/VI-DU.md)
- 🌐 [English version](docs/README-EN.md)

## ⚡ Quick Start

```bash
# 1. Index dự án (chỉ chạy 1 lần hoặc khi có thay đổi lớn)
python3 .context/scripts/master_indexer.py

# 2. Tạo ngữ cảnh cho task
python3 .context/scripts/generate_claude_context.py "Task của bạn"

# 3. Xem kết quả
cat .context/generated/.claude_context.md

# 4. Copy và sử dụng với Claude!
```

## 🎯 Ví dụ nhanh

```bash
# Ví dụ: Thêm chức năng dark mode
python3 .context/scripts/generate_claude_context.py "Thêm dark mode toggle vào Settings"

# Kết quả:
# 🎯 Phân tích task: Thêm dark mode toggle vào Settings
# 📊 Modules liên quan: Features (100%), Theme (79%), Core (30%)
# ✅ Đã lưu: .context/generated/.claude_context.md
# 📏 Kích thước: ~830 tokens
```

## 📊 Hiệu suất

- **Indexing**: 0.07s cho 74 files (13K LOC)
- **Tạo ngữ cảnh**: ~0.1s mỗi task
- **Dung lượng**: ~500KB cho tất cả data đã index
- **Giảm token**: 70-85%

## 🔧 Xem dữ liệu đã index

```bash
# Xem tất cả modules
ls -la .context/modules/
cat .context/modules/Features.json

# Xem index chính
cat .context/index.json

# Xem quy tắc
cat .context/rules.json

# Xem cache symbols
cat .context/cache/symbols.json
```

## 💡 Cấu hình

Chỉnh sửa `.context/config.json`:

```json
{
  "project": {
    "name": "ios-template",
    "root_path": "Sources/iOSTemplate"  // Cập nhật nếu cần
  },
  "context_limits": {
    "claude_max_tokens": 8000,  // Giới hạn kích thước ngữ cảnh
    "cursor_max_tokens": 3000
  }
}
```

## ❓ Troubleshooting

### Lỗi: "Source directory not found"
Cập nhật `root_path` trong `.context/config.json`

### Không tìm thấy rules
Kiểm tra thư mục `.ai/rules/` có tồn tại và chứa các file .md

### Ngữ cảnh quá lớn
Giảm `claude_max_tokens` trong `config.json`

## 🎉 Metrics thành công

Từ dự án ios-template:
- ✅ Giảm token: 70-85%
- ✅ Độ chính xác ngữ cảnh: Cao (nhận diện đúng modules liên quan)
- ✅ Tốc độ: Dưới 1 giây cho tất cả operations
- ✅ Zero dependencies bên ngoài

---

**Được xây dựng với ❤️ cho việc phát triển iOS hiệu quả với AI**

*Context Hub v1.0 - Local, Nhanh, Đơn giản*
