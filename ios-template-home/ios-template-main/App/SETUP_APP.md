# 🚀 Hướng dẫn Setup App - CỰC KỲ ĐƠN GIẢN

## Bước 1: Mở Xcode Project

```bash
# Mở Finder
open /Volumes/externalDisk/code/ios/ios-template/App/iOSTemplateApp
```

Tìm file `iOSTemplateApp.xcodeproj` (nếu có) và **double-click** để mở.

**Nếu KHÔNG có file .xcodeproj**, làm theo hướng dẫn bên dưới để tạo mới.

---

## Bước 2: Add Swift File vào Project (Drag & Drop)

1. Trong Xcode, mở **Project Navigator** (⌘ + 1)
2. Tìm folder **"iOSTemplateApp"** (folder màu vàng)
3. Mở **Finder** tới folder:
   ```
   /Volumes/externalDisk/code/ios/ios-template/App/iOSTemplateApp/iOSTemplateApp/
   ```
4. **Kéo file `iOSTemplateApp.swift`** từ Finder vào folder "iOSTemplateApp" trong Xcode
5. Trong popup:
   - ✅ Tích "Copy items if needed"
   - ✅ Tích "iOSTemplateApp" target
   - Nhấn **Finish**

---

## Bước 3: Link Swift Package (Kéo thả)

### Cách 1: Drag & Drop (Dễ nhất)
1. Mở **Finder** tới folder gốc:
   ```
   /Volumes/externalDisk/code/ios/ios-template
   ```
2. **Kéo file `Package.swift`** vào Xcode **Project Navigator**
3. Xcode sẽ tự động detect và add local package

### Cách 2: Add Package Dialog
1. Trong Xcode: **File** → **Add Package Dependencies**
2. Nhấn **Add Local...** (góc dưới trái)
3. Chọn folder:
   ```
   /Volumes/externalDisk/code/ios/ios-template
   ```
4. Nhấn **Add Package**
5. Chọn **iOSTemplate** library
6. Nhấn **Add Package**

---

## Bước 4: Verify & Build

1. **Project** → **Target "iOSTemplateApp"** → **General**
2. Scroll xuống **"Frameworks, Libraries, and Embedded Content"**
3. Nếu chưa có `iOSTemplate`, nhấn **"+"** và add
4. Chọn **Scheme "iOSTemplateApp"**
5. Chọn **Simulator** (e.g., iPhone 15 Pro)
6. Nhấn **▶️ Run** hoặc **⌘ + R**

---

## 🆘 Nếu chưa có .xcodeproj File

Tạo project mới:

1. **Xcode** → **File** → **New** → **Project**
2. Chọn **iOS** → **App** → **Next**
3. Cấu hình:
   - **Product Name**: `iOSTemplateApp`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
4. **Save tới**: `/Volumes/externalDisk/code/ios/ios-template/App/iOSTemplateApp`
5. ⚠️ **QUAN TRỌNG**: Trong popup save:
   - ❌ **KHÔNG** tích "Create Git repository"
   - ❌ **KHÔNG** tích "Add to workspace"
6. Xóa files Xcode tạo:
   - `ContentView.swift`
   - `iOSTemplateAppApp.swift` (file cũ)
7. Quay lại **Bước 2** ở trên

---

## ✅ Success!

App sẽ launch và hiện:
1. **OnboardingView** → nhấn "Get Started"
2. **LoginView** → nhấn "Sign In"
3. **MainTabView** với 4 tabs (Home, Explore, Profile, Settings)

---

## 🐛 Troubleshooting

### Lỗi "Cannot find 'RootView' in scope"
→ Kiểm tra file `iOSTemplateApp.swift` có dòng:
```swift
import iOSTemplate  // ← Phải có
```

### Lỗi "No such module 'ComposableArchitecture'"
→ **File** → **Packages** → **Resolve Package Versions**

### Build lỗi iOS version
→ **Build Settings** → search "Deployment Target" → set **16.0**
