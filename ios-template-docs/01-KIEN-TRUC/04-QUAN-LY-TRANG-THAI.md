# 🗃️ Quản Lý Trạng Thái (State Management)

## 1. Tổng Quan

### 1.1 State trong TCA

State là **nguồn sự thật duy nhất** (Single Source of Truth) cho toàn bộ ứng dụng.

```
┌─────────────────────────────────────────────────────────────────┐
│                      STATE HIERARCHY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌─────────────────────┐                     │
│                    │   APP STATE         │                     │
│                    │   (Root)            │                     │
│                    └──────────┬──────────┘                     │
│                               │                                 │
│           ┌───────────────────┼───────────────────┐            │
│           │                   │                   │            │
│           ▼                   ▼                   ▼            │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│    │ Feature A   │    │ Feature B   │    │ Feature C   │      │
│    │ State       │    │ State       │    │ State       │      │
│    └─────────────┘    └──────┬──────┘    └─────────────┘      │
│                              │                                  │
│                    ┌─────────┴─────────┐                       │
│                    ▼                   ▼                       │
│             ┌───────────┐       ┌───────────┐                  │
│             │ Child 1   │       │ Child 2   │                  │
│             │ State     │       │ State     │                  │
│             └───────────┘       └───────────┘                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. App State Structure

### 2.1 Root State

```swift
@Reducer
struct AppReducer {
    @ObservableState
    struct State: Equatable {
        // MARK: - Navigation
        var selectedTab: Tab = .home
        var path: StackState<Destination> = StackState()

        // MARK: - Feature States
        var home = HomeReducer.State()
        var search = SearchReducer.State()
        var settings = SettingsReducer.State()

        // MARK: - Presented States (Optional)
        @Presents var detail: DetailReducer.State?
        @Presents var alert: AlertState<Action.Alert>?

        // MARK: - Global States
        var isConnected: Bool = true
        var isGlobalLoading: Bool = false
        var appVersion: String = "1.0.0"
    }

    enum Tab: String, CaseIterable, Equatable {
        case home
        case search
        case notifications
        case settings
    }
}
```

### 2.2 Feature State

```swift
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        // MARK: - Data
        var products: [Product] = []
        var categories: [Category] = []

        // MARK: - Loading
        var loadingState: LoadingState = .idle

        // MARK: - Pagination
        var currentPage: Int = 1
        var hasMoreData: Bool = true

        // MARK: - Filters
        var selectedCategory: Category?
        var sortBy: SortOption = .newest

        // MARK: - UI State
        var isRefreshing: Bool = false
    }

    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum SortOption: String, CaseIterable {
        case newest
        case priceAsc = "price_asc"
        case priceDesc = "price_desc"
        case bestSeller = "best_seller"
    }
}
```

---

## 3. State Types

### 3.1 Loading State Pattern

```swift
// Generic loading state - Trạng thái loading tổng quát
enum LoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case failed(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    var error: String? {
        if case .failed(let message) = self { return message }
        return nil
    }
}

// Usage - Cách sử dụng
@ObservableState
struct State: Equatable {
    var users: LoadingState<[User]> = .idle
    var detail: LoadingState<Product> = .idle
}
```

### 3.2 Form State Pattern

```swift
@ObservableState
struct SettingsFormState: Equatable {
    // Fields - Các trường nhập liệu
    var theme: String = ""
    var language: String = ""
    var notificationsEnabled: Bool = true

    // Validation errors - Lỗi validation
    var nameError: String?
    var emailError: String?
    var phoneError: String?

    // Form state - Trạng thái form
    var isSubmitting: Bool = false
    var isSubmitted: Bool = false

    // Computed validation - Kiểm tra hợp lệ
    var isValid: Bool {
        !fullName.isEmpty &&
        email.contains("@") &&
        nameError == nil &&
        emailError == nil
    }
}
```

### 3.3 List State Pattern

```swift
@ObservableState
struct ListState: Equatable {
    // Data - Dữ liệu
    var items: IdentifiedArrayOf<Item> = []

    // Selection - Lựa chọn
    var selectedItemID: Item.ID?
    var isSelectionMode: Bool = false
    var selectedItemIDs: Set<Item.ID> = []

    // Pagination - Phân trang
    var page: Int = 1
    var pageSize: Int = 20
    var totalCount: Int = 0
    var hasMoreData: Bool { items.count < totalCount }

    // Loading - Trạng thái tải
    var isLoadingMore: Bool = false
    var isRefreshing: Bool = false

    // Search & Filter - Tìm kiếm và lọc
    var searchQuery: String = ""
    var filter: FilterOptions = .init()
}
```

---

## 4. State Scoping

### 4.1 Store Scoping

```swift
struct RootView: View {
    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabChanged)) {
            // Scope to child store - Scope xuống child store
            HomeView(
                store: store.scope(
                    state: \.home,
                    action: \.home
                )
            )
            .tabItem { Label("Home", systemImage: "house") }
            .tag(AppReducer.Tab.home)

            SettingsView(
                store: store.scope(
                    state: \.settings,
                    action: \.settings
                )
            )
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(AppReducer.Tab.settings)
        }
    }
}
```

### 4.2 Optional State (Presented)

```swift
// Parent state - State cha
@ObservableState
struct State: Equatable {
    @Presents var detail: DetailReducer.State?
}

// Parent reducer - Reducer cha
var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case .itemTapped(let id):
            state.detail = DetailReducer.State(itemID: id)
            return .none
        }
    }
    .ifLet(\.$detail, action: \.detail) {
        DetailReducer()
    }
}

// View
.sheet(item: $store.scope(state: \.detail, action: \.detail)) { detailStore in
    DetailView(store: detailStore)
}
```

---

## 5. State Persistence

### 5.1 UserDefaults Persistence

```swift
// Property wrapper cho persistent state
@propertyWrapper
struct Persisted<T: Codable>: Equatable where T: Equatable {
    private let key: String
    private let defaultValue: T

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data) else {
                return defaultValue
            }
            return value
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }

    init(wrappedValue: T, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
}

// Usage trong State
@ObservableState
struct SettingsState: Equatable {
    @Persisted(key: "theme") var theme: Theme = .system
    @Persisted(key: "language") var language: Language = .vietnamese
    @Persisted(key: "notifications") var notificationsEnabled: Bool = true
}
```

---

## 6. Best Practices

```
┌─────────────────────────────────────────────────────────────────┐
│                    STATE DESIGN RULES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✅ DO:                                                         │
│  • Keep state flat (avoid deep nesting)                        │
│  • Use computed properties for derived state                   │
│  • Make state Equatable for diffing                            │
│  • Use IdentifiedArray for collections                         │
│  • Separate UI state from data state                           │
│                                                                 │
│  ❌ DON'T:                                                      │
│  • Store UI-only state (animations, gestures)                  │
│  • Duplicate data across states                                │
│  • Store computed values                                        │
│  • Use reference types in state                                │
│  • Over-nest child states                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### State Checklist

- [ ] State là struct, conform Equatable
- [ ] Không có computed values được lưu
- [ ] Loading states được handle
- [ ] Error states được handle
- [ ] Optional states dùng @Presents
- [ ] Collections dùng IdentifiedArrayOf

---

_State management là nền tảng của app. Thiết kế state tốt giúp app dễ debug và maintain._
