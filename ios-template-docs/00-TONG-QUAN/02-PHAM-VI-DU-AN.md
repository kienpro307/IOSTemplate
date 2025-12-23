# 📋 Phạm Vi Dự Án (Project Scope)

## 1. Tổng Quan Phạm Vi

### 1.1 Định Nghĩa

Dự án **iOS Template** bao gồm việc xây dựng một codebase template hoàn chỉnh cho ứng dụng iOS, có thể tái sử dụng cho nhiều dự án khác nhau.

### 1.2 Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                        TRONG PHẠM VI                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • iOS App Template                                      │   │
│  │  • TCA Architecture                                      │   │
│  │  • Core Services (Network, Storage, Cache)               │   │
│  │  • Firebase Integration                                  │   │
│  │  • In-App Purchase                                       │   │
│  │  • Push Notifications                                    │   │
│  │  • Localization                                          │   │
│  │  • UI Component Library                                  │   │
│  │  • Unit & UI Tests                                       │   │
│  │  • CI/CD Pipeline                                        │   │
│  │  • Documentation                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      NGOÀI PHẠM VI                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ✗ iPad-specific layouts                                 │   │
│  │  ✗ macOS/watchOS/tvOS support                           │   │
│  │  ✗ Backend/Server development                           │   │
│  │  ✗ Custom ML models training                            │   │
│  │  ✗ Specific business logic (app-dependent)              │   │
│  │  ✗ App Store submission automation                      │   │
│  │  ✗ Marketing materials                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Chi Tiết Những Gì SẼ LÀM

### 2.1 Core Architecture

| Component | Mô tả | Priority |
|-----------|-------|----------|
| **TCA Setup** | The Composable Architecture với Store, Reducer, Action, State | P0 |
| **Dependency Injection** | Container để inject dependencies | P0 |
| **Navigation** | Tab + Stack navigation với TCA | P0 |
| **State Management** | Global state với local state | P0 |

### 2.2 Infrastructure Layer

| Component | Mô tả | Priority |
|-----------|-------|----------|
| **Network Client** | Moya-based API client | P0 |
| **Storage** | UserDefaults + Keychain wrappers | P0 |
| **Database** | Core Data / SwiftData setup | P1 |
| **Cache** | Memory + Disk cache | P1 |
| **File Manager** | File operations utilities | P2 |

### 2.3 Services Layer

| Service | Mô tả | Priority |
|---------|-------|----------|
| **Firebase Analytics** | Event tracking | P0 |
| **Firebase Crashlytics** | Crash reporting | P0 |
| **Firebase Remote Config** | Feature flags | P1 |
| **Firebase Cloud Messaging** | Push notifications | P1 |
| **In-App Purchase** | StoreKit 2 integration | P1 |
| **Advertising** | AdMob integration | P2 |

### 2.4 UI Layer

| Component | Mô tả | Priority |
|-----------|-------|----------|
| **Theme System** | Colors, Fonts, Spacing | P0 |
| **Button Components** | Primary, Secondary, Tertiary | P0 |
| **Form Components** | TextField, Toggle, Picker | P0 |
| **List Components** | Cells, Sections, Empty state | P1 |
| **Loading States** | Shimmer, Spinner, Progress | P1 |
| **Error States** | Toast, Alert, Full screen | P1 |

### 2.5 Feature Modules

| Feature | Mô tả | Priority |
|---------|-------|----------|
| **Onboarding** | First-time user experience | P1 |
| **Home** | Main screen template | P1 |
| **Settings** | App settings, Account management | P1 |

**Lưu ý:**
- App **KHÔNG** có Authentication
- App **KHÔNG** có Profile

### 2.6 Development Tools

| Tool | Mô tả | Priority |
|------|-------|----------|
| **SwiftLint** | Code linting | P0 |
| **SwiftFormat** | Code formatting | P1 |
| **Unit Tests** | XCTest setup | P0 |
| **UI Tests** | XCUITest setup | P2 |
| **GitHub Actions** | CI/CD pipeline | P1 |
| **Fastlane** | Deployment automation | P2 |

---

## 3. Chi Tiết Những Gì KHÔNG LÀM

### 3.1 Platform Support

❌ **iPad Layouts**
- Template chỉ focus iPhone
- iPad có thể hoạt động nhưng không tối ưu
- Sẽ xem xét trong version tương lai

❌ **macOS / watchOS / tvOS**
- Chỉ iOS
- Cross-platform là scope riêng

### 3.2 Backend

❌ **Server Development**
- Không bao gồm backend code
- Chỉ client-side
- API contracts sẽ được document

❌ **Database Backend**
- Không Firestore rules
- Không Cloud Functions
- Chỉ client SDK usage

### 3.3 Business Logic

❌ **App-Specific Features**
- Không e-commerce logic
- Không social features cụ thể
- Không domain-specific code

Template cung cấp **infrastructure**, không phải **business features**.

### 3.4 Advanced AI

❌ **ML Model Training**
- Không train models
- Chỉ integrate pre-trained models
- Core ML usage only

❌ **Complex AI Pipelines**
- Không AI orchestration
- Chỉ simple API calls to AI services

---

## 4. Deliverables (Sản Phẩm Bàn Giao)

### 4.1 Code Deliverables

```
📦 Deliverables
├── 📁 Source Code
│   ├── Complete Xcode project
│   ├── All Swift packages
│   ├── Configuration files
│   └── Resource files
│
├── 📁 Tests
│   ├── Unit tests (>80% coverage)
│   ├── UI tests (critical paths)
│   └── Mock data
│
└── 📁 CI/CD
    ├── GitHub Actions workflows
    ├── Fastlane configuration
    └── Build scripts
```

