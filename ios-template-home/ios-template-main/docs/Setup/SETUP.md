# 🚀 Hướng Dẫn Setup và Chạy iOS Template Project

## 📋 Yêu Cầu Hệ Thống

### Phần Cứng
- **Mac**: MacBook Air/Pro, iMac, Mac Mini (Apple Silicon hoặc Intel)
- **RAM**: Tối thiểu 8GB (khuyến nghị 16GB+)
- **Dung lượng**: Ít nhất 20GB trống

### Phần Mềm
- **macOS**: Sonoma (14.0) trở lên
- **Xcode**: Version 15.0 trở lên
- **Swift**: 5.9+ (đi kèm Xcode)
- **Git**: Đã cài đặt sẵn trên macOS

### Thiết Bị Test (Optional)
- **iPhone**: iOS 16.0 trở lên
- **Cable**: Lightning/USB-C để kết nối Mac
- **Apple Developer Account**: Miễn phí (để test trên thiết bị thật)

---

## 📥 BƯỚC 1: Cài Đặt Xcode

### 1.1. Download Xcode
```bash
# Cách 1: Từ App Store (Khuyến nghị)
# Mở App Store → Tìm "Xcode" → Click "Get/Download"

# Cách 2: Từ Apple Developer
# https://developer.apple.com/download/
# Download Xcode 15.x.xip
```

### 1.2. Install Command Line Tools
Mở Terminal và chạy:
```bash
xcode-select --install
```

### 1.3. Verify Installation
```bash
# Check Xcode version
xcodebuild -version
# Expected: Xcode 15.0+

# Check Swift version
swift --version
# Expected: Swift 5.9+
```

---

## 📦 BƯỚC 2: Clone Project

### 2.1. Clone Repository
```bash
# Di chuyển đến thư mục làm việc
cd ~/Documents

# Clone project
git clone https://github.com/kienpro307/ios-template.git

# Vào thư mục project
cd ios-template
```

### 2.2. Checkout Branch
```bash
# Xem các branch hiện có
git branch -a

# Checkout branch mới nhất
git checkout claude/help-request-011CV66G6PPfdycAxDBsDAT9
```

---

## 🔧 BƯỚC 3: Mở Project Trong Xcode

### 3.1. Mở Package.swift
```bash
# Cách 1: Từ Terminal
open Package.swift

# Cách 2: Từ Finder
# Double-click vào file Package.swift
# Xcode sẽ tự động mở
```

### 3.2. Xcode Sẽ Tự Động:
- ✅ Resolve Swift Package Dependencies
- ✅ Download TCA, Swinject, Kingfisher, KeychainAccess, Moya
- ✅ Build project structure
- ✅ Index code

**⏱️ Lần đầu mở có thể mất 5-10 phút để download dependencies!**

### 3.3. Kiểm Tra Dependencies
Trong Xcode:
1. Vào **File → Packages → Resolve Package Versions**
2. Đợi cho đến khi status bar hiển thị "Indexing Complete"

---

## 🏗️ BƯỚC 4: Build Project

### 4.1. Chọn Scheme và Destination

**Trên Xcode toolbar:**
1. **Scheme**: Chọn `iOSTemplate` (hoặc tên target của bạn)
2. **Destination**:
   - Simulator: `iPhone 15 Pro` (hoặc bất kỳ iOS 16+ simulator)
   - Real Device: Tên iPhone của bạn (nếu đã kết nối)

### 4.2. Build Project
```bash
# Cách 1: Từ Menu
Product → Build (⌘B)

# Cách 2: Keyboard shortcut
⌘B
```

### 4.3. Kiểm Tra Lỗi
- Nếu build thành công: ✅ "Build Succeeded"
- Nếu có lỗi: Xem trong **Issue Navigator** (⌘4)

**Common Issues:**
```swift
// Nếu thiếu dependencies
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions

// Nếu có lỗi SwiftLint
# Install SwiftLint
brew install swiftlint
```

---

## 📱 BƯỚC 5: Chạy Trên Simulator

### 5.1. Khởi Động Simulator
```bash
# Chọn destination: Any iOS 16+ Simulator
# Click nút Run (▶️) hoặc ⌘R
```

### 5.2. App Sẽ Khởi Động
- Simulator sẽ mở tự động
- App sẽ được install và chạy
- Bạn sẽ thấy màn hình Onboarding/Login

### 5.3. Debug Console
Xem logs trong **Debug Area** (⌘⇧Y):
```
💬 [2024-11-13 15:30:00.123] [AppReducer.swift:45] reduce() - App launched
ℹ️ [2024-11-13 15:30:00.456] [RootView.swift:23] body - Root view appeared
```

