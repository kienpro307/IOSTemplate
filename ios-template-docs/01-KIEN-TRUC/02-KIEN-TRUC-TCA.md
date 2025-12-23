# 🔄 Kiến Trúc TCA Chi Tiết

## 1. TCA Overview

### 1.1 TCA là gì?

**TCA (The Composable Architecture)** là một framework để xây dựng ứng dụng theo cách:
- **Consistent** (Nhất quán): Một cách duy nhất để quản lý state
- **Testable** (Có thể test): Logic dễ dàng được test
- **Composable** (Có thể kết hợp): Features có thể được kết hợp
- **Ergonomic** (Tiện dụng): API đơn giản, dễ sử dụng

### 1.2 Core Concepts

```
┌─────────────────────────────────────────────────────────────────┐
│                      TCA CORE CONCEPTS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│  │    STATE    │    │   ACTION    │    │   REDUCER   │        │
│  │   (What)    │    │   (Event)   │    │   (How)     │        │
│  └─────────────┘    └─────────────┘    └─────────────┘        │
│                                                                 │
│                    ┌─────────────┐                             │
│                    │    STORE    │                             │
│                    │  (Runtime)  │                             │
│                    └─────────────┘                             │
│                                                                 │
│        ┌─────────┐   ┌─────────┐   ┌─────────────┐            │
│        │  EFFECT │   │   VIEW  │   │ DEPENDENCY  │            │
│        │(Side fx)│   │  (UI)   │   │ (Services)  │            │
│        └─────────┘   └─────────┘   └─────────────┘            │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. State (Trạng Thái)

### 2.1 State Definition

State là struct chứa **tất cả dữ liệu** mà feature cần để render UI và thực hiện logic.

```swift
import ComposableArchitecture

@Reducer
struct HomeReducer {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        // Data - Dữ liệu chính
        var products: [Product] = []
        var categories: [Category] = []
        
        // Loading states - Trạng thái tải
        var isLoading: Bool = false
        
        // Error states - Trạng thái lỗi
        var error: String?
        
        // Computed properties - Thuộc tính tính toán
        var hasProducts: Bool {
            !products.isEmpty
        }
    }
}
```

### 2.2 State Rules

| Rule | Mô tả | Ví dụ |
|------|-------|-------|
| **Equatable** | State phải Equatable | `struct State: Equatable` |
| **Value Type** | Dùng struct, không dùng class | `struct State` |
| **Flat** | Tránh nesting sâu | Tách child states |
| **Minimal** | Chỉ data cần thiết | Không duplicate |
| **Computed** | Dùng computed cho derived | `var hasProducts` |

---

## 3. Action (Hành Động)

### 3.1 Action Categories

```swift
enum Action: Equatable {
    // User actions - Hành động từ người dùng
    case onAppear
    case refreshButtonTapped
    case productTapped(Product.ID)
    case searchQueryChanged(String)
    
    // Internal actions - Hành động nội bộ từ effects
    case productsResponse(Result<[Product], Error>)
    case searchResponse(Result<[Product], Error>)
    
    // Delegate actions - Gửi lên parent reducer
    case delegate(Delegate)
    
    enum Delegate: Equatable {
        case productSelected(Product)
        case didComplete
    }
    
    // Child actions - Nhận từ child features
    case detail(DetailReducer.Action)
    
    // Binding actions - Cho two-way binding
    case binding(BindingAction<State>)
}
```

### 3.2 Action Naming Convention

| Loại | Convention | Ví dụ |
|------|------------|-------|
| User taps | `[element]Tapped` | `loginButtonTapped` |
| User changes | `[field]Changed` | `emailChanged(String)` |
| Lifecycle | `on[Event]` | `onAppear`, `onDisappear` |
| Response | `[action]Response` | `fetchResponse(Result<T, Error>)` |
| Delegate | `delegate(Delegate)` | `delegate(.didComplete)` |

---

## 4. Reducer

### 4.1 Reducer Structure

```swift
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable { /* ... */ }
    
    enum Action: Equatable { /* ... */ }
    
    // MARK: - Dependencies
    @Dependency(\.productService) var productService
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        // Binding reducer cho two-way binding
        BindingReducer()
        
        // Main reducer
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let products = try await productService.fetchProducts()
                    await send(.productsResponse(.success(products)))
                } catch: { error, send in
                    await send(.productsResponse(.failure(error)))
                }
                
            case .productsResponse(.success(let products)):
                state.isLoading = false
                state.products = products
                return .none
                
            case .productsResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .productTapped(let id):
                guard let product = state.products.first(where: { $0.id == id }) else {
                    return .none
                }
                return .send(.delegate(.productSelected(product)))
                
            case .delegate:
                // Parent sẽ handle
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
```

---

## 5. Effect (Hiệu Ứng)

### 5.1 Effect Types

```swift
// .none - Không có side effect
return .none

