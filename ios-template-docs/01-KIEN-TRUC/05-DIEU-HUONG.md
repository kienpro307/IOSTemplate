# 🧭 Điều Hướng (Navigation)

## 1. Navigation Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    NAVIGATION STRUCTURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                     ┌─────────────────┐                        │
│                     │   Root View     │                        │
│                     │   (Conditional) │                        │
│                     └────────┬────────┘                        │
│                              │                                  │
│              ┌───────────────┴───────────────┐                 │
│              │                               │                 │
│              ▼                               ▼                 │
│       ┌───────────┐                   ┌───────────┐           │
│       │Onboarding │                   │   Main    │           │
│       │  (First)  │                   │  (Tabs)   │           │
│       └───────────┘                   └─────┬─────┘           │
│                                             │                  │
│              ┌──────────────┬───────────────┼────────┐        │
│              ▼              ▼               ▼        ▼        │
│         ┌────────┐    ┌────────┐    ┌────────┐ ┌────────┐    │
│         │  Home  │    │ Search │    │ Notif  │ │Settings│    │
│         │ Stack  │    │ Stack  │    │ Stack  │ │ Stack  │    │
│         └────────┘    └────────┘    └────────┘ └────────┘    │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Root Navigation

### 2.1 Conditional Root View

```swift
struct RootView: View {
    @Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
        Group {
            if store.isCheckingFirstLaunch {
                // Splash/Loading
                SplashView()
            } else if store.shouldShowOnboarding {
                // First time - Onboarding
                OnboardingView(
                    store: store.scope(
                        state: \.onboarding,
                        action: \.onboarding
                    )
                )
            } else {
                // Main app
                MainTabView(store: store)
            }
        }
        .animation(.default, value: store.shouldShowOnboarding)
    }
}
```

---

## 3. Tab Navigation

### 3.1 Tab State

```swift
@Reducer
struct AppReducer {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        
        // Tab badges
        var notificationBadgeCount: Int = 0
    }
    
    enum Tab: String, CaseIterable {
        case home
        case search
        case notifications
        case settings
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .notifications: return "bell"
            case .settings: return "gear"
            }
        }
        
        var title: String {
            switch self {
            case .home: return "Trang chủ"
            case .search: return "Tìm kiếm"
            case .notifications: return "Thông báo"
            case .settings: return "Cài đặt"
            }
        }
    }
}
```

### 3.2 Tab View

```swift
struct MainTabView: View {
    @Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabChanged)) {
            ForEach(AppReducer.Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
                    .badge(badge(for: tab))
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppReducer.Tab) -> some View {
        switch tab {
        case .home:
            HomeView(store: store.scope(state: \.home, action: \.home))
        case .search:
            SearchView(store: store.scope(state: \.search, action: \.search))
        case .notifications:
            NotificationsView(store: store.scope(state: \.notifications, action: \.notifications))
        case .settings:
            SettingsView(store: store.scope(state: \.settings, action: \.settings))
        }
    }
    
    private func badge(for tab: AppReducer.Tab) -> Int {
        switch tab {
        case .notifications: return store.notificationBadgeCount
        default: return 0
        }
    }
}
```

---

## 4. Stack Navigation

### 4.1 NavigationStack với TCA

```swift
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Destination.State>()
    }
    
    enum Action {
        case path(StackActionOf<Destination>)
        case productTapped(Product.ID)
        case categoryTapped(Category.ID)
    }
    
    @Reducer
    enum Destination {
        case productDetail(ProductDetailReducer)
        case categoryList(CategoryListReducer)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .productTapped(let id):
                state.path.append(.productDetail(.init(productID: id)))
                return .none
                
            case .categoryTapped(let id):
                state.path.append(.categoryList(.init(categoryID: id)))
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
```

### 4.2 NavigationStack View

```swift
struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            // Root content
            ProductListView(store: store)
                .navigationTitle("Trang chủ")
        } destination: { store in
            switch store.case {
            case .productDetail(let detailStore):
                ProductDetailView(store: detailStore)
                
            case .categoryList(let categoryStore):
                CategoryListView(store: categoryStore)
            }
        }
    }
}
```

---

## 5. Modal Presentation

### 5.1 Sheet

```swift
@ObservableState
struct State: Equatable {
    @Presents var editSheet: EditReducer.State?
}

// Reducer
.ifLet(\.$editSheet, action: \.editSheet) {
    EditReducer()
}

// View
.sheet(item: $store.scope(state: \.editSheet, action: \.editSheet)) { editStore in
    EditView(store: editStore)
}
```

### 5.2 Full Screen Cover

```swift
.fullScreenCover(
    item: $store.scope(state: \.imageViewer, action: \.imageViewer)
) { imageStore in
    FullScreenImageView(store: imageStore)
}
```

### 5.3 Alert

```swift
@ObservableState
struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
}

enum Action {
    case alert(PresentationAction<Alert>)
    
    enum Alert {
        case confirmDelete
        case cancel
    }
}

// Show alert - Hiển thị alert
state.alert = AlertState {
    TextState("Xác nhận xóa?")
} actions: {
    ButtonState(role: .destructive, action: .confirmDelete) {
        TextState("Xóa")
    }
    ButtonState(role: .cancel, action: .cancel) {
        TextState("Hủy")
    }
} message: {
    TextState("Bạn có chắc muốn xóa item này?")
}

// View
.alert($store.scope(state: \.alert, action: \.alert))
```

---

## 6. Deep Linking

### 6.1 URL Handling

```swift
enum DeepLink: Equatable {
    case product(id: String)
    case category(id: String)
    case settings
    case notification(id: String)
    
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return nil
        }
        
        let pathComponents = components.path.split(separator: "/").map(String.init)
        
        switch host {
        case "product":
            guard let id = pathComponents.first else { return nil }
            self = .product(id: id)
        case "category":
            guard let id = pathComponents.first else { return nil }
            self = .category(id: id)
        case "settings":
            self = .settings
        default:
            return nil
        }
    }
}
```

### 6.2 Handle Deep Link

```swift
case .handleDeepLink(let deepLink):
    switch deepLink {
    case .product(let id):
        state.selectedTab = .home
        state.home.path.append(.productDetail(.init(productID: id)))
        
    case .settings:
        state.selectedTab = .settings
        
    // ... other cases
    }
    return .none
```

---

## 7. Navigation Patterns

### 7.1 Pop to Root

```swift
case .popToRoot:
    state.home.path.removeAll()
    return .none
```

### 7.2 Dismiss

```swift
// Child gửi delegate - Child sends delegate action
case .completed:
    return .send(.delegate(.completed))

// Parent handle dismiss
case .editSheet(.presented(.delegate(.completed))):
    state.editSheet = nil  // Dismiss sheet
    return .none
```

---

## 8. Summary

| Navigation Type | TCA Solution |
|-----------------|--------------|
| Tab | State enum + TabView |
| Stack | StackState + NavigationStack |
| Sheet | @Presents + .sheet |
| Full Screen | @Presents + .fullScreenCover |
| Alert | AlertState + .alert |
| Deep Link | Action + URL parsing |

---

*Navigation trong TCA được quản lý hoàn toàn bởi State, giúp dễ test và debug.*
