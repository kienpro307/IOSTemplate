# 📦 Tổng Quan Mô-đun (Module Overview)

## 1. Kiến Trúc Multi-Module (4-Tier)

> 📖 **Chi tiết:** [08-MULTI-MODULE-ARCHITECTURE.md](../01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md)

```
┌─────────────────────────────────────────────────────────────────┐
│                    4-TIER MODULE ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TIER 4: APPS (Ứng dụng)                                 │   │
│  │ XTranslate │ BankingApp │ HealthApp │ ... (8+ apps)     │   │
│  │ • Release độc lập                                       │   │
│  │ • Chọn version services riêng                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TIER 3: DOMAIN (Business Logic riêng từng app)          │   │
│  │ XTranslateKit │ BankingKit │ HealthKit                  │   │
│  │ • Logic riêng cho từng app                              │   │
│  │ • Không share giữa các apps                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TIER 2: SERVICES (Dịch vụ dùng chung)                   │   │
│  │ iOSMonetizationKit │ iOSAnalyticsKit │ iOSAuthKit       │   │
│  │ • Ads, IAP, Payment                                     │   │
│  │ • Update độc lập                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TIER 1: FOUNDATION (Nền tảng)                           │   │
│  │ iOSLocationKit │ iOSRemoteConfigKit │ iOSConsentKit     │   │
│  │ • Không dependencies ngoài Apple SDK                    │   │
│  │ • Cực kỳ ổn định                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Danh Sách Mô-đun Chi Tiết

### 2.1 TIER 1: FOUNDATION

| Module | Mục đích | Dependencies | Update |
|--------|----------|--------------|--------|
| **iOSLocationKit** | Location services | Apple SDK only | Hiếm |
| **iOSRemoteConfigKit** | Firebase Remote Config | Firebase | Hiếm |
| **iOSConsentKit** | ATT, CMP, Privacy | iOSLocationKit | Hiếm |

### 2.2 TIER 2: SERVICES

| Module | Mục đích | Dependencies | Update |
|--------|----------|--------------|--------|
| **iOSMonetizationKit** | Ads, IAP, Payment | Foundation + AdMob | Thường xuyên |
| **iOSAnalyticsKit** | Analytics, Tracking | Foundation + Firebase | Thường xuyên |
| **iOSAuthKit** | Auth services | Foundation | Tùy theo |

### 2.3 TIER 3: DOMAIN (App-specific)

| Module | Mục đích | Dependencies |
|--------|----------|--------------|
| **XTranslateKit** | Translation business logic | Foundation + Services |
| **BankingKit** | Banking business logic | Foundation + Services |
| **HealthKit** | Health business logic | Foundation + Services |

### 2.4 TIER 4: APPS

| App | Domain Kit | Description |
|-----|------------|-------------|
| **XTranslate** | XTranslateKit | Translation app |
| **BankingApp** | BankingKit | Banking app |
| **HealthApp** | HealthKit | Health app |

---

## 3. Legacy Module Structure (Single App)

> ⚠️ **Note:** Cấu trúc này dùng cho **single app**, không phải multi-app.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SINGLE APP MODULE HIERARCHY                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Level 0 (Foundation):                                          │
│  └── LOI (Core)                                                 │
│      • Không phụ thuộc module nào                               │
│      • Cung cấp base cho tất cả modules khác                   │
│                                                                 │
│  Level 1 (Infrastructure):                                      │
│  ├── GIAO_DIEN (UI)                                            │
│  │   • Phụ thuộc: LOI                                          │
│  │   • Design system, components                               │
│  │                                                              │
│  └── DICH_VU (Services)                                        │
│      • Phụ thuộc: LOI                                          │
│      • Firebase, Auth, Payment                                  │
│                                                                 │
│  Level 2 (Features):                                            │
│  └── TINH_NANG (Features)                                      │
│      • Phụ thuộc: LOI, GIAO_DIEN, DICH_VU                      │
│      • Business features                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Module Communication

### 4.1 Cross-Reducer Communication

> 📖 **Chi tiết:** [10-TCA-PATTERNS-SOLID.md](../01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md)

```
┌─────────────────────────────────────────────────────────────────┐
│                   MODULE COMMUNICATION                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Pattern 1: Parent Forwards (RECOMMENDED)                       │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │  UserFeature ──delegate──► AppFeature ──forward──► AdFeature│
│  │                                                           │ │
│  │  • Parent owns all states                                 │ │
│  │  • Children send delegate actions                         │ │
│  │  • Parent forwards to affected children                   │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Pattern 2: Dependency Injection (ADVANCED)                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                                                           │ │
│  │  AdFeature ──@Dependency──► UserStateReader               │ │
│  │                                                           │ │
│  │  • Feature injects state readers                          │ │
│  │  • More decoupled but complex                             │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Communication Rules

```
✅ ALLOWED:
• Upper layer → Lower layer (App → Domain → Service)
• Same layer via protocols (Service ↔ Service)
• Events/Delegates upward

❌ NOT ALLOWED:
• Lower layer → Upper layer directly
• Circular dependencies
• Direct coupling between apps
```

---

## 5. Adding New Module

### 5.1 Checklist

1. [ ] Xác định Tier phù hợp (Foundation/Services/Domain/Apps)
2. [ ] Tạo repo mới (nếu multi-repo)
3. [ ] Tạo Package.swift với dependencies đúng
4. [ ] Định nghĩa public API (protocols)
5. [ ] Implement code
6. [ ] Viết tests
7. [ ] Update documentation
8. [ ] Tag version (semantic versioning)

### 5.2 Version Pinning

```swift
// XTranslate/Package.swift
dependencies: [
    // ✅ EXACT VERSION - Kiểm soát hoàn toàn
    .package(
        url: "https://github.com/you/ios-foundation",
        exact: "1.5.2"
    )
]
```

---

## 6. Module Files

Chi tiết về từng module được mô tả trong các file:

| File | Mô tả |
|------|-------|
| `01-LOI/README.md` | Core module |
| `02-GIAO-DIEN/README.md` | UI module |
| `03-DICH-VU/README.md` | Services module |
| `04-TINH-NANG/README.md` | Features module |

---

## 7. Related Documents

| Document | Mô tả |
|----------|-------|
| [Multi-Module Architecture](../01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md) | Kiến trúc 4 tầng chi tiết |
| [TCA Patterns & SOLID](../01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md) | Cross-reducer communication |
| [Startup Orchestration](../01-KIEN-TRUC/09-STARTUP-ORCHESTRATION.md) | Service orchestration |

---

*Kiến trúc modular giúp code dễ maintain, test, và tái sử dụng cho 8+ apps.*