---

## 📲 BƯỚC 6: Chạy Trên iPhone Thật

### 6.1. Kết Nối iPhone
1. Cắm iPhone vào Mac bằng cable
2. Mở khóa iPhone
3. Trust computer khi được hỏi:
   ```
   Trust This Computer?
   → Trust
   ```

### 6.2. Add Apple ID vào Xcode

**Lần đầu chạy trên device:**
1. Xcode → **Settings** (⌘,)
2. Chọn tab **Accounts**
3. Click **+** → **Apple ID**
4. Đăng nhập bằng Apple ID của bạn (miễn phí)

### 6.3. Setup Signing & Capabilities

1. Chọn project **iOSTemplate** trong Navigator
2. Chọn target **iOSTemplate**
3. Tab **Signing & Capabilities**
4. Check ✅ **Automatically manage signing**
5. **Team**: Chọn Apple ID của bạn
6. **Bundle Identifier**: Đổi thành unique ID (VD: `com.yourname.iostemplate`)

```
Example:
com.kienpro.iostemplate
com.john.myapp
```

### 6.4. Build và Run
1. Chọn **Destination**: Tên iPhone của bạn
2. Click **Run** (▶️) hoặc ⌘R
3. **LẦN ĐẦU SẼ CÓ LỖI:** "Untrusted Developer"

### 6.5. Trust Developer Certificate (Trên iPhone)

**Trên iPhone:**
1. Mở **Settings** (Cài đặt)
2. Vào **General** (Cài đặt chung)
3. Scroll xuống **VPN & Device Management**
   (hoặc **Profiles & Device Management**)
4. Trong **Developer App**, chọn Apple ID của bạn
5. Tap **Trust "[Your Apple ID]"**
6. Confirm **Trust**

### 6.6. Run Lại Trong Xcode
- Quay lại Xcode
- Click **Run** (▶️) một lần nữa
- App sẽ chạy trên iPhone! 🎉

---

## 🎨 BƯỚC 7: Explore App Features

### 7.1. Onboarding Flow
App sẽ show 3 trang onboarding:
1. **Welcome** - Giới thiệu app
2. **Secure** - Bảo mật
3. **Fast** - Hiệu năng

Nhấn **Get Started** hoặc **Skip**

### 7.2. Login Screen
- Mock login (không cần credentials thật)
- Click **Sign In** để vào app

### 7.3. Main App (4 Tabs)
```
┌─────────────────────────┐
│       Home Tab          │ ← Dashboard với quick actions
├─────────────────────────┤
│     Explore Tab         │ ← Search và discovery
├─────────────────────────┤
│     Profile Tab         │ ← User profile và stats
├─────────────────────────┤
│    Settings Tab         │ ← App settings
└─────────────────────────┘
```

### 7.4. Test Features
- ✅ Switch tabs
- ✅ Dark/Light mode (Settings → Theme)
- ✅ Change language (Settings → Language)
- ✅ View profile stats
- ✅ Test quick actions on Home

---

## 🔍 BƯỚC 8: Debug và Development

### 8.1. Xem Logs
```bash
# Trong Xcode Debug Area (⌘⇧Y)
# Hoặc trong Console app trên Mac
```

### 8.2. SwiftUI Previews
Mở bất kỳ View file nào (VD: `HomeView.swift`):
```swift
#Preview {
    HomeView(store: Store(...))
}
```

Click **Canvas** button (hoặc ⌘⌥⏎) để xem preview

### 8.3. Breakpoints
- Click vào line number để thêm breakpoint (chấm xanh)
- Run app, app sẽ pause tại breakpoint
- Xem variables trong **Variables View**

### 8.4. Memory Graph
- Run app
- Click **Debug Memory Graph** button (⚠️ icon)
- Xem memory allocations và leaks

---

## 📝 BƯỚC 9: Modify Code

### 9.1. Thay Đổi UI
Mở `HomeView.swift`:
```swift
// Thay đổi welcome text
Text("Welcome back,")
    .font(.theme.bodyMedium)

// Thành:
Text("Xin chào,")
    .font(.theme.bodyMedium)
```

Save (⌘S) và run lại (⌘R)

### 9.2. Thay Đổi Colors
Mở `Colors.swift`:
```swift
// Thay đổi primary color
public static let primary = Color("Primary", bundle: .module)

// Hoặc hardcode:
public static let primary = Color.blue
```

### 9.3. Add New Feature
1. Create new file: **File → New → File** (⌘N)
2. Chọn **Swift File**
3. Đặt tên theo convention (VD: `NewFeatureView.swift`)
4. Implement feature theo TCA pattern

