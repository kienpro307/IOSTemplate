# Cài Đặt iOS Template

Hướng dẫn cài đặt chi tiết từ A-Z để bắt đầu với iOS Template.

---

## Mục Lục

- [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
- [Cài Đặt Cơ Bản](#cài-đặt-cơ-bản)
- [Cấu Hình Firebase](#cấu-hình-firebase)
- [Cấu Hình In-App Purchase](#cấu-hình-in-app-purchase)
- [Xác Minh Cài Đặt](#xác-minh-cài-đặt)
- [Troubleshooting](#troubleshooting)

---

## Yêu Cầu Hệ Thống

### Bắt Buộc

| Requirement | Version | Download |
|-------------|---------|----------|
| **macOS** | 13.0+ (Ventura) | - |
| **Xcode** | 15.0+ | [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Swift** | 5.9+ | Đi kèm với Xcode |
| **Git** | 2.0+ | `brew install git` hoặc Xcode Command Line Tools |

### Optional (Khuyến Nghị)

| Tool | Mục đích | Cài đặt |
|------|----------|---------|
| **Homebrew** | Package manager | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| **SwiftLint** | Code linting | `brew install swiftlint` |
| **Sourcery** | Code generation | `brew install sourcery` |

---

## Cài Đặt Cơ Bản

### Bước 1: Clone Repository

```bash
# Clone từ GitHub
git clone https://github.com/your-org/ios-template.git

# Hoặc clone với SSH
git clone git@github.com:your-org/ios-template.git

# Di chuyển vào thư mục project
cd ios-template
```

### Bước 2: Mở Project trong Xcode

```bash
# Mở Xcode project
open IOSTemplate.xcodeproj

# Hoặc mở từ Xcode: File → Open → chọn IOSTemplate.xcodeproj
```

### Bước 3: Resolve Swift Package Dependencies

Xcode sẽ tự động resolve dependencies khi mở project lần đầu.

Nếu không tự động, thực hiện thủ công:

```
Xcode → File → Packages → Resolve Package Versions
```

**Danh sách dependencies sẽ được tải:**
- ✅ ComposableArchitecture (TCA) - v1.15+
- ✅ Moya - v15.0+ (Network layer)
- ✅ Kingfisher - v8.0+ (Image loading)
- ✅ KeychainAccess - v4.2+ (Secure storage)
- ✅ Firebase iOS SDK - v11.0+ (Analytics, Crashlytics, etc.)

> **Lưu ý:** Lần đầu tiên resolve có thể mất 3-5 phút tùy tốc độ mạng.

### Bước 4: Chọn Target và Simulator

1. Chọn target: `IOSTemplate` (không phải test targets)
2. Chọn simulator: `iPhone 15 Pro` hoặc bất kỳ iOS 16.0+ device

```
Xcode → Product → Destination → iPhone 15 Pro
```

### Bước 5: Build Project

```
Xcode → Product → Build (⌘B)
```

Hoặc dùng terminal:

```bash
xcodebuild -scheme IOSTemplate -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**Build thành công khi:**
- ✅ No errors (0 errors)
- ⚠️ Có thể có warnings (ignore được)
- ✅ Status bar hiển thị "Build Succeeded"

---

## Cấu Hình Firebase

Template đã tích hợp Firebase, nhưng bạn cần cấu hình Firebase project riêng.

### Option 1: Sử Dụng Mock Firebase (Nhanh - Cho Development)

Template mặc định sử dụng mock Firebase services. **Không cần làm gì thêm!**

Mock services cho phép:
- ✅ App chạy được ngay không cần Firebase account
- ✅ Tất cả Firebase calls đều return mock data
- ✅ Suitable cho development và testing

### Option 2: Setup Firebase Thật (Cho Production)

#### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** hoặc **"Create a project"**
3. Nhập project name (ví dụ: `MyAwesomeApp`)
4. (Optional) Enable Google Analytics
5. Click **"Create project"**

#### Bước 2: Add iOS App vào Firebase

1. Trong Firebase Console, click **"Add app"** → chọn **iOS**
2. **Bundle ID**: Nhập bundle ID của app (mặc định: `com.template.ios`)
   - Lấy Bundle ID: Xcode → Target → General → Bundle Identifier
3. **App nickname** (optional): Nhập tên dễ nhớ
4. **App Store ID** (optional): Bỏ qua nếu chưa publish
5. Click **"Register app"**

#### Bước 3: Download GoogleService-Info.plist

1. Download file `GoogleService-Info.plist`
2. **Quan trọng:** Kéo thả file vào Xcode project
   - Vị trí: Kéo vào root của project (cùng level với `Sources/`)
   - ✅ Check "Copy items if needed"
   - ✅ Check "Add to targets: IOSTemplate"
3. Click **"Add"**

#### Bước 4: Xác Minh File Đã Được Add

```bash
# Kiểm tra file tồn tại trong project
ls -la | grep GoogleService-Info.plist

# Output mong đợi:
# GoogleService-Info.plist
```

**Trong Xcode:**
- File hiển thị trong Project Navigator (sidebar trái)
- File có icon plist (màu xanh lá)

#### Bước 5: Enable Firebase Services

Trong Firebase Console, enable các services cần thiết:

| Service | Enable Tại | Cần Cho |
|---------|------------|---------|
| **Analytics** | Analytics → Dashboard | Event tracking |
| **Crashlytics** | Crashlytics → Dashboard | Crash reporting |
| **Cloud Messaging** | Cloud Messaging | Push notifications |
| **Remote Config** | Remote Config | Feature flags |

**Hướng dẫn chi tiết:** Xem [Firebase Setup Guide](../03-TINH-NANG-CO-SAN/04-FIREBASE.md)

---

## Cấu Hình In-App Purchase

Nếu app của bạn cần IAP, follow các bước sau:

### Bước 1: Setup App Store Connect

1. Truy cập [App Store Connect](https://appstoreconnect.apple.com)
2. Tạo app mới (nếu chưa có)
3. Vào **App Store → In-App Purchases**

### Bước 2: Tạo IAP Products

Tạo các sản phẩm IAP cần thiết:

```
Ví dụ Product IDs:
- com.yourapp.premium.monthly
- com.yourapp.premium.yearly
- com.yourapp.consumable.coins_100
```

### Bước 3: Cập Nhật Product IDs trong Code

Mở file `Sources/Services/Payment/IAPProduct.swift`:

```swift
public enum IAPProduct: String, CaseIterable {
    // Subscription products
    case premiumMonthly = "com.yourapp.premium.monthly"
    case premiumYearly = "com.yourapp.premium.yearly"
    
    // Consumable products
    case coins100 = "com.yourapp.consumable.coins_100"
    case coins500 = "com.yourapp.consumable.coins_500"
    
    // Non-consumable products
    case removeAds = "com.yourapp.premium.remove_ads"
}
```

### Bước 4: Test IAP với Sandbox Account

1. Tạo sandbox tester account trên App Store Connect
2. Settings → Users and Access → Sandbox Testers → Add Tester
3. Test IAP trên device/simulator với sandbox account

**Hướng dẫn chi tiết:** Xem [IAP Setup Guide](../03-TINH-NANG-CO-SAN/03-IAP.md)

---

## Xác Minh Cài Đặt

### Checklist

Run qua checklist này để đảm bảo setup đúng:

- [ ] **Xcode mở được project** (`IOSTemplate.xcodeproj`)
- [ ] **Dependencies resolved thành công** (không có package errors)
- [ ] **Build thành công** (⌘B không lỗi)
- [ ] **Run được trên simulator** (⌘R app launch được)
- [ ] **Onboarding hiển thị** (lần đầu chạy sẽ thấy onboarding)
- [ ] **Tab navigation hoạt động** (switch giữa Home, Search, Notifications, Settings)
- [ ] **Settings screen hoạt động** (theme toggle, language, etc.)

### Test Commands

```bash
# Build project
xcodebuild -scheme IOSTemplate -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Run tests
xcodebuild -scheme IOSTemplate -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

# Run SwiftLint (nếu đã cài)
swiftlint

# Hoặc dùng script có sẵn
./lint.sh
```

**Expected Output:**
```
✅ Build Succeeded
✅ Tests Passed (if running tests)
⚠️ SwiftLint: 0 errors, X warnings
```

---

## Troubleshooting

### Lỗi Thường Gặp

#### 1. "No such module 'ComposableArchitecture'"

**Nguyên nhân:** SPM dependencies chưa được resolve.

**Giải pháp:**
```bash
# Trong Xcode
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions

# Hoặc xóa derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### 2. "Build Failed" với Firebase errors

**Nguyên nhân:** 
- `GoogleService-Info.plist` chưa được add vào target
- File bị corrupt

**Giải pháp:**
```bash
# Kiểm tra file tồn tại
ls -la GoogleService-Info.plist

# Re-add file vào Xcode
# 1. Xóa file khỏi project (Keep in Finder)
# 2. Kéo thả lại với "Copy items if needed" checked
```

#### 3. "Could not find module 'Firebase' for target 'IOSTemplate'"

**Nguyên nhân:** Firebase SDK chưa được link vào target.

**Giải pháp:**
```bash
# Check Package.swift có đúng dependencies không
# Target IOSTemplate phải có:
dependencies: [
    "Core",
    "UI", 
    "Services",
    "Features",
]
```

#### 4. Simulator không khởi động được

**Nguyên nhân:** 
- Simulator crash
- Device không compatible

**Giải pháp:**
```bash
# Reset simulator
xcrun simctl erase all

# Hoặc chọn simulator khác
Xcode → Product → Destination → [chọn device khác]
```

#### 5. Code signing errors

**Nguyên nhân:** Development team chưa được set.

**Giải pháp:**
```
1. Xcode → Target → Signing & Capabilities
2. Team → Select your Apple ID
3. Bundle Identifier → Đổi thành unique ID (com.yourcompany.appname)
```

### Lỗi Khác

Nếu gặp lỗi không có trong list trên:

1. **Clean Build Folder**: ⌘⇧K (Shift + Command + K)
2. **Quit Xcode** và mở lại
3. **Reset Package Caches**
4. **Delete Derived Data**

```bash
# Script tổng hợp để reset everything
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build
xcodebuild clean
```

---

## Các Bước Tiếp Theo

Sau khi cài đặt thành công:

1. ✅ [Hiểu Cấu Trúc Dự Án](02-CAU-TRUC-DU-AN.md) - Tìm hiểu folder structure
2. ✅ [Chạy Thử App](03-CHAY-THU.md) - Build và test app
3. ✅ [Đổi Tên App](../04-CUSTOMIZE/01-DOI-TEN-APP.md) - Customize cho project của bạn
4. ✅ [Tạo Feature Đầu Tiên](../02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md) - Learn TCA workflow

---

## Xem Thêm

- [Cấu Trúc Dự Án](02-CAU-TRUC-DU-AN.md)
- [Chạy Thử & Troubleshooting](03-CHAY-THU.md)
- [Firebase Setup Chi Tiết](../03-TINH-NANG-CO-SAN/04-FIREBASE.md)
- [IAP Setup Chi Tiết](../03-TINH-NANG-CO-SAN/03-IAP.md)
- [FAQ](../05-THAM-KHAO/03-FAQ.md)

---

**Chúc mừng! 🎉** Bạn đã setup xong iOS Template. Happy coding! 🚀

