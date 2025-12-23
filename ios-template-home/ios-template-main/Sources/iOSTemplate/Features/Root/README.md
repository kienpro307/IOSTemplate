# Root - Navigation Container

## Tổng quan

Thư mục `Root/` chứa **root-level navigation controllers** của ứng dụng. Đây là entry point của UI layer, điều khiển toàn bộ navigation flows dựa trên app state.

### Chức năng chính
- Root navigation logic (authenticated vs non-authenticated)
- Main tab bar container
- Lifecycle event handling
- Tab selection management
- Deep link routing preparation

### Tác động đến toàn bộ app
- **Critical Impact**: Quyết định flow chính của app
- Điều khiển authenticated/non-authenticated navigation
- Quản lý tab bar và tab switching
- Handle app lifecycle events

---

## Cấu trúc Files

```
Root/
├── RootView.swift       # Root navigation controller (70 dòng)
└── MainTabView.swift    # Tab bar container (73 dòng)
```

**Tổng cộng**: 2 files, 143 dòng code

---

## Chi tiết các Files

### 1. RootView.swift (70 dòng)

**Chức năng**: Root view controller, điều khiển navigation flow chính

#### Component Overview

```swift
public struct RootView: View {
    @Bindable var store: StoreOf<AppReducer>

    public var body: some View {
        Group {
            if store.user.isAuthenticated {
                MainTabView(store: store)
            } else {
                if store.config.featureFlags.showOnboarding {
                    OnboardingView(store: store)
                } else {
                    LoginView(store: store)
                }
            }
        }
        .onAppear {
            store.send(.appLaunched)
        }
    }
}
```

#### Navigation Logic

**Conditional Routing** (dòng 14-26):

```
┌─────────────────────────────────────────┐
│         RootView Decision Tree          │
└─────────────────────────────────────────┘
                    │
                    ▼
        ┌─────────────────────┐
        │  isAuthenticated?   │
        └─────────────────────┘
                │
        ┌───────┴───────┐
        │               │
       YES             NO
        │               │
        ▼               ▼
┌──────────────┐  ┌──────────────────┐
│ MainTabView  │  │ showOnboarding?  │
│ (Tabs)       │  └──────────────────┘
└──────────────┘        │
                ┌───────┴───────┐
                │               │
               YES             NO
                │               │
                ▼               ▼
        ┌──────────────┐  ┌──────────────┐
        │ Onboarding   │  │  LoginView   │
        │    View      │  │              │
        └──────────────┘  └──────────────┘
```

**State Dependencies**:

| State | Type | Purpose |
|-------|------|---------|
| `store.user.isAuthenticated` | Bool (computed) | Determines if user logged in |
| `store.config.featureFlags.showOnboarding` | Bool | Show onboarding to new users |

**Authentication Check**:
```swift
// AppState.swift - UserState
public var isAuthenticated: Bool {
    return profile != nil
}
```

#### Lifecycle Events (dòng 27-29)

**App Launch**:
```swift
.onAppear {
    store.send(.appLaunched)
}
```

**Flow**:
1. RootView appears
2. Dispatch `.appLaunched` action
3. AppReducer handles:
   - Fetch remote config
   - Load user data from storage
   - Initialize services

#### Tab Change Tracking (dòng 30-38)

**Tab Change Handler**:
```swift
.onChange(of: store.navigation.selectedTab) { _, newTab in
    handleTabChange(newTab)
}

private func handleTabChange(_ tab: AppTab) {
    // Handle tab change analytics, etc.
    print("Tab changed to: \(tab.title)")
}
```

**Purpose**:
- Track tab switches for analytics
- Perform tab-specific actions
- Reset tab state if needed

#### SwiftUI Previews (dòng 43-69)

**Authenticated Preview**:
```swift
#Preview("Authenticated") {
    RootView(
        store: Store(
            initialState: AppState(
                user: UserState(
                    profile: UserProfile(
                        id: "123",
                        email: "test@example.com",
                        name: "Test User"
                    )
                )
            )
        ) {
            AppReducer()
        }
    )
}
```
- Shows MainTabView
- User profile present

**Not Authenticated Preview**:
```swift
#Preview("Not Authenticated") {
    RootView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
```
- Shows LoginView or OnboardingView
- Default AppState (no profile)

---

### 2. MainTabView.swift (73 dòng)

**Chức năng**: Main tab bar container cho authenticated users

#### Component Overview

```swift
public struct MainTabView: View {
    @Bindable var store: StoreOf<AppReducer>

    public var body: some View {
        TabView(selection: $store.navigation.selectedTab) {
            // 4 tabs: Home, Explore, Profile, Settings
        }
        .tint(.theme.primary)
    }
}
```

