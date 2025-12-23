# Onboarding - First-Time User Experience

## Tổng quan

Thư mục `Onboarding/` chứa **first-time user onboarding flow**. Đây là experience cho new users lần đầu mở app, giới thiệu key features và value propositions.

### Chức năng chính
- Page-based onboarding flow (3 pages)
- Feature highlights presentation
- Skip functionality
- Navigation to login/sign up
- Smooth page transitions
- Feature flag controlled display

### Tác động đến toàn bộ app
- **Medium Impact**: Chỉ xuất hiện cho new users
- First impression của app
- Controlled by `showOnboarding` feature flag
- Navigate to Auth flow sau completion
- Có thể skip để go straight to login

---

## Cấu trúc Files

```
Onboarding/
└── OnboardingView.swift     # Onboarding flow (197 dòng)
```

**Tổng cộng**: 1 file, 197 dòng code

**Note**: File cũng chứa placeholder LoginView (dòng 133-174), nhưng actual LoginView nằm trong `Auth/LoginView.swift`

---

## Chi tiết File: OnboardingView.swift (197 dòng)

### Component Overview

```swift
public struct OnboardingView: View {
    let store: StoreOf<AppReducer>
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        // 3 onboarding pages
    ]

    public var body: some View {
        VStack {
            // Skip button
            // TabView with pages
            // Continue/Get Started button
        }
    }
}
```

### Local State (dòng 7)

```swift
@State private var currentPage = 0
```

**Purpose**:
- Track current page index (0, 1, 2)
- Control TabView selection
- Determine button text ("Continue" vs "Get Started")

---

## Onboarding Pages

### Page Data Model (dòng 80-85)

```swift
struct OnboardingPage {
    let icon: String         // SF Symbol name
    let title: String        // Page title
    let description: String  // Page description
    let color: Color        // Gradient color
}
```

### Page Definitions (dòng 13-32)

**Page 1: Welcome** (dòng 14-19):
```swift
OnboardingPage(
    icon: "sparkles",
    title: "Welcome",
    description: "Experience the best features in one place",
    color: .blue
)
```

**Visual**: Blue gradient, sparkles icon
**Message**: Introduction, general welcome

**Page 2: Secure** (dòng 20-25):
```swift
OnboardingPage(
    icon: "lock.shield",
    title: "Secure",
    description: "Your data is encrypted and protected",
    color: .green
)
```

**Visual**: Green gradient, lock shield icon
**Message**: Security and privacy

**Page 3: Fast** (dòng 26-31):
```swift
OnboardingPage(
    icon: "bolt.fill",
    title: "Fast",
    description: "Lightning-fast performance everywhere",
    color: .orange
)
```

**Visual**: Orange gradient, bolt icon
**Message**: Performance and speed

---

## UI Structure

### 1. Skip Button (dòng 36-44)

```swift
HStack {
    Spacer()
    Button("Skip") {
        completeOnboarding()
    }
    .tertiaryButton()
}
.padding()
```

**Position**: Top-right corner
**Action**: Skip onboarding → Go to login
**Style**: Tertiary button (subtle)

### 2. Page View (dòng 46-54)

```swift
TabView(selection: $currentPage) {
    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
        OnboardingPageView(page: page)
            .tag(index)
    }
}
.tabViewStyle(.page(indexDisplayMode: .always))
.indexViewStyle(.page(backgroundDisplayMode: .always))
```

**Style**: `.page` - Horizontal swipe pages
**Indicator**: Page dots (1, 2, 3)
**Binding**: `$currentPage` - Two-way binding để track current page

**Enumeration Pattern**:
```swift
Array(pages.enumerated())  // [(0, page1), (1, page2), (2, page3)]
```

### 3. Continue/Get Started Button (dòng 56-67)

```swift
Button(currentPage == pages.count - 1 ? "Get Started" : "Continue") {
    if currentPage < pages.count - 1 {
        withAnimation {
            currentPage += 1
        }
    } else {
        completeOnboarding()
    }
}
.primaryButton()
.padding()
```

**Dynamic Text**:
- Pages 0-1: "Continue"
- Page 2 (last): "Get Started"

**Action Logic**:
```swift
if currentPage < pages.count - 1 {
    // Not last page → Next page
    currentPage += 1
} else {
    // Last page → Complete onboarding
    completeOnboarding()
}
```

**Animation**: `withAnimation` for smooth page transition

---

## OnboardingPageView Component (dòng 89-129)

### Structure

```swift
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            Spacer()

            // Icon with gradient circle
            // Title and description

            Spacer()
        }
    }
}
```

### Icon Section (dòng 96-111)

```swift
Image(systemName: page.icon)
    .font(.system(size: 100))
    .foregroundColor(.white)
    .frame(width: 200, height: 200)
    .background(
        Circle()
            .fill(
                LinearGradient(
                    colors: [page.color, page.color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    )
    .shadow(.xl)
```

