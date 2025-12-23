# Hướng dẫn Sử dụng Context Hub

## 📋 Mục lục

1. [Setup ban đầu](#setup-ban-đầu)
2. [Sử dụng hàng ngày](#sử-dụng-hàng-ngày)
3. [Re-indexing](#re-indexing)
4. [Tối ưu hóa](#tối-ưu-hóa)
5. [Troubleshooting](#troubleshooting)

---

## 🚀 Setup ban đầu

Context Hub đã được setup sẵn và index dự án của bạn!

### Kiểm tra kết quả indexing

```bash
# Xem thông tin tổng quan
cat .context/index.json

# Kết quả mong đợi:
# {
#   "project": "ios-template",
#   "modules": 9,
#   "total_files": 74,
#   "total_loc": 13466,
#   ...
# }
```

### Xem các modules đã index

```bash
ls -la .context/modules/

# Kết quả:
# Core.json
# Features.json
# Services.json
# Theme.json
# ...
```

---

## 💼 Sử dụng hàng ngày

### Workflow chuẩn

#### Bước 1: Xác định task

Ví dụ: "Thêm dark mode toggle vào Settings screen"

#### Bước 2: Tạo ngữ cảnh

```bash
python3 .context/scripts/generate_claude_context.py "Thêm dark mode toggle vào Settings"
```

**Output**:
```
🎯 Phân tích task: Thêm dark mode toggle vào Settings
📊 Modules liên quan: Features (100%), Theme (79%), Core (30%)
✅ Đã lưu: .context/generated/.claude_context.md
📏 Kích thước: 830 tokens
```

#### Bước 3: Xem ngữ cảnh

```bash
cat .context/generated/.claude_context.md
```

Hoặc mở bằng editor:
```bash
# VS Code
code .context/generated/.claude_context.md

# Vim
vim .context/generated/.claude_context.md

# Nano
nano .context/generated/.claude_context.md
```

#### Bước 4: Sử dụng với Claude

1. Copy toàn bộ nội dung file `.claude_context.md`
2. Paste vào Claude (CLI hoặc Web)
3. Thêm mô tả chi tiết task nếu cần
4. Bắt đầu coding!

---

## 🎯 Các cách sử dụng

### Cách 1: Command line (Nhanh nhất)

```bash
# Tạo ngữ cảnh
python3 .context/scripts/generate_claude_context.py "Your task here"

# Xem và copy
cat .context/generated/.claude_context.md | pbcopy  # macOS
cat .context/generated/.claude_context.md | xclip   # Linux
```

### Cách 2: Interactive mode

```bash
python3 .context/scripts/generate_claude_context.py

# Sau đó nhập task khi được hỏi:
> Thêm Firebase authentication
> Tạo Card component có thể tái sử dụng
> Fix lỗi navigation trong Home tab
> quit  # để thoát
```

### Cách 3: Script automation

Tạo file `generate_context.sh`:

```bash
#!/bin/bash
# Script tự động tạo và mở context

TASK="$1"

if [ -z "$TASK" ]; then
    echo "Usage: ./generate_context.sh 'your task'"
    exit 1
fi

# Tạo context
python3 .context/scripts/generate_claude_context.py "$TASK"

# Mở bằng editor mặc định
open .context/generated/.claude_context.md
```

Sử dụng:
```bash
chmod +x generate_context.sh
./generate_context.sh "Thêm dark mode"
```

---

## 🔄 Re-indexing

### Khi nào cần re-index?

✅ **CẦN re-index khi**:
- Thêm modules hoặc files mới
- Đổi tên files quan trọng
- Cập nhật rules trong `.ai/rules/`
- Thay đổi kiến trúc lớn

❌ **KHÔNG cần re-index khi**:
- Sửa code nhỏ trong existing files
- Thêm/sửa comments
- Đổi tên biến
- Fix bugs nhỏ

### Cách re-index

```bash
# Full re-index (khuyến nghị)
python3 .context/scripts/master_indexer.py

# Kết quả:
# 🚀 MASTER INDEXER STARTING
# ✅ Modules indexed: 9
# ✅ Files processed: 74
# ⏱️ Duration: 0.07 seconds
```

### Re-index tự động (Coming soon)

Git hooks sẽ tự động re-index khi commit.

---

## ⚡ Tối ưu hóa

### Viết task description tốt

#### ✅ Tốt (Cụ thể, có keywords):
```
"Thêm dark mode toggle vào Settings screen"
"Implement Firebase authentication trong AuthService"
"Tạo Card component tái sử dụng theo Parameterized Pattern"
"Fix bug navigation khi chuyển tab"
```

#### ❌ Không tốt (Quá chung chung):
```
"Làm cho tốt hơn"
"Fix bug"
"Thêm feature"
"Update UI"
```

### Giảm token sử dụng

Nếu ngữ cảnh quá lớn, chỉnh trong `config.json`:

```json
{
  "context_limits": {
    "claude_max_tokens": 6000  // Giảm từ 8000
  }
}
```

### Tăng độ chính xác

Thêm keywords vào task:
```
# Thay vì
"Thêm dark mode"

# Tốt hơn
"Thêm dark mode toggle vào Settings screen, update Colors.swift và AppState"
```

---

## 🔍 Xem dữ liệu đã index

### Xem tất cả modules

```bash
# List modules
ls .context/modules/

# Xem chi tiết 1 module
cat .context/modules/Features.json
```

Kết quả:
```json
{
  "name": "Features",
  "purpose": "UI features - Onboarding, Auth, Settings, Home, Profile",
  "total_files": 11,
  "total_loc": 2108,
  "key_symbols": [
    "struct:MainTabView",
    "struct:SettingsView",
    "function:validateForm",
    ...
  ],
  "dependencies": ["ComposableArchitecture", "SwiftUI"],
  "files": ["SettingsView.swift", "HomeView.swift", ...]
}
```

### Xem quy tắc

```bash
cat .context/rules.json
```

### Xem symbols cache

```bash
# Tìm symbol cụ thể
cat .context/cache/symbols.json | grep "AppState"

# Kết quả: "AppState": "Sources/iOSTemplate/Core/AppState.swift"
```

---

## ❓ Troubleshooting

### Lỗi: "Source directory not found"

**Nguyên nhân**: Đường dẫn source code sai

**Giải pháp**:
```bash
# Kiểm tra đường dẫn thực tế
ls Sources/iOSTemplate/

# Cập nhật trong config.json
{
  "project": {
    "root_path": "Sources/iOSTemplate"  // Sửa đường dẫn đúng
  }
}
```

### Không tìm thấy rules

**Nguyên nhân**: Thư mục `.ai/rules/` không tồn tại

**Giải pháp**:
```bash
# Kiểm tra
ls .ai/rules/

# Nếu không có, tạo mới
mkdir -p .ai/rules/

# Hoặc cập nhật config.json
{
  "rules": {
    "source_path": "path/to/your/rules"
  }
}
```

### Ngữ cảnh quá lớn

**Nguyên nhân**: Task quá chung chung, include nhiều modules

**Giải pháp 1** - Cụ thể hóa task:
```bash
# Thay vì
python3 .context/scripts/generate_claude_context.py "Update UI"

# Cụ thể hơn
python3 .context/scripts/generate_claude_context.py "Update Settings screen UI"
```

**Giải pháp 2** - Giảm token limit:
```json
{
  "context_limits": {
    "claude_max_tokens": 6000
  }
}
```

### Module không được detect

**Nguyên nhân**: Tên module không có trong config

**Giải pháp**:
```json
{
  "modules": [
    "Core",
    "Features",
    "Services",
    "YourNewModule"  // Thêm module mới
  ]
}
```

Sau đó re-index:
```bash
python3 .context/scripts/master_indexer.py
```

---

## 📊 Best Practices

### 1. Re-index định kỳ

```bash
# Mỗi tuần hoặc sau khi merge PR lớn
python3 .context/scripts/master_indexer.py
```

### 2. Kiểm tra ngữ cảnh trước khi gửi

```bash
# Xem preview
head -50 .context/generated/.claude_context.md

# Kiểm tra size
wc -w .context/generated/.claude_context.md
```

### 3. Tổ chức rules tốt

Giữ `.ai/rules/` organized:
```
.ai/rules/
├── naming-rules.md      # Quy tắc đặt tên
├── architecture.md      # Patterns kiến trúc
├── testing-rules.md     # Quy tắc testing
└── code-style.md        # Code style
```

### 4. Backup dữ liệu

```bash
# Backup định kỳ
tar -czf context-backup-$(date +%Y%m%d).tar.gz .context/
```

---

## 🎓 Tips & Tricks

### Tip 1: Alias commands

Thêm vào `.bashrc` hoặc `.zshrc`:

```bash
alias ctx="python3 .context/scripts/generate_claude_context.py"
alias ctx-index="python3 .context/scripts/master_indexer.py"
alias ctx-view="cat .context/generated/.claude_context.md"
```

Sử dụng:
```bash
ctx "Thêm dark mode"
ctx-view
```

### Tip 2: Preview trong terminal

```bash
# macOS
cat .context/generated/.claude_context.md | less

# Với syntax highlighting (nếu có bat)
bat .context/generated/.claude_context.md
```

### Tip 3: Tích hợp với editor

VS Code: Tạo task trong `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Context",
      "type": "shell",
      "command": "python3",
      "args": [
        ".context/scripts/generate_claude_context.py",
        "${input:taskDescription}"
      ]
    }
  ],
  "inputs": [
    {
      "id": "taskDescription",
      "type": "promptString",
      "description": "Task description"
    }
  ]
}
```

---

## 📚 Xem thêm

- [Cấu trúc dữ liệu](CAU-TRUC-DU-LIEU.md)
- [Ví dụ use cases](VI-DU.md)
- [English version](README-EN.md)

---

**Chúc bạn coding hiệu quả với Context Hub!** 🚀
