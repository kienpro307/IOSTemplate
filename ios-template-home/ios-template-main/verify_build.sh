#!/bin/bash

echo "🔍 Verifying iOS Template Project..."
echo ""

# Check for common syntax errors
echo "1️⃣ Checking for syntax issues..."

# Check for missing imports
echo "   Checking imports..."
missing_imports=0
for file in $(find Sources/iOSTemplate -name "*.swift" -type f); do
    if grep -q "import " "$file"; then
        :
    else
        echo "   ⚠️  No imports in: $file"
        missing_imports=$((missing_imports + 1))
    fi
done

if [ $missing_imports -eq 0 ]; then
    echo "   ✅ All files have proper imports"
else
    echo "   ⚠️  $missing_imports files may need imports"
fi

# Check for unresolved types
echo ""
echo "2️⃣ Checking for common type issues..."

# Check protocol definitions
protocols=(
    "StorageServiceProtocol"
    "SecureStorageProtocol"
    "NetworkServiceProtocol"
    "AuthServiceProtocol"
    "AnalyticsServiceProtocol"
    "CrashlyticsServiceProtocol"
    "RemoteConfigServiceProtocol"
    "PushNotificationServiceProtocol"
    "BiometricAuthenticationServiceProtocol"
    "PermissionManagerProtocol"
    "MediaManagerProtocol"
    "LocalizationManagerProtocol"
)

for protocol in "${protocols[@]}"; do
    if grep -q "public protocol $protocol" Sources/iOSTemplate/Services/ServiceProtocols.swift; then
        echo "   ✅ $protocol defined"
    else
        echo "   ❌ $protocol NOT defined"
    fi
done

# Check theme accessors
echo ""
echo "3️⃣ Checking theme system..."

if grep -q "static var theme: Theme.Type" Sources/iOSTemplate/Theme/Colors.swift; then
    echo "   ✅ Color.theme accessor present"
else
    echo "   ❌ Color.theme accessor missing"
fi

if grep -q "static var theme: Theme.Type" Sources/iOSTemplate/Theme/Typography.swift; then
    echo "   ✅ Font.theme accessor present"
else
    echo "   ❌ Font.theme accessor missing"
fi

# Summary
echo ""
echo "4️⃣ File Statistics:"
swift_files=$(find Sources/iOSTemplate -name "*.swift" -type f | wc -l)
test_files=$(find Tests -name "*.swift" -type f 2>/dev/null | wc -l)
doc_files=$(find docs -name "*.md" -type f 2>/dev/null | wc -l)

echo "   📄 Swift source files: $swift_files"
echo "   🧪 Test files: $test_files"
echo "   📚 Documentation files: $doc_files"

echo ""
echo "5️⃣ Package structure:"
if [ -f "Package.swift" ]; then
    echo "   ✅ Package.swift exists"
else
    echo "   ❌ Package.swift missing"
fi

if [ -d ".github/workflows" ]; then
    workflow_count=$(find .github/workflows -name "*.yml" -type f | wc -l)
    echo "   ✅ GitHub Actions workflows: $workflow_count"
else
    echo "   ⚠️  No GitHub Actions workflows"
fi

if [ -d "fastlane" ]; then
    if [ -f "fastlane/Fastfile" ]; then
        echo "   ✅ Fastlane configured"
    else
        echo "   ⚠️  Fastlane incomplete"
    fi
else
    echo "   ⚠️  No Fastlane"
fi

echo ""
echo "✨ Verification complete!"
