# Cấu trúc Dữ liệu Context Hub

Tài liệu này giải thích chi tiết cấu trúc và format của tất cả files dữ liệu trong Context Hub.

---

## 📋 Tổng quan Files

```
.context/
├── config.json              # Cấu hình hệ thống
├── index.json              # Index tổng quan dự án
├── rules.json              # Quy tắc coding
├── patterns.json           # Patterns kiến trúc
├── quick_reference.json    # Tham khảo nhanh
├── modules/                # Data từng module
│   └── *.json
└── cache/
    └── symbols.json        # Cache symbols
```

---

## ⚙️ config.json

**Mục đích**: Cấu hình toàn bộ hệ thống

**Cấu trúc**:

```json
{
  "project": {
    "name": "ios-template",
    "architecture": "TCA + Parameterized Component Pattern",
    "root_path": "Sources/iOSTemplate"
  },
  "modules": [
    "Core", "Features", "Services", "Theme",
    "Network", "Storage", "Monetization", "Utilities"
  ],
  "indexing": {
    "file_extensions": [".swift"],
    "ignore_patterns": [
      "*.generated.swift",
      "Tests/",
      ".build/"
    ],
    "max_file_size_kb": 100
  },
  "context_limits": {
    "claude_max_tokens": 8000,
    "cursor_max_tokens": 3000,
    "claude_compression_ratio": 0.7,
    "max_rules_for_cursor": 15
  },
  "rules": {
    "source_path": ".ai/rules",
    "priority_categories": [
      "critical", "architecture", "naming", "testing"
    ]
  }
}
```

**Các trường quan trọng**:

| Trường | Mô tả | Có thể sửa? |
|--------|-------|-------------|
| `project.root_path` | Đường dẫn source code | ✅ Có |
| `modules` | List modules cần index | ✅ Có |
| `context_limits.claude_max_tokens` | Giới hạn token cho Claude | ✅ Có |
| `rules.source_path` | Đường dẫn rules | ✅ Có |

---

## 📊 index.json

**Mục đích**: Index tổng quan dự án

**Cấu trúc**:

```json
{
  "project": "ios-template",
  "architecture": "TCA + Parameterized Component Pattern",
  "modules": 9,
  "module_list": [
    "Core", "Features", "Services", "Theme",
    "Network", "Storage", "Monetization", "Utilities", "Misc"
  ],
  "total_files": 74,
  "total_loc": 13466,
  "indexed_at": "2025-11-23T17:36:21.964134",
  "config_version": "1.0",
  "last_full_index": "2025-11-23T17:36:21.968907",
  "stats": {
    "modules_indexed": 9,
    "files_processed": 74,
    "rules_indexed": 20,
    "indexing_duration": "0:00:00.068470"
  }
}
```

**Thông tin quan trọng**:
- `total_files`: Tổng số files đã index
- `total_loc`: Tổng dòng code
- `indexed_at`: Thời gian index lần cuối
- `stats.indexing_duration`: Thời gian indexing

---

## 📦 modules/*.json

**Mục đích**: Thông tin chi tiết từng module

**Ví dụ** - `modules/Features.json`:

```json
{
  "name": "Features",
  "purpose": "UI features - Onboarding, Auth, Settings, Home, Profile",
  "total_files": 11,
  "total_loc": 2108,
  "key_symbols": [
    "function:validateForm",
    "struct:MainTabView",
    "struct:ExploreView",
    "struct:PermissionRow",
    "struct:NotificationSettingsView",
    "function:makeBody",
    "function:handleResendEmail",
    "function:completeOnboarding",
    "struct:ProfileView",
    "struct:OnboardingView"
  ],
  "dependencies": [
    "ComposableArchitecture",
    "SwiftUI",
    "UIKit"
  ],
  "files": [
    "SettingsView.swift",
    "HomeView.swift",
    "RegistrationView.swift",
    "LoginView.swift",
    "ForgotPasswordView.swift",
    "ExploreView.swift",
    "MainTabView.swift",
    "OnboardingView.swift",
    "ProfileView.swift",
    "PermissionsView.swift"
  ]
}
```

**Giải thích các trường**:

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| `name` | string | Tên module |
| `purpose` | string | Mục đích của module |
| `total_files` | number | Số lượng files |
| `total_loc` | number | Tổng dòng code |
| `key_symbols` | array | Top symbols (classes, structs, functions) |
| `dependencies` | array | Import dependencies |
| `files` | array | Danh sách files chính |

**Format symbols**:
- `struct:ClassName` - Struct
- `class:ClassName` - Class
- `enum:EnumName` - Enum
- `protocol:ProtocolName` - Protocol
- `function:functionName` - Function

