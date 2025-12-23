#!/usr/bin/env python3
"""
Claude Context Generator - Tạo context tối ưu cho Claude dựa trên task
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List
from datetime import datetime

class ClaudeContextGenerator:
    def __init__(self):
        """Initialize context generator"""
        self.context_dir = Path(".context")
        self.config = self.load_config()
        self.max_tokens = self.config['context_limits']['claude_max_tokens']

    def load_config(self) -> dict:
        """Load configuration"""
        config_path = self.context_dir / "config.json"
        with open(config_path, 'r') as f:
            return json.load(f)

    def load_index(self) -> dict:
        """Load master index"""
        index_path = self.context_dir / "index.json"
        if index_path.exists():
            with open(index_path, 'r') as f:
                return json.load(f)
        return {}

    def analyze_task(self, task_description: str) -> Dict[str, float]:
        """Phân tích task để xác định relevant modules"""
        task_lower = task_description.lower()

        # Keywords map to modules
        module_keywords = {
            'Core': ['state', 'reducer', 'action', 'store', 'tca', 'architecture', 'config'],
            'Features': ['screen', 'view', 'feature', 'user interface', 'ui', 'page', 'onboarding', 'auth', 'settings', 'home', 'profile'],
            'Services': ['service', 'api', 'business', 'logic', 'manager', 'firebase', 'analytics'],
            'Theme': ['theme', 'color', 'style', 'dark mode', 'typography', 'design', 'spacing'],
            'Network': ['network', 'api', 'request', 'http', 'endpoint', 'fetch', 'moya'],
            'Storage': ['storage', 'database', 'cache', 'persist', 'save', 'keychain', 'userdefaults'],
            'Monetization': ['iap', 'purchase', 'subscription', 'admob', 'ads', 'revenue', 'appsflyer'],
            'Utilities': ['extension', 'helper', 'utility', 'util', 'common']
        }

        # Calculate relevance scores
        relevance_scores = {}

        for module, keywords in module_keywords.items():
            score = sum(1 for keyword in keywords if keyword in task_lower)
            if score > 0:
                relevance_scores[module] = score / len(keywords)

        # Normalize scores
        if relevance_scores:
            max_score = max(relevance_scores.values())
            relevance_scores = {k: v/max_score for k, v in relevance_scores.items()}

        # Always include Core if any module is relevant
        if relevance_scores and 'Core' not in relevance_scores:
            relevance_scores['Core'] = 0.3

        return relevance_scores

    def load_module_data(self, module_name: str) -> dict:
        """Load module data from JSON"""
        module_path = self.context_dir / "modules" / f"{module_name}.json"
        if module_path.exists():
            with open(module_path, 'r') as f:
                return json.load(f)
        return {}

    def load_rules(self, priority_levels: List[str] = ['critical', 'high']) -> List[dict]:
        """Load relevant rules"""
        rules_path = self.context_dir / "rules.json"
        if not rules_path.exists():
            return []

        with open(rules_path, 'r') as f:
            all_rules = json.load(f)

        relevant_rules = []
        for priority in priority_levels:
            if priority in all_rules:
                relevant_rules.extend(all_rules[priority][:5])  # Top 5 per priority

        return relevant_rules

    def load_patterns(self) -> dict:
        """Load architectural patterns"""
        patterns_path = self.context_dir / "patterns.json"
        if not patterns_path.exists():
            return {}

        with open(patterns_path, 'r') as f:
            return json.load(f)

    def estimate_tokens(self, text: str) -> int:
        """Estimate token count (rough approximation)"""
        # Rough estimate: 1 token ≈ 4 characters
        return len(text) // 4

    def generate_context(self, task_description: str) -> str:
        """Generate complete context for Claude"""
        print(f"\n🎯 Analyzing task: {task_description}")

        # Analyze task
        relevance_scores = self.analyze_task(task_description)

        if not relevance_scores:
            print("⚠️ Could not determine relevant modules. Using general context.")
            relevance_scores = {'Core': 1.0, 'Features': 0.5}

        # Sort modules by relevance
        relevant_modules = sorted(relevance_scores.items(), key=lambda x: x[1], reverse=True)

        print(f"📊 Relevant modules: {', '.join([f'{m} ({s:.0%})' for m, s in relevant_modules[:5]])}")

        # Build context
        context_parts = []

        # 1. Header
        context_parts.append(f"""# 🎯 CONTEXT FOR TASK

**Task**: {task_description}

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}

---

## 📱 Project Overview

- **Name**: ios-template
- **Architecture**: TCA (The Composable Architecture) + Parameterized Component Pattern
- **UI Framework**: SwiftUI
- **iOS Target**: 16.0+
- **Language**: Swift 5.9+

### Key Architectural Pattern: Parameterized Component

This project uses a unique pattern where:
- **Components** = View + Config
- Views are pure rendering (NO hardcoded values)
- Configs contain all customization (data, callbacks, styling)
- Enables one template for multiple apps without forking

Example:
```swift
// Config
struct OnboardingConfig {{
    let pages: [Page]
    let onComplete: () -> Void
}}

// View
struct OnboardingView: View {{
    let config: OnboardingConfig
    // Uses config for everything
}}
```

---

""")

        # 2. Relevant Modules
        context_parts.append("## 📦 Relevant Modules\n\n")

        token_count = self.estimate_tokens(context_parts[0])

        for module_name, score in relevant_modules[:5]:  # Top 5 modules
            if token_count > self.max_tokens * 0.6:  # Leave room for rules
                break

            module_data = self.load_module_data(module_name)
            if module_data:
                module_section = f"""### {module_name} (Relevance: {score:.0%})

