#!/usr/bin/env python3
"""
Rules Indexer - Extract và organize rules từ .ai/rules/
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

class RulesIndexer:
    def __init__(self, config_path: str = ".context/config.json"):
        """Khởi tạo rules indexer"""
        self.config_path = Path(config_path)
        self.config = self.load_config()
        self.project_root = Path.cwd()
        self.rules_path = self.project_root / self.config['rules']['source_path']

    def load_config(self) -> dict:
        """Load configuration"""
        with open(self.config_path, 'r') as f:
            return json.load(f)

    def parse_markdown_rule(self, content: str) -> List[dict]:
        """Parse rules từ markdown content"""
        rules = []
        current_category = "general"
        current_priority = "medium"

        lines = content.split('\n')

        for line in lines:
            line = line.strip()

            # Skip empty lines
            if not line:
                continue

            # Detect category headers (## Header)
            if line.startswith('##'):
                current_category = line.replace('#', '').strip().lower()
                continue

            # Detect priority markers
            if 'CRITICAL' in line or 'MUST' in line:
                current_priority = 'critical'
            elif 'IMPORTANT' in line or 'SHOULD' in line:
                current_priority = 'high'
            elif 'OPTIONAL' in line or 'NICE TO HAVE' in line:
                current_priority = 'low'

            # Detect rules (lines starting with -, *, or numbered)
            if re.match(r'^[-*•]|\d+\.', line):
                # Extract rule text
                rule_text = re.sub(r'^[-*•]|\d+\.', '', line).strip()

                if rule_text and len(rule_text) > 10:  # Skip very short lines
                    rules.append({
                        'text': rule_text,
                        'category': current_category,
                        'priority': current_priority,
                        'source_file': None  # Will be set by caller
                    })

            # Also capture rules in code blocks
            elif line.startswith('`') and line.endswith('`'):
                rule_text = line.strip('`')
                if len(rule_text) > 10:  # Skip very short code snippets
                    rules.append({
                        'text': f"Code pattern: {rule_text}",
                        'category': current_category,
                        'priority': current_priority,
                        'source_file': None
                    })

        return rules

    def extract_patterns(self, content: str) -> List[dict]:
        """Extract architectural patterns từ content"""
        patterns = []

        # Look for pattern definitions
        pattern_keywords = [
            'pattern', 'architecture', 'structure', 'design',
            'approach', 'strategy', 'methodology'
        ]

        lines = content.split('\n')
        for i, line in enumerate(lines):
            line_lower = line.lower()

            # Check if line contains pattern keywords
            if any(keyword in line_lower for keyword in pattern_keywords):
                # Get context (current line + next 2 lines)
                context_lines = []
                for j in range(i, min(i + 3, len(lines))):
                    if lines[j].strip():
                        context_lines.append(lines[j].strip())

                if context_lines:
                    pattern_text = ' '.join(context_lines)
                    if len(pattern_text) > 20 and len(pattern_text) < 500:
                        patterns.append({
                            'description': pattern_text[:200],  # Limit length
                            'category': self.categorize_pattern(pattern_text)
                        })

        return patterns

    def categorize_pattern(self, text: str) -> str:
        """Categorize architectural pattern"""
        text_lower = text.lower()

        if 'component' in text_lower:
            return 'component'
        elif 'navigation' in text_lower or 'routing' in text_lower:
            return 'navigation'
        elif 'state' in text_lower or 'reducer' in text_lower:
            return 'state-management'
        elif 'network' in text_lower or 'api' in text_lower:
            return 'networking'
        elif 'storage' in text_lower or 'database' in text_lower:
            return 'persistence'
        else:
            return 'general'

    def process_rules_file(self, file_path: Path) -> Tuple[List[dict], List[dict]]:
        """Process một rule file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract rules và patterns
            rules = self.parse_markdown_rule(content)
            patterns = self.extract_patterns(content)

            # Add source file to rules
            for rule in rules:
                rule['source_file'] = file_path.name

            return rules, patterns

        except Exception as e:
            print(f"⚠️ Error processing {file_path}: {e}")
            return [], []

    def index_all_rules(self) -> Tuple[dict, dict]:
        """Index tất cả rules files"""
        print(f"🔍 Scanning rules từ: {self.rules_path}")

        all_rules = {
            'critical': [],
            'high': [],
            'medium': [],
            'low': []
        }

        all_patterns = {}

        # Check if rules directory exists
        if not self.rules_path.exists():
            print(f"⚠️ Rules directory không tồn tại: {self.rules_path}")
            return all_rules, all_patterns

        # Find all markdown files
        rule_files = list(self.rules_path.glob("*.md"))
        print(f"📄 Found {len(rule_files)} rule files")

        for file_path in rule_files:
            rules, patterns = self.process_rules_file(file_path)

            # Categorize rules by priority
            for rule in rules:
                priority = rule['priority']
                all_rules[priority].append(rule)

            # Group patterns by category
            for pattern in patterns:
                category = pattern['category']
                if category not in all_patterns:
                    all_patterns[category] = []
                all_patterns[category].append(pattern['description'])

        # Remove duplicates and limit counts
        for priority in all_rules:
            # Remove duplicate rules
            unique_rules = []
            seen = set()
            for rule in all_rules[priority]:
                rule_key = rule['text'][:50]  # Use first 50 chars as key
                if rule_key not in seen:
                    seen.add(rule_key)
                    unique_rules.append(rule)
            all_rules[priority] = unique_rules[:20]  # Max 20 rules per priority

        return all_rules, all_patterns

    def save_rules(self, rules: dict, patterns: dict):
        """Save rules and patterns to JSON"""
        # Save rules
        rules_output = Path(".context/rules.json")
        with open(rules_output, 'w') as f:
            json.dump(rules, f, indent=2)

        total_rules = sum(len(rules[p]) for p in rules)
        print(f"✅ Saved {total_rules} rules to rules.json")

        # Save patterns
        patterns_output = Path(".context/patterns.json")
        with open(patterns_output, 'w') as f:
            json.dump(patterns, f, indent=2)

        total_patterns = sum(len(patterns[c]) for c in patterns)
        print(f"✅ Saved {total_patterns} patterns to patterns.json")

    def create_quick_reference(self, rules: dict) -> dict:
        """Tạo quick reference cho các rules quan trọng nhất"""
        quick_ref = {
            'top_rules': [],
            'naming_conventions': [],
            'architecture_rules': [],
            'testing_requirements': []
        }

        # Get top critical and high priority rules
        for rule in rules.get('critical', [])[:5]:
            quick_ref['top_rules'].append(rule['text'])

        for rule in rules.get('high', [])[:3]:
            quick_ref['top_rules'].append(rule['text'])

        # Extract specific categories
        all_rules_flat = []
        for priority_rules in rules.values():
            all_rules_flat.extend(priority_rules)

        for rule in all_rules_flat:
            rule_text = rule['text'].lower()

            if 'naming' in rule['category'] or 'name' in rule_text:
                quick_ref['naming_conventions'].append(rule['text'])
            elif 'architecture' in rule['category'] or 'tca' in rule_text:
                quick_ref['architecture_rules'].append(rule['text'])
            elif 'test' in rule['category'] or 'test' in rule_text:
                quick_ref['testing_requirements'].append(rule['text'])

        # Limit each category
        for key in quick_ref:
            quick_ref[key] = quick_ref[key][:5]

        return quick_ref

    def run(self):
        """Main process"""
        print("🚀 Starting rules indexing...")

        # Index all rules
        rules, patterns = self.index_all_rules()

        # Save results
        self.save_rules(rules, patterns)

        # Create quick reference
        quick_ref = self.create_quick_reference(rules)

        # Save quick reference
        quick_ref_path = Path(".context/quick_reference.json")
        with open(quick_ref_path, 'w') as f:
            json.dump(quick_ref, f, indent=2)

        print("✅ Created quick reference")
        print("✨ Rules indexing complete!")

        return rules, patterns


if __name__ == "__main__":
    indexer = RulesIndexer()
    indexer.run()