// .run - Async operation
return .run { send in
    let data = try await api.fetchData()
    await send(.dataResponse(.success(data)))
}

// .send - Gửi action ngay lập tức
return .send(.nextAction)

// .concatenate - Chạy tuần tự
return .concatenate(
    .send(.startLoading),
    .run { send in /* ... */ }
)

// .merge - Chạy song song
return .merge(
    .run { send in /* fetch A */ },
    .run { send in /* fetch B */ }
)

// .cancel - Hủy effect
return .cancel(id: CancelID.search)

// .cancellable - Có thể hủy
return .run { send in /* ... */ }
    .cancellable(id: CancelID.search)
```

### 5.2 Cancellation Pattern

```swift
enum CancelID { case search }

case .searchQueryChanged(let query):
    state.searchQuery = query
    
    guard !query.isEmpty else {
        return .cancel(id: CancelID.search)
    }
    
    return .run { send in
        try await Task.sleep(for: .milliseconds(300))
        let results = try await searchService.search(query)
        await send(.searchResponse(.success(results)))
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)
```

---

## 6. Dependencies

### 6.1 Defining Dependencies

```swift
// Protocol definition - Định nghĩa protocol
protocol ProductServiceProtocol: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: String) async throws -> Product
}

// Live implementation - Implementation thực tế
struct LiveProductService: ProductServiceProtocol {
    let networkClient: NetworkClientProtocol
    
    func fetchProducts() async throws -> [Product] {
        try await networkClient.request(.fetchProducts)
    }
    
    func fetchProduct(id: String) async throws -> Product {
        try await networkClient.request(.fetchProduct(id: id))
    }
}

// Mock implementation - Implementation giả cho test
struct MockProductService: ProductServiceProtocol {
    var products: [Product] = []
    var error: Error?
    
    func fetchProducts() async throws -> [Product] {
        if let error { throw error }
        return products
    }
    
    func fetchProduct(id: String) async throws -> Product {
        if let error { throw error }
        return products.first { $0.id == id } ?? Product.mock
    }
}

// Dependency key - Đăng ký dependency
struct ProductServiceKey: DependencyKey {
    static let liveValue: ProductServiceProtocol = LiveProductService(
        networkClient: LiveNetworkClient()
    )
    static let testValue: ProductServiceProtocol = MockProductService()
    static let previewValue: ProductServiceProtocol = MockProductService(
        products: Product.mockList
    )
}

extension DependencyValues {
    var productService: ProductServiceProtocol {
        get { self[ProductServiceKey.self] }
        set { self[ProductServiceKey.self] = newValue }
    }
}
```

### 6.2 Using Dependencies

```swift
@Reducer
struct HomeReducer {
    @Dependency(\.productService) var productService
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    
    // Sử dụng trong reducer body
    return .run { send in
        let products = try await productService.fetchProducts()
        await send(.productsResponse(.success(products)))
    }
}
```

---

## 7. Store & View

### 7.1 Creating Store

```swift
@main
struct MyApp: App {
    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

### 7.2 View Integration

```swift
struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        List {
            ForEach(store.products) { product in
                ProductRow(product: product)
                    .onTapGesture {
                        store.send(.productTapped(product.id))
                    }
            }
        }
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
```

---

## 8. Testing

### 8.1 Test Structure

```swift
@MainActor
func testFetchProductsSuccess() async {
    let mockProducts = [Product.mock]
    
    let store = TestStore(
        initialState: HomeReducer.State()
    ) {
        HomeReducer()
    } withDependencies: {
        $0.productService = MockProductService(products: mockProducts)
    }
    
    await store.send(.onAppear) {
        $0.isLoading = true
    }
    
    await store.receive(\.productsResponse.success) {
        $0.isLoading = false
        $0.products = mockProducts
    }
}

@MainActor
func testFetchProductsFailure() async {
    let mockError = NSError(domain: "test", code: 500)
    
    let store = TestStore(
        initialState: HomeReducer.State()
    ) {
        HomeReducer()
    } withDependencies: {
        $0.productService = MockProductService(error: mockError)
    }
    
    await store.send(.onAppear) {
        $0.isLoading = true
    }
    
    await store.receive(\.productsResponse.failure) {
        $0.isLoading = false
        $0.error = mockError.localizedDescription
    }
}
```

---

## 9. Best Practices

### 9.1 State Design
- Keep state flat (tránh nesting sâu)
- Use computed properties cho derived state
- Dùng IdentifiedArray cho collections

### 9.2 Action Design
- Name actions as past-tense events (đã xảy ra)
- Group related actions với enum
- Use delegate pattern cho parent communication

### 9.3 Reducer Design
- Keep reducers pure (không side effects trong switch)
- Use dependencies cho all external interactions
- Cancel in-flight effects khi cần

### 9.4 Testing
- Test all state mutations
- Test effect outputs
- Use exhaustive testing

---

*TCA giúp code predictable, testable, và maintainable. Follow conventions để tận dụng tối đa framework.*
