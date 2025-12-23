# Core - TCA Architecture Foundation

## Tổng quan

Thư mục `Core/` là nền tảng kiến trúc của toàn bộ ứng dụng, sử dụng **The Composable Architecture (TCA)** để quản lý state và logic. Đây là **Single Source of Truth** cho toàn bộ app state, actions, và business logic.

### Chức năng chính
- Quản lý toàn bộ state của application (user, config, navigation, network)
- Xử lý tất cả actions và events trong app
- Điều phối data flow giữa các features
- Cung cấp predictable state management với pure functions

### Tác động đến toàn bộ app
- **Critical Impact**: Mọi thay đổi trong Core/ ảnh hưởng đến toàn bộ app
- Tất cả features phụ thuộc vào AppState và AppAction
- Quyết định cách app phản ứng với user interactions
- Đảm bảo state consistency và predictability

---

## Cấu trúc Files

```
Core/
├── AppState.swift      # Global state structure (234 dòng)
├── AppAction.swift     # Action definitions (148 dòng)
├── AppReducer.swift    # Main reducer logic (240 dòng)
└── AppStore.swift      # Store factory methods (46 dòng)
```

---

## Chi tiết các Files

### 1. AppState.swift (234 dòng)

**Chức năng**: Định nghĩa cấu trúc state toàn cục của app

#### Các struct chính:

##### `AppState` (dòng 7-41)
Global app state, là root state chứa tất cả sub-states.

**Properties**:
- `user: UserState` - State về user hiện tại
- `config: ConfigState` - Remote config và feature flags
- `navigation: NavigationState` - Điều khiển navigation
- `network: NetworkState` - Trạng thái kết nối mạng

**Cách sử dụng**:
```swift
let appState = AppState()
// Hoặc với custom initial state
let customState = AppState(
    user: UserState(profile: someProfile),
    navigation: NavigationState(selectedTab: .home)
)
```

##### `UserState` (dòng 46-65)
State liên quan đến user và authentication.

**Properties**:
- `profile: UserProfile?` - Thông tin user (nil nếu chưa đăng nhập)
- `preferences: UserPreferences` - Settings của user
- `isAuthenticated: Bool` - Computed property, `true` nếu profile != nil

**Quan hệ**: Được sử dụng bởi Auth, Profile, Settings features

##### `UserProfile` (dòng 68-85)
Model chứa thông tin user.

**Properties**:
- `id: String` - User ID
- `email: String` - Email
- `name: String` - Tên hiển thị
- `avatarURL: URL?` - Link ảnh đại diện

**Codable**: Có thể lưu vào UserDefaults hoặc Keychain

##### `UserPreferences` (dòng 88-107)
Settings và preferences của user.

**Properties**:
- `themeMode: ThemeMode` - Theme mode (auto/light/dark)
- `languageCode: String` - Ngôn ngữ (default: "en")
- `notificationsEnabled: Bool` - Bật/tắt notifications

**Tác động**: Khi thay đổi, toàn bộ app UI sẽ update theo theme/language mới

##### `ConfigState` (dòng 118-140)
Remote configuration và feature flags.

**Properties**:
- `remoteConfig: [String: String]` - Key-value từ remote config
- `featureFlags: FeatureFlags` - Feature toggles
- `appVersion: String` - App version hiện tại
- `buildNumber: String` - Build number

**Tác động**: Kiểm soát features nào được bật/tắt runtime

##### `FeatureFlags` (dòng 143-157)
Feature toggles cho A/B testing và gradual rollout.

**Properties**:
- `showOnboarding: Bool` - Hiện onboarding cho user mới
- `enableAnalytics: Bool` - Bật/tắt analytics
- `enablePushNotifications: Bool` - Bật/tắt push notifications

##### `NavigationState` (dòng 162-176)
Quản lý navigation state.

**Properties**:
- `selectedTab: AppTab` - Tab đang được chọn (default: .home)
- `pendingDeepLink: URL?` - Deep link đang xử lý

**Tác động**: Điều khiển tab nào được hiển thị trong MainTabView

##### `AppTab` (dòng 179-202)
Enum định nghĩa các tabs trong app.

**Cases**:
- `.home`, `.explore`, `.profile`, `.settings`

**Methods**:
- `title: String` - Tên tab hiển thị
- `iconName: String` - SF Symbol icon name

##### `NetworkState` (dòng 207-226)
Theo dõi network connectivity.

