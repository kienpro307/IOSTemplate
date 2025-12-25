# iOS Template - Hướng Dẫn Sử Dụng

## Giới Thiệu

**iOS Template** là một template ứng dụng iOS hiện đại được xây dựng trên **TCA (The Composable Architecture)** với kiến trúc multi-module, giúp bạn khởi tạo dự án iOS mới một cách nhanh chóng và chuyên nghiệp.

### Template Dành Cho Ai?

- ✅ Developers muốn bắt đầu dự án iOS mới với kiến trúc vững chắc
- ✅ Team cần một codebase chuẩn để phát triển multiple apps
- ✅ Developers muốn học TCA (The Composable Architecture)
- ✅ Projects cần tích hợp sẵn Firebase, IAP, và các services phổ biến

### Tech Stack Chính

| Công nghệ | Version | Mục đích |
|-----------|---------|----------|
| **Swift** | 5.9+ | Ngôn ngữ lập trình |
| **iOS** | 16.0+ | Platform tối thiểu |
| **SwiftUI** | - | UI Framework |
| **TCA** | 1.15+ | Architecture pattern |
| **Moya** | 15.0+ | Network layer |
| **Firebase** | 11.0+ | Analytics, Crashlytics, Remote Config, Push Notifications |
| **StoreKit 2** | - | In-App Purchase |
| **Kingfisher** | 8.0+ | Image loading & caching |
| **KeychainAccess** | 4.2+ | Secure storage |

---

## 🚀 Quick Start (5 Phút)

### Yêu Cầu Hệ Thống

- macOS 13.0+ (Ventura hoặc mới hơn)
- Xcode 15.0+
- Swift 5.9+
- CocoaPods hoặc Homebrew (optional, cho tools)

### Cài Đặt Nhanh

```bash
# 1. Clone repository
git clone https://github.com/your-org/ios-template.git
cd ios-template

# 2. Mở Xcode project
open IOSTemplate.xcodeproj

# 3. Chọn target và simulator
# Xcode → Product → Destination → iPhone 15 Pro

# 4. Build & Run
# Xcode → Product → Run (⌘R)
```

### Cấu Hình Firebase (Optional)

Nếu muốn sử dụng Firebase:

1. Tạo project mới trên [Firebase Console](https://console.firebase.google.com)
2. Download file `GoogleService-Info.plist`
3. Thêm vào Xcode project (kéo thả vào root)
4. Build lại project

> **Lưu ý:** Firebase không bắt buộc. Template vẫn chạy được với mock services.

---

## 📖 Documentation

### Bắt Đầu (Priority 1)

| Tài liệu | Mô tả | Thời gian đọc |
|----------|-------|---------------|
| [01. Cài Đặt](01-BAT-DAU/01-CAI-DAT.md) | Hướng dẫn cài đặt chi tiết | 10 phút |
| [02. Cấu Trúc Dự Án](01-BAT-DAU/02-CAU-TRUC-DU-AN.md) | Hiểu rõ folder structure | 15 phút |
| [03. Chạy Thử](01-BAT-DAU/03-CHAY-THU.md) | Build, run và troubleshooting | 10 phút |

### Hướng Dẫn Sử Dụng (Priority 2)

| Tài liệu | Mô tả | Thời gian đọc |
|----------|-------|---------------|
| [01. Tạo Tính Năng Mới](02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md) | Step-by-step tạo feature với TCA | 30 phút |
| [02. Sử Dụng Services](02-HUONG-DAN-SU-DUNG/02-SU-DUNG-SERVICES.md) | Network, Storage, Cache, Keychain | 20 phút |
| [03. Navigation](02-HUONG-DAN-SU-DUNG/03-NAVIGATION.md) | Tab, NavigationStack, Modal, Deep Links | 20 phút |
| [04. Theme & UI](02-HUONG-DAN-SU-DUNG/04-THEME-UI.md) | Colors, Typography, Components | 15 phút |
| [05. Viết Tests](02-HUONG-DAN-SU-DUNG/05-VIET-TESTS.md) | TCA testing patterns | 25 phút |

### Tính Năng Có Sẵn

| Tài liệu | Mô tả |
|----------|-------|
| [01. Onboarding](03-TINH-NANG-CO-SAN/01-ONBOARDING.md) | Customize onboarding flow |
| [02. Settings](03-TINH-NANG-CO-SAN/02-SETTINGS.md) | Thêm settings options |
| [03. In-App Purchase](03-TINH-NANG-CO-SAN/03-IAP.md) | Setup IAP với StoreKit 2 |
| [04. Firebase](03-TINH-NANG-CO-SAN/04-FIREBASE.md) | Analytics, Crashlytics, Remote Config |

### Customize Template

| Tài liệu | Mô tả |
|----------|-------|
| [01. Đổi Tên App](04-CUSTOMIZE/01-DOI-TEN-APP.md) | Bundle ID, display name, icons |
| [02. Thêm Dependency](04-CUSTOMIZE/02-THEM-DEPENDENCY.md) | Thêm SPM packages mới |
| [03. Xóa Tính Năng](04-CUSTOMIZE/03-XOA-TINH-NANG.md) | Remove IAP, Firebase, Ads không cần |

### Tham Khảo

| Tài liệu | Mô tả |
|----------|-------|
| [01. Dependencies](05-THAM-KHAO/01-DEPENDENCIES.md) | Danh sách tất cả dependencies |
| [02. Code Templates](05-THAM-KHAO/02-CODE-TEMPLATES.md) | Mẫu code cho Reducer, View, Service |
| [03. FAQ](05-THAM-KHAO/03-FAQ.md) | Câu hỏi thường gặp |
| [04. Error Handling](05-THAM-KHAO/04-ERROR-HANDLING.md) | AppError patterns |

---

## 🏗️ Kiến Trúc Tổng Quan

Template sử dụng **Multi-Module Architecture** với 4 layers:

```
┌─────────────────────────────────────┐
│           App Layer                 │
│  (Entry point & RootView)           │
├─────────────────────────────────────┤
│         Features Layer              │
│  (Home, Settings, IAP, Onboarding)  │
├─────────────────────────────────────┤
│         Services Layer              │
│  (Firebase, Payment, Ads)           │
├─────────────────────────────────────┤
│         Core Layer                  │
│  (Architecture, Dependencies, Nav)  │
├─────────────────────────────────────┤
│           UI Layer                  │
│  (Design System, Components)        │
└─────────────────────────────────────┘
```

### Dependency Graph

```
App → Features → Services → Core
                         ↘ UI → Core
```

**Quy tắc dependency:**
- App có thể dùng tất cả modules
- Features có thể dùng Services, Core, UI
- Services chỉ dùng Core
- UI chỉ dùng Core
- Core không phụ thuộc module nào

---

## ✨ Tính Năng Có Sẵn

### 📱 Core Features
- ✅ **TCA Architecture** - Predictable state management
- ✅ **Multi-Module** - Scalable codebase structure
- ✅ **Navigation System** - Tab + Stack + Modal + Deep Links
- ✅ **Error Handling** - Comprehensive error hierarchy
- ✅ **Dependency Injection** - Testable & mockable dependencies

### 🎨 UI/UX
- ✅ **Design System** - Colors, Typography, Spacing
- ✅ **Dark Mode Support** - Adaptive colors
- ✅ **Onboarding Flow** - Customizable intro screens
- ✅ **Settings Screen** - Theme, language, notifications preferences

### 🔥 Services
- ✅ **Firebase Analytics** - Event tracking
- ✅ **Firebase Crashlytics** - Crash reporting
- ✅ **Firebase Remote Config** - Feature flags
- ✅ **Push Notifications** - FCM integration
- ✅ **In-App Purchase** - StoreKit 2 implementation

### 🛠️ Developer Experience
- ✅ **Network Layer** - Moya-based API client
- ✅ **Cache System** - Memory + Disk caching
- ✅ **Secure Storage** - Keychain wrapper
- ✅ **Logger System** - OSLog + file logging
- ✅ **SwiftLint Ready** - Code style enforcement

---

## 📦 Project Structure

```
IOSTemplate/
├── Sources/
│   ├── App/              # Entry point
│   │   ├── Main.swift
│   │   ├── AppState.swift
│   │   ├── AppAction.swift
│   │   ├── AppReducer.swift
│   │   └── RootView.swift
│   │
│   ├── Core/             # Foundation layer
│   │   ├── Architecture/
│   │   ├── Dependencies/
│   │   ├── Navigation/
│   │   ├── Errors/
│   │   └── Cache/
│   │
│   ├── UI/               # Design system
│   │   ├── Theme/
│   │   └── Components/
│   │
│   ├── Services/         # External services
│   │   ├── Firebase/
│   │   ├── Payment/
│   │   └── Ads/
│   │
│   └── Features/         # Business features
│       ├── Onboarding/
│       ├── Home/
│       ├── Settings/
│       └── IAP/
│
├── Tests/
│   ├── CoreTests/
│   └── FeaturesTests/
│
├── docs/                 # Documentation (bạn đang đọc)
├── ios-template-docs/    # Internal development docs
├── Package.swift         # SPM manifest
└── README.md             # Project overview
```

---

## 🎯 Workflow Khuyến Nghị

Khi bắt đầu với template:

1. **Đọc docs cơ bản** (1 giờ)
   - [01. Cài Đặt](01-BAT-DAU/01-CAI-DAT.md)
   - [02. Cấu Trúc Dự Án](01-BAT-DAU/02-CAU-TRUC-DU-AN.md)
   - [03. Chạy Thử](01-BAT-DAU/03-CHAY-THU.md)

2. **Customize template cho project** (30 phút)
   - [Đổi Tên App](04-CUSTOMIZE/01-DOI-TEN-APP.md)
   - [Xóa Tính Năng](04-CUSTOMIZE/03-XOA-TINH-NANG.md) không cần

3. **Học cách tạo feature** (1 giờ)
   - [Tạo Tính Năng Mới](02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md)
   - Thực hành tạo 1-2 screens đơn giản

4. **Tích hợp services cần thiết** (2-4 giờ)
   - Setup Firebase nếu cần
   - Configure IAP products
   - Setup network endpoints

5. **Phát triển features chính** (ongoing)
   - Follow TCA patterns
   - Viết tests cho business logic
   - Track analytics events

---

## 💡 Best Practices

### Do's ✅

- ✅ Follow TCA pattern (State → Action → Reducer → View)
- ✅ Sử dụng `@Dependency` cho tất cả dependencies
- ✅ Viết tests cho Reducers (business logic)
- ✅ Track analytics events cho user actions
- ✅ Handle errors properly với `AppError` hierarchy
- ✅ Sử dụng code templates trong `ios-template-docs/05-CODE-TEMPLATES/`

### Don'ts ❌

- ❌ Đừng modify Core module trừ khi thực sự cần
- ❌ Đừng bypass dependency injection (hardcode dependencies)
- ❌ Đừng skip error handling (luôn handle errors)
- ❌ Đừng ignore warnings (fix tất cả warnings)
- ❌ Đừng commit `GoogleService-Info.plist` (add vào .gitignore)

---

## 🆘 Cần Trợ Giúp?

### Tài Nguyên

- 📖 **Documentation**: Đọc docs trong folder `docs/`
- 📝 **Code Templates**: Xem `ios-template-docs/05-CODE-TEMPLATES/`
- ❓ **FAQ**: Xem [FAQ](05-THAM-KHAO/03-FAQ.md)
- 🐛 **Issues**: Report bugs trên GitHub Issues

### Common Issues

| Vấn đề | Giải pháp |
|--------|-----------|
| Build failed | Xem [Troubleshooting](01-BAT-DAU/03-CHAY-THU.md) |
| Firebase không hoạt động | Check `GoogleService-Info.plist` đã thêm chưa |
| Tests failed | Kiểm tra mock dependencies setup |
| Lint errors | Run `./lint.sh` để xem chi tiết |

---

## 📄 License

MIT License - Free to use for personal and commercial projects.

---

## 📌 Version

- **Version**: 1.0.0
- **Last Updated**: December 2024
- **TCA Version**: 1.15+
- **iOS Version**: 16.0+

---

**Happy Coding! 🚀**

Nếu template này hữu ích, hãy star ⭐ repository để support team phát triển.

