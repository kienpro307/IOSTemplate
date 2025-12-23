# Phase 9 Build Troubleshooting Checklist

## ✅ Verification Steps

### 1. Check File Structure
```bash
# All Phase 9 files should exist:
ls -la Sources/iOSTemplate/Services/Monitoring/
ls -la Sources/iOSTemplate/Services/Maintenance/
ls -la Sources/iOSTemplate/Services/FeatureFlags/
```

**Expected files:**
- ✅ MonitoringDashboardManager.swift
- ✅ AlertConfigurationService.swift
- ✅ MaintenanceManager.swift
- ✅ FeatureIterationManager.swift
- ✅ FeatureFlagManager+Rollout.swift

### 2. Verify All Types Exist

Run this to check all required types:
```bash
grep -r "class FirebaseAnalyticsService" Sources/
grep -r "class FirebaseCrashlyticsService" Sources/
grep -r "class FirebasePerformanceService" Sources/
grep -r "class NotificationManager" Sources/
grep -r "class FeatureFlagManager" Sources/
```

### 3. Check Access Levels

All Phase 9 classes should be `public`:
```bash
grep -n "public final class" Sources/iOSTemplate/Services/Monitoring/*.swift
grep -n "public final class" Sources/iOSTemplate/Services/Maintenance/*.swift
```

### 4. Common Build Errors & Fixes

#### Error: "Cannot find type 'X' in scope"

**Possible causes:**
1. Missing import (though usually not needed in same module)
2. File not included in target
3. Access level issue

**Fix:**
```bash
# Check if file is in Package.swift target
grep -A 20 "name: \"iOSTemplate\"" Package.swift
```

#### Error: "Value of protocol type cannot conform to protocol"

**Fix:** Check that you're using the concrete type, not protocol:
```swift
// ✅ Correct
private let analytics: AnalyticsServiceProtocol

// ❌ Wrong
private let analytics: AnalyticsServiceProtocol.Type
```

#### Error: "Ambiguous use of 'X'"

**Fix:** Fully qualify the type:
```swift
// If there's ambiguity
iOSTemplate.MonitoringDashboardManager.shared
```

### 5. Clean Build

If you see phantom errors:
```bash
# In Xcode
# 1. Product → Clean Build Folder (⇧⌘K)
# 2. Close Xcode
# 3. Delete derived data:
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# 4. Reopen Xcode
# 5. Product → Build (⌘B)
```

### 6. Check for Circular Dependencies

Phase 9 dependency chain:
```
MonitoringDashboardManager
  → FirebaseCrashlyticsService
  → FirebaseAnalyticsService
  → FirebasePerformanceService

AlertConfigurationService
  → AnalyticsServiceProtocol
  → CrashlyticsServiceProtocol
  → NotificationManager

MaintenanceManager
  → AnalyticsServiceProtocol
  → CrashlyticsServiceProtocol

FeatureIterationManager
  → AnalyticsServiceProtocol
  → CrashlyticsServiceProtocol
  → RemoteConfigServiceProtocol
  → FeatureFlagManager
```

No circular dependencies detected ✅

### 7. Verify Protocol Conformance

Check that all service implementations conform to protocols:
```bash
# FirebaseAnalyticsService should conform to AnalyticsServiceProtocol
grep "AnalyticsServiceProtocol" Sources/iOSTemplate/Services/Firebase/FirebaseAnalyticsService.swift

# FirebaseCrashlyticsService should conform to CrashlyticsServiceProtocol
grep "CrashlyticsServiceProtocol" Sources/iOSTemplate/Services/Firebase/FirebaseCrashlyticsService.swift
```

### 8. Test-Specific Issues

If tests fail to compile:
```bash
# Check test target includes all necessary files
grep -A 10 "testTarget" Package.swift
```

Test files should have `@testable import iOSTemplate`

## 🔍 Get Specific Error Info

If none of the above help, get the exact error:

### Method 1: Xcode
1. Open project in Xcode
2. Product → Build (⌘B)
3. Click on error in Issue Navigator
4. Copy full error message

### Method 2: Command Line
```bash
cd App/iOSTemplateApp
xcodebuild -scheme iOSTemplateApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build 2>&1 | grep "error:"
```

### Method 3: Swift Package
```bash
# From project root
swift build 2>&1 | tee /tmp/build.log
# Then check /tmp/build.log for errors
```

## 📝 Common Error Patterns

### Pattern 1: Missing Type
```
Error: Cannot find type 'MonitoringDashboardManager' in scope
```
**Fix:** Check file exists and is in correct location

### Pattern 2: Access Level
```
Error: 'MonitoringDashboardManager' initializer is inaccessible due to 'internal' protection level
```
**Fix:** Ensure class and init are `public`

### Pattern 3: Protocol Mismatch
```
Error: Type 'FirebaseAnalyticsService' does not conform to protocol 'AnalyticsServiceProtocol'
```
**Fix:** Check protocol method signatures match

### Pattern 4: Async/Await
```
Error: Expression is 'async' but is not marked with 'await'
```
**Fix:** Add `await` or remove `async` from function

## 🆘 If Still Stuck

Provide these details:
1. **Exact error message** (full text from Xcode)
2. **Which file** has the error
3. **Line number** of error
4. **Xcode version** you're using
5. **Swift version**: `swift --version`

This will help pinpoint the exact issue!
