# iOS Template

Modern iOS app template built with TCA (The Composable Architecture).

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/your-org/ios-template.git
cd ios-template

# Open in Xcode
open IOSTemplate.xcodeproj

# Build & Run
⌘R
```

## 📖 Documentation

**Comprehensive documentation available in [`docs/`](docs/README.md)**

### Quick Links

| Section | Description |
|---------|-------------|
| [Getting Started](docs/01-BAT-DAU/01-CAI-DAT.md) | Setup & installation |
| [Project Structure](docs/01-BAT-DAU/02-CAU-TRUC-DU-AN.md) | Understand the codebase |
| [Creating Features](docs/02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md) | TCA workflow guide |
| [Customizing](docs/04-CUSTOMIZE/01-DOI-TEN-APP.md) | Rebrand for your app |
| [FAQ](docs/05-THAM-KHAO/03-FAQ.md) | Common questions |

## 🎯 Features

- ✅ **TCA Architecture** - Predictable state management
- ✅ **Multi-Module** - Scalable structure (Core, UI, Services, Features)
- ✅ **Firebase** - Analytics, Crashlytics, Remote Config, Push Notifications
- ✅ **In-App Purchase** - StoreKit 2 implementation
- ✅ **Design System** - Colors, Typography, Components
- ✅ **Dark Mode** - Full support
- ✅ **Onboarding** - Customizable flow
- ✅ **Settings** - Theme, language, notifications

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Swift | 5.9+ | Language |
| iOS | 16.0+ | Platform |
| SwiftUI | - | UI Framework |
| TCA | 1.15+ | Architecture |
| Moya | 15.0+ | Network layer |
| Firebase | 11.0+ | Backend services |
| Kingfisher | 8.0+ | Image loading |
| KeychainAccess | 4.2+ | Secure storage |

## 📁 Project Structure

```
IOSTemplate/
├── Sources/
│   ├── App/              # Entry point & RootView
│   ├── Core/             # Foundation (Architecture, Dependencies, Navigation)
│   ├── UI/               # Design system & Components
│   ├── Services/         # External services (Firebase, Payment, Ads)
│   └── Features/         # Business features (Home, Settings, IAP, Onboarding)
├── Tests/
├── docs/                 # 📖 User documentation
└── ios-template-docs/    # Internal development docs
```

## 🎓 Learning Resources

New to TCA? Start here:

1. [Installation Guide](docs/01-BAT-DAU/01-CAI-DAT.md) - Get up and running
2. [Architecture Overview](docs/01-BAT-DAU/02-CAU-TRUC-DU-AN.md) - Understand the structure
3. [Create Your First Feature](docs/02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md) - Step-by-step tutorial
4. [Navigation Guide](docs/02-HUONG-DAN-SU-DUNG/03-NAVIGATION.md) - Tabs, stacks, modals, deep links

## 🤝 Contributing

See development docs in [`ios-template-docs/`](ios-template-docs/README.md) for AI guidelines and internal processes.

## 📄 License

MIT License

---

**For detailed documentation, visit [`docs/`](docs/README.md)**
