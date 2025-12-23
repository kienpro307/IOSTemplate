# 🚨 ĐỌC TRƯỚC KHI LÀM VIỆC

## ⚠️ Quy Tắc Bắt Buộc

### 1. Ngôn Ngữ Code
```
✅ Code (tên hàm, biến, class, struct, enum): TIẾNG ANH
✅ Comment, documentation: TIẾNG VIỆT
```

### 2. Ví Dụ

```swift
// ✅ ĐÚNG
struct HomeReducer {
    struct State {
        var products: [Product] = []  // Danh sách sản phẩm
        var isLoading: Bool = false   // Đang tải dữ liệu
    }
    
    enum Action {
        case onAppear           // Khi view xuất hiện
        case productTapped(id)  // Khi tap vào sản phẩm
    }
}

// ❌ SAI - Không dùng tiếng Việt cho code
struct BoGiamTrangChu {
    var danhSachSanPham: [SanPham] = []
    var dangTai: Bool = false
}
```

### 3. App Không Có Authentication
- App này **KHÔNG** có tính năng đăng nhập/đăng ký
- **KHÔNG** tạo các tính năng liên quan đến user authentication
- Focus vào các tính năng chính của app

---

## 🏗️ Architecture (QUAN TRỌNG)

### 4. Multi-Module Architecture (4-Tier)

> 📖 **Chi tiết:** [08-MULTI-MODULE-ARCHITECTURE.md](../01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md)

```
TIER 4: APPS        → XTranslate, BankingApp (8+ apps)
TIER 3: DOMAIN      → XTranslateKit, BankingKit (app-specific)
TIER 2: SERVICES    → iOSMonetizationKit, iOSAnalyticsKit (shared)
TIER 1: FOUNDATION  → iOSLocationKit, iOSRemoteConfigKit (base)
```

### 5. TCA Pattern & SOLID Principles

> 📖 **Chi tiết:** [10-TCA-PATTERNS-SOLID.md](../01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md)

- Mọi feature phải dùng TCA
- State là struct, conform Equatable
- Action là enum
- Side effects qua Effect
- **SOLID Score: 9.8/10** - Tuân thủ nghiêm ngặt

### 6. Cross-Reducer Communication

```swift
// ✅ PATTERN 1: Parent Forwards (RECOMMENDED)
// Parent owns all states, forwards changes to children

// ❌ KHÔNG dùng Event Bus hoặc Global State
```

### 7. Startup Orchestration

> 📖 **Chi tiết:** [09-STARTUP-ORCHESTRATION.md](../01-KIEN-TRUC/09-STARTUP-ORCHESTRATION.md)

- **7-step startup flow**
- **Two-phase configuration** (giải quyết circular dependency)
- **Lazy consent mode** (recommended cho UX tốt)

---

## 📁 File Structure

### Single Feature
```
Features/
└── FeatureName/
    ├── FeatureNameReducer.swift
    ├── FeatureNameView.swift
    ├── Components/
    └── Models/
```

### Multi-Module Package
```
Package/
├── Package.swift
├── Sources/
│   └── ModuleName/
│       ├── Public/
│       └── Internal/
└── Tests/
    └── ModuleNameTests/
```

---

## ✅ Checklist Trước Khi Code

### Basic
- [ ] Code dùng tiếng Anh
- [ ] Comment dùng tiếng Việt
- [ ] Follow TCA pattern
- [ ] Không liên quan đến authentication

### Architecture
- [ ] Tuân thủ SOLID principles
- [ ] Dùng Parent Forwards pattern cho cross-reducer
- [ ] Dependencies qua @Dependency, không global
- [ ] Logic ở Reducer, không ở View

### Testing
- [ ] Có unit tests cho Reducer
- [ ] Mock dependencies properly
- [ ] Test các error cases

---

## 📚 Tài Liệu Cần Đọc

| Priority | Document | Mô tả |
|----------|----------|-------|
| 🔴 HIGH | [TCA Patterns & SOLID](../01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md) | Design patterns |
| 🔴 HIGH | [Multi-Module Architecture](../01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md) | 4-tier system |
| 🟡 MEDIUM | [Startup Orchestration](../01-KIEN-TRUC/09-STARTUP-ORCHESTRATION.md) | 7-step flow |
| 🟡 MEDIUM | [Code Templates](../05-CODE-TEMPLATES/) | Reducer, View templates |

---

## ⚡ Quick Reference

### TCA Reducer Template
```swift
@Reducer
struct FeatureReducer {
    @ObservableState
    struct State: Equatable {
        // State properties
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            // Delegate actions for parent
        }
    }
    
    @Dependency(\.someService) var someService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // Side effect
                }
            case .delegate:
                return .none
            }
        }
    }
}
```

### Anti-Patterns (TRÁNH)

```swift
// ❌ Business logic in View
struct BadView: View {
    var body: some View {
        Button("Load") {
            Task {
                let data = try await api.fetch() // ❌ SAI
            }
        }
    }
}

// ❌ Global state
class GlobalManager {
    static let shared = GlobalManager() // ❌ SAI
}

// ❌ Fat Reducer (quá nhiều logic)
// → Tách thành nhiều reducers nhỏ
```

---

*Đọc kỹ trước khi code để đảm bảo consistency và quality.*