---

## 📋 rules.json

**Mục đích**: Quy tắc coding được extract từ `.ai/rules/`

**Cấu trúc**:

```json
{
  "critical": [
    {
      "text": "Views MUST NOT contain hardcoded values",
      "category": "component pattern",
      "priority": "critical",
      "source_file": "component-pattern-rules.md"
    }
  ],
  "high": [
    {
      "text": "Use @ObservableState for TCA state",
      "category": "architecture",
      "priority": "high",
      "source_file": "code-conventions.md"
    }
  ],
  "medium": [...],
  "low": [...]
}
```

**Phân loại priority**:

| Priority | Mô tả | Khi nào áp dụng |
|----------|-------|-----------------|
| `critical` | Bắt buộc | MUST follow, vi phạm = lỗi nghiêm trọng |
| `high` | Rất quan trọng | SHOULD follow, vi phạm = code review reject |
| `medium` | Khuyến nghị | Nên follow nếu có thể |
| `low` | Tùy chọn | Nice to have |

**Các trường**:
- `text`: Nội dung quy tắc
- `category`: Nhóm quy tắc (naming, architecture, testing, v.v.)
- `priority`: Mức độ quan trọng
- `source_file`: File gốc chứa quy tắc

---

## 🏗️ patterns.json

**Mục đích**: Architectural patterns được phát hiện trong code

**Cấu trúc**:

```json
{
  "component": [
    "Parameterized Component Pattern: Component = View + Config...",
    "Views are pure rendering with NO hardcoded values..."
  ],
  "state-management": [
    "TCA pattern with State → Action → Reducer → Effect flow...",
    "Use @ObservableState for reactive state updates..."
  ],
  "networking": [
    "Moya integration for type-safe API calls...",
    "Network layer with protocol abstraction..."
  ],
  "persistence": [
    "Multi-layer storage: UserDefaults, Keychain, FileStorage...",
    "Protocol-based storage for testability..."
  ]
}
```

**Categories**:
- `component`: Component design patterns
- `state-management`: State management patterns (TCA, Redux, v.v.)
- `navigation`: Navigation patterns
- `networking`: Network layer patterns
- `persistence`: Data persistence patterns
- `general`: Các patterns khác

---

## ⚡ quick_reference.json

**Mục đích**: Tham khảo nhanh cho các quy tắc quan trọng nhất

**Cấu trúc**:

```json
{
  "top_rules": [
    "Views MUST NOT contain hardcoded values",
    "Use @ObservableState for TCA state",
    "Follow Parameterized Component Pattern",
    "Create Config object in Core/ViewConfigs/",
    "Implement View in Features/"
  ],
  "naming_conventions": [
    "Files: PascalCase (UserService.swift)",
    "Variables: camelCase",
    "Protocols: Suffix with Protocol"
  ],
  "architecture_rules": [
    "TCA: State → Action → Reducer → Effect",
    "Component = View + Config",
    "Protocol-oriented design for services"
  ],
  "testing_requirements": [
    "Target coverage: 80%+",
    "Test all reducers",
    "Mock external dependencies"
  ]
}
```

**Sử dụng**: Hiển thị trong generated context để Claude nhanh chóng nắm được các quy tắc quan trọng.

---

## 🗂️ cache/symbols.json

**Mục đích**: Map nhanh từ symbol → file path

**Cấu trúc**:

```json
{
  "AppState": "Sources/iOSTemplate/Core/AppState.swift",
  "AppReducer": "Sources/iOSTemplate/Core/AppReducer.swift",
  "AppAction": "Sources/iOSTemplate/Core/AppAction.swift",
  "MainTabView": "Sources/iOSTemplate/Features/MainTabView.swift",
  "SettingsView": "Sources/iOSTemplate/Features/SettingsView.swift",
  "Colors": "Sources/iOSTemplate/Theme/Colors.swift",
  "Typography": "Sources/iOSTemplate/Theme/Typography.swift"
}
```

**Sử dụng**:
- Tìm nhanh file chứa một symbol cụ thể
- Search references
- Cross-reference analysis (future feature)

**Tra cứu**:
```bash
# Tìm file chứa AppState
cat .context/cache/symbols.json | grep "AppState"

# Kết quả:
# "AppState": "Sources/iOSTemplate/Core/AppState.swift"
```

---

## 📄 generated/.claude_context.md

**Mục đích**: Ngữ cảnh được tạo tự động cho Claude

**Cấu trúc**:

```markdown
# 🎯 CONTEXT FOR TASK

**Task**: Add dark mode toggle to Settings screen

**Generated**: 2025-11-23 17:36

---

## 📱 Project Overview

- **Name**: ios-template
- **Architecture**: TCA + Parameterized Component Pattern
- **UI Framework**: SwiftUI
- **iOS Target**: 16.0+

### Key Architectural Pattern: Parameterized Component
[Giải thích pattern...]

---

## 📦 Relevant Modules

### Features (Relevance: 100%)
**Purpose**: UI features - Onboarding, Auth, Settings, Home, Profile
**Files**: SettingsView.swift, HomeView.swift...
**Key Symbols**: struct:SettingsView, function:validateForm...

### Theme (Relevance: 79%)
[Similar structure...]

---

## ⚠️ CRITICAL RULES

1. **[CRITICAL]** Views MUST NOT contain hardcoded values
2. **[HIGH]** Use @ObservableState for TCA state
...

---

## 💡 Instructions for Implementation

**Your Task**: Add dark mode toggle to Settings screen

**Follow These Guidelines**:
1. TCA Architecture: Use State → Action → Reducer → Effect
2. Parameterized Components: NO hardcoded values
...

---

*Context generated by Context Hub v1.0*
```

**Sections**:

| Section | Mục đích |
|---------|----------|
| Task Header | Xác định task và thời gian tạo |
| Project Overview | High-level context về dự án |
| Relevant Modules | Modules liên quan đến task |
| Critical Rules | Quy tắc quan trọng cần follow |
| Instructions | Hướng dẫn implementation |

---

## 🔍 Cách Data được Sử dụng

### Flow tạo ngữ cảnh:

```
User Task
    ↓
Analyze Keywords
    ↓
Match với modules/ ← modules/*.json
    ↓
Get Relevant Modules
    ↓
Load Rules ← rules.json
    ↓
Load Patterns ← patterns.json
    ↓
Load Quick Ref ← quick_reference.json
    ↓
Assemble Context
    ↓
Compress & Format
    ↓
Save to generated/.claude_context.md
```

### Ví dụ với task "Add dark mode":

1. **Keyword matching**:
   - "dark mode" → Theme module (color, styling)
   - "Settings" → Features module

2. **Load modules data**:
   ```
   modules/Theme.json → Colors.swift, Typography.swift
   modules/Features.json → SettingsView.swift
   modules/Core.json → AppState.swift (for state)
   ```

3. **Load rules**:
   ```
   rules.json → critical & high priority rules
   ```

4. **Assemble**:
   ```
   Project overview
   + Relevant modules (Theme, Features, Core)
   + Critical rules
   + Implementation guide
   = Final context (~830 tokens)
   ```

---

## 📊 Kích thước Files

**Typical sizes** (cho ios-template project):

| File | Size | Records |
|------|------|---------|
| config.json | ~1KB | 1 config |
| index.json | ~500B | 1 index |
| rules.json | ~5KB | 20 rules |
| patterns.json | ~8KB | 43 patterns |
| quick_reference.json | ~2KB | 4 categories |
| modules/*.json | ~1-3KB each | 9 modules |
| symbols.json | ~50KB | 786 symbols |
| .claude_context.md | ~3-8KB | Generated |

**Total**: ~500KB cho toàn bộ indexed data

---

## 🛠️ Maintenance

### Khi nào data được update?

1. **Manual re-index**:
   ```bash
   python3 .context/scripts/master_indexer.py
   ```

2. **Auto-update** (future):
   - Git hooks sau commits
   - Watch file changes

### Backup data:

```bash
# Backup tất cả
tar -czf context-backup.tar.gz .context/

# Chỉ backup data (không backup scripts)
tar -czf context-data-backup.tar.gz \
  .context/*.json \
  .context/modules/ \
  .context/cache/
```

### Restore data:

```bash
tar -xzf context-backup.tar.gz
```

---

## 🎓 Advanced Usage

### Custom parsers

Để thêm support cho ngôn ngữ khác (Kotlin, TypeScript):

1. Sửa `config.json`:
   ```json
   {
     "indexing": {
       "file_extensions": [".swift", ".kt", ".ts"]
     }
   }
   ```

2. Update `scanner.py` với regex patterns mới

### Export data

```bash
# Export to JSON
cat .context/index.json | jq '.' > export.json

# Export symbols to CSV
cat .context/cache/symbols.json | \
  jq -r 'to_entries[] | [.key, .value] | @csv' > symbols.csv
```

---

**Tài liệu này giải thích đầy đủ cấu trúc data của Context Hub.**

Xem thêm: [Hướng dẫn sử dụng](HUONG-DAN-SU-DUNG.md) | [Ví dụ](VI-DU.md)
