#!/usr/bin/env python3
"""
Scanner Module - Quét project iOS và tạo index cho từng module
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple
from datetime import datetime

class ProjectScanner:
    def __init__(self, config_path: str = ".context/config.json"):
        """Khởi tạo scanner với config"""
        self.config_path = Path(config_path)
        self.config = self.load_config()
        self.project_root = Path.cwd()
        self.source_root = self.project_root / self.config['project']['root_path']

    def load_config(self) -> dict:
        """Load configuration file"""
        with open(self.config_path, 'r') as f:
            return json.load(f)

    def should_ignore(self, file_path: Path) -> bool:
        """Kiểm tra xem file có nên bị ignore không"""
        path_str = str(file_path)
        for pattern in self.config['indexing']['ignore_patterns']:
            if pattern.replace('*', '') in path_str:
                return True

        # Check file size
        if file_path.exists():
            size_kb = file_path.stat().st_size / 1024
            if size_kb > self.config['indexing']['max_file_size_kb']:
                return True

        return False

    def extract_symbols(self, content: str) -> Dict[str, List[str]]:
        """Extract classes, structs, enums, protocols từ Swift code"""
        symbols = {
            'classes': [],
            'structs': [],
            'enums': [],
            'protocols': [],
            'extensions': [],
            'functions': []
        }

        # Regex patterns cho Swift
        patterns = {
            'classes': r'(?:public\s+)?(?:final\s+)?class\s+(\w+)',
            'structs': r'(?:public\s+)?struct\s+(\w+)',
            'enums': r'(?:public\s+)?enum\s+(\w+)',
            'protocols': r'protocol\s+(\w+)',
            'extensions': r'extension\s+(\w+)',
            'functions': r'(?:public\s+)?func\s+(\w+)'
        }

        for symbol_type, pattern in patterns.items():
            matches = re.findall(pattern, content)
            symbols[symbol_type] = list(set(matches))  # Remove duplicates

        return symbols

    def extract_imports(self, content: str) -> List[str]:
        """Extract import statements"""
        imports = re.findall(r'import\s+(\w+)', content)
        return list(set(imports))

    def analyze_file(self, file_path: Path) -> dict:
        """Phân tích một file Swift"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract thông tin
            symbols = self.extract_symbols(content)
            imports = self.extract_imports(content)

            # Đếm lines of code (không tính blank lines và comments)
            lines = content.split('\n')
            loc = sum(1 for line in lines
                     if line.strip() and not line.strip().startswith('//'))

            return {
                'path': str(file_path.relative_to(self.project_root)),
                'name': file_path.name,
                'size_bytes': file_path.stat().st_size,
                'loc': loc,
                'symbols': symbols,
                'imports': imports,
                'has_tests': 'XCTest' in imports or '@Test' in content
            }
        except Exception as e:
            print(f"Error analyzing {file_path}: {e}")
            return None

    def identify_module(self, file_path: Path) -> str:
        """Xác định file thuộc module nào"""
        relative_path = file_path.relative_to(self.source_root)
        parts = relative_path.parts

        if len(parts) > 0:
            # Module name là folder đầu tiên trong source
            module_name = parts[0]
            # Kiểm tra xem có trong list modules không
            if module_name in self.config['modules']:
                return module_name

        # Default module cho files không thuộc module cụ thể
        return "Misc"

    def scan_project(self) -> Tuple[Dict[str, dict], dict]:
        """Quét toàn bộ project"""
        print(f"🔍 Scanning project từ: {self.source_root}")

        modules = {}
        all_symbols = {}  # Map symbol -> file path

        # Tìm tất cả Swift files
        swift_files = list(self.source_root.rglob("*.swift"))
        print(f"📁 Tìm thấy {len(swift_files)} Swift files")

        for file_path in swift_files:
            # Skip ignored files
            if self.should_ignore(file_path):
                continue

            # Phân tích file
            file_info = self.analyze_file(file_path)
            if not file_info:
                continue

            # Xác định module
            module_name = self.identify_module(file_path)

            # Thêm vào module tương ứng
            if module_name not in modules:
                modules[module_name] = {
                    'name': module_name,
                    'files': [],
                    'total_loc': 0,
                    'key_symbols': [],
                    'dependencies': set()
                }

            modules[module_name]['files'].append(file_info)
            modules[module_name]['total_loc'] += file_info['loc']

            # Thêm symbols
            for symbol_type, symbols in file_info['symbols'].items():
                for symbol in symbols:
                    modules[module_name]['key_symbols'].append(f"{symbol_type[:-1]}:{symbol}")
                    all_symbols[symbol] = file_info['path']

            # Thêm dependencies
            modules[module_name]['dependencies'].update(file_info['imports'])

        # Convert sets to lists cho JSON serialization
        for module in modules.values():
            module['dependencies'] = list(module['dependencies'])
            module['key_symbols'] = list(set(module['key_symbols']))[:20]  # Limit 20 symbols

        return modules, all_symbols

    def get_module_purpose(self, module_name: str) -> str:
        """Mô tả purpose của module"""
        purposes = {
            'Core': 'TCA foundation - State, Actions, Reducers, Store, ViewConfigs',
            'Features': 'UI features - Onboarding, Auth, Settings, Home, Profile',
            'Services': 'Business logic và external services integrations',
            'Theme': 'UI theming - Colors, Typography, Spacing, Component styles',
            'Network': 'API clients và networking layer',
            'Storage': 'Data persistence - UserDefaults, Keychain, FileStorage',
            'Monetization': 'IAP, AdMob, Revenue tracking, Analytics',
            'Utilities': 'Helper functions, extensions, utilities',
            'Misc': 'Other files'
        }
        return purposes.get(module_name, 'Miscellaneous files')

    def save_module_data(self, modules: dict):
        """Lưu data của từng module"""
        modules_dir = Path(".context/modules")
        modules_dir.mkdir(parents=True, exist_ok=True)

        for module_name, module_data in modules.items():
            # Tạo summary cho module
            module_summary = {
                'name': module_name,
                'purpose': self.get_module_purpose(module_name),
                'total_files': len(module_data['files']),
                'total_loc': module_data['total_loc'],
                'key_symbols': module_data['key_symbols'][:10],  # Top 10 symbols
                'dependencies': sorted(list(set(module_data['dependencies'])))[:10],
                'files': [f['name'] for f in module_data['files']][:20]  # Top 20 files
            }

            # Lưu file JSON
            output_path = modules_dir / f"{module_name}.json"
            with open(output_path, 'w') as f:
                json.dump(module_summary, f, indent=2)

            print(f"✅ Saved module: {module_name} ({module_summary['total_files']} files, {module_summary['total_loc']} LOC)")

    def save_symbols_cache(self, symbols: dict):
        """Lưu symbol cache để search nhanh"""
        cache_dir = Path(".context/cache")
        cache_dir.mkdir(parents=True, exist_ok=True)

        output_path = cache_dir / "symbols.json"
        with open(output_path, 'w') as f:
            json.dump(symbols, f, indent=2)

        print(f"✅ Saved symbols cache: {len(symbols)} symbols")

    def save_master_index(self, modules: dict):
        """Tạo master index file"""
        index = {
            'project': self.config['project']['name'],
            'architecture': self.config['project']['architecture'],
            'modules': len(modules),
            'module_list': list(modules.keys()),
            'total_files': sum(len(m['files']) for m in modules.values()),
            'total_loc': sum(m['total_loc'] for m in modules.values()),
            'indexed_at': datetime.now().isoformat(),
            'config_version': '1.0'
        }

        output_path = Path(".context/index.json")
        with open(output_path, 'w') as f:
            json.dump(index, f, indent=2)

        print(f"✅ Created master index")
        print(f"📊 Stats: {index['total_files']} files, {index['total_loc']} LOC")

    def run(self):
        """Main scanning process"""
        print("🚀 Starting project scan...")

        # Scan project
        modules, symbols = self.scan_project()

        # Save results
        self.save_module_data(modules)
        self.save_symbols_cache(symbols)
        self.save_master_index(modules)

        print("✨ Scanning complete!")
        return modules


if __name__ == "__main__":
    scanner = ProjectScanner()
    scanner.run()