#### Tab Configuration

**Tab 1: Home** (dòng 14-21):
```swift
NavigationStack {
    HomeView(store: store)
}
.tabItem {
    Label(AppTab.home.title, systemImage: AppTab.home.iconName)
}
.tag(AppTab.home)
```

**Tab 2: Explore** (dòng 23-30):
```swift
NavigationStack {
    ExploreView(store: store)
}
.tabItem {
    Label(AppTab.explore.title, systemImage: AppTab.explore.iconName)
}
.tag(AppTab.explore)
```

**Tab 3: Profile** (dòng 32-39):
```swift
NavigationStack {
    ProfileView(store: store)
}
.tabItem {
    Label(AppTab.profile.title, systemImage: AppTab.profile.iconName)
}
.tag(AppTab.profile)
```

**Tab 4: Settings** (dòng 41-48):
```swift
NavigationStack {
    SettingsView(store: store)
}
.tabItem {
    Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
}
.tag(AppTab.settings)
```

#### Tab Metadata (AppState.swift)

```swift
public enum AppTab: String, Equatable {
    case home, explore, profile, settings

    public var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    public var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "safari.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
```

#### Tab Selection Binding (dòng 13)

**Two-way Binding**:
```swift
TabView(selection: $store.navigation.selectedTab)
```

**Read**: Current tab từ AppState
```swift
let currentTab = store.navigation.selectedTab
```

**Write**: User taps tab → Update AppState
```swift
// User taps Profile tab
// → store.navigation.selectedTab = .profile
```

**Programmatic Selection**:
```swift
// From any view
store.send(.navigation(.selectTab(.home)))
```

#### Navigation Stack per Tab (dòng 15, 24, 33, 42)

Mỗi tab có riêng `NavigationStack`:

**Benefits**:
- Independent navigation state per tab
- Push/pop navigation within each tab
- Preserve navigation stack when switching tabs

**Example**:
```
Home Tab:
  HomeView → DetailView → SubDetailView

Explore Tab:
  ExploreView → CategoryView

(Switch to Explore, then back to Home)
→ Home still at SubDetailView
```

#### Styling (dòng 50)

**Tint Color**:
```swift
.tint(.theme.primary)
```

- Selected tab icon color
- Selected tab text color
- Applies primary brand color

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**:
```swift
// Authentication status
store.user.isAuthenticated → Bool

// Onboarding flag
store.config.featureFlags.showOnboarding → Bool

// Current tab
store.navigation.selectedTab → AppTab
```

### Actions Dispatched

**Lifecycle**:
```swift
store.send(.appLaunched)
```

**Navigation**:
```swift
store.send(.navigation(.selectTab(.home)))
store.send(.navigation(.selectTab(.profile)))
```

---

## Navigation Flows

### 1. App Launch Flow

```
App Start
    ↓
RootView.onAppear
    ↓
store.send(.appLaunched)
    ↓
AppReducer handles:
    - Fetch remote config
    - Load user from storage
    ↓
isAuthenticated check
    ↓
┌────────────┴────────────┐
│                         │
YES                      NO
│                         │
MainTabView          showOnboarding?
    ↓                     │
Home Tab         ┌────────┴────────┐
                 │                 │
                YES               NO
                 │                 │
          OnboardingView     LoginView
```

### 2. Login Success Flow

```
LoginView
    ↓
User taps Login
    ↓
store.send(.user(.loginSuccess(profile)))
    ↓
AppReducer:
    - state.user.profile = profile
    - return .send(.navigation(.selectTab(.home)))
    ↓
isAuthenticated = true
    ↓
RootView re-renders
    ↓
Shows MainTabView
    ↓
Home tab selected
```

### 3. Logout Flow

```
SettingsView
    ↓
User taps Logout
    ↓
store.send(.user(.logout))
    ↓
AppReducer:
    - state.user.profile = nil
    - Clear tokens
    ↓
isAuthenticated = false
    ↓
RootView re-renders
    ↓
Shows LoginView
```

### 4. Tab Switch Flow

```
User taps Explore tab
    ↓
TabView binding updates
    ↓
store.navigation.selectedTab = .explore
    ↓
RootView.onChange triggers
    ↓
handleTabChange(.explore)
    ↓
Analytics tracking
    ↓
ExploreView shows
```

---

## Cách hoạt động với Features

### Pass Store Down

Store được pass từ RootView → Child views:

```swift
RootView(store: globalStore)
    ↓
MainTabView(store: globalStore)
    ↓
HomeView(store: globalStore)
```

**Single Store**: Tất cả views chia sẻ cùng Store instance

### Child View Integration