**Purpose**: {module_data.get('purpose', 'N/A')}

**Statistics**:
- Files: {module_data.get('total_files', 0)}
- Lines of Code: {module_data.get('total_loc', 0):,}

**Key Symbols**:
{', '.join(module_data.get('key_symbols', [])[:8])}

**Dependencies**: {', '.join(module_data.get('dependencies', [])[:5]) or 'None'}

**Main Files**:
{chr(10).join(f'- {f}' for f in module_data.get('files', [])[:6])}

"""
                context_parts.append(module_section)
                token_count += self.estimate_tokens(module_section)

        # 3. Critical Rules
        context_parts.append("\n---\n\n## ⚠️ CRITICAL RULES\n\n")

        rules = self.load_rules(['critical', 'high'])
        for i, rule in enumerate(rules[:12], 1):  # Top 12 rules
            if token_count > self.max_tokens * 0.85:
                break

            rule_text = f"{i}. **[{rule['priority'].upper()}]** {rule['text']}\n\n"
            context_parts.append(rule_text)
            token_count += self.estimate_tokens(rule_text)

        # 4. Quick Reference
        quick_ref_path = self.context_dir / "quick_reference.json"
        if quick_ref_path.exists() and token_count < self.max_tokens * 0.9:
            with open(quick_ref_path, 'r') as f:
                quick_ref = json.load(f)

            context_parts.append("\n---\n\n## ⚡ Quick Reference\n\n")

            if 'top_rules' in quick_ref and quick_ref['top_rules']:
                context_parts.append("**Most Important Rules**:\n")
                for rule in quick_ref['top_rules'][:5]:
                    context_parts.append(f"- {rule}\n")

        # 5. Instructions
        context_parts.append(f"""

---

## 💡 Instructions for Implementation

**Your Task**: {task_description}

**Follow These Guidelines**:

1. **TCA Architecture**: Use State → Action → Reducer → Effect pattern
2. **Parameterized Components**: NO hardcoded values in Views
   - Create Config object in `Core/ViewConfigs/`
   - Implement View in `Features/`
3. **SwiftUI Best Practices**: Use @ObservableState, proper state management
4. **Error Handling**: Add appropriate error handling and validation
5. **Testing**: Consider test coverage (target: 80%+)

**File Organization**:
- Configs → `Sources/iOSTemplate/Core/ViewConfigs/`
- Views → `Sources/iOSTemplate/Features/`
- Reducers → `Sources/iOSTemplate/Core/`
- Services → `Sources/iOSTemplate/Services/`

**Estimated Context Size**: ~{token_count:,} tokens

---

*Context generated by Context Hub v1.0*
""")

        # Combine all parts
        full_context = ''.join(context_parts)

        return full_context

    def save_context(self, context: str):
        """Save generated context"""
        output_dir = self.context_dir / "generated"
        output_dir.mkdir(exist_ok=True)

        output_path = output_dir / ".claude_context.md"

        # Backup existing if exists
        if output_path.exists():
            backup_path = output_dir / ".claude_context.md.bak"
            output_path.rename(backup_path)
            print(f"📦 Backed up previous context")

        # Save new context
        with open(output_path, 'w') as f:
            f.write(context)

        print(f"✅ Context saved to: {output_path}")
        print(f"📏 Size: {len(context):,} chars (~{self.estimate_tokens(context):,} tokens)")

        return output_path

    def interactive_mode(self):
        """Interactive mode for generating context"""
        print("\n" + "=" * 60)
        print("🤖 CLAUDE CONTEXT GENERATOR")
        print("=" * 60)

        print("\n📝 Enter task description (or 'quit' to exit):")
        print("\nExamples:")
        print("  - Add dark mode toggle to Settings screen")
        print("  - Implement user authentication with Firebase")
        print("  - Create reusable card component")
        print("  - Fix navigation issue in Home tab")

        while True:
            print("\n> ", end="")
            task = input().strip()

            if task.lower() in ['quit', 'exit', 'q']:
                print("👋 Goodbye!")
                break

            if not task:
                print("⚠️ Please enter a task description")
                continue

            # Generate context
            context = self.generate_context(task)

            # Save context
            output_path = self.save_context(context)

            # Show preview
            lines = context.split('\n')
            preview_lines = min(30, len(lines))

            print(f"\n📄 Context Preview (first {preview_lines} lines):")
            print("-" * 60)
            print('\n'.join(lines[:preview_lines]))
            print("...")
            print("-" * 60)

            print(f"\n✅ Full context saved to: {output_path}")
            print("📋 Copy the content and paste into Claude!")

            print("\n🔄 Generate another? (Enter new task or 'quit')")


def main():
    """Entry point"""
    import sys

    generator = ClaudeContextGenerator()

    # Check if task provided as argument
    if len(sys.argv) > 1:
        task = ' '.join(sys.argv[1:])
        context = generator.generate_context(task)
        output_path = generator.save_context(context)

        print(f"\n📋 Context ready! Next steps:")
        print(f"   1. cat {output_path}")
        print(f"   2. Copy content to Claude")
        print(f"   3. Add your task and start coding!")
    else:
        # Interactive mode
        generator.interactive_mode()


if __name__ == "__main__":
    main()
