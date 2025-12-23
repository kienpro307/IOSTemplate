# Features - UI Layer & User Interfaces

## Tổng quan

Thư mục `Features/` chứa tất cả UI screens và user-facing features của ứng dụng. Đây là **Presentation Layer** được xây dựng với SwiftUI và **The Composable Architecture (TCA)**, tập trung vào việc hiển thị UI và xử lý user interactions.

### Chức năng chính
- Định nghĩa tất cả screens/views trong app
- Xử lý user input và interactions
- Hiển thị data từ AppState
- Dispatch actions đến AppReducer
- Implement navigation flows
- Sử dụng Design System tokens (Colors, Typography, Spacing)

### Tác động đến toàn bộ app
- **High Impact**: Đây là layer mà users tương tác trực tiếp
- Tất cả user experiences được định nghĩa ở đây
- Quyết định UX flows và navigation patterns
- Integrate với Core (AppState) để display và update state
- Sử dụng Design System để đảm bảo UI consistency

---

## Cấu trúc Thư mục

```
Features/
├── Root/                    # Root navigation & app container
│   ├── RootView.swift       # Root routing logic (70 dòng)
│   └── MainTabView.swift    # Main tab bar (73 dòng)
├── Auth/                    # Authentication screens
│   └── LoginView.swift      # Login screen (170 dòng)
├── Onboarding/              # First-time user experience
│   └── OnboardingView.swift # Onboarding flow (197 dòng)
├── Home/                    # Main dashboard
│   └── HomeView.swift       # Home screen (255 dòng)
├── Explore/                 # Discovery & search
│   └── ExploreView.swift    # Explore screen (210 dòng)
├── Profile/                 # User profile
│   └── ProfileView.swift    # Profile screen (222 dòng)
└── Settings/                # App settings
    └── SettingsView.swift   # Settings screen (269 dòng)
```

**Tổng cộng**: 8 files, 1,466 dòng code

---

## Features Architecture

### Navigation Hierarchy

```
RootView (Root Controller)
│
├─ if isAuthenticated = false
│  │
│  ├─ if showOnboarding = true
│  │  └─ OnboardingView → LoginView
│  │
│  └─ if showOnboarding = false
│     └─ LoginView
│
└─ if isAuthenticated = true
   └─ MainTabView (Tab Bar)
      │
      ├─ Tab 1: HomeView
      ├─ Tab 2: ExploreView
      ├─ Tab 3: ProfileView
      └─ Tab 4: SettingsView
```

### Data Flow Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    SwiftUI View                          │
│          (HomeView, ProfileView, etc.)                   │
│                                                          │
│  @Bindable var store: StoreOf<AppReducer>               │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ 1. Read State
                 │    store.user.profile
                 │    store.navigation.selectedTab
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                     AppState                             │
│              (Single Source of Truth)                    │
│                                                          │
│  • user: UserState                                       │
│  • navigation: NavigationState                           │
│  • config: ConfigState                                   │
│  • network: NetworkState                                 │
└────────────────┬────────────────────────────────────────┘
                 ▲
                 │
                 │ 3. State Updated
                 │
┌────────────────┴────────────────────────────────────────┐
│                   AppReducer                             │
│              (Business Logic Layer)                      │
│                                                          │
│  Processes actions → Updates state → Returns effects    │
└────────────────▲────────────────────────────────────────┘
                 │
                 │ 2. Dispatch Action
                 │    store.send(.user(.logout))
                 │    store.send(.navigation(.selectTab(.home)))
                 │