**Visual**:
- 100pt SF Symbol icon
- White color
- 200x200 circle background
- Linear gradient (solid → 60% opacity)
- Large shadow for depth

**Gradient Direction**: Top-left to bottom-right

### Content Section (dòng 113-124)

```swift
VStack(spacing: Spacing.md) {
    Text(page.title)
        .font(.theme.displayMedium)
        .foregroundColor(.theme.textPrimary)

    Text(page.description)
        .font(.theme.bodyLarge)
        .foregroundColor(.theme.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, Spacing.xxxl)
}
```

**Typography**:
- Title: Display Medium (large, bold)
- Description: Body Large
- Center aligned
- Horizontal padding for narrower text

---

## Logic và Navigation

### completeOnboarding() Method (dòng 72-75)

```swift
private func completeOnboarding() {
    // TODO: Mark onboarding as completed
    store.send(.navigation(.navigateTo(.login)))
}
```

#### Current Implementation

**Action**: Navigate to login screen

**Dispatch**:
```swift
store.send(.navigation(.navigateTo(.login)))
```

#### TODO: Mark Onboarding as Completed (Line 73)

**Purpose**: Prevent showing onboarding again

**Proper Implementation**:
```swift
private func completeOnboarding() {
    // 1. Save flag to UserDefaults/Keychain
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

    // 2. Update feature flag in AppState
    store.send(.config(.updateFeatureFlag(
        key: "showOnboarding",
        value: false
    )))

    // 3. Navigate to login
    store.send(.navigation(.navigateTo(.login)))
}
```

**AppState Integration**:
```swift
// Core/AppState.swift - FeatureFlags
public struct FeatureFlags: Equatable {
    public var showOnboarding: Bool = true  // Default true for new users

    public init() {
        // Load from storage
        self.showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
```

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**:
```swift
// RootView checks this flag
store.config.featureFlags.showOnboarding
```

**Write to AppState**:
```swift
// Navigate to login
store.send(.navigation(.navigateTo(.login)))

// Update feature flag (TODO)
store.send(.config(.updateFeatureFlag(key: "showOnboarding", value: false)))
```

### Navigation Flow

```
RootView
    ↓
if !isAuthenticated && showOnboarding == true
    ↓
OnboardingView
    ↓
User swipes through pages or taps Skip
    ↓
completeOnboarding()
    ↓
store.send(.navigation(.navigateTo(.login)))
    ↓
AppReducer handles navigation
    ↓
RootView re-renders
    ↓
Shows LoginView
```

---

## Page Navigation Patterns

### 1. Swipe Navigation

```
Page 1 ←→ Page 2 ←→ Page 3
```

**User Action**: Swipe left/right
**Result**: TabView automatically updates `currentPage`

### 2. Button Navigation

```
Page 1
  ↓ [Continue]
Page 2
  ↓ [Continue]
Page 3
  ↓ [Get Started]
LoginView
```

**User Action**: Tap button
**Result**:
- Pages 1-2: `currentPage += 1`
- Page 3: `completeOnboarding()`

### 3. Skip Navigation

```
Any Page
  ↓ [Skip]
LoginView
```

**User Action**: Tap Skip
**Result**: `completeOnboarding()` immediately

---

## Design System Usage

### Colors

```swift
// Gradient colors
.blue, .green, .orange  // Page gradient colors

// Background
Color.theme.background  // Main background

// Text
Color.theme.textPrimary    // Titles
Color.theme.textSecondary  // Descriptions
```

### Typography

```swift
.font(.theme.displayMedium)  // Page titles
.font(.theme.bodyLarge)      // Page descriptions
```

### Spacing

```swift
Spacing.xxxl  // 48pt - Large section spacing
Spacing.md    // 12pt - Title/description spacing
```

### Shadows

```swift
.shadow(.xl)  // Icon circle shadow
```

### Button Styles

```swift
.tertiaryButton()  // Skip button (subtle)
.primaryButton()   // Continue/Get Started (prominent)
```

---

## Best Practices

### 1. Feature Flag Control

```swift
// ✅ Good - Control with feature flag
if store.config.featureFlags.showOnboarding {
    OnboardingView(store: store)
}

// ❌ Bad - Hardcoded always show
OnboardingView(store: store)
```

### 2. Persistence

```swift
// ✅ Good - Save completion state
private func completeOnboarding() {
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    store.send(.navigation(.navigateTo(.login)))
}

// ❌ Bad - No persistence, shows every time
private func completeOnboarding() {
    store.send(.navigation(.navigateTo(.login)))
}
```

### 3. Page Count Flexibility

```swift
// ✅ Good - Dynamic based on pages.count
Button(currentPage == pages.count - 1 ? "Get Started" : "Continue")

if currentPage < pages.count - 1 {
    currentPage += 1
}

// ❌ Bad - Hardcoded
Button(currentPage == 2 ? "Get Started" : "Continue")
```

### 4. Animation

```swift
// ✅ Good - Smooth transitions
withAnimation {
    currentPage += 1
}

// ❌ Bad - Abrupt changes
currentPage += 1
```