**Home Tab**:
```swift
NavigationStack {
    HomeView(store: store)
}
```

HomeView có thể:
- Read: `store.user.profile?.name`
- Write: `store.send(.user(.updateProfile(...)))`

**Profile Tab**:
```swift
NavigationStack {
    ProfileView(store: store)
}
```

ProfileView có thể:
- Read: `store.user.profile`
- Navigate: `store.send(.navigation(.selectTab(.settings)))`

---

## Best Practices

### 1. Single Responsibility

```swift
// ✅ Good - RootView chỉ handle routing
if store.user.isAuthenticated {
    MainTabView(store: store)
} else {
    LoginView(store: store)
}

// ❌ Bad - Don't put business logic here
if store.user.isAuthenticated {
    // Don't fetch data here
    // Don't handle complex state
    MainTabView(store: store)
}
```

### 2. Use Lifecycle Events

```swift
// ✅ Good - Use .onAppear for initialization
.onAppear {
    store.send(.appLaunched)
}

// ❌ Bad - Don't init in view init
public init(store: StoreOf<AppReducer>) {
    self.store = store
    store.send(.appLaunched)  // Wrong timing
}
```

### 3. Preserve Navigation State

```swift
// ✅ Good - Each tab has NavigationStack
NavigationStack {
    HomeView(store: store)
}

// ❌ Bad - Shared NavigationStack
NavigationStack {
    TabView {
        HomeView(store: store)  // Navigation state conflicts
        ExploreView(store: store)
    }
}
```

---

## Testing

### Unit Tests

**Test Navigation Logic**:
```swift
func testAuthenticatedShowsMainTab() async {
    let store = TestStore(
        initialState: AppState(
            user: UserState(
                profile: UserProfile(id: "123", email: "test@example.com", name: "Test")
            )
        )
    ) {
        AppReducer()
    }

    // isAuthenticated should be true
    XCTAssertTrue(store.state.user.isAuthenticated)
}

func testUnauthenticatedShowsLogin() async {
    let store = TestStore(
        initialState: AppState()
    ) {
        AppReducer()
    }

    // isAuthenticated should be false
    XCTAssertFalse(store.state.user.isAuthenticated)
}
```

**Test Tab Selection**:
```swift
func testTabSelection() async {
    let store = TestStore(
        initialState: AppState()
    ) {
        AppReducer()
    }

    await store.send(.navigation(.selectTab(.profile))) {
        $0.navigation.selectedTab = .profile
    }
}
```

### Preview Testing

Use Xcode Previews to test:
- Authenticated state
- Non-authenticated state
- Different tabs
- Dark/Light mode

---

## Common Patterns

### 1. Conditional Navigation

```swift
if store.user.isAuthenticated {
    MainTabView(store: store)
} else {
    if store.config.featureFlags.showOnboarding {
        OnboardingView(store: store)
    } else {
        LoginView(store: store)
    }
}
```

### 2. Tab Selection Change Tracking

```swift
.onChange(of: store.navigation.selectedTab) { oldTab, newTab in
    // Track analytics
    Analytics.track("tab_changed", properties: [
        "from": oldTab.title,
        "to": newTab.title
    ])

    // Reset search/filters when changing tabs
    if newTab == .explore {
        resetExploreFilters()
    }
}
```

### 3. Deep Link Handling

```swift
.onOpenURL { url in
    store.send(.navigation(.handleDeepLink(url)))
}
```

---

## Performance Considerations

### 1. Lazy View Loading

TabView loads all tabs on init. Consider lazy loading:

```swift
// Current: All tabs loaded immediately
TabView {
    HomeView(store: store)      // Loaded
    ExploreView(store: store)   // Loaded
    ProfileView(store: store)   // Loaded
    SettingsView(store: store)  // Loaded
}

// Optimization: Load on demand (if needed)
// Use .tag and conditional rendering
```

### 2. Memory Management

```swift
// Store is passed by reference
// All tabs share same Store instance
// No memory duplication
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: State models
- **Core/AppAction**: Actions
- **Core/AppReducer**: Business logic
- **Features/Auth**: LoginView
- **Features/Onboarding**: OnboardingView
- **Features/Home**: HomeView
- **Features/Explore**: ExploreView
- **Features/Profile**: ProfileView
- **Features/Settings**: SettingsView

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Core/README.md](../../Core/README.md) - AppState, AppAction, AppReducer
- [Auth/README.md](../Auth/README.md) - Login flow
- [Onboarding/README.md](../Onboarding/README.md) - Onboarding flow

---

## TODO Items

**RootView.swift**:
- Dòng 36: Enhance handleTabChange với analytics tracking
- Consider deep link routing logic
- Add transition animations between authenticated states

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