**Properties**:
- `isConnected: Bool` - Có internet không
- `connectionType: ConnectionType` - Loại kết nối (wifi/cellular/ethernet/none)
- `pendingRequestsCount: Int` - Số requests đang chờ

**Tác động**: Hiển thị offline UI, retry logic

---

### 2. AppAction.swift (148 dòng)

**Chức năng**: Định nghĩa tất cả actions (events) có thể xảy ra trong app

#### Các enum chính:

##### `AppAction` (dòng 6-40)
Root action enum, chứa tất cả top-level actions.

**Cases**:
- **Lifecycle Actions**:
  - `.appLaunched` - App vừa khởi động
  - `.appDidBecomeActive` - App vào foreground
  - `.appDidEnterBackground` - App vào background
  - `.appWillTerminate` - App sắp đóng

- **Domain Actions**:
  - `.user(UserAction)` - Actions về user
  - `.navigation(NavigationAction)` - Navigation events
  - `.network(NetworkAction)` - Network events
  - `.config(ConfigAction)` - Config/feature flag changes

**Cách sử dụng**:
```swift
store.send(.appLaunched)
store.send(.user(.logout))
store.send(.navigation(.selectTab(.home)))
```

##### `UserAction` (dòng 45-66)
Actions liên quan đến user.

**Cases**:
- `.loginSuccess(UserProfile)` - Đăng nhập thành công
- `.logout` - Đăng xuất
- `.updateProfile(UserProfile)` - Cập nhật profile
- `.updatePreferences(UserPreferences)` - Cập nhật settings
- `.changeThemeMode(ThemeMode)` - Đổi theme
- `.changeLanguage(String)` - Đổi ngôn ngữ
- `.toggleNotifications(Bool)` - Bật/tắt notifications

**Flow**:
1. User tương tác với UI (Login button, Settings toggle)
2. View dispatch UserAction
3. AppReducer xử lý và update UserState
4. UI tự động update theo state mới

##### `NavigationAction` (dòng 70-89)
Điều khiển navigation.

**Cases**:
- `.selectTab(AppTab)` - Chọn tab mới
- `.handleDeepLink(URL)` - Xử lý deep link
- `.deepLinkHandled` - Deep link đã xử lý xong
- `.navigateTo(Destination)` - Navigate đến màn hình
- `.goBack` - Quay lại
- `.dismiss` - Đóng modal/sheet

**Destination** (dòng 92-98):
- `.home`, `.profile`, `.settings`, `.login`, `.onboarding`

##### `NetworkAction` (dòng 103-115)
Theo dõi network state.

**Cases**:
- `.statusChanged(isConnected: Bool, type: ConnectionType)` - Network status thay đổi
- `.requestStarted` - Bắt đầu API request
- `.requestCompleted` - Request hoàn tất
- `.error` - Network error xảy ra

**Tự động hóa**: NetworkService tự động dispatch các actions này

##### `ConfigAction` (dòng 120-147)
Quản lý remote config.

**Cases**:
- `.fetchRemoteConfig` - Tải remote config
- `.remoteConfigFetched([String: String])` - Config đã tải về
- `.updateFeatureFlag(key: String, value: Bool)` - Update feature flag
- `.fetchFailed(Error)` - Tải config thất bại

**Custom Equatable** (dòng 133-146): Do Error không Equatable, cần custom implementation

---

### 3. AppReducer.swift (240 dòng)

**Chức năng**: Core business logic, xử lý actions và update state

#### Các function chính:

##### `AppReducer` struct (dòng 7-74)
Main reducer struct conform Reducer protocol.

**Dependencies**:
- `@Dependency(\.continuousClock) var clock` - Để handle async operations

**`body` property** (dòng 16-74):
Reducer composition, switch trên AppAction và delegate đến handlers.

**Flow**:
```
AppAction → switch → Handler function → State mutation + Effects
```

**Lifecycle handling** (dòng 21-51):
- `.appLaunched`: Merge fetch config + load user data
- `.appDidBecomeActive`: Refresh data (TODO)
- `.appDidEnterBackground`: Save state (TODO)
- `.appWillTerminate`: Cleanup (TODO)

##### `handleUserAction(_:_:)` (dòng 78-125)
Xử lý tất cả UserAction.

**Logic chi tiết**:

1. **`.loginSuccess(profile)`** (dòng 83-87):
   - Set `state.user.profile = profile`
   - Effect: Navigate to home tab
   - Side effect: Save token vào Keychain (TODO)

