# Đổi Tên App & Rebrand Template

Hướng dẫn chi tiết để customize template cho project của bạn.

---

## Mục Lục

- [Đổi Tên App](#đổi-tên-app)
- [Đổi Bundle Identifier](#đổi-bundle-identifier)
- [Đổi App Icon](#đổi-app-icon)
- [Đổi Colors & Theme](#đổi-colors--theme)
- [Cập Nhật Metadata](#cập-nhật-metadata)
- [Checklist](#checklist)

---

## Đổi Tên App

### 1. Display Name (Tên Hiển Thị)

**Tên hiển thị trên Home Screen và App Store.**

#### Trong Xcode

```
1. Xcode → Target IOSTemplate → General
2. Display Name → Đổi thành "Your App Name"
```

#### Trong Info.plist

```xml
<key>CFBundleDisplayName</key>
<string>Your App Name</string>
```

**Lưu ý:**
- Max 30 characters
- Tránh ký tự đặc biệt
- Unique trên App Store

---

### 2. Scheme Name

**Tên scheme trong Xcode (cho build/run).**

```
1. Xcode → Product → Scheme → Manage Schemes
2. Double-click "IOSTemplate" scheme
3. Đổi Name thành "YourAppName"
```

---

### 3. Target Name (Advanced)

**Đổi tên target trong Xcode.**

⚠️ **Warning:** Phức tạp, có thể break project. Chỉ làm nếu cần thiết.

```
1. Xcode → Target "IOSTemplate" → Double-click để rename
2. Đổi thành "YourAppName"
3. Clean Build Folder (⌘⇧K)
4. Build lại (⌘B)
```

**Sau khi đổi, update:**
- Scheme name
- Test targets
- Package.swift target references

---

## Đổi Bundle Identifier

**Bundle ID là unique identifier cho app trên App Store.**

### Format

```
com.[company].[appname]

Ví dụ:
- com.example.myapp
- com.yourcompany.awesomeapp
```

### Trong Xcode

```
1. Xcode → Target IOSTemplate → Signing & Capabilities
2. Bundle Identifier → Đổi thành "com.yourcompany.yourapp"
```

### Trong Package.swift (Nếu cần)

Không cần thay đổi, Bundle ID chỉ cấu hình trong Xcode project.

### Reverse DNS Notation

**Best practices:**
- Lowercase letters
- No special characters (except .)
- No spaces
- Use your domain: `com.yourdomain.appname`

**Examples:**

| Company | App Name | Bundle ID |
|---------|----------|-----------|
| Apple | iTunes | com.apple.iTunes |
| Google | Gmail | com.google.Gmail |
| Your Company | My App | com.yourcompany.myapp |

---

## Đổi App Icon

### 1. Chuẩn Bị Icons

**Required sizes:**

| Size | Usage |
|------|-------|
| 1024x1024 | App Store |
| 180x180 | iPhone @3x |
| 120x120 | iPhone @2x |
| 167x167 | iPad Pro @2x |
| 152x152 | iPad @2x |
| 76x76 | iPad @1x |

**Design guidelines:**
- ✅ PNG format
- ✅ No transparency
- ✅ Square (1:1 ratio)
- ✅ Rounded corners handled by iOS
- ❌ No text (trừ logo/brand name)

### 2. Generate Icons

**Tool khuyến nghị:**
- [AppIcon.co](https://appicon.co) - Free online generator
- [MakeAppIcon](https://makeappicon.com) - Free
- [AppIconizer](https://github.com/Recouse/AppIconizer) - Mac app

**Steps:**
1. Upload 1024x1024 master icon
2. Generate all sizes
3. Download .zip

### 3. Add vào Xcode

```
1. Xcode → Assets.xcassets
2. Click "AppIcon"
3. Kéo thả từng size vào slots tương ứng
```

**Hoặc:**

```
1. Xóa AppIcon set hiện tại
2. Kéo thả .appiconset folder từ downloaded zip
```

### 4. Verify

```
1. Build & Run (⌘R)
2. Return to Home Screen (⌘⇧H trong Simulator)
3. Check icon hiển thị đúng
```

---

## Đổi Colors & Theme

### 1. Primary Colors

**File:** `Sources/UI/Theme/Colors.swift`

```swift
public enum Colors {
    // MARK: - Primary (Brand Colors)
    /// Màu chính của app - Thay đổi theo brand
    public static let primary = Color(hex: "#007AFF")  // Đổi sang màu brand của bạn
    
    /// Màu primary nhạt hơn
    public static let primaryLight = Color(hex: "#4DA8FF")
    
    /// Màu primary đậm hơn
    public static let primaryDark = Color(hex: "#0051A8")
    
    // MARK: - Secondary
    /// Màu phụ của app
    public static let secondary = Color(hex: "#5AC8FA")  // Đổi nếu cần
    
    // ... rest of colors
}
```

**Hex to Color Extension:**

```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### 2. Adaptive Colors (Light/Dark Mode)

Để support cả light và dark mode:

```swift
public static let background = Color("Background", bundle: .module)
```

**Add to Assets.xcassets:**

```
1. Assets.xcassets → Right-click → New Color Set
2. Name: "Background"
3. Attributes Inspector → Appearances → Any, Light, Dark
4. Set colors cho từng mode:
   - Light: #FFFFFF
   - Dark: #000000
```

### 3. Xem Preview

```swift
#Preview("Light Mode") {
    HomeView(store: ...)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HomeView(store: ...)
        .preferredColorScheme(.dark)
}
```

---

## Cập Nhật Metadata

### 1. Version & Build Number

**File:** `Package.swift` hoặc Xcode Target settings

```
Xcode → Target → General
- Version: 1.0.0 (marketing version)
- Build: 1 (internal build number)
```

**Versioning scheme:**
- `1.0.0` - Major.Minor.Patch
- `1.0.1` - Bug fixes
- `1.1.0` - New features
- `2.0.0` - Major changes

### 2. Copyright

**File:** Info.plist

```xml
<key>NSHumanReadableCopyright</key>
<string>Copyright © 2024 Your Company. All rights reserved.</string>
```

### 3. App Category

```xml
<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>
```

**Common categories:**
- `public.app-category.business`
- `public.app-category.education`
- `public.app-category.entertainment`
- `public.app-category.productivity`
- `public.app-category.social-networking`
- `public.app-category.utilities`

### 4. Supported Orientations

```
Xcode → Target → General → Deployment Info
- iPhone: Portrait only (khuyến nghị)
- iPad: All orientations
```

### 5. Required Device Capabilities

**File:** Info.plist

```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
    <string>arm64</string>
</array>
```

---

## Firebase Configuration

Nếu app dùng Firebase, cần update:

### 1. Tạo Firebase Project Mới

```
1. Firebase Console → Add Project
2. Project name: Your App Name
3. Enable Google Analytics (optional)
```

### 2. Add iOS App

```
1. Firebase → Add app → iOS
2. Bundle ID: com.yourcompany.yourapp (phải match Xcode)
3. App nickname: Your App Name
4. Download GoogleService-Info.plist
```

### 3. Replace File

```bash
# Xóa file cũ
rm GoogleService-Info.plist

# Add file mới vào Xcode
# Kéo thả file vào project root
```

**Checklist:**
- [ ] File trong project root
- [ ] "Copy items if needed" checked
- [ ] "Add to targets: IOSTemplate" checked

---

## URL Schemes & Deep Links

### 1. Custom URL Scheme

**File:** Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

**Usage:**
```
yourapp://settings
yourapp://profile/123
```

### 2. Universal Links (Optional)

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourapp.com</string>
</array>
```

**Requires:**
- Apple Developer account (paid)
- Domain ownership
- apple-app-site-association file on server

---

## Cleanup

### 1. Xóa Template Branding

**README.md:**

```markdown
# Your App Name

Description of your app.

## Features

- Feature 1
- Feature 2

## Installation

...
```

### 2. Xóa Template Docs (Optional)

```bash
# Nếu không cần internal docs nữa
rm -rf ios-template-docs/
```

**Giữ lại:**
- `docs/` - User documentation
- `README.md` - Project overview

### 3. Update Git Remote

```bash
# Remove template remote
git remote remove origin

# Add your repo
git remote add origin https://github.com/yourcompany/yourapp.git

# Push
git push -u origin main
```

---

## Checklist

### Pre-Deployment

- [ ] **Display Name** changed
- [ ] **Bundle Identifier** changed (unique)
- [ ] **App Icon** updated (all sizes)
- [ ] **Primary Colors** changed to brand colors
- [ ] **Dark Mode** tested
- [ ] **Version** set to 1.0.0
- [ ] **Copyright** updated
- [ ] **Firebase** configured (if using)
- [ ] **URL Scheme** updated (if using)
- [ ] **README.md** updated
- [ ] **Build successful** (⌘B)
- [ ] **App runs** on simulator (⌘R)
- [ ] **App runs** on device
- [ ] **No template references** left

### Code Signing

- [ ] **Team** selected
- [ ] **Provisioning profile** valid
- [ ] **Capabilities** configured (if needed):
  - [ ] Push Notifications
  - [ ] In-App Purchase
  - [ ] Associated Domains

### Testing

- [ ] Launch app - no crashes
- [ ] Onboarding works
- [ ] All tabs work
- [ ] Settings work
- [ ] IAP flow works (if using)
- [ ] Firebase analytics tracking (if using)

---

## Script Tự Động (Optional)

Tạo script để automate một số steps:

**File:** `rebrand.sh`

```bash
#!/bin/bash

# Rebrand iOS Template

echo "🎨 Rebranding iOS Template..."

# Input
read -p "App Display Name: " APP_NAME
read -p "Bundle ID (com.company.app): " BUNDLE_ID
read -p "Primary Color (hex): " PRIMARY_COLOR

# Update Display Name in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" Info.plist

# Update Bundle ID (needs Xcode project manipulation - complex)
# TODO: Implement or skip

# Update Colors.swift
sed -i '' "s/#007AFF/$PRIMARY_COLOR/g" Sources/UI/Theme/Colors.swift

echo "✅ Rebranding complete!"
echo ""
echo "Manual steps remaining:"
echo "1. Update App Icon in Assets.xcassets"
echo "2. Update Bundle ID in Xcode"
echo "3. Replace GoogleService-Info.plist"
echo "4. Test build & run"
```

Run:

```bash
chmod +x rebrand.sh
./rebrand.sh
```

---

## Xem Thêm

- [Thêm Dependency](02-THEM-DEPENDENCY.md)
- [Xóa Tính Năng](03-XOA-TINH-NANG.md)
- [Firebase Setup](../03-TINH-NANG-CO-SAN/04-FIREBASE.md)

---

**Tip:** Làm rebranding ngay khi bắt đầu project mới để tránh confusion sau này! 🎨

