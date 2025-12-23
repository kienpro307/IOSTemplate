# 📱 iOS Template Project

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://www.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![TCA](https://img.shields.io/badge/TCA-1.0+-purple.svg)](https://github.com/pointfreeco/swift-composable-architecture)

> Template iOS hiện đại, production-ready với TCA architecture và Parameterized Component Pattern, được thiết kế cho AI-assisted development và multi-app reusability

---

## 📚 Quick Links

- 🚀 **[Quick Start](QUICK_START.md)** - Get running in 5 minutes!
- 📖 **[Setup Guide](SETUP.md)** - Detailed setup instructions
- 📘 **[API Documentation](docs/API_DOCUMENTATION.md)** - Complete API reference
- 🔧 **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues & solutions
- 🚢 **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Deploy to App Store
- 🤝 **[Contributing](docs/CONTRIBUTING.md)** - How to contribute

---

## 🎯 Tổng Quan

Đây là một **Swift Package Template** có thể tái sử dụng cho nhiều apps iOS khác nhau. Template cung cấp reusable components với **Parameterized Component Pattern**, cho phép mỗi app customize content và behavior mà không cần fork hay duplicate code.

### Đặc Điểm Nổi Bật

- ✅ **Modular Architecture**: Swift Package có thể tái sử dụng cho nhiều apps
- ✅ **Parameterized Component Pattern**: Customize components qua configuration objects
- ✅ The Composable Architecture (TCA) for state management
- ✅ SwiftUI for modern UI development
- ✅ Dependency Injection with Swinject
- ✅ Comprehensive theme system with dark/light mode
- ✅ Network layer with Moya
- ✅ Firebase integration (Analytics, Crashlytics, Remote Config)
- ✅ Storage abstractions (UserDefaults, Keychain, CoreData)
- ✅ Comprehensive testing setup
- ✅ AI-friendly documentation and structure

### Tại Sao Chọn Template Này?

**Một Template, Nhiều Apps:**
```
Banking App  ←─┐
Fitness App  ←─┼─ Sử dụng cùng iOS Template
E-commerce   ←─┘
```

Mỗi app có UI và logic riêng, nhưng đều dùng chung foundation từ template này.

## 📋 Yêu Cầu

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- macOS Sonoma hoặc mới hơn

## 🚀 Bắt Đầu Nhanh

### Cài Đặt

1. Clone repository:
```bash
git clone https://github.com/kienpro307/ios-template.git
cd ios-template
```

2. Mở Xcode project:
```bash
open Package.swift
```

3. Build và run (⌘R)

📖 **[Xem Hướng Dẫn Chi Tiết →](./SETUP.md)**

## 💡 Cách Sử Dụng Template

### Quick Start: Tạo App Mới

**Bước 1:** Tạo iOS App target (hoặc project riêng)

```swift
// App/MyApp/MyApp.swift
import iOSTemplate

@main
struct MyApp: App {
    let store: StoreOf<AppReducer>

    init() {
        _ = DIContainer.shared
        self.store = Store(initialState: AppState()) {
            AppReducer()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

**Bước 2:** Customize components với configs

```swift
// Onboarding với custom config
let myOnboardingConfig = OnboardingConfig(
    pages: [
        OnboardingPage(
            icon: "star.fill",
            title: "My App Feature",
            description: "Custom description",
            color: .blue
        )
    ],
    finalButtonText: "Start Now",
    onComplete: {
        // Custom logic cho app của bạn
    }
)

OnboardingView(store: store, config: myOnboardingConfig)
```

**Bước 3:** Tương tự cho các features khác

```swift
// Login với custom config
let myLoginConfig = LoginConfig(
    title: "Welcome to My App",
    primaryColor: .blue,
    onLogin: { email, password in
        // Custom login logic
    }
)

LoginView(store: store, config: myLoginConfig)
```

### Parameterized Component Pattern

Template này sử dụng **Parameterized Component Pattern** - mỗi reusable component nhận một config object:

```
┌─────────────────────────────────────┐
│  Template (Swift Package)           │
│                                     │
│  ┌──────────┐      ┌─────────────┐ │
│  │   View   │◄─────│   Config    │ │
│  │(Generic) │      │(Customize)  │ │
│  └──────────┘      └─────────────┘ │
└─────────────────────────────────────┘
           │
           │ Used by
           ▼
    ┌─────────────┐
    │  Your App   │
    │             │
    │  myConfig   │
    │  View(      │
    │    config   │
    │  )          │
    └─────────────┘