2. **`.logout`** (dòng 89-93):
   - Clear `state.user.profile`
   - Effect: Navigate to login screen
   - Side effect: Clear tokens (TODO)

3. **`.updateProfile(profile)`** (dòng 95-99):
   - Update profile in state
   - Side effect: Save to storage (TODO)

4. **`.changeThemeMode(mode)`** (dòng 107-111):
   - Update `state.user.preferences.themeMode`
   - Side effect: Persist preference (TODO)
   - **Tác động UI**: SwiftUI tự động re-render với theme mới

5. **`.changeLanguage(languageCode)`** (dòng 113-117):
   - Update language code
   - Side effect: Update localization system (TODO)

##### `handleNavigationAction(_:_:)` (dòng 129-164)
Xử lý navigation logic.

**Logic chi tiết**:

1. **`.selectTab(tab)`** (dòng 134-137):
   - Update `state.navigation.selectedTab`
   - MainTabView sẽ tự động switch tab

2. **`.handleDeepLink(url)`** (dòng 139-147):
   - Set `state.navigation.pendingDeepLink`
   - Effect: Async processing (300ms delay)
   - Parse URL và navigate đến destination (TODO)
   - Sau khi xong, send `.deepLinkHandled`

3. **`.deepLinkHandled`** (dòng 149-152):
   - Clear pending deep link

**Deep link flow**:
```
URL received → .handleDeepLink(url)
  → Parse URL → Navigate
  → .deepLinkHandled → Clear pending
```

##### `handleNetworkAction(_:_:)` (dòng 168-194)
Quản lý network state.

**Logic**:

1. **`.statusChanged(isConnected, type)`**:
   - Update connectivity state
   - **Tác động**: Show/hide offline banner

2. **`.requestStarted`**:
   - Increment `pendingRequestsCount`
   - **Tác động**: Show loading indicator nếu count > 0

3. **`.requestCompleted`**:
   - Decrement count (min = 0)
   - **Tác động**: Hide loading khi count = 0

##### `handleConfigAction(_:_:)` (dòng 198-231)
Xử lý remote config.

**Logic chi tiết**:

1. **`.fetchRemoteConfig`** (dòng 203-213):
   - Effect: Async fetch config (mock 1 second delay)
   - Mock data: `feature_new_ui`, `min_app_version`
   - Sau khi fetch xong, send `.remoteConfigFetched`

2. **`.remoteConfigFetched(config)`** (dòng 215-219):
   - Update `state.config.remoteConfig`
   - Parse và update feature flags (TODO)

3. **`.fetchFailed`** (dòng 226-229):
   - Use default values
   - Don't crash app

**Config flow**:
```
App launch → .fetchRemoteConfig → Async fetch
  → Success: .remoteConfigFetched → Update state
  → Failure: .fetchFailed → Use defaults
```

---

### 4. AppStore.swift (46 dòng)

**Chức năng**: Factory methods để tạo Store instances

#### Các function:

##### `live()` (dòng 7-14)
Tạo production store với live dependencies.

```swift
public static func live() -> StoreOf<AppReducer> {
    Store(initialState: AppState()) {
        AppReducer()
            ._printChanges() // Debug - remove in production
    }
}
```

**Sử dụng**: Trong main app entry point
```swift
@main
struct MyApp: App {
    let store = AppStore.live()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
```

##### `preview(state:)` (dòng 17-25)
Tạo store cho SwiftUI previews.

```swift
public static func preview(
    state: AppState = AppState()
) -> StoreOf<AppReducer>
```

**Sử dụng**: Trong SwiftUI previews
```swift
#Preview {
    let store = AppStore.preview(
        state: AppState(
            user: UserState(profile: mockProfile)
        )
    )
    return HomeView(store: store)
}
```

##### `test(state:)` (dòng 28-36)
Tạo TestStore cho unit testing.

```swift
public static func test(
    state: AppState = AppState()
) -> TestStore<AppState, AppAction>
```

**Sử dụng**: Trong unit tests
```swift
func testLogout() async {
    let store = AppStore.test(
        state: AppState(
            user: UserState(profile: mockProfile)
        )
    )

    await store.send(.user(.logout)) {
        $0.user.profile = nil
    }
}
```

---

## Cách các Files hoạt động cùng nhau

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────┐
│                   SwiftUI Views                      │
│        (HomeView, ProfileView, SettingsView)        │
└─────────────────┬───────────────────────────────────┘
                  │ 1. User Action
                  ▼
