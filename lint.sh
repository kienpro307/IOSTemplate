#!/bin/bash

# SwiftLint script cho iOS Template
# Chạy SwiftLint để kiểm tra code style

set -e

echo "🔍 Running SwiftLint..."

# Kiểm tra xem SwiftLint đã được cài đặt chưa
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint chưa được cài đặt."
    echo "📦 Cài đặt SwiftLint: brew install swiftlint"
    exit 1
fi

# Chạy SwiftLint
swiftlint lint --config .swiftlint.yml

echo "✅ SwiftLint completed successfully!"

