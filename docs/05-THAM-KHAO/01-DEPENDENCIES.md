# Dependencies Reference

Danh sách tất cả dependencies trong iOS Template.

---

## Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **TCA** | 1.15+ | Architecture framework |
| **Moya** | 15.0+ | Network layer |
| **Kingfisher** | 8.0+ | Image loading & caching |
| **KeychainAccess** | 4.2+ | Secure storage |
| **Firebase** | 11.0+ | Analytics, Crashlytics, etc. |

---

## Firebase Modules

| Module | Purpose |
|--------|---------|
| FirebaseCore | Core Firebase |
| FirebaseAnalytics | Event tracking |
| FirebaseCrashlytics | Crash reporting |
| FirebaseMessaging | Push notifications |
| FirebaseRemoteConfig | Feature flags |

---

## Version Requirements

- **Swift**: 5.9+
- **iOS**: 16.0+
- **Xcode**: 15.0+
- **macOS**: 13.0+ (Ventura)

---

## Update Dependencies

```bash
# Update to latest
Xcode → File → Packages → Update to Latest Package Versions

# Or in Package.swift
.package(url: "...", from: "2.0.0")  // Change version
```

---

## Xem Thêm

- [Thêm Dependency](../04-CUSTOMIZE/02-THEM-DEPENDENCY.md)
- [Cài Đặt](../01-BAT-DAU/01-CAI-DAT.md)

