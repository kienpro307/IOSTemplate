# Context Hub - Multi-AI Collaboration System

> Hệ thống quản lý ngữ cảnh local cho iOS development với Claude & Cursor

## 🎯 Overview

Context Hub giải quyết vấn đề:
- ❌ AI thiếu context về project → code sai patterns
- ❌ Claude và Cursor làm việc độc lập → xung đột code
- ❌ Token usage cao (15K-20K tokens/prompt) → tốn chi phí

Giải pháp:
- ✅ Local context management (JSON files)
- ✅ Smart filtering: Chỉ gửi relevant context (6-8K tokens)
- ✅ Auto-indexing: Track project structure và rules
- ✅ 100% local, không cần database

## 📊 Results từ iOS Template Project

**Indexing Results**:
- ✅ 9 modules indexed (Core, Features, Services, Theme, etc.)
- ✅ 74 files processed
- ✅ 13,466 lines of code
- ✅ 786 symbols mapped
- ✅ 20 rules extracted
- ⏱️ Indexing time: 0.07 seconds

**Token Savings**:
- **Before**: 15,000-20,000 tokens (dump all relevant files)
- **After**: ~800-3,000 tokens (filtered context)
- **Savings**: 70-85% 🎉

## 🏗️ Architecture

```
Project Files → Scanner → .context/ (JSON) → Generator → Claude/Cursor
                   ↓                            ↑
              [Modules, Rules, Symbols]    Smart Filtering
```

## 📁 Structure

```
.context/
├── config.json              # Configuration
├── index.json              # Master index
├── rules.json              # Extracted rules
├── patterns.json           # Architectural patterns
├── quick_reference.json    # Quick reference
├── modules/                # Per-module data
│   ├── Core.json
│   ├── Features.json
│   ├── Services.json
│   └── ...
├── cache/                  # Symbol cache
│   └── symbols.json
├── generated/              # Auto-generated
│   └── .claude_context.md
└── scripts/                # Python scripts
    ├── scanner.py
    ├── rules_indexer.py
    ├── master_indexer.py
    └── generate_claude_context.py
```

## 🚀 Usage

### 1. Initial Setup (Already Done!)

The Context Hub has been set up and indexed your project.

### 2. Generate Context for Claude

```bash
# For a specific task
python3 .context/scripts/generate_claude_context.py "Add dark mode to Settings"

# Interactive mode
python3 .context/scripts/generate_claude_context.py
```

This will create `.context/generated/.claude_context.md` with:
- Relevant modules based on your task
- Key files and symbols
- Critical rules to follow
- Implementation guidelines

### 3. Use Context with Claude

```bash
# View the generated context
cat .context/generated/.claude_context.md

# Copy and paste into Claude
# Then add your task description
```

### 4. Re-index After Major Changes

When you add new files or significantly modify the project:

```bash
python3 .context/scripts/master_indexer.py
```

This will:
- Re-scan all Swift files
- Update module data
- Re-extract rules
- Rebuild symbol cache

## 📊 What Gets Indexed

### Code (from `Sources/iOSTemplate/`)
- **Modules**: Automatically detected from folder structure
- **Files**: All .swift files
- **Symbols**: Classes, structs, enums, protocols, functions
- **Dependencies**: Import statements
- **Statistics**: File count, LOC, etc.

### Rules (from `.ai/rules/`)
- Coding conventions
- Architecture patterns
- Testing requirements
- Naming standards

### Patterns
- Parameterized Component Pattern
- TCA patterns
- Navigation patterns
- etc.

## 🎯 How Context Generation Works

### Task Analysis

When you provide a task like "Add dark mode to Settings":

1. **Keyword Matching**: Analyzes task for keywords
   - "dark mode", "theme" → Theme module
   - "settings" → Features module
   - Automatically includes Core (TCA foundation)

2. **Relevance Scoring**: Calculates relevance for each module
   - Features: 100% (Settings screen)
   - Theme: 79% (dark mode, colors)
   - Core: 30% (always included for state management)

3. **Context Assembly**:
   - Top 5 most relevant modules
   - Critical rules (high/critical priority)
   - Architecture patterns
   - Implementation guidelines

4. **Token Optimization**: Keeps context under 8K tokens
   - Only key symbols (top 10 per module)
   - Only main files (top 6 per module)
   - Top dependencies (top 5)

### Example Output

For "Add dark mode to Settings screen":
- **Modules**: Features, Theme, Core
- **Files**: SettingsView.swift, Colors.swift, AppState.swift, etc.
- **Rules**: Parameterized Component Pattern, naming conventions
- **Size**: ~830 tokens

## 📝 Configuration

Edit `.context/config.json` to customize:

```json
{
  "project": {
    "name": "ios-template",
    "root_path": "Sources/iOSTemplate"  // Update if needed
  },
  "context_limits": {
    "claude_max_tokens": 8000,  // Max context size
    "cursor_max_tokens": 3000
  },
  "rules": {
    "source_path": ".ai/rules"  // Where to find rules
  }
}
```

## 🔍 Viewing Indexed Data

### View All Modules
```bash
ls -la .context/modules/
cat .context/modules/Features.json
```

### View Master Index
```bash
cat .context/index.json
```

### View Rules
```bash
cat .context/rules.json
```

### View Symbol Cache
```bash
cat .context/cache/symbols.json
```

### View Quick Reference
```bash
cat .context/quick_reference.json
```

## 💡 Best Practices

### When to Re-index

Run `master_indexer.py` when:
- ✅ Added new modules or files
- ✅ Renamed significant files
- ✅ Updated rules in `.ai/rules/`
- ✅ Major architectural changes

No need to re-index for:
- ❌ Small code changes in existing files
- ❌ Adding/modifying comments
- ❌ Changing variable names

### Task Descriptions

**Good task descriptions** (specific, uses project terminology):
- ✅ "Add dark mode toggle to Settings screen"
- ✅ "Implement Firebase authentication in AuthService"
- ✅ "Create reusable Card component following Parameterized Pattern"
- ✅ "Fix navigation bug in Home tab"

**Poor task descriptions** (too vague):
- ❌ "Make it better"
- ❌ "Fix bug"
- ❌ "Add feature"

### Using Context with Claude

1. Generate context: `python3 .context/scripts/generate_claude_context.py "your task"`
2. Review context: `cat .context/generated/.claude_context.md`
3. Copy to Claude
4. Add any specific requirements
5. Start coding!

The context already includes:
- Project architecture
- Relevant files
- Critical rules
- Implementation guidelines

## 🔧 Troubleshooting

### Error: "Source directory not found"

Update `root_path` in `.context/config.json`:
```json
{
  "project": {
    "root_path": "Sources/iOSTemplate"  // Adjust to your actual path
  }
}
```

### No rules found

Check that `.ai/rules/` directory exists and contains .md files.

If your rules are elsewhere, update in `config.json`:
```json
{
  "rules": {
    "source_path": "path/to/your/rules"
  }
}
```

### Context too large

Reduce max tokens in `config.json`:
```json
{
  "context_limits": {
    "claude_max_tokens": 6000  // Reduce from 8000
  }
}
```

### Module not detected

Ensure module folder name matches one in `config.json`:
```json
{
  "modules": [
    "Core",
    "Features",
    "Services",
    // Add your module here
  ]
}
```

## 📈 Performance

- **Indexing**: 0.07s for 74 files (13K LOC)
- **Context Generation**: ~0.1s per task
- **Storage**: ~500KB for all indexed data
- **Memory**: Minimal (JSON files)

## 🎉 Success Metrics

From ios-template project:
- ✅ Token reduction: 70-85%
- ✅ Context accuracy: High (correctly identifies relevant modules)
- ✅ Speed: Sub-second for all operations
- ✅ Zero external dependencies

## 🚀 Next Steps

### Phase 2 Features (Future)

1. **Cursor Integration**
   - `sync_cursorrules.py`: Auto-update `.cursorrules`
   - Keep Cursor in sync with latest rules

2. **Git Hooks**
   - `incremental_update.py`: Re-index changed files
   - Auto-update after commits

3. **Advanced Features**
   - Symbol search
   - Cross-reference analysis
   - Code similarity detection

### Contributing

To extend Context Hub:
1. Add new scripts to `.context/scripts/`
2. Update `config.json` with new settings
3. Run tests

## 📚 Files Reference

### Core Scripts

- **`scanner.py`**: Scans Swift files, extracts symbols, creates module index
- **`rules_indexer.py`**: Parses `.ai/rules/`, extracts coding conventions
- **`master_indexer.py`**: Orchestrates full indexing (runs all indexers)
- **`generate_claude_context.py`**: Generates filtered context for Claude

### Data Files

- **`index.json`**: Master index with project stats
- **`rules.json`**: All coding rules categorized by priority
- **`patterns.json`**: Architectural patterns
- **`quick_reference.json`**: Quick reference for top rules
- **`modules/*.json`**: Per-module data (files, symbols, dependencies)
- **`cache/symbols.json`**: Symbol → file mapping

### Generated Files

- **`.claude_context.md`**: Generated context for Claude (recreated each time)

---

**Built with ❤️ for efficient AI-assisted iOS development**

*Context Hub v1.0 - Local, Fast, Simple*