```

**Lợi ích:**
- ✅ Không cần fork hay modify template code
- ✅ Mỗi app có UI và logic riêng
- ✅ Update template → tất cả apps được cải thiện
- ✅ Type-safe và SwiftUI-native

📖 **[Xem Chi Tiết Pattern →](./COMPONENT_PATTERN.md)**
📖 **[Hiểu Kiến Trúc Modular →](./ARCHITECTURE.md)**

### Cấu Trúc Project

```
ios-template/
├── Sources/iOSTemplate/           # 📦 Swift Package - Template Library
│   ├── Core/                      # Core components
│   │   ├── ViewConfigs/          # 🎨 Config models cho components
│   │   ├── TCA/                  # TCA reducers, actions, state
│   │   ├── DI/                   # Dependency injection
│   │   └── Theme/                # Theme system
│   ├── Features/                  # 🎯 Reusable feature modules
│   │   ├── Onboarding/           # OnboardingView + config
│   │   ├── Auth/                 # LoginView + config
│   │   ├── Home/                 # HomeView
│   │   └── Profile/              # ProfileView
│   ├── Services/                  # 🔧 Business services
│   │   ├── Network/              # API layer
│   │   ├── Storage/              # Data persistence
│   │   └── Logging/              # Logging system
│   └── iOSTemplate.swift         # Module entry point
│
├── App/iOSTemplateApp/            # 📱 App Wrapper - Example usage
│   ├── iOSTemplateApp.swift      # iOS App entry point
│   └── Configs/                  # App-specific configs (optional)
│
├── Tests/                         # 🧪 Unit và integration tests
│   ├── CoreTests/
│   ├── FeaturesTests/
│   └── ServicesTests/
│
├── docs/                          # 📚 Documentation
│   ├── ARCHITECTURE.md           # Kiến trúc modular
│   ├── COMPONENT_PATTERN.md      # Pattern guide
│   └── SETUP.md                  # Setup guide
│
├── .ai/                           # 🤖 AI context và rules
│   ├── context/                  # Context files
│   ├── rules/                    # Code conventions
│   └── agents/                   # Agent instructions
│
├── Package.swift                  # Swift Package definition
└── README.md                      # This file
```

**Key Points:**
- `Sources/iOSTemplate/`: Template code (reusable)
- `App/`: App wrapper (app-specific)
- `Core/ViewConfigs/`: Config models cho Parameterized Components
- `Features/`: Reusable views + logic

## 🏗️ Kiến Trúc

### Modular Architecture

Template này là một **Swift Package** (library), không phải standalone app:

```
┌─────────────────────────────────────────┐
│  iOS Template (Swift Package)           │
│  - Reusable components                  │
│  - TCA state management                 │
│  - Services (Network, Storage, etc.)    │
└─────────────────────────────────────────┘
                 │
                 │ Used by
                 ▼
    ┌────────────────────────┐
    │  Banking App           │
    │  Fitness App           │
    │  E-commerce App        │
    └────────────────────────┘
```

**Lợi ích:**
- ✅ **Reusability**: Một template, nhiều apps
- ✅ **Separation**: Template = generic, App = specific
- ✅ **Maintainability**: Update template → all apps benefit
- ✅ **Testability**: Test template độc lập

📖 **[Đọc Chi Tiết Kiến Trúc →](./ARCHITECTURE.md)**

### The Composable Architecture (TCA)

Project sử dụng **TCA** cho quản lý state:

- **Dự đoán được (Predictable)**: Luồng dữ liệu một chiều
- **Dễ kiểm thử (Testable)**: Pure functions, dễ dàng test
- **Có thể kết hợp (Composable)**: Xây dựng tính năng phức tạp từ những thành phần đơn giản
- **Observable**: Tích hợp SwiftUI với @ObservableState

**Luồng Dữ Liệu:**
```
View → Action → Reducer → State → View
            ↓
          Effect (side effects)
```

### Parameterized Component Pattern

Mỗi reusable component = **View + Config**:

```swift
// Config: Chứa data và behavior
public struct XYZConfig {
    let title: String
    let color: Color
    let onComplete: () -> Void
}

// View: Nhận config và render
public struct XYZView: View {
    let config: XYZConfig

    var body: some View {
        Text(config.title)
            .foregroundColor(config.color)
        Button("Done") {
            config.onComplete()  // App-specific logic
        }
    }
}