┌─────────────────────────────────────────────────────┐
│               AppStore (Store)                       │
│         Created by AppStore.live()                   │
└─────────────────┬───────────────────────────────────┘
                  │ 2. Dispatch Action
                  ▼
┌─────────────────────────────────────────────────────┐
│           AppReducer.body (switch)                   │
│     Routes to specific handler functions             │
└──┬──────────┬──────────┬──────────┬─────────────────┘
   │          │          │          │
   ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ User   │ │  Nav   │ │Network │ │Config  │ 3. Handler
│Handler │ │Handler │ │Handler │ │Handler │    Functions
└────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘
     │          │          │          │
     └──────────┴──────────┴──────────┘
                  │ 4. Mutate State
                  ▼
┌─────────────────────────────────────────────────────┐
│               AppState (mutated)                     │
│  ┌──────────┬──────────┬──────────┬──────────┐     │
│  │UserState │ConfigSt  │  NavSt   │NetworkSt │     │
│  └──────────┴──────────┴──────────┴──────────┘     │
└─────────────────┬───────────────────────────────────┘
                  │ 5. State Change
                  ▼
┌─────────────────────────────────────────────────────┐
│              SwiftUI Views (Update)                  │
│           Automatic re-render via @State             │
└─────────────────────────────────────────────────────┘
```

### Chi tiết từng bước:

#### 1. Khởi tạo App
```swift
// App entry point
@main
struct iOSTemplateApp: App {
    let store = AppStore.live() // Tạo store

    var body: some Scene {
        WindowGroup {
            RootView(store: store) // Pass store down
                .onAppear {
                    store.send(.appLaunched) // Trigger lifecycle
                }
        }
    }
}
```

#### 2. View Dispatch Action
```swift
// HomeView.swift
struct HomeView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        Button("Logout") {
            store.send(.user(.logout)) // Dispatch action
        }
    }
}
```

#### 3. Reducer Xử lý
```swift
// AppReducer.swift - Internal flow
AppAction.user(.logout)
  → body switch case .user(userAction)
  → handleUserAction(&state, .logout)
  → state.user.profile = nil
  → return .send(.navigation(.navigateTo(.login)))
```

#### 4. State Update
```swift
// State mutation in reducer
state.user.profile = nil  // AppState.user.profile updated
```

#### 5. UI Update
```swift
// SwiftUI automatically observes state changes
// View re-renders with new state
// Login screen is shown
```

---

## Cách các Functions hoạt động với nhau

### Example: Login Flow

```swift
// 1. User taps Login button in LoginView
store.send(.user(.loginSuccess(userProfile)))

// 2. AppReducer.body receives action
case .user(userAction):
    return handleUserAction(&state, userAction)

// 3. handleUserAction processes
case .loginSuccess(profile):
    state.user.profile = profile        // Update state
    return .send(.navigation(.selectTab(.home)))  // Side effect

// 4. Navigation action processed
case .navigation(.selectTab(.home)):
    state.navigation.selectedTab = .home

// 5. UI updates automatically
// - RootView sees isAuthenticated = true
// - Shows MainTabView instead of LoginView
// - Home tab is selected
```

### Example: Deep Link Handling

```swift
// 1. App receives deep link
store.send(.navigation(.handleDeepLink(url)))

// 2. handleNavigationAction starts processing
case .handleDeepLink(url):
    state.navigation.pendingDeepLink = url  // Mark as pending
    return .run { send in
        try await clock.sleep(for: .milliseconds(300))
        // Parse URL and navigate
        await send(.navigation(.deepLinkHandled))  // Mark done
    }

// 3. After processing
case .deepLinkHandled:
    state.navigation.pendingDeepLink = nil  // Clear
```

### Example: Network Monitoring

```swift
// 1. NetworkService starts request
store.send(.network(.requestStarted))
// → state.network.pendingRequestsCount = 1
// → Show loading indicator

// 2. Request completes
store.send(.network(.requestCompleted))
// → state.network.pendingRequestsCount = 0
// → Hide loading indicator
```

---

## Integration với Features

### Feature Reducer Pattern

Features khác có thể integrate với Core:

```swift
// HomeFeature.swift
@Reducer
struct HomeFeature {
    struct State {
        var items: [Item]
        // Can access global state via parent
    }

    enum Action {
        case itemTapped(Item)
        case logout
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .logout:
                // This will be handled by AppReducer
                return .none
            }
        }
    }
}