---

## Testing

### Unit Tests

```swift
func testOnboardingPageCount() {
    let view = OnboardingView(store: AppStore.preview())
    XCTAssertEqual(view.pages.count, 3)
}

func testOnboardingPages() {
    let view = OnboardingView(store: AppStore.preview())

    XCTAssertEqual(view.pages[0].title, "Welcome")
    XCTAssertEqual(view.pages[0].icon, "sparkles")

    XCTAssertEqual(view.pages[1].title, "Secure")
    XCTAssertEqual(view.pages[1].icon, "lock.shield")

    XCTAssertEqual(view.pages[2].title, "Fast")
    XCTAssertEqual(view.pages[2].icon, "bolt.fill")
}
```

### UI Tests

```swift
func testOnboardingFlow() throws {
    let app = XCUIApplication()
    app.launch()

    // Verify first page
    XCTAssertTrue(app.staticTexts["Welcome"].exists)

    // Tap Continue
    app.buttons["Continue"].tap()

    // Verify second page
    XCTAssertTrue(app.staticTexts["Secure"].exists)

    // Tap Continue again
    app.buttons["Continue"].tap()

    // Verify third page
    XCTAssertTrue(app.staticTexts["Fast"].exists)

    // Tap Get Started
    app.buttons["Get Started"].tap()

    // Verify navigated to login
    XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
}

func testOnboardingSkip() throws {
    let app = XCUIApplication()
    app.launch()

    // Tap Skip from first page
    app.buttons["Skip"].tap()

    // Verify navigated to login
    XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
}
```

---

## Preview

### Default Preview (dòng 178-186)

```swift
#Preview("Onboarding") {
    OnboardingView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
```

**Shows**: Full onboarding flow

---

## Customization Examples

### Add More Pages

```swift
private let pages: [OnboardingPage] = [
    OnboardingPage(
        icon: "sparkles",
        title: "Welcome",
        description: "Experience the best features in one place",
        color: .blue
    ),
    OnboardingPage(
        icon: "lock.shield",
        title: "Secure",
        description: "Your data is encrypted and protected",
        color: .green
    ),
    OnboardingPage(
        icon: "bolt.fill",
        title: "Fast",
        description: "Lightning-fast performance everywhere",
        color: .orange
    ),
    // Add new page
    OnboardingPage(
        icon: "person.2.fill",
        title: "Connected",
        description: "Stay connected with friends and family",
        color: .purple
    )
]
```

**Note**: Button text logic automatically adapts

### Add Progress Indicator

```swift
// Add to OnboardingView
HStack(spacing: 8) {
    ForEach(0..<pages.count, id: \.self) { index in
        Circle()
            .fill(index == currentPage ? Color.theme.primary : Color.theme.border)
            .frame(width: 8, height: 8)
    }
}
.padding(.bottom, Spacing.md)
```

### Add Analytics Tracking

```swift
TabView(selection: $currentPage) {
    // ...
}
.onChange(of: currentPage) { oldValue, newValue in
    Analytics.track("onboarding_page_viewed", properties: [
        "page": newValue,
        "title": pages[newValue].title
    ])
}
```

---

## Future Enhancements

### 1. Video/Animation Support

```swift
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let videoURL: URL?  // Add video
}

// In OnboardingPageView
if let videoURL = page.videoURL {
    VideoPlayer(player: AVPlayer(url: videoURL))
} else {
    Image(systemName: page.icon)
}
```

### 2. Interactive Elements

```swift
// Add interaction for engagement
Button("Try it") {
    // Show feature demo
}
```

### 3. Permission Requests

```swift
// Page for permissions
OnboardingPage(
    icon: "bell.fill",
    title: "Stay Updated",
    description: "Get notifications for important updates",
    color: .red
)

// Request permission on this page
Button("Enable Notifications") {
    requestNotificationPermission()
}
```

### 4. User Preferences

```swift
// Collect user preferences during onboarding
struct OnboardingPage {
    let collectsInput: Bool
    let inputType: InputType?

    enum InputType {
        case interests
        case location
        case notifications
    }
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: Feature flags
- **Core/AppAction**: Navigation actions
- **Design System**: Colors, Typography, Spacing, Shadows, Buttons

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Navigation flow
- [Auth/README.md](../Auth/README.md) - Login after onboarding
- [Core/README.md](../../Core/README.md) - Feature flags
- [Design System/README.md](../../DesignSystem/README.md) - UI components

---

## TODO Items

**OnboardingView.swift**:
- **Dòng 73**: Mark onboarding as completed in persistent storage
  - Save to UserDefaults: `hasCompletedOnboarding`
  - Update AppState feature flag
  - Prevent showing onboarding again

**Additional Enhancements**:
- Add analytics tracking for page views
- Add progress indicator (dots with current page highlight)
- Add video/animation support for pages
- Add permission request flows (notifications, location)
- Add user preference collection
- Add A/B testing support for different onboarding flows
- Add localization for multi-language support

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