---

## 🐛 Troubleshooting

### Lỗi: "Could not resolve package dependencies"
```bash
# Solution:
File → Packages → Reset Package Caches
File → Packages → Update to Latest Package Versions
```

### Lỗi: "Build failed" với SwiftLint
```bash
# Install SwiftLint
brew install swiftlint

# Hoặc disable SwiftLint tạm thời
# Comment out SwiftLint build phase
```

### Lỗi: "Signing for iOSTemplate requires a development team"
```bash
# Solution:
1. Xcode → Settings → Accounts
2. Add Apple ID
3. Project → Signing & Capabilities
4. Select your Team
```

### Lỗi: "Untrusted Developer" trên iPhone
```bash
# Solution:
iPhone Settings → General → VPN & Device Management
→ Trust developer certificate
```

### Simulator chạy chậm
```bash
# Reset simulator:
Device → Erase All Content and Settings

# Hoặc dùng simulator nhỏ hơn:
iPhone SE (3rd generation)
```

---

## 📚 Next Steps

### 1. Đọc Documentation
```bash
# Xem các file .md trong .ai/
.ai/context/         # Project context
.ai/rules/           # Coding rules
.ai/agents/          # Agent guides
```

### 2. Explore Code Structure
```
Sources/iOSTemplate/
├── Core/           # TCA app state/actions/reducers
├── Features/       # UI features (Home, Profile, etc.)
├── Theme/          # Colors, Typography, Spacing
├── Services/       # DI, Protocols
├── Storage/        # UserDefaults, Keychain, Files
├── Network/        # API, Moya
└── Utilities/      # Logger, Cache
```

### 3. Run Tests
```bash
# Trong Xcode:
Product → Test (⌘U)

# Xem test results:
View → Navigators → Test Navigator (⌘6)
```

### 4. Customize App
- Đổi app name
- Đổi bundle identifier
- Thêm app icon
- Customize colors/fonts
- Add new features

---

## 🎓 Học Thêm

### Swift & SwiftUI
- [Swift Official Docs](https://docs.swift.org/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui)

### TCA (The Composable Architecture)
- [Official Docs](https://pointfreeco.github.io/swift-composable-architecture/)
- [Point-Free Videos](https://www.pointfree.co/)
- [Examples](https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples)

### iOS Development
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Apple Developer Docs](https://developer.apple.com/documentation/)
- [Ray Wenderlich](https://www.raywenderlich.com/)

---

## 💡 Tips & Tricks

### Keyboard Shortcuts
```
⌘B          Build
⌘R          Run
⌘.          Stop
⌘U          Test
⌘⇧K         Clean Build Folder
⌘⇧Y         Toggle Debug Area
⌘⌥⏎         Show Preview
⌘0          Toggle Navigator
⌘⌥0         Toggle Inspector
⌘/          Comment/Uncomment
⌘⌥[         Move line up
⌘⌥]         Move line down
```

### Xcode Tips
1. **Double tap Shift**: Quick Open (tìm file nhanh)
2. **⌘ + Click**: Jump to definition
3. **⌃Space**: Code completion
4. **⌘⇧O**: Open quickly
5. **⌘⇧F**: Find in project

### Development Workflow
```
1. Create feature branch
2. Write code
3. Test on simulator
4. Test on device
5. Run unit tests
6. Commit changes
7. Push to GitHub
```

---

## 🆘 Cần Giúp Đỡ?

### Resources
- **Project Issues**: [GitHub Issues](https://github.com/kienpro307/ios-template/issues)
- **Xcode Help**: Help → Xcode Help
- **Stack Overflow**: Tag `swift`, `swiftui`, `ios`
- **Apple Forums**: [developer.apple.com/forums](https://developer.apple.com/forums/)

### Common Questions

**Q: Tôi không có Mac, có chạy được không?**
A: Không. iOS development chỉ chạy được trên macOS.

**Q: Cần phải trả tiền Apple Developer không?**
A: Không cần cho development. Chỉ cần $99/năm khi publish lên App Store.

**Q: App có thể chạy trên Android không?**
A: Không. Đây là native iOS app. Muốn chạy Android cần viết lại bằng Kotlin/Java hoặc dùng cross-platform framework như Flutter/React Native.

**Q: Tôi chưa biết Swift, bắt đầu từ đâu?**
A: Bắt đầu với [Swift Playgrounds](https://www.apple.com/swift/playgrounds/) hoặc [Swift Documentation](https://docs.swift.org/swift-book/).

---

**Chúc bạn code vui vẻ! 🚀**

*Document Version: 1.0*
*Last Updated: November 2024*