┌────────────────┴────────────────────────────────────────┐
│                    SwiftUI View                          │
│           User taps button / interacts                   │
└─────────────────────────────────────────────────────────┘
```

---

## Features Overview

### 1. Root (Navigation Container)

**Chức năng**: Điều khiển navigation root-level của app

**Components**:
- **RootView**: Root routing logic dựa trên authentication state
- **MainTabView**: Tab bar container cho authenticated users

**Navigation Logic**:
```swift
if store.user.isAuthenticated {
    MainTabView(store: store)  // Show main app
} else {
    if store.config.featureFlags.showOnboarding {
        OnboardingView(store: store)  // First-time user
    } else {
        LoginView(store: store)  // Returning user
    }
}
```

**State Dependencies**:
- `store.user.isAuthenticated` - Authentication status
- `store.config.featureFlags.showOnboarding` - Onboarding flag
- `store.navigation.selectedTab` - Current selected tab

---

### 2. Auth (Authentication)

**Chức năng**: User authentication và login

**Components**:
- **LoginView**: Email/password login form
- Social login placeholders (Apple, Google)

**Actions Dispatched**:
```swift
store.send(.user(.loginSuccess(profile)))  // Successful login
```

**UI Features**:
- Email/password fields
- Social login buttons (Apple, Google)
- Sign up navigation link
- Design System integration (colors, spacing, typography)

---

### 3. Onboarding (First-Time Experience)

**Chức năng**: First-time user onboarding flow

**Components**:
- **OnboardingView**: Page-based onboarding với 3 pages
- **OnboardingPageView**: Individual page component

**Pages**:
1. Welcome - Introduction
2. Secure - Security features
3. Fast - Performance highlights

**Navigation Flow**:
```
Page 1 → Page 2 → Page 3 → LoginView
  ↓       ↓        ↓
Skip → LoginView
```

---

### 4. Home (Main Dashboard)

**Chức năng**: Main dashboard screen khi logged in

**UI Sections**:
- **Header**: Greeting với user name, notifications button
- **Welcome Card**: Getting started CTA
- **Quick Actions Grid**: 4 action cards (Share, Saved, Analytics, Friends)
- **Recent Activity**: Activity feed

**State Usage**:
```swift
store.user.profile?.name  // Display user name
```

**Components**:
- `QuickActionCard` - Action button card
- `ActivityRow` - Activity list item

---

### 5. Explore (Discovery)

**Chức năng**: Content discovery và search

**UI Sections**:
- **Search Bar**: Searchable modifier
- **Popular Searches**: Tag chips
- **Categories Grid**: 4 category cards (Development, Design, Learning, Business)
- **Trending**: Ranked trending list với trend indicators

**Components**:
- `TagChip` - Search tag pill
- `CategoryCard` - Category card với gradient background
- `TrendingRow` - Trending item với rank và trend indicator

**Features**:
- `.searchable(text: $searchText)` - Native search
- Horizontal scroll cho tags
- Grid layout cho categories
- Trend up/down indicators

---

### 6. Profile (User Profile)

**Chức năng**: User profile và personal content

**UI Sections**:
- **Profile Header**: Avatar, name, email
- **Stats Section**: Posts, Followers, Following counts
- **Actions**: Edit profile, Share profile buttons
- **Activity**: Favorites, Saved, History menu items

**State Usage**:
```swift
store.user.profile?.name   // User name
store.user.profile?.email  // User email
```

**Components**:
- `StatItem` - Stat display (value + label)
- `ProfileMenuItem` - Menu item với icon, title, subtitle

**Navigation**:
- Edit button trong toolbar
- Menu items navigate to detail screens

---

### 7. Settings (App Settings)

**Chức năng**: App configuration và account management

**UI Sections**:
- **Account**: User info display
- **Preferences**: Theme, Language settings
- **Notifications**: Push notification toggle
- **About**: Version, Build, Privacy Policy, Terms, Support
- **Danger Zone**: Logout, Delete Account

**State Bindings**:
```swift
// Theme selection
Binding(
    get: { store.user.preferences.themeMode },
    set: { store.send(.user(.changeThemeMode($0))) }
)

// Notifications toggle
Binding(
    get: { store.user.preferences.notificationsEnabled },
    set: { store.send(.user(.toggleNotifications($0))) }
)
```

**Actions Dispatched**:
- `.user(.changeThemeMode(mode))` - Change theme
- `.user(.changeLanguage(code))` - Change language
- `.user(.toggleNotifications(enabled))` - Toggle notifications
- `.user(.logout)` - Log out

**Sub-Views**:
- `LanguageSettingsView` - Language selection
- `NotificationSettingsView` - Notification preferences
- `PrivacyPolicyView` - Privacy policy
- `TermsOfServiceView` - Terms of service

---

## Integration với Core Layer

### AppState Integration

All features access global state via TCA Store:

```swift
public struct HomeView: View {
    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        // Read state
        Text(store.user.profile?.name ?? "User")

