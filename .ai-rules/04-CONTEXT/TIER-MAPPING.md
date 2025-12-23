# Tier Mapping - Xác định Tier của Code

> File này giúp AI xác định code từ ios-template-home thuộc tier nào trong kiến trúc 4-tier

## Kiến Trúc 4-Tier

```
TIER 4: APPS        → App entry point
TIER 3: DOMAIN      → Features (business logic)
TIER 2: SERVICES    → External services integration
TIER 1: FOUNDATION  → Core, UI (base infrastructure)
```

## Mapping: ios-template-home → Tier mới

### TIER 1: FOUNDATION

| ios-template-home Path | Tier | Module hiện tại | Mô tả |
|------------------------|------|-----------------|-------|
| `Theme/Colors.swift` | TIER 1 | `UI/Theme/` | Design system - Foundation |
| `Theme/Typography.swift` | TIER 1 | `UI/Theme/` | Design system - Foundation |
| `Theme/Spacing.swift` | TIER 1 | `UI/Theme/` | Design system - Foundation |
| `Theme/Components/ButtonStyles.swift` | TIER 1 | `UI/Components/` | UI Components - Foundation |
| `Storage/UserDefaultsStorage.swift` | TIER 1 | `Core/Dependencies/` | Storage - Foundation |
| `Storage/KeychainStorage.swift` | TIER 1 | `Core/Dependencies/` | Storage - Foundation |
| `Network/NetworkService.swift` | TIER 1 | `Core/Dependencies/` | Network - Foundation |
| `Network/APITarget.swift` | TIER 1 | `Core/Dependencies/` | Network - Foundation |
| `Utilities/Cache/MemoryCache.swift` | TIER 1 | `Core/` | Cache - Foundation |
| `Utilities/Cache/DiskCache.swift` | TIER 1 | `Core/` | Cache - Foundation |
| `Utilities/Logger.swift` | TIER 1 | `Core/` | Logger - Foundation |

### TIER 2: SERVICES

| ios-template-home Path | Tier | Module hiện tại | Mô tả |
|------------------------|------|-----------------|-------|
| `Services/Firebase/FirebaseManager.swift` | TIER 2 | `Services/Firebase/` | Firebase integration - Services |
| `Services/Firebase/FirebaseAnalyticsService.swift` | TIER 2 | `Services/Firebase/` | Analytics - Services |
| `Services/Firebase/FirebaseCrashlyticsService.swift` | TIER 2 | `Services/Firebase/` | Crashlytics - Services |
| `Services/Firebase/FirebaseRemoteConfigService.swift` | TIER 2 | `Services/Firebase/` | Remote Config - Services |
| `Services/Firebase/FirebaseMessagingService.swift` | TIER 2 | `Services/Firebase/` | Push Notifications - Services |
| `Monetization/IAP/IAPService.swift` | TIER 2 | `Services/Payment/` | IAP - Services |
| `Monetization/Ads/AdMobManager.swift` | TIER 2 | `Services/Ads/` | AdMob - Services |
| `Services/AuthenticationService.swift` | TIER 2 | `Services/Auth/` | Auth - Services (nếu cần) |

### TIER 3: DOMAIN (App-specific)

| ios-template-home Path | Tier | Module hiện tại | Mô tả |
|------------------------|------|-----------------|-------|
| `Features/Home/HomeView.swift` | TIER 3 | `Features/Home/` | Business feature - Domain |
| `Features/Settings/SettingsView.swift` | TIER 3 | `Features/Settings/` | Business feature - Domain |
| `Features/Onboarding/OnboardingView.swift` | TIER 3 | `Features/Onboarding/` | Business feature - Domain |
| `Features/Profile/ProfileView.swift` | TIER 3 | `Features/Profile/` | Business feature - Domain |

### TIER 4: APPS

| ios-template-home Path | Tier | Module hiện tại | Mô tả |
|------------------------|------|-----------------|-------|
| `Core/AppReducer.swift` | TIER 4 | `App/` | App entry - Apps |
| `Core/AppState.swift` | TIER 4 | `App/` | App state - Apps |
| `Core/AppAction.swift` | TIER 4 | `App/` | App actions - Apps |
| `Features/Root/RootView.swift` | TIER 4 | `App/` | Root view - Apps |

---

## Module hiện tại → Tier

| Module hiện tại | Tier | Dependencies |
|-----------------|------|--------------|
| `Core/` | TIER 1 (FOUNDATION) | Không phụ thuộc gì |
| `UI/` | TIER 1 (FOUNDATION) | Chỉ phụ thuộc Core |
| `Services/` | TIER 2 (SERVICES) | Chỉ phụ thuộc Core |
| `Features/` | TIER 3 (DOMAIN) | Phụ thuộc Core, UI, Services |
| `App/` | TIER 4 (APPS) | Phụ thuộc tất cả |

---

## Quy tắc Kiểm tra Tier

### Khi copy code từ ios-template-home:

1. **Xác định tier của code cũ:**
   - Tra bảng mapping ở trên
   - Xác định code thuộc TIER nào

2. **Xác định tier của module đang làm:**
   - Xem task đang làm thuộc module nào (Core/UI/Services/Features/App)
   - Tra bảng "Module hiện tại → Tier" ở trên

3. **So sánh:**
   - Nếu **KHỚP** → Tiếp tục copy và adapt
   - Nếu **KHÔNG KHỚP** → **CẢNH BÁO** và hỏi user

### Ví dụ Cảnh báo:

```
⚠️ CẢNH BÁO KIẾN TRÚC - TIER KHÔNG KHỚP:

- Code từ ios-template-home: `Services/Firebase/FirebaseManager.swift`
- Tier của code cũ: TIER 2 (SERVICES)
- Module đang làm: `Core/` (TIER 1 - FOUNDATION)
- Vấn đề: Code thuộc TIER 2 nhưng đang làm ở TIER 1

Giải pháp đề xuất:
1. Tạo ở `Sources/Services/Firebase/FirebaseManager.swift` (đúng tier)
2. Hoặc tạo ở `Sources/Core/` nhưng cần xác nhận (sai tier)

Bạn muốn:
- [A] Tạo ở Services/ (đúng tier) ✅ RECOMMENDED
- [B] Tạo ở Core/ (cần giải thích lý do)
- [C] Bỏ qua task này
```

---

## Checklist trước khi copy code

- [ ] Xác định tier của code từ ios-template-home
- [ ] Xác định tier của module đang làm
- [ ] So sánh: Khớp hay không khớp?
- [ ] Nếu không khớp → Cảnh báo và hỏi user
- [ ] Chờ user quyết định trước khi tiếp tục

---

**Cập nhật lần cuối:** December 23, 2024

