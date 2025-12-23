# Home - Main Dashboard

## Tổng quan

Thư mục `Home/` chứa **main dashboard screen** của ứng dụng. Đây là first screen mà authenticated users nhìn thấy khi mở app, displaying welcome message, quick actions, và recent activity.

### Chức năng chính
- Personalized welcome header
- Quick action shortcuts
- Recent activity feed
- Notification access
- Getting started prompts
- Feature discovery

### Tác động đến toàn bộ app
- **High Impact**: Main entry point cho authenticated users
- First impression sau login
- Hub cho accessing other features
- Personalized experience với user data
- Default tab trong MainTabView

---

## Cấu trúc Files

```
Home/
└── HomeView.swift           # Home screen (255 dòng)
```

**Tổng cộng**: 1 file, 255 dòng code

---

## Chi tiết File: HomeView.swift (255 dòng)

### Component Overview

```swift
public struct HomeView: View {
    @Bindable var store: StoreOf<AppReducer>

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                headerSection
                welcomeCard
                quickActionsSection
                recentActivitySection
                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.theme.background)
    }
}
```

### State Access (dòng 6)

```swift
@Bindable var store: StoreOf<AppReducer>
```

**Read State**:
```swift
store.user.profile?.name  // User name for greeting
```

**Dispatch Actions**:
```swift
store.send(.user(.logout))  // Example action
```

---

## UI Sections

### 1. Header Section (dòng 38-62)

```swift
private var headerSection: some View {
    HStack {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Welcome back,")
                .font(.theme.bodyMedium)
                .foregroundColor(.theme.textSecondary)

            Text(store.user.profile?.name ?? "User")
                .font(.theme.headlineLarge)
                .foregroundColor(.theme.textPrimary)
        }

        Spacer()

        // Notification badge
        Button {
            // Handle notification tap
        } label: {
            Image(systemName: "bell.fill")
                .font(.title3)
                .foregroundColor(.theme.textPrimary)
        }
        .iconButton()
    }
}
```

#### Components

**Greeting Text** (dòng 40-47):
- "Welcome back," - Secondary text
- User name - Primary, large headline
- Fallback: "User" if profile is nil

**State Dependency**:
```swift
store.user.profile?.name
```

**Notification Button** (dòng 53-60):
- Bell icon
- Icon button style
- TODO: Handle notification tap (Line 54)

**Potential Implementation**:
```swift
Button {
    store.send(.navigation(.navigateTo(.notifications)))
} label: {
    ZStack(alignment: .topTrailing) {
        Image(systemName: "bell.fill")

        // Badge for unread count
        if notificationCount > 0 {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
        }
    }
}
```

---

### 2. Welcome Card (dòng 64-92)

```swift
private var welcomeCard: some View {
    VStack(alignment: .leading, spacing: Spacing.md) {
        HStack {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundColor(.theme.primary)

            Text("Getting Started")
                .font(.theme.headlineSmall)
                .foregroundColor(.theme.textPrimary)

            Spacer()
        }

        Text("Explore the app features and customize your experience.")
            .font(.theme.bodyMedium)
            .foregroundColor(.theme.textSecondary)
            .lineLimit(2)

        Button("Get Started") {
            // Handle get started
        }
        .primaryButton()
    }
    .cardPadding()
    .background(Color.theme.surface)
    .cornerRadius(CornerRadius.card)
    .shadow(.md)
}
```

#### Visual Structure

**Card Layout**:
```
┌────────────────────────────────────┐
│ ✨ Getting Started                 │
│                                    │
│ Explore the app features and      │
│ customize your experience.        │
│                                    │
│ [  Get Started  ]                 │
└────────────────────────────────────┘
```

**Icon + Title** (dòng 66-75):
- Sparkles icon (primary color)
- "Getting Started" headline
- Horizontal layout

**Description** (dòng 77-81):
- Body text
- Secondary color
- 2 line limit

**CTA Button** (dòng 83-86):
- "Get Started" primary button
- TODO: Handle action (Line 84)

**Styling** (dòng 88-91):
- Card padding modifier
- Surface background color
- Card corner radius
- Medium shadow

**Potential Implementation**:
```swift
Button("Get Started") {
    // Navigate to onboarding/tutorial
    store.send(.navigation(.navigateTo(.tutorial)))

    // Or show feature tour
    showFeatureTour = true
}
```

---

### 3. Quick Actions Section (dòng 94-132)

```swift
private var quickActionsSection: some View {
    VStack(alignment: .leading, spacing: Spacing.md) {
        Text("Quick Actions")
            .font(.theme.titleLarge)
            .foregroundColor(.theme.textPrimary)

        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ],
            spacing: Spacing.md
        ) {
            QuickActionCard(icon: "square.and.arrow.up", title: "Share", color: .blue)
            QuickActionCard(icon: "bookmark", title: "Saved", color: .green)
            QuickActionCard(icon: "chart.bar", title: "Analytics", color: .orange)
            QuickActionCard(icon: "person.2", title: "Friends", color: .purple)
        }
    }
}
```

#### Grid Layout

**2-Column Grid**:
```
┌─────────────┬─────────────┐
│   Share     │   Saved     │
│     📤      │     🔖      │
│    Blue     │   Green     │
├─────────────┼─────────────┤
│  Analytics  │  Friends    │
│     📊      │     👥      │
│   Orange    │   Purple    │
└─────────────┴─────────────┘
```

**Grid Configuration** (dòng 100-105):
- 2 flexible columns
- Equal width
- Spacing between items

**Quick Actions**:
1. **Share** - Blue, share icon
2. **Saved** - Green, bookmark icon
3. **Analytics** - Orange, chart icon
4. **Friends** - Purple, people icon

---

### 4. Recent Activity Section (dòng 134-167)

```swift
private var recentActivitySection: some View {
    VStack(alignment: .leading, spacing: Spacing.md) {
        HStack {
            Text("Recent Activity")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            Spacer()

            Button("See All") {
                // Handle see all
            }
            .tertiaryButton()
        }

        VStack(spacing: Spacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: "Activity \(index + 1)",
                    subtitle: "2 hours ago",
                    color: .green
                )

                if index < 2 {
                    Divider()
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.theme.surface)
        .cornerRadius(CornerRadius.card)
    }
}
```

#### Visual Structure

```
Recent Activity                 See All

┌────────────────────────────────────┐
│ ✅  Activity 1                     │
│     2 hours ago                 ›  │
├────────────────────────────────────┤
│ ✅  Activity 2                     │
│     2 hours ago                 ›  │
├────────────────────────────────────┤
│ ✅  Activity 3                     │
│     2 hours ago                 ›  │
└────────────────────────────────────┘
```

**Header** (dòng 136-147):
- "Recent Activity" title
- "See All" tertiary button
- TODO: Handle see all (Line 144)

**Activity List** (dòng 149-166):
- 3 mock activity items
- Checkmark icon (green)
- Title: "Activity 1", "Activity 2", "Activity 3"
- Subtitle: "2 hours ago"
- Dividers between items
- Card background

**Potential Implementation**:
```swift
// Replace mock data with real activities
@State private var activities: [Activity] = []

VStack(spacing: Spacing.sm) {
    ForEach(activities) { activity in
        ActivityRow(
            icon: activity.icon,
            title: activity.title,
            subtitle: activity.formattedDate,
            color: activity.color
        )
    }
}
```

---

## Reusable Components

### QuickActionCard (dòng 172-199)

```swift
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button {
            // Handle action
        } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(color)
                    .cornerRadius(CornerRadius.md)

                Text(title)
                    .font(.theme.labelMedium)
                    .foregroundColor(.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Color.theme.backgroundSecondary)
            .cornerRadius(CornerRadius.card)
        }
    }
}
```

**Visual**:
```
┌─────────────┐
│  ┌───────┐  │
│  │  📤   │  │  ← Colored square with icon
│  └───────┘  │
│   Share     │  ← Label
└─────────────┘
```

**Parameters**:
- `icon`: SF Symbol name
- `title`: Action label
- `color`: Background color cho icon square

**Styling**:
- Icon: 56x56 colored square
- Title: Label medium font
- Full width button
- Secondary background
- Card corner radius

**Action**: TODO - Currently placeholder

### ActivityRow (dòng 203-232)

```swift
struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textPrimary)

                Text(subtitle)
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.theme.textTertiary)
        }
    }
}
```

**Visual**:
```
✅  Activity 1          ›
    2 hours ago
```

**Layout**:
- Leading: Colored icon
- Center: Title + subtitle (vertical stack)
- Trailing: Chevron indicator

**Parameters**:
- `icon`: SF Symbol name
- `title`: Activity title
- `subtitle`: Timestamp or description
- `color`: Icon color

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**:
```swift
store.user.profile?.name  // User name for greeting
```

**Potential Future State**:
```swift
store.user.notifications.unreadCount  // Notification badge count
store.user.activities.recent         // Recent activities
store.user.quickActions              // Customizable quick actions
```

### Actions Dispatched

**Potential Actions**:
```swift
// Notification tap
store.send(.navigation(.navigateTo(.notifications)))

// Quick action tap
store.send(.home(.quickActionTapped(.share)))

// Activity tap
store.send(.home(.activityTapped(activityID)))
```

---

## Design System Usage

### Colors

```swift
Color.theme.background           // Screen background
Color.theme.backgroundSecondary  // Quick action cards
Color.theme.surface              // Welcome card, activity list
Color.theme.primary              // Sparkles icon
Color.theme.textPrimary          // Titles, names
Color.theme.textSecondary        // Descriptions
Color.theme.textTertiary         // Chevron
```

### Typography

```swift
.font(.theme.headlineLarge)   // User name
.font(.theme.headlineSmall)   // "Getting Started"
.font(.theme.titleLarge)      // Section titles
.font(.theme.bodyMedium)      // Descriptions
.font(.theme.bodyLarge)       // Activity titles
.font(.theme.labelMedium)     // Quick action labels
.font(.theme.caption)         // Timestamps
```

### Spacing

```swift
Spacing.xl          // 24pt - Section spacing
Spacing.md          // 12pt - Grid spacing, padding
Spacing.sm          // 8pt - Activity spacing
Spacing.xs          // 4pt - Greeting spacing
Spacing.viewPadding // Standard view padding
```

### Corner Radius

```swift
CornerRadius.card  // 16pt - Cards
CornerRadius.md    // 8pt - Icon squares
```

### Shadows

```swift
.shadow(.md)  // Welcome card shadow
```

### Modifiers

```swift
.cardPadding()   // Card padding modifier
.iconButton()    // Notification button
.primaryButton() // Get Started button
.tertiaryButton() // See All button
```

---

## Best Practices

### 1. Personalization

```swift
// ✅ Good - Use user data
Text(store.user.profile?.name ?? "User")

// ❌ Bad - Generic greeting
Text("User")
```

### 2. Empty State Handling

```swift
// ✅ Good - Handle empty activities
if activities.isEmpty {
    Text("No recent activity")
} else {
    ForEach(activities) { activity in
        ActivityRow(...)
    }
}

// ❌ Bad - Assume data exists
ForEach(activities) { ... }
```

### 3. ScrollView Usage

```swift
// ✅ Good - ScrollView for vertical scrolling
ScrollView {
    VStack {
        // Sections
    }
}

// ❌ Bad - VStack without scroll (content might overflow)
VStack {
    // Many sections
}
```

### 4. Component Reusability

```swift
// ✅ Good - Reusable components
QuickActionCard(icon: "star", title: "Favorites", color: .yellow)

// ❌ Bad - Duplicate code
Button {
    // ...
} label: {
    VStack {
        Image(systemName: "star")
        // Duplicate styling
    }
}
```

---

## Testing

### Unit Tests

```swift
func testHomeViewRendersUserName() {
    let store = AppStore.preview(
        state: AppState(
            user: UserState(
                profile: UserProfile(
                    id: "123",
                    email: "test@example.com",
                    name: "John Doe"
                )
            )
        )
    )

    let view = HomeView(store: store)
    // Test that view uses correct name
}
```

### UI Tests

```swift
func testHomeViewElements() throws {
    let app = XCUIApplication()
    app.launch()

    // Navigate to Home tab
    app.tabBars.buttons["Home"].tap()

    // Verify elements
    XCTAssertTrue(app.staticTexts["Welcome back,"].exists)
    XCTAssertTrue(app.staticTexts["Quick Actions"].exists)
    XCTAssertTrue(app.staticTexts["Recent Activity"].exists)
    XCTAssertTrue(app.buttons["Get Started"].exists)
}
```

---

## Preview

```swift
#Preview {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: AppState(
                    user: UserState(
                        profile: UserProfile(
                            id: "123",
                            email: "test@example.com",
                            name: "John Doe"
                        )
                    )
                )
            ) {
                AppReducer()
            }
        )
    }
}
```

**Shows**:
- Home screen
- User name: "John Doe"
- All sections rendered

---

## Future Enhancements

### 1. Dynamic Quick Actions

```swift
// Customizable quick actions from AppState
let quickActions = store.user.preferences.quickActions

LazyVGrid {
    ForEach(quickActions) { action in
        QuickActionCard(
            icon: action.icon,
            title: action.title,
            color: action.color
        )
    }
}
```

### 2. Real Activity Feed

```swift
// Fetch from API
@State private var activities: [Activity] = []

.task {
    activities = try await networkService.request(.getRecentActivities())
}
```

### 3. Notification Badge

```swift
// Show unread count
ZStack(alignment: .topTrailing) {
    Image(systemName: "bell.fill")

    if store.user.notifications.unreadCount > 0 {
        Text("\(store.user.notifications.unreadCount)")
            .font(.caption2)
            .foregroundColor(.white)
            .padding(4)
            .background(Color.red)
            .clipShape(Circle())
    }
}
```

### 4. Pull to Refresh

```swift
ScrollView {
    // Content
}
.refreshable {
    await refreshHomeData()
}
```

### 5. Shimmer Loading

```swift
if isLoading {
    VStack {
        ShimmerView(height: 100)  // Welcome card
        ShimmerView(height: 200)  // Quick actions
        ShimmerView(height: 300)  // Activities
    }
} else {
    // Actual content
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: UserProfile, UserState
- **Design System**: Colors, Typography, Spacing, Shadows, Buttons
- **Assets**: Icons, Images

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Tab navigation
- [Core/README.md](../../Core/README.md) - AppState, UserState
- [Design System/README.md](../../DesignSystem/README.md) - UI tokens

---

## TODO Items

**HomeView.swift**:
- **Dòng 54**: Handle notification tap → Navigate to notifications screen
- **Dòng 84**: Handle get started action → Navigate to tutorial/onboarding
- **Dòng 144**: Handle see all action → Navigate to full activity list

**Future Enhancements**:
- Replace mock activities với real data từ API
- Add pull-to-refresh functionality
- Add shimmer loading states
- Add notification badge với unread count
- Add customizable quick actions
- Add empty states for sections
- Add error handling
- Add analytics tracking for actions

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