### 4.2 Documentation Deliverables

```
📚 Documentation
├── 📁 Architecture Docs
│   ├── System overview
│   ├── Module documentation
│   └── API documentation
│
├── 📁 Developer Guides
│   ├── Setup guide
│   ├── Coding conventions
│   └── Contribution guide
│
└── 📁 AI Context
    ├── Project context
    ├── Rules & conventions
    └── Code templates
```

### 4.3 Acceptance Criteria

| Deliverable | Criteria | Verification |
|-------------|----------|--------------|
| Source Code | Builds without errors | `xcodebuild build` |
| Source Code | No SwiftLint warnings | `swiftlint lint` |
| Unit Tests | Coverage > 80% | Coverage report |
| UI Tests | Critical paths pass | Test report |
| Documentation | All modules documented | Review checklist |
| CI/CD | Pipeline runs successfully | GitHub Actions |

---

## 5. Assumptions (Giả Định)

### 5.1 Technical Assumptions

1. **Development Environment**
   - macOS Sonoma hoặc mới hơn
   - Xcode 15.0 hoặc mới hơn
   - Swift 5.9 hoặc mới hơn

2. **Target Devices**
   - iPhone only (iPad adaptive)
   - iOS 16.0 minimum
   - Portrait orientation primary

3. **Third-Party Services**
   - Firebase project available
   - Apple Developer account active
   - AdMob account (nếu cần ads)

### 5.2 Process Assumptions

1. **Development Process**
   - Git-based workflow
   - Code review required
   - CI/CD for all merges

2. **Testing**
   - Unit tests for all logic
   - Manual QA for UI
   - TestFlight for beta

---

## 6. Constraints (Ràng Buộc)

### 6.1 Technical Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| iOS 16+ | Minimum deployment target | Không dùng APIs cũ |
| SwiftUI only | Không UIKit trừ khi bắt buộc | Giới hạn customization |
| SPM only | Không CocoaPods/Carthage | Một số libs không support |
| TCA | Bắt buộc dùng TCA | Learning curve |

### 6.2 Resource Constraints

| Constraint | Description | Mitigation |
|------------|-------------|------------|
| Time | Limited development time | Prioritize P0 features |
| Single developer | One person team | AI assistance |
| Budget | No paid tools/services | Use free tiers |

---

## 7. Dependencies (Phụ Thuộc)

### 7.1 External Dependencies

| Dependency | Type | Risk Level |
|------------|------|------------|
| Apple APIs | Platform | Low |
| Firebase SDK | Third-party | Medium |
| TCA Framework | Third-party | Low |
| Moya | Third-party | Low |
| Kingfisher | Third-party | Low |

### 7.2 Internal Dependencies

```
Module Dependencies:
───────────────────────────────────────────
UngDung (App)
    └── depends on: TinhNang, DichVu, GiaoDien, Loi

TinhNang (Features)
    └── depends on: DichVu, GiaoDien, Loi

DichVu (Services)
    └── depends on: Loi

GiaoDien (UI)
    └── depends on: Loi

Loi (Core)
    └── depends on: nothing (independent)
───────────────────────────────────────────
```

---

## 8. Success Criteria (Tiêu Chí Thành Công)

### 8.1 Must Have (Bắt Buộc)

- [ ] App builds and runs on simulator
- [ ] TCA architecture functioning
- [ ] Network calls working
- [ ] Storage working (UserDefaults, Keychain)
- [ ] Basic UI components available
- [ ] Core features working (Onboarding, Home, Settings)
- [ ] Unit tests passing

### 8.2 Should Have (Nên Có)

- [ ] Firebase Analytics integrated
- [ ] Crashlytics integrated
- [ ] Push notifications working
- [ ] Localization setup
- [ ] CI/CD pipeline working
- [ ] Documentation complete

### 8.3 Nice to Have (Tốt Nếu Có)

- [ ] In-App Purchase working
- [ ] AdMob integrated
- [ ] UI tests for critical paths
- [ ] Performance optimized
- [ ] Accessibility support

---

## 9. Change Management

### 9.1 Scope Change Process

```
┌─────────────────────────────────────────────────────────────┐
│                  SCOPE CHANGE PROCESS                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Request         2. Evaluate         3. Decide          │
│  ┌─────────┐       ┌─────────┐        ┌─────────┐         │
│  │ Submit  │  ───► │ Impact  │  ───►  │ Approve │         │
│  │ change  │       │ analysis│        │ /Reject │         │
│  └─────────┘       └─────────┘        └─────────┘         │
│                                             │               │
│                    4. Implement             │               │
│                    ┌─────────┐              │               │
│                    │ Update  │ ◄────────────┘               │
│                    │ docs &  │                              │
│                    │ code    │                              │
│                    └─────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 9.2 Out of Scope Requests

Nếu có yêu cầu ngoài phạm vi:

1. **Document** yêu cầu trong backlog
2. **Evaluate** cho phase tiếp theo
3. **Prioritize** dựa trên value/effort
4. **Implement** nếu được approve cho version mới

---

## 10. Glossary

| Thuật ngữ | Định nghĩa |
|-----------|------------|
| P0 | Priority 0 - Bắt buộc, không thể thiếu |
| P1 | Priority 1 - Quan trọng, nên có |
| P2 | Priority 2 - Tốt nếu có, có thể delay |
| TCA | The Composable Architecture |
| SPM | Swift Package Manager |
| IAP | In-App Purchase |
| FCM | Firebase Cloud Messaging |

---

*Tài liệu này định nghĩa rõ ràng phạm vi dự án. Mọi thay đổi phải qua quy trình change management.*