        // Dispatch action
        Button("Logout") {
            store.send(.user(.logout))
        }
    }
}
```

### State Access Patterns

**Read State** (Unidirectional):
```swift
// ✅ Good - Read from store
store.user.profile?.name
store.navigation.selectedTab
store.config.featureFlags.showOnboarding

// ❌ Bad - Don't create local copies
@State private var userName: String  // Avoid this
```

**Dispatch Actions**:
```swift
// User actions
store.send(.user(.loginSuccess(profile)))
store.send(.user(.logout))
store.send(.user(.updateProfile(newProfile)))

// Navigation actions
store.send(.navigation(.selectTab(.home)))
store.send(.navigation(.navigateTo(.profile)))

// Preferences
store.send(.user(.changeThemeMode(.dark)))
store.send(.user(.changeLanguage("en")))
```

---

## Design System Integration

All features use centralized Design System tokens:

### Colors

```swift
// Theme colors
Color.theme.background
Color.theme.backgroundSecondary
Color.theme.surface
Color.theme.primary
Color.theme.secondary

// Text colors
Color.theme.textPrimary
Color.theme.textSecondary
Color.theme.textTertiary

// Semantic colors
Color.theme.border
Color.theme.warning
Color.theme.error
Color.theme.success
```

### Typography

```swift
// Display
.font(.theme.displayLarge)
.font(.theme.displayMedium)
.font(.theme.displaySmall)

// Headline
.font(.theme.headlineLarge)
.font(.theme.headlineMedium)
.font(.theme.headlineSmall)

// Title
.font(.theme.titleLarge)
.font(.theme.titleMedium)

// Body
.font(.theme.bodyLarge)
.font(.theme.bodyMedium)
.font(.theme.body)

// Label
.font(.theme.labelMedium)

// Caption
.font(.theme.caption)
.font(.theme.captionBold)
```

### Spacing

```swift
// Spacing tokens
.padding(Spacing.xs)      // 4pt
.padding(Spacing.sm)      // 8pt
.padding(Spacing.md)      // 12pt
.padding(Spacing.lg)      // 16pt
.padding(Spacing.xl)      // 24pt
.padding(Spacing.xxl)     // 32pt
.padding(Spacing.xxxl)    // 48pt

// Semantic spacing
.padding(Spacing.viewPadding)     // Standard view padding
.cardPadding()                     // Card padding modifier
```

### Corner Radius

```swift
.cornerRadius(CornerRadius.sm)      // 4pt
.cornerRadius(CornerRadius.md)      // 8pt
.cornerRadius(CornerRadius.lg)      // 12pt
.cornerRadius(CornerRadius.card)    // 16pt
.cornerRadius(CornerRadius.chip)    // 20pt
```

### Shadows

```swift
.shadow(.sm)
.shadow(.md)
.shadow(.lg)
.shadow(.xl)
```

### Button Styles

```swift
Button("Primary") { }
    .primaryButton()

Button("Secondary") { }
    .secondaryButton()

Button("Tertiary") { }
    .tertiaryButton()

Button("Icon") { }
    .iconButton()
```

---

## Navigation Patterns

### 1. Tab Navigation

MainTabView sử dụng SwiftUI TabView với binding đến AppState:

```swift
TabView(selection: $store.navigation.selectedTab) {
    NavigationStack {
        HomeView(store: store)
    }
    .tabItem {
        Label(AppTab.home.title, systemImage: AppTab.home.iconName)
    }
    .tag(AppTab.home)

    // Other tabs...
}
```

**Programmatic Tab Selection**:
```swift
store.send(.navigation(.selectTab(.profile)))
```

### 2. NavigationStack

Mỗi tab có riêng NavigationStack:

```swift
NavigationStack {
    HomeView(store: store)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
}
```

### 3. NavigationLink

Cho detail navigation:

```swift
NavigationLink {
    LanguageSettingsView(store: store)
} label: {
    Text("Language")
}
```

### 4. Modal Presentation

```swift
.sheet(isPresented: $showSheet) {
    DetailView(store: store)
}