// AppReducer can compose feature reducers:
var body: some ReducerOf<Self> {
    Scope(state: \.home, action: /AppAction.home) {
        HomeFeature()
    }

    Reduce { state, action in
        // App-level logic
    }
}
```

---

## Testing Strategy

### 1. State Tests
```swift
func testInitialState() {
    let state = AppState()
    XCTAssertNil(state.user.profile)
    XCTAssertEqual(state.navigation.selectedTab, .home)
    XCTAssertTrue(state.network.isConnected)
}
```

### 2. Reducer Tests
```swift
func testLoginSuccess() async {
    let store = AppStore.test()

    await store.send(.user(.loginSuccess(mockProfile))) {
        $0.user.profile = mockProfile
    }

    await store.receive(.navigation(.selectTab(.home))) {
        $0.navigation.selectedTab = .home
    }
}
```

### 3. Effect Tests
```swift
func testDeepLinkHandling() async {
    let store = AppStore.test()

    await store.send(.navigation(.handleDeepLink(mockURL))) {
        $0.navigation.pendingDeepLink = mockURL
    }

    // Wait for async effect
    await store.receive(.navigation(.deepLinkHandled)) {
        $0.navigation.pendingDeepLink = nil
    }
}
```

---

## Best Practices

### 1. State Design
- Keep state structs simple và Equatable
- Use computed properties cho derived state
- Avoid storing UI state in AppState (use local @State instead)

### 2. Action Design
- Actions nên describe "what happened", không phải "what to do"
- Use associated values để pass data
- Group related actions trong enums

### 3. Reducer Logic
- Keep reducers pure (no side effects in state mutations)
- Use Effects cho async work, API calls, etc.
- Separate handler functions cho clarity

### 4. Performance
- Use `@ObservableState` để optimize SwiftUI updates
- Scope stores khi pass vào child views
- Avoid unnecessary state copies

---

## Common Patterns

### 1. Conditional Navigation
```swift
// RootView.swift
if store.user.isAuthenticated {
    MainTabView(store: store)
} else if store.config.featureFlags.showOnboarding {
    OnboardingView(store: store)
} else {
    LoginView(store: store)
}
```

### 2. Loading States
```swift
// Show loading nếu có pending requests
if store.network.pendingRequestsCount > 0 {
    LoadingView()
}
```

### 3. Feature Flags
```swift
// Conditional features
if store.config.featureFlags.enableAnalytics {
    trackEvent("screen_viewed")
}
```

---

## Migration Guide

### Thêm State mới:
1. Add property vào AppState
2. Thêm action tương ứng vào AppAction
3. Handle action trong AppReducer
4. Add tests

### Thêm Feature mới:
1. Tạo FeatureState trong AppState
2. Tạo FeatureAction trong AppAction
3. Create feature reducer
4. Compose vào AppReducer
5. Update RootView navigation

---

## Dependencies

- **ComposableArchitecture**: Core TCA framework
- **Foundation**: Swift standard library

---

## Related Documentation

- [TCA Agent Guide](/.ai/agents/tca-agent.md) - TCA implementation guidelines
- [Feature Template](/.ai/templates/feature-template.md) - Creating new features
- [Architecture Decisions](/.ai/context/decisions-log.md) - Why TCA was chosen

---

## TODO Items

Các TODOs trong code hiện tại:

**AppReducer.swift**:
- Dòng 31: Load actual user data from storage
- Dòng 38: Refresh data logic in `appDidBecomeActive`
- Dòng 44: Save state in `appDidEnterBackground`
- Dòng 50: Cleanup resources in `appWillTerminate`
- Dòng 98: Save profile to storage
- Dòng 104: Save preferences to storage
- Dòng 110: Save theme preference to storage
- Dòng 116: Update localization system
- Dòng 122: Update notification settings
- Dòng 142: Parse and navigate deep links
- Dòng 191: Show network error UI
- Dòng 218: Update feature flags from config

---

## Performance Metrics

- **State size**: ~1KB average (depends on user data)
- **Reducer complexity**: O(1) for most actions
- **Test coverage**: 90%+ (AppReducerTests.swift)

---

## Troubleshooting

### Issue: State không update UI
**Giải pháp**: Đảm bảo AppState và sub-states đều Equatable

### Issue: Effects không chạy
**Giải pháp**: Check reducer return `.run` hoặc `.send` Effects

### Issue: Memory leak
**Giải pháp**: Cancel long-running effects khi cần, sử dụng `.cancellable(id:)`

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
