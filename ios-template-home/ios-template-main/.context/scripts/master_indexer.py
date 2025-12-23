#!/usr/bin/env python3
"""
Master Indexer - Orchestrator để chạy tất cả indexing tasks
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime

class MasterIndexer:
    def __init__(self):
        """Initialize master indexer"""
        self.project_root = Path.cwd()
        self.context_dir = self.project_root / ".context"
        self.scripts_dir = self.context_dir / "scripts"

        # Add scripts directory to path
        sys.path.insert(0, str(self.scripts_dir))

        self.stats = {
            'start_time': datetime.now(),
            'modules_indexed': 0,
            'rules_indexed': 0,
            'files_processed': 0,
            'errors': []
        }

    def check_requirements(self) -> bool:
        """Kiểm tra các requirements cần thiết"""
        print("🔍 Checking requirements...")

        # Check if .context directory exists
        if not self.context_dir.exists():
            print("❌ .context directory not found. Run setup first!")
            return False

        # Check config file
        config_path = self.context_dir / "config.json"
        if not config_path.exists():
            print("❌ config.json not found")
            return False

        # Check if source directory exists
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)

            source_path = self.project_root / config['project']['root_path']
            if not source_path.exists():
                print(f"❌ Source directory not found: {source_path}")
                print(f"   Please update 'root_path' in config.json")
                return False
        except Exception as e:
            print(f"❌ Error reading config: {e}")
            return False

        print("✅ All requirements met")
        return True

    def run_scanner(self) -> bool:
        """Chạy project scanner"""
        print("\n📦 Running Project Scanner...")
        print("-" * 50)

        try:
            # Import và run scanner
            from scanner import ProjectScanner
            scanner = ProjectScanner()
            modules = scanner.run()

            self.stats['modules_indexed'] = len(modules)
            self.stats['files_processed'] = sum(len(m['files']) for m in modules.values())

            print(f"✅ Scanner completed: {self.stats['modules_indexed']} modules")
            return True

        except Exception as e:
            error_msg = f"Scanner failed: {str(e)}"
            print(f"❌ {error_msg}")
            self.stats['errors'].append(error_msg)
            return False

    def run_rules_indexer(self) -> bool:
        """Chạy rules indexer"""
        print("\n📋 Running Rules Indexer...")
        print("-" * 50)

        try:
            # Import và run rules indexer
            from rules_indexer import RulesIndexer
            indexer = RulesIndexer()
            rules, patterns = indexer.run()

            # Count total rules
            total_rules = sum(len(rules[p]) for p in rules)
            self.stats['rules_indexed'] = total_rules

            print(f"✅ Rules indexer completed: {total_rules} rules")
            return True

        except Exception as e:
            error_msg = f"Rules indexer failed: {str(e)}"
            print(f"⚠️ {error_msg}")
            self.stats['errors'].append(error_msg)
            # Not critical - continue anyway
            return True

    def update_master_index(self):
        """Update master index với thông tin mới nhất"""
        print("\n📝 Updating master index...")

        index_path = self.context_dir / "index.json"

        try:
            # Load existing index
            if index_path.exists():
                with open(index_path, 'r') as f:
                    index = json.load(f)
            else:
                index = {}

            # Update với stats mới
            index['last_full_index'] = datetime.now().isoformat()
            index['stats'] = {
                'modules_indexed': self.stats['modules_indexed'],
                'files_processed': self.stats['files_processed'],
                'rules_indexed': self.stats['rules_indexed'],
                'indexing_duration': str(datetime.now() - self.stats['start_time'])
            }

            if self.stats['errors']:
                index['errors'] = self.stats['errors']

            # Save updated index
            with open(index_path, 'w') as f:
                json.dump(index, f, indent=2)

            print("✅ Master index updated")

        except Exception as e:
            print(f"⚠️ Failed to update master index: {e}")

    def generate_summary(self):
        """Generate summary report"""
        duration = datetime.now() - self.stats['start_time']

        print("\n" + "=" * 60)
        print("📊 INDEXING SUMMARY")
        print("=" * 60)
        print(f"✅ Modules indexed: {self.stats['modules_indexed']}")
        print(f"✅ Files processed: {self.stats['files_processed']}")
        print(f"✅ Rules indexed: {self.stats['rules_indexed']}")
        print(f"⏱️ Duration: {duration.total_seconds():.2f} seconds")

        if self.stats['errors']:
            print(f"\n⚠️ Errors encountered: {len(self.stats['errors'])}")
            for error in self.stats['errors']:
                print(f"  - {error}")
        else:
            print("\n🎉 No errors - indexing completed successfully!")

        print("\n📁 Output files created:")
        output_files = [
            ".context/index.json",
            ".context/rules.json",
            ".context/patterns.json",
            ".context/quick_reference.json",
            ".context/modules/*.json",
            ".context/cache/symbols.json"
        ]
        for file in output_files:
            print(f"  ✅ {file}")

        print("\n💡 Next steps:")
        print("  1. Generate context cho Claude:")
        print("     python .context/scripts/generate_claude_context.py 'your task'")
        print("\n  2. Xem các files đã tạo:")
        print("     ls -la .context/modules/")

    def run(self):
        """Main orchestration process"""
        print("🚀 MASTER INDEXER STARTING")
        print("=" * 60)
        print(f"📅 Time: {self.stats['start_time'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"📁 Project: {self.project_root}")
        print("=" * 60)

        # Check requirements
        if not self.check_requirements():
            print("\n❌ Requirements check failed. Exiting...")
            return False

        # Run each indexer in sequence
        success = True

        # 1. Project Scanner (required)
        if not self.run_scanner():
            success = False
            print("\n❌ Critical error in scanner. Stopping...")
            return False

        # 2. Rules Indexer (optional but recommended)
        self.run_rules_indexer()

        # Update master index
        self.update_master_index()

        # Generate summary
        self.generate_summary()

        return success


def main():
    """Entry point"""
    indexer = MasterIndexer()
    success = indexer.run()

    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