.fullScreenCover(isPresented: $showCover) {
    OnboardingView(store: store)
}
```

---

## Cách tạo Feature mới

### Step 1: Tạo Feature Folder và File

```bash
mkdir -p Sources/iOSTemplate/Features/NewFeature
touch Sources/iOSTemplate/Features/NewFeature/NewFeatureView.swift
```

### Step 2: Implement SwiftUI View với TCA

```swift
import SwiftUI
import ComposableArchitecture

/// NewFeature view - [Description]
public struct NewFeatureView: View {
    @Bindable var store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.xl) {
            // Read state
            Text(store.user.profile?.name ?? "User")
                .font(.theme.title)
                .foregroundColor(.theme.textPrimary)

            // Dispatch action
            Button("Action") {
                store.send(.user(.someAction))
            }
            .primaryButton()
        }
        .padding(Spacing.viewPadding)
        .navigationTitle("New Feature")
        .background(Color.theme.background)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NewFeatureView(
            store: Store(
                initialState: AppState()
            ) {
                AppReducer()
            }
        )
    }
}
```

### Step 3: Thêm vào Navigation

**Thêm tab mới** (nếu cần):

1. Add case vào `AppTab` enum trong `Core/AppState.swift`:
```swift
public enum AppTab: String, Equatable {
    case home, explore, profile, settings
    case newFeature  // Add this

    public var title: String {
        // ...
        case .newFeature: return "New Feature"
    }

    public var iconName: String {
        // ...
        case .newFeature: return "star"
    }
}
```

2. Thêm tab vào `MainTabView.swift`:
```swift
NavigationStack {
    NewFeatureView(store: store)
}
.tabItem {
    Label(AppTab.newFeature.title, systemImage: AppTab.newFeature.iconName)
}
.tag(AppTab.newFeature)
```

**Hoặc thêm NavigationLink** (cho detail screens):
```swift
NavigationLink {
    NewFeatureView(store: store)
} label: {
    Text("Open New Feature")
}
```

### Step 4: Thêm Actions (nếu cần)

Nếu feature cần actions mới, thêm vào `Core/AppAction.swift`:

```swift
public enum UserAction: Equatable {
    // Existing actions...
    case newFeatureAction(String)  // Add new action
}
```

### Step 5: Handle Actions trong Reducer

Thêm logic vào `Core/AppReducer.swift`:

```swift
private func handleUserAction(
    _ state: inout AppState,
    _ action: UserAction
) -> Effect<AppAction> {
    switch action {
    // ...
    case .newFeatureAction(let data):
        // Handle action
        state.user.someProperty = data
        return .none
    }
}
```

### Step 6: Add Tests

```swift
import XCTest
import ComposableArchitecture
@testable import iOSTemplate

final class NewFeatureTests: XCTestCase {
    func testNewFeature() async {
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        await store.send(.user(.newFeatureAction("test"))) {
            $0.user.someProperty = "test"
        }
    }
}
```

---

## Best Practices

### 1. State Management

```swift
// ✅ Good - Use TCA Store
@Bindable var store: StoreOf<AppReducer>

// Read state
let userName = store.user.profile?.name

// Dispatch actions
store.send(.user(.logout))

// ❌ Bad - Local state for global data
@State private var isLoggedIn: Bool = false  // Don't duplicate AppState
```

### 2. Component Reusability

```swift
// ✅ Good - Reusable components
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        // ...
    }
}

// Use in multiple places
QuickActionCard(icon: "star", title: "Favorites", color: .blue)
```

### 3. Design System Consistency

```swift
// ✅ Good - Use Design System tokens
.font(.theme.title)
.foregroundColor(.theme.textPrimary)
.padding(Spacing.md)
.cornerRadius(CornerRadius.card)

// ❌ Bad - Magic numbers
.font(.system(size: 18))
.foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
.padding(12)
.cornerRadius(8)
```

### 4. Preview Variants

```swift
#Preview("Default") {
    HomeView(store: AppStore.preview())
}

#Preview("Empty State") {
    HomeView(
        store: AppStore.preview(
            state: AppState(user: UserState())
        )
    )
}

