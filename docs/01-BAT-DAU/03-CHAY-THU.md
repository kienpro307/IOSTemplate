# Chạy Thử & Troubleshooting

Hướng dẫn build, run và xử lý các lỗi thường gặp.

---

## Mục Lục

- [Build Project](#build-project)
- [Run trên Simulator](#run-trên-simulator)
- [Run trên Device Thật](#run-trên-device-thật)
- [Run Tests](#run-tests)
- [Common Issues](#common-issues)
- [Advanced Troubleshooting](#advanced-troubleshooting)

---

## Build Project

### Trong Xcode

**Cách 1: Keyboard Shortcut (Nhanh nhất)**

```
⌘B (Command + B)
```

**Cách 2: Menu**

```
Xcode → Product → Build
```

**Cách 3: Icon**

Click icon ▶ ở toolbar (nhưng không run)

### Từ Terminal

```bash
# Build với xcodebuild
xcodebuild -scheme IOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# Build với swift build (cho SPM packages)
swift build
```

### Build Settings

**Debug Build (Development):**
- Faster compilation
- Debug symbols included
- No optimization

```bash
xcodebuild -configuration Debug ...
```

**Release Build (Production):**
- Slower compilation
- Optimized binary
- Smaller app size

```bash
xcodebuild -configuration Release ...
```

### Build Output

**Successful Build:**

```
✅ Build Succeeded
⏱️ Duration: 10.5 seconds
📦 Products: IOSTemplate.app
```

**Failed Build:**

```
❌ Build Failed
🔴 2 errors
⚠️ 5 warnings
```

Click vào errors trong Issue Navigator (⌘5) để xem chi tiết.

---

## Run trên Simulator

### Bước 1: Chọn Simulator

```
Xcode → Product → Destination → [Select Simulator]
```

**Simulators khuyến nghị:**
- iPhone 15 Pro (iOS 17+) - Mới nhất
- iPhone 14 Pro (iOS 16+) - Template minimum
- iPhone SE (3rd gen) - Test small screen
- iPad Pro 12.9" - Test tablet

### Bước 2: Run App

**Keyboard Shortcut:**

```
⌘R (Command + R)
```

**Menu:**

```
Xcode → Product → Run
```

### Bước 3: Verify App Running

App sẽ launch với:

1. **Onboarding Flow** (lần đầu chạy)
   - 3 màn hình onboarding
   - "Get Started" button
   
2. **Home Screen** (đã complete onboarding)
   - Tab bar với 4 tabs
   - Welcome card
   - Quick actions
   - Recent activities

### Kiểm Tra Tính Năng

- [ ] **Tab Navigation**: Switch giữa Home, Search, Notifications, Settings
- [ ] **Onboarding**: Swipe qua các pages, click "Get Started"
- [ ] **Settings**: Toggle theme, language, notifications
- [ ] **Pull-to-Refresh**: Kéo xuống ở Home screen
- [ ] **Premium Button**: Click "Premium" trong Settings → IAP screen hiển thị

---

## Run trên Device Thật

### Yêu Cầu

- iPhone/iPad với iOS 16.0+
- USB cable hoặc WiFi debugging enabled
- Apple Developer account (free hoặc paid)

### Bước 1: Connect Device

1. Kết nối iPhone qua USB
2. Trust computer trên iPhone (nếu lần đầu)
3. Xcode sẽ tự detect device

### Bước 2: Code Signing

```
Xcode → Target IOSTemplate → Signing & Capabilities
```

1. **Team**: Select your Apple ID
2. **Bundle Identifier**: Đổi thành unique ID
   ```
   com.yourcompany.iostemplate
   ```
3. Xcode sẽ tự động generate provisioning profile

### Bước 3: Trust Developer

**Lần đầu chạy trên device:**

1. App sẽ không launch (untrusted developer)
2. iPhone → Settings → General → VPN & Device Management
3. Trust developer certificate
4. Return to app và launch lại

### Bước 4: Run

```
⌘R
```

App sẽ install và launch trên device thật.

### Debugging trên Device

```
Xcode → Window → Devices and Simulators → [Your Device]
```

Xem:
- Console logs
- Crash logs
- Installed apps

---

## Run Tests

Template có unit tests cho reducers và business logic.

### Run All Tests

**Keyboard Shortcut:**

```
⌘U (Command + U)
```

**Menu:**

```
Xcode → Product → Test
```

### Run Specific Test

1. Mở test file (ví dụ: `HomeReducerTests.swift`)
2. Click ◇ icon bên cạnh test function
3. Hoặc `Ctrl + Option + Cmd + U`

### Test Structure

```
Tests/
├── CoreTests/
│   └── CoreTests.swift
└── FeaturesTests/
    ├── HomeReducerTests.swift
    ├── SettingsReducerTests.swift
    ├── IAPReducerTests.swift
    └── OnboardingReducerTests.swift
```

### Test Output

**All Pass:**

```
✅ Executed 25 tests, with 0 failures (0 unexpected)
```

**Some Fail:**

```
❌ Executed 25 tests, with 2 failures (2 unexpected)

Failed Tests:
- HomeReducerTests.testLoadData()
- IAPReducerTests.testPurchaseFlow()
```

### Test Coverage

Xem test coverage:

```
Xcode → Product → Test
→ Show Code Coverage (⌘9 → Coverage tab)
```

**Target coverage:** >80% cho business logic reducers.

---

## Common Issues

### 1. Build Errors

#### "No such module 'ComposableArchitecture'"

**Nguyên nhân:** SPM dependencies chưa resolved.

**Giải pháp:**

```bash
# Option 1: Reset Package Caches
Xcode → File → Packages → Reset Package Caches

# Option 2: Resolve Package Versions
Xcode → File → Packages → Resolve Package Versions

# Option 3: Terminal
rm -rf .build
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### "Cannot find 'Store' in scope"

**Nguyên nhân:** Missing import hoặc TCA không resolved.

**Giải pháp:**

```swift
// Thêm import
import ComposableArchitecture
```

#### Multiple errors về Firebase

**Nguyên nhân:** `GoogleService-Info.plist` issue.

**Giải pháp:**

```bash
# Check file tồn tại
ls -la GoogleService-Info.plist

# Re-add vào Xcode với "Copy items if needed"
```

---

### 2. Runtime Errors

#### App Crashes on Launch

**Check Console Logs:**

```
⌘⇧Y (Show Debug Area)
```

**Common causes:**
- Firebase misconfiguration
- Missing dependency
- State initialization error

**Giải pháp:**

```swift
// Add breakpoint tại AppReducer.init()
// Check state initialization
```

#### Onboarding không hiển thị

**Nguyên nhân:** `hasCompletedOnboarding` flag đã set = true.

**Giải pháp:**

```bash
# Reset app data
xcrun simctl erase all

# Hoặc delete app từ simulator và reinstall
```

#### Firebase Analytics không track

**Kiểm tra:**

1. `GoogleService-Info.plist` added?
2. Firebase initialized trong `Main.swift`?
3. Analytics enabled trên Firebase Console?

**Debug:**

```swift
// Enable debug logging
FirebaseApp.configure()
Analytics.setAnalyticsCollectionEnabled(true)
```

---

### 3. Simulator Issues

#### Simulator Không Launch

**Giải pháp:**

```bash
# Kill simulator processes
killall Simulator

# Restart Xcode
```

#### Simulator Chậm/Lag

**Giải pháp:**

1. Close unused apps
2. Restart simulator:
   ```
   Device → Restart
   ```
3. Reset simulator:
   ```bash
   xcrun simctl erase all
   ```

#### "Unable to boot device"

**Giải pháp:**

```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Restart Mac (last resort)
```

---

### 4. Code Signing Issues

#### "Signing for IOSTemplate requires a development team"

**Giải pháp:**

```
1. Xcode → Target → Signing & Capabilities
2. Team → Add Account
3. Sign in với Apple ID
4. Select team
```

#### "Failed to register bundle identifier"

**Nguyên nhân:** Bundle ID conflict.

**Giải pháp:**

```
Change Bundle Identifier to unique:
com.yourcompany.uniquename
```

#### "Provisioning profile doesn't support Capability"

**Giải pháp:**

1. Check capabilities enabled:
   - Push Notifications
   - In-App Purchase
2. Regenerate provisioning profile
3. Download và install

---

### 5. SwiftLint Warnings

#### "Line too long"

**Giải pháp:**

```swift
// Break long lines
let message = "This is a very long message " +
              "that exceeds the line limit"
```

#### "Trailing whitespace"

**Giải pháp:**

```
Xcode → Preferences → Text Editing
→ Check "Automatically trim trailing whitespace"
```

#### Run SwiftLint

```bash
# Run lint
./lint.sh

# Auto-fix some issues
swiftlint --fix
```

---

## Advanced Troubleshooting

### Clean Build Folder

Khi có weird build issues:

```
⌘⇧K (Command + Shift + K)
```

Hoặc:

```
Xcode → Product → Clean Build Folder
```

### Delete Derived Data

Nuclear option - xóa tất cả build artifacts:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Lưu ý:** Build lần sau sẽ lâu hơn.

### Reset Xcode Preferences

Nếu Xcode hoạt động abnormally:

```bash
# Backup first!
mv ~/Library/Preferences/com.apple.dt.Xcode.plist ~/Desktop/

# Restart Xcode
```

### Check Xcode Version

```bash
xcodebuild -version

# Output:
# Xcode 15.0
# Build version 15A240d
```

Template require Xcode 15.0+.

### Check Swift Version

```bash
swift --version

# Output:
# swift-driver version: 1.87.1
# Swift version 5.9
```

Template require Swift 5.9+.

### Enable Debug Logging

Thêm launch arguments:

```
Xcode → Edit Scheme → Run → Arguments
→ Arguments Passed On Launch

Add:
-FIRDebugEnabled        # Firebase debug
-com.apple.CoreData.SQLDebug 1  # CoreData (if using)
```

### Instruments Profiling

Profile performance issues:

```
⌘I (Command + I)

Tools:
- Time Profiler (CPU)
- Allocations (Memory)
- Leaks (Memory leaks)
```

---

## Xác Minh Mọi Thứ Hoạt Động

### Checklist

- [ ] **Build Succeeded** (⌘B không lỗi)
- [ ] **App Launch** (⌘R app mở được)
- [ ] **Onboarding** (lần đầu hiển thị đúng)
- [ ] **Tab Navigation** (switch tabs hoạt động)
- [ ] **Settings** (theme toggle, preferences)
- [ ] **IAP Screen** (Premium button → IAP view)
- [ ] **Pull-to-Refresh** (Home screen refresh)
- [ ] **Tests Pass** (⌘U all green)
- [ ] **No Crashes** (app stable trong 5 phút)
- [ ] **Console Clean** (không có error logs bất thường)

### Performance Metrics

**Expected Performance:**

| Metric | Target | Good | Needs Improvement |
|--------|--------|------|-------------------|
| Build Time | <15s | <30s | >30s |
| Launch Time | <2s | <3s | >3s |
| Memory Usage | <100MB | <150MB | >200MB |
| Frame Rate | 60 FPS | >50 FPS | <50 FPS |

---

## Script Tổng Hợp

Tạo script để automate testing:

```bash
#!/bin/bash
# test.sh

echo "🧹 Cleaning..."
xcodebuild clean

echo "📦 Resolving packages..."
xcodebuild -resolvePackageDependencies

echo "🔨 Building..."
xcodebuild -scheme IOSTemplate -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

echo "🧪 Running tests..."
xcodebuild -scheme IOSTemplate -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

echo "✅ Done!"
```

Run:

```bash
chmod +x test.sh
./test.sh
```

---

## Các Bước Tiếp Theo

Sau khi chạy thành công:

1. ✅ [Tạo Feature Mới](../02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md) - Học TCA workflow
2. ✅ [Đổi Tên App](../04-CUSTOMIZE/01-DOI-TEN-APP.md) - Customize template
3. ✅ [Sử Dụng Services](../02-HUONG-DAN-SU-DUNG/02-SU-DUNG-SERVICES.md) - Network, Storage, Firebase

---

## Xem Thêm

- [Cài Đặt](01-CAI-DAT.md)
- [Cấu Trúc Dự Án](02-CAU-TRUC-DU-AN.md)
- [FAQ](../05-THAM-KHAO/03-FAQ.md)

---

**Tip:** Bookmark trang này! Bạn sẽ quay lại nhiều lần khi gặp issues. 😅