// Usage: App customize qua config
let myConfig = XYZConfig(
    title: "My Title",
    color: .blue,
    onComplete: { /* app logic */ }
)
XYZView(config: myConfig)
```

📖 **[Đọc Chi Tiết Pattern →](./COMPONENT_PATTERN.md)**

## 🛠️ Công Nghệ Sử Dụng

### Core
- **UI**: SwiftUI
- **Architecture**: TCA (The Composable Architecture)
- **Dependency Injection**: Swinject
- **Ngôn ngữ**: Swift 5.9+

### Networking
- **HTTP Client**: Moya + Alamofire
- **Image Loading**: Kingfisher

### Data & Storage
- **Database**: Core Data / SwiftData (iOS 17+)
- **Secure Storage**: KeychainAccess
- **Cache**: NSCache + custom disk cache

### Firebase
- Analytics
- Crashlytics
- Remote Config
- Cloud Messaging (Push Notifications)

### Development Tools
- **Linting**: SwiftLint
- **Testing**: XCTest
- **CI/CD**: GitHub Actions

## 📚 Tài Liệu

### 📖 Documentation Chính

- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Kiến trúc modular, Swift Package structure
- **[COMPONENT_PATTERN.md](./COMPONENT_PATTERN.md)**: Parameterized Component Pattern guide
- **[SETUP.md](./SETUP.md)**: Hướng dẫn setup project với Xcode

### 🤖 AI Context & Rules

Tài liệu cho AI-assisted development trong thư mục `.ai/`:

- **[Code Conventions](./.ai/rules/code-conventions.md)**: Chuẩn code Swift
- **[Git Workflow](./.ai/rules/git-workflow.md)**: Quy trình branch và commit
- **[Testing Rules](./.ai/rules/testing-rules.md)**: Chiến lược và patterns testing
- **[TCA Agent](./.ai/agents/tca-agent.md)**: Hướng dẫn implement TCA
- **[UI Agent](./.ai/agents/ui-agent.md)**: SwiftUI best practices
- **[Component Pattern Rules](./.ai/rules/component-pattern-rules.md)**: Rules cho Parameterized Components ⭐

## 🧪 Kiểm Thử

Chạy tests:
```bash
# Tất cả tests
swift test

# Test cụ thể
swift test --filter LoginReducerTests

# Với coverage
xcodebuild test -scheme iOSTemplate -enableCodeCoverage YES
```

### Yêu Cầu Coverage
- Reducers: 90%+
- Business Logic: 80%+
- Utilities: 100%
- Tổng thể: 80%+

## 🎨 Hệ Thống Giao Diện

Project bao gồm hệ thống theme toàn diện:

```swift
// Colors
Text("Hello")
    .foregroundColor(.theme.primary)
    .background(Color.theme.background)

// Typography
Text("Title")
    .font(.theme.title)

// Components
PrimaryButton("Sign In") {
    // Action
}
```

## 🤖 Phát Triển với AI

Project này được tối ưu hóa cho phát triển có trợ giúp AI:

1. **Context Files**: `.ai/context/` chứa tổng quan project và thông tin sprint hiện tại
2. **Agent Instructions**: `.ai/agents/` có hướng dẫn chuyên biệt cho agents
3. **Templates**: `.ai/templates/` cung cấp code templates
4. **Conventions**: `.ai/rules/` định nghĩa coding standards

### Làm Việc với AI Agents

```bash
# Trước khi bắt đầu, AI nên đọc:
- .ai/context/project-overview.md
- .ai/context/current-sprint.md
- .ai/rules/code-conventions.md
- Hướng dẫn agents liên quan
```

## 📦 Tính Năng

### Tính Năng Core (Đã Bao Gồm)
- [x] App architecture với TCA
- [x] Hệ thống navigation (TabView + NavigationStack)
- [x] Hệ thống theme (Dark/Light mode)
- [x] Dependency injection
- [x] Storage layer
- [x] Network layer
- [x] Error handling
- [x] Logging system

### Modules Tùy Chọn
- [ ] Authentication (Email, Social, Biometric)
- [ ] Firebase integration
- [ ] In-App Purchases
- [ ] Localization (đa ngôn ngữ)
- [ ] Media handling (Camera, Photos)
- [ ] AI integration (OpenAI, Claude)

## 🚢 Triển Khai

### Build Configurations
- **Debug**: Development build với verbose logging
- **Staging**: QA build với staging API
- **Release**: Production build đã tối ưu

### Fastlane (Sắp Ra Mắt)
```bash
fastlane test        # Chạy tests
fastlane beta        # Deploy lên TestFlight
fastlane release     # Deploy lên App Store
```

## 🤝 Đóng Góp

Chúng tôi chào đón mọi đóng góp! Vui lòng làm theo các bước sau:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Tuân theo coding conventions trong `.ai/rules/`
4. Viết tests cho các thay đổi của bạn
5. Commit các thay đổi (`git commit -m 'feat: add amazing feature'`)
6. Push lên branch (`git push origin feature/amazing-feature`)
7. Mở Pull Request

Xem [CONTRIBUTING.md](./docs/CONTRIBUTING.md) để biết hướng dẫn chi tiết.

## 📄 Giấy Phép

Project này được cấp phép theo MIT License - xem file [LICENSE](LICENSE) để biết chi tiết.

## 🙏 Cảm Ơn

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) by Point-Free
- [Moya](https://github.com/Moya/Moya) cho networking
- [Kingfisher](https://github.com/onevcat/Kingfisher) cho image loading
- [Swinject](https://github.com/Swinject/Swinject) cho dependency injection

## 📞 Liên Hệ

- Chủ Sở Hữu Project: [Your Name]
- Email: [your.email@example.com]
- Issues: [GitHub Issues](https://github.com/yourusername/ios-template/issues)

---

**Trạng Thái**: 🚧 Phase 0-2 hoàn thành ✅

**Phiên Bản**: 0.1.0

**Cập Nhật Lần Cuối**: Tháng 11 năm 2024