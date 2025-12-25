# 🎯 TCA Patterns & SOLID Principles

## 1. SOLID Principles trong TCA

### 1.1 Overall Assessment

```
┌─────────────────────────────────────────────────────────────┐
│                 TCA SOLID COMPLIANCE SCORE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ S - Single Responsibility     ████████████░ 9.5/10  │   │
│  │ O - Open/Closed               █████████████ 10/10   │   │
│  │ L - Liskov Substitution       █████████████ 10/10   │   │
│  │ I - Interface Segregation     █████████████ 10/10   │   │
│  │ D - Dependency Inversion      ████████████░ 9.5/10  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ OVERALL SCORE                 ████████████░ 9.8/10  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Chi Tiết Từng Nguyên Tắc

#### S - Single Responsibility Principle (9.5/10)

```swift
// ✅ TCA tuân thủ tốt
// Mỗi component có 1 trách nhiệm duy nhất:

struct ProductFeature {
    // State: CHỈ chứa data
    @ObservableState
    struct State: Equatable {
        var products: [Product] = []
        var isLoading: Bool = false
    }

    // Action: CHỈ định nghĩa events
    enum Action {
        case loadProducts
        case productsLoaded([Product])
    }

    // Reducer: CHỈ xử lý logic
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Business logic here
        }
    }
}

// View: CHỈ render UI
struct ProductView: View {
    @Bindable var store: StoreOf<ProductFeature>
    var body: some View { /* UI only */ }
}
```

**Điểm trừ (-0.5)**: Reducer đôi khi có thể phình to nếu không tách tốt.

#### O - Open/Closed Principle (10/10)

```swift
// ✅ TCA xuất sắc ở điểm này
// Mở rộng bằng composition, không cần sửa code cũ

// Ban đầu
@Reducer
struct ProductFeature {
    var body: some ReducerOf<Self> {
        Reduce { state, action in /* logic */ }
    }
}

// Mở rộng thêm analytics - KHÔNG SỬA CODE CŨ
@Reducer
struct ProductFeature {
    var body: some ReducerOf<Self> {
        Reduce { state, action in /* logic */ }

        // Thêm mới bằng composition
        AnalyticsReducer()  // ✅ Extension
    }
}
```

#### L - Liskov Substitution Principle (10/10)

```swift
// ✅ TCA sử dụng protocols và dependency injection hoàn hảo

// Protocol definition
protocol ProductServiceProtocol {
    func fetchProducts() async throws -> [Product]
}

// Live implementation
struct LiveProductService: ProductServiceProtocol {
    func fetchProducts() async throws -> [Product] {
        // Real API call
    }
}

// Mock implementation - Có thể thay thế hoàn toàn
struct MockProductService: ProductServiceProtocol {
    var products: [Product] = []
    func fetchProducts() async throws -> [Product] {
        return products
    }
}

// Cả hai đều có thể dùng thay thế nhau ✅
```

#### I - Interface Segregation Principle (10/10)

```swift
// ✅ TCA khuyến khích interfaces nhỏ, focused

// ❌ Interface quá lớn
protocol AppServiceProtocol {
    func fetchProducts() async throws -> [Product]
    func fetchUsers() async throws -> [User]
    func sendAnalytics() async throws
    func processPayment() async throws
}

// ✅ Interfaces nhỏ, tách biệt
protocol ProductServiceProtocol {
    func fetchProducts() async throws -> [Product]
}

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
}

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent) async
}

// Mỗi feature chỉ depend vào interface cần thiết
@Dependency(\.productService) var productService  // Chỉ cần products
```

#### D - Dependency Inversion Principle (9.5/10)

```swift
// ✅ TCA có @Dependency system tuyệt vời

// High-level module (Reducer) không depend on low-level module
@Reducer
struct ProductFeature {
    // Depend on abstraction, not implementation
    @Dependency(\.productService) var productService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Dùng productService mà không cần biết implementation
        }
    }
}

// Dependency registration
struct ProductServiceKey: DependencyKey {
    static let liveValue: ProductServiceProtocol = LiveProductService()
    static let testValue: ProductServiceProtocol = MockProductService()
}
```

**Điểm trừ (-0.5)**: Phải manual register dependencies.

---

## 2. Cross-Reducer Communication

### 2.1 Vấn Đề

```
Feature A cần data từ Feature B
Ví dụ: AdFeature cần biết:
- User có premium không? (từ UserFeature)
- Ads có enabled trong config không? (từ ConfigFeature)

❓ Làm sao để AdFeature biết được?
```

### 2.2 Pattern 1: Parent Forwards (RECOMMENDED)

```swift
// ✅ PATTERN 1: Parent forwards data xuống children

// Parent owns all states
@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var user = UserFeature.State()
        var config = ConfigFeature.State()
        var ad = AdFeature.State()
    }

    enum Action {
        case user(UserFeature.Action)
        case config(ConfigFeature.Action)
        case ad(AdFeature.Action)
    }

    var body: some ReducerOf<Self> {
        // Compose children
        Scope(state: \.user, action: \.user) { UserFeature() }
        Scope(state: \.config, action: \.config) { ConfigFeature() }
        Scope(state: \.ad, action: \.ad) { AdFeature() }

        // Parent forwards changes
        Reduce { state, action in
            switch action {
            // User premium status changed
            case .user(.delegate(.premiumStatusChanged(let isPremium))):
                // Forward to Ad
                return .send(.ad(.userPremiumStatusChanged(isPremium)))

            // Config ads setting changed
            case .config(.delegate(.adsEnabledChanged(let enabled))):
                // Forward to Ad
                return .send(.ad(.configAdsEnabledChanged(enabled)))

            default:
                return .none
            }
        }
    }
}

// AdFeature receives updates
@Reducer
struct AdFeature {
    @ObservableState
    struct State: Equatable {
        // ⭐ Ad owns shouldShowAd logic
        var shouldShowAd: Bool = false
        var isInitialized: Bool = false

        // Data received from outside
        var isPremiumUser: Bool = false
        var adsEnabledInConfig: Bool = true

        mutating func recalculate() {
            shouldShowAd = adsEnabledInConfig &&
                          isInitialized &&
                          !isPremiumUser
        }
    }

    enum Action {
        case initialize
        case initialized

        // ⭐ Receive updates from parent
        case userPremiumStatusChanged(Bool)
        case configAdsEnabledChanged(Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initialized:
                state.isInitialized = true
                state.recalculate()
                return .none

            case .userPremiumStatusChanged(let isPremium):
                state.isPremiumUser = isPremium
                state.recalculate()  // ⭐ AdFeature owns this logic
                return .none

            case .configAdsEnabledChanged(let enabled):
                state.adsEnabledInConfig = enabled
                state.recalculate()  // ⭐ AdFeature owns this logic
                return .none
            }
        }
    }
}
```

**Pros:**

- ✅ SOLID compliant (SRP: mỗi feature owns logic của nó)
- ✅ Easy to understand flow
- ✅ Easy to test
- ✅ No circular dependencies

**Cons:**

- ⚠️ Parent cần biết tất cả relationships
- ⚠️ Nhiều forwarding code

### 2.3 Pattern 2: Dependency Injection (ADVANCED)

```swift
// ✅ PATTERN 2: Inject other feature's state reader

// Shared state interface
protocol UserStateReader {
    var isPremium: Bool { get }
}

protocol ConfigStateReader {
    var isAdsEnabled: Bool { get }
}

// AdFeature reads from dependencies
@Reducer
struct AdFeature {
    @Dependency(\.userStateReader) var userStateReader
    @Dependency(\.configStateReader) var configStateReader

    @ObservableState
    struct State: Equatable {
        var shouldShowAd: Bool = false
        var isInitialized: Bool = false

        mutating func recalculate(
            isPremium: Bool,
            adsEnabled: Bool
        ) {
            shouldShowAd = adsEnabled && isInitialized && !isPremium
        }
    }

    enum Action {
        case checkShouldShowAd
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkShouldShowAd:
                // Read from dependencies
                let isPremium = userStateReader.isPremium
                let adsEnabled = configStateReader.isAdsEnabled
                state.recalculate(isPremium: isPremium, adsEnabled: adsEnabled)
                return .none
            }
        }
    }
}
```

**Pros:**

- ✅ More decoupled
- ✅ AdFeature doesn't know about parent

**Cons:**

- ⚠️ More complex setup
- ⚠️ Harder to trace data flow

### 2.4 Pattern 3: Event Bus (NOT RECOMMENDED for TCA)

```swift
// ❌ NOT RECOMMENDED in TCA
// Shown for comparison only

class EventBus {
    static let shared = EventBus()

    func publish(_ event: AppEvent) {
        // Broadcast to all subscribers
    }

    func subscribe(to eventType: AppEvent.Type, handler: @escaping (AppEvent) -> Void) {
        // Subscribe
    }
}

// Problems:
// ❌ Global state
// ❌ Hard to test
// ❌ Hard to trace
// ❌ Against TCA philosophy
```

### 2.5 Pattern Comparison

| Pattern              | Complexity | Testability | SOLID | When to use    |
| -------------------- | ---------- | ----------- | ----- | -------------- |
| Parent Forwards ✅   | Low        | High        | ✅    | Default choice |
| Dependency Injection | Medium     | High        | ✅    | Complex apps   |
| Event Bus ❌         | Low        | Low         | ❌    | Never in TCA   |

---

## 3. Clean Architecture Score

### 3.1 Assessment

```
┌─────────────────────────────────────────────────────────────┐
│              CLEAN ARCHITECTURE COMPLIANCE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Separation of Concerns    █████████████ 10/10       │   │
│  │ Dependency Rule           ████████████░ 9.5/10      │   │
│  │ Testability               █████████████ 10/10       │   │
│  │ Framework Independence    ████████████░ 9.5/10      │   │
│  │ UI Independence           █████████████ 10/10       │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ OVERALL SCORE             ████████████░ 9.8/10      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Layers Mapping

```
Clean Architecture          TCA Mapping
─────────────────────────────────────────────────────
Entities                    Models, Domain objects
Use Cases                   Reducer logic, Effects
Interface Adapters          Dependencies, Clients
Frameworks & Drivers        SwiftUI Views, URLSession

┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                      VIEW                           │   │
│  │                   (SwiftUI)                         │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    REDUCER                          │   │
│  │               (Business Logic)                      │   │
│  │   ┌───────────────────────────────────────────┐    │   │
│  │   │ State │ Action │ Reduce │ Effects        │    │   │
│  │   └───────────────────────────────────────────┘    │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  DEPENDENCIES                       │   │
│  │              (External Services)                    │   │
│  │   ┌────────┐  ┌────────┐  ┌────────┐              │   │
│  │   │API     │  │Storage │  │Firebase│              │   │
│  │   │Client  │  │Client  │  │Client  │              │   │
│  │   └────────┘  └────────┘  └────────┘              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Design Patterns trong TCA

### 4.1 Patterns Used

| Pattern       | TCA Implementation    | Usage                     |
| ------------- | --------------------- | ------------------------- |
| State Machine | Reducer + State       | Core pattern              |
| Command       | Action enum           | All user events           |
| Observer      | Store subscription    | View binding              |
| Factory       | Dependency system     | Service creation          |
| Composite     | Reducer composition   | Feature combination       |
| Decorator     | Reducer operators     | Logging, analytics        |
| Strategy      | Protocol dependencies | Swappable implementations |

### 4.2 State Machine Pattern

```swift
// TCA Reducer = State Machine

@Reducer
struct AuthFeature {
    // States
    enum AuthState: Equatable {
        case loggedOut
        case loggingIn
        case loggedIn(User)
        case error(String)
    }

    @ObservableState
    struct State: Equatable {
        var authState: AuthState = .loggedOut
    }

    // Events (Transitions)
    enum Action {
        case loginTapped
        case loginSuccess(User)
        case loginFailure(Error)
        case logoutTapped
    }

    // Transition Logic
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch (state.authState, action) {
            // loggedOut + loginTapped → loggingIn
            case (.loggedOut, .loginTapped):
                state.authState = .loggingIn
                return .run { /* perform login */ }

            // loggingIn + success → loggedIn
            case (.loggingIn, .loginSuccess(let user)):
                state.authState = .loggedIn(user)
                return .none

            // loggingIn + failure → error
            case (.loggingIn, .loginFailure(let error)):
                state.authState = .error(error.localizedDescription)
                return .none

            // loggedIn + logout → loggedOut
            case (.loggedIn, .logoutTapped):
                state.authState = .loggedOut
                return .none

            default:
                return .none
            }
        }
    }
}
```

### 4.3 Composite Pattern

```swift
// Compose multiple reducers

@Reducer
struct AppFeature {
    var body: some ReducerOf<Self> {
        // Compose features
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        // Core logic
        Reduce { state, action in
            // Root-level logic
        }
    }
}
```

### 4.4 Decorator Pattern

```swift
// Add behavior without modifying original

// Original reducer
@Reducer
struct ProductFeature { /* ... */ }

// Decorated with logging
extension Reducer {
    func logging() -> some ReducerOf<Self> {
        Reduce { state, action in
            print("📝 Action: \(action)")
            let effect = self.reduce(into: &state, action: action)
            print("📊 New state: \(state)")
            return effect
        }
    }
}

// Usage
@Reducer
struct AppFeature {
    var body: some ReducerOf<Self> {
        ProductFeature()
            .logging()  // ✅ Decorated
    }
}
```

---

## 5. Testability

### 5.1 Testing Score

```
┌─────────────────────────────────────────────────────────────┐
│                   TESTABILITY SCORE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Unit Tests                 █████████████ 100%             │
│  ├── Reducer logic          Easy to test                   │
│  ├── State transitions      Predictable                    │
│  └── Effects                Mockable dependencies          │
│                                                             │
│  Integration Tests          █████████████ 100%             │
│  ├── Feature composition    TestStore                     │
│  └── Side effects          Controlled environment         │
│                                                             │
│  UI Tests                   ████████████░ 95%              │
│  └── View rendering         Snapshot tests possible        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Unit Test Example

```swift
@MainActor
func testLoadProducts() async {
    let mockProducts = [Product.mock]

    let store = TestStore(
        initialState: ProductFeature.State()
    ) {
        ProductFeature()
    } withDependencies: {
        $0.productService.fetchProducts = { mockProducts }
    }

    await store.send(.loadProducts) {
        $0.isLoading = true
    }

    await store.receive(.productsLoaded(mockProducts)) {
        $0.isLoading = false
        $0.products = mockProducts
    }
}

@MainActor
func testLoadProductsFailure() async {
    struct TestError: Error {}

    let store = TestStore(
        initialState: ProductFeature.State()
    ) {
        ProductFeature()
    } withDependencies: {
        $0.productService.fetchProducts = { throw TestError() }
    }

    await store.send(.loadProducts) {
        $0.isLoading = true
    }

    await store.receive(.loadFailed) {
        $0.isLoading = false
        $0.error = "Failed to load"
    }
}
```

---

## 6. Common Anti-Patterns

### 6.1 Các Lỗi Thường Gặp

```
┌─────────────────────────────────────────────────────────────┐
│                    ANTI-PATTERNS                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ❌ Fat Reducer                                             │
│  Reducer quá lớn, làm quá nhiều việc                       │
│  → Tách thành nhiều reducers nhỏ                           │
│                                                             │
│  ❌ Business Logic in View                                  │
│  View chứa logic xử lý                                     │
│  → Di chuyển vào Reducer                                   │
│                                                             │
│  ❌ Direct State Mutation in View                          │
│  View trực tiếp thay đổi state                            │
│  → Luôn qua Action                                         │
│                                                             │
│  ❌ Global Dependencies                                     │
│  Sử dụng singleton global                                  │
│  → Dùng @Dependency system                                 │
│                                                             │
│  ❌ Circular Dependencies                                   │
│  Feature A depends B, B depends A                          │
│  → Parent forwards pattern                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Before/After Examples

```swift
// ❌ BEFORE: Business logic in View
struct ProductView: View {
    @State var products: [Product] = []

    var body: some View {
        List(products) { product in
            Text(product.name)
        }
        .onAppear {
            // ❌ Logic in View
            Task {
                products = try await APIClient.fetchProducts()
            }
        }
    }
}

// ✅ AFTER: Logic in Reducer
struct ProductView: View {
    @Bindable var store: StoreOf<ProductFeature>

    var body: some View {
        List(store.products) { product in
            Text(product.name)
        }
        .onAppear {
            // ✅ Just send action
            store.send(.onAppear)
        }
    }
}

@Reducer
struct ProductFeature {
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // ✅ Logic in Reducer
                    let products = try await apiClient.fetchProducts()
                    await send(.productsLoaded(products))
                }
            }
        }
    }
}
```

---

## 7. Migration Strategy

### 7.1 Từ MVVM sang TCA

```
Phase 1: Identify components
├── ViewModel → Reducer
├── Model → State
├── View bindings → Store

Phase 2: Create TCA structure
├── Define State struct
├── Define Action enum
├── Implement Reducer

Phase 3: Update Views
├── Replace @StateObject với Store
├── Replace method calls với store.send()
├── Replace bindings với $store

Phase 4: Test
├── Write unit tests cho Reducer
└── Verify UI behavior
```

### 7.2 Example Migration

```swift
// ❌ BEFORE: MVVM
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false

    func loadProducts() {
        isLoading = true
        Task {
            products = try await apiClient.fetchProducts()
            isLoading = false
        }
    }
}

// ✅ AFTER: TCA
@Reducer
struct ProductFeature {
    @ObservableState
    struct State: Equatable {
        var products: [Product] = []
        var isLoading = false
    }

    enum Action {
        case loadProducts
        case productsLoaded([Product])
    }

    @Dependency(\.apiClient) var apiClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadProducts:
                state.isLoading = true
                return .run { send in
                    let products = try await apiClient.fetchProducts()
                    await send(.productsLoaded(products))
                }
            case .productsLoaded(let products):
                state.isLoading = false
                state.products = products
                return .none
            }
        }
    }
}
```

---

## 8. Summary

### Key Takeaways

1. **TCA đạt 9.8/10 SOLID compliance** - Architecture rất solid
2. **Parent Forwards là pattern mặc định** cho cross-reducer communication
3. **Clean Architecture mapping tự nhiên** với TCA
4. **100% testable** với TestStore
5. **Tránh anti-patterns** bằng cách follow conventions

### Recommendations

| Situation            | Recommendation               |
| -------------------- | ---------------------------- |
| New project          | Start with TCA               |
| Existing MVVM        | Migrate gradually            |
| Cross-reducer data   | Parent Forwards pattern      |
| Complex dependencies | Dependency Injection pattern |
| Testing              | Always use TestStore         |

---

_TCA không chỉ là architecture, mà là cách tư duy về state management đúng đắn._