#Preview("Dark Mode") {
    HomeView(store: AppStore.preview())
        .preferredColorScheme(.dark)
}
```

### 5. Accessibility

```swift
// Add accessibility labels
Image(systemName: "bell")
    .accessibilityLabel("Notifications")

Button("Delete") { }
    .accessibilityHint("Delete this item")
```

---

## Testing Features

### 1. Unit Tests với TestStore

```swift
func testLogin() async {
    let store = TestStore(
        initialState: AppState()
    ) {
        AppReducer()
    }

    let profile = UserProfile(
        id: "123",
        email: "test@example.com",
        name: "Test User"
    )

    await store.send(.user(.loginSuccess(profile))) {
        $0.user.profile = profile
    }

    // Verify navigation effect
    await store.receive(.navigation(.selectTab(.home))) {
        $0.navigation.selectedTab = .home
    }
}
```

### 2. SwiftUI Preview Testing

Sử dụng Xcode Previews để test:
- Different states (logged in, logged out, empty state)
- Dark mode / Light mode
- Different locales
- Accessibility sizes

### 3. Snapshot Testing

```swift
func testHomeViewSnapshot() {
    let view = HomeView(store: AppStore.preview())
    assertSnapshot(matching: view, as: .image)
}
```

---

## Common Patterns

### 1. Conditional Rendering

```swift
// Based on authentication
if store.user.isAuthenticated {
    MainTabView(store: store)
} else {
    LoginView(store: store)
}

// Based on feature flags
if store.config.featureFlags.enableNewUI {
    NewHomeView(store: store)
} else {
    HomeView(store: store)
}
```

### 2. Loading States

```swift
if store.network.pendingRequestsCount > 0 {
    ProgressView()
} else {
    ContentView()
}
```

### 3. Empty States

```swift
if posts.isEmpty {
    VStack {
        Image(systemName: "tray")
        Text("No posts yet")
    }
} else {
    List(posts) { post in
        PostRow(post: post)
    }
}
```

### 4. Error Handling

```swift
.alert("Error", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(errorMessage)
}
```

---

## Performance Considerations

### 1. Use LazyVStack/LazyHStack

```swift
// ✅ Good - Lazy loading
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}

// ❌ Bad - Loads all at once
ScrollView {
    VStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### 2. Avoid Heavy Computations in body

```swift
// ✅ Good - Computed once
let sortedItems = items.sorted()

var body: some View {
    List(sortedItems) { ... }
}

// ❌ Bad - Computed on every render
var body: some View {
    List(items.sorted()) { ... }  // Sorts every time
}
```

### 3. Use @Bindable Appropriately

```swift
// ✅ Good - Only when binding is needed
@Bindable var store: StoreOf<AppReducer>

// For bindings
TextField("Name", text: $store.user.profile.name)

// For read-only
Text(store.user.profile.name)
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core Layer**: AppState, AppAction, AppReducer
- **Design System**: Colors, Typography, Spacing, Components
- **Assets**: Images, Icons, Localization

---

## Related Documentation

- [Core Layer](/Sources/iOSTemplate/Core/README.md) - AppState, AppAction, AppReducer
- [Design System](/Sources/iOSTemplate/DesignSystem/README.md) - UI tokens and components
- [Root/README.md](Root/README.md) - Root navigation
- [Auth/README.md](Auth/README.md) - Authentication
- [Home/README.md](Home/README.md) - Home screen
- [Settings/README.md](Settings/README.md) - Settings screen

---

## TODO Items

**LoginView.swift**:
- Dòng 94: Implement Apple login
- Dòng 108: Implement Google login
- Dòng 135: Navigate to sign up screen
- Dòng 149: Implement actual authentication API

**OnboardingView.swift**:
- Dòng 73: Mark onboarding as completed in storage

**HomeView.swift**:
- Dòng 54: Handle notification tap
- Dòng 84: Handle get started action
- Dòng 144: Handle see all action

**ExploreView.swift**:
- Implement search functionality
- Handle category selection
- Handle trending item tap

**ProfileView.swift**:
- Dòng 37: Implement edit profile
- Implement share profile functionality

**SettingsView.swift**:
- Dòng 112: Open support page
- Dòng 129: Handle delete account

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
