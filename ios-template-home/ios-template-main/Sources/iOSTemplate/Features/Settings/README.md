# Settings - App Configuration

## Tổng quan

Thư mục `Settings/` chứa **app settings và configuration screens**. Đây là nơi users quản lý account, preferences, notifications, và app settings.

### Chức năng chính
- Account information display
- App preferences (theme, language)
- Notification settings
- About information (version, build)
- Legal information (privacy policy, terms)
- Logout và account deletion
- Support access

### Tác động đến toàn bộ app
- **Critical Impact**: Controls app behavior
- Theme changes affect entire UI
- Language changes affect all text
- Notification toggles affect push notifications
- Logout action logs user out
- Tab thứ 4 trong MainTabView

---

## Cấu trúc Files

```
Settings/
└── SettingsView.swift       # Settings screen (269 dòng)
```

**Tổng cộng**: 1 file, 269 dòng code

**File cũng chứa**:
- SettingsRow component
- LanguageSettingsView
- NotificationSettingsView
- PrivacyPolicyView
- TermsOfServiceView

---

## Chi tiết File: SettingsView.swift (269 dòng)

### Component Overview

```swift
public struct SettingsView: View {
    @Bindable var store: StoreOf<AppReducer>

    public var body: some View {
        List {
            accountSection
            preferencesSection
            notificationsSection
            aboutSection
            dangerZoneSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
```

### State Access (dòng 6)

```swift
@Bindable var store: StoreOf<AppReducer>
```

**Read State**:
```swift
store.user.profile?.name                    // User name
store.user.profile?.email                   // User email
store.user.preferences.themeMode            // Theme setting
store.user.preferences.languageCode         // Language
store.user.preferences.notificationsEnabled // Notifications
store.config.appVersion                     // App version
store.config.buildNumber                    // Build number
```

**Write State** (via bindings):
```swift
themeBinding                 // Theme picker binding
notificationsBinding         // Notifications toggle binding
```

---

## UI Sections

### 1. Account Section (dòng 35-59)

```swift
private var accountSection: some View {
    Section("Account") {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.theme.primary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(store.user.profile?.name ?? "User")
                    .font(.theme.bodyLarge)
                    .foregroundColor(.theme.textPrimary)

                Text(store.user.profile?.email ?? "")
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
Account
┌──────────────────────────────────┐
│ 👤  John Doe               ›     │
│     john@example.com             │
└──────────────────────────────────┘
```

**Layout**:
- Person icon (primary color)
- Name (body large, primary text)
- Email (caption, secondary text)
- Chevron (trailing)

**Interaction**: Tappable row → Navigate to account details (potential)

---

### 2. Preferences Section (dòng 61-82)

```swift
private var preferencesSection: some View {
    Section("Preferences") {
        // Theme
        Picker("Theme", selection: themeBinding) {
            Text("Auto").tag(ThemeMode.auto)
            Text("Light").tag(ThemeMode.light)
            Text("Dark").tag(ThemeMode.dark)
        }

        // Language
        NavigationLink {
            LanguageSettingsView(store: store)
        } label: {
            HStack {
                Text("Language")
                Spacer()
                Text(store.user.preferences.languageCode.uppercased())
                    .foregroundColor(.theme.textSecondary)
            }
        }
    }
}
```

#### Theme Picker (dòng 64-68)

```swift
Picker("Theme", selection: themeBinding) {
    Text("Auto").tag(ThemeMode.auto)
    Text("Light").tag(ThemeMode.light)
    Text("Dark").tag(ThemeMode.dark)
}
```

**Options**:
- **Auto**: System theme
- **Light**: Light mode
- **Dark**: Dark mode

**Binding** (dòng 138-143):
```swift
private var themeBinding: Binding<ThemeMode> {
    Binding(
        get: { store.user.preferences.themeMode },
        set: { store.send(.user(.changeThemeMode($0))) }
    )
}
```

**Flow**:
1. User selects theme
2. Binding setter called
3. Dispatch `.user(.changeThemeMode(newMode))`
4. AppReducer updates state
5. UI re-renders with new theme

#### Language Navigation Link (dòng 71-80)

```swift
NavigationLink {
    LanguageSettingsView(store: store)
} label: {
    HStack {
        Text("Language")
        Spacer()
        Text(store.user.preferences.languageCode.uppercased())
            .foregroundColor(.theme.textSecondary)
    }
}
```

**Display**:
- "Language" label
- Current language code (e.g., "EN", "VI")
- Navigate to LanguageSettingsView

---

### 3. Notifications Section (dòng 84-92)

```swift
private var notificationsSection: some View {
    Section("Notifications") {
        Toggle("Push Notifications", isOn: notificationsBinding)

        NavigationLink("Notification Settings") {
            NotificationSettingsView(store: store)
        }
    }
}
```

#### Push Notifications Toggle (dòng 86)

```swift
Toggle("Push Notifications", isOn: notificationsBinding)
```

**Binding** (dòng 145-150):
```swift
private var notificationsBinding: Binding<Bool> {
    Binding(
        get: { store.user.preferences.notificationsEnabled },
        set: { store.send(.user(.toggleNotifications($0))) }
    )
}
```

**Flow**:
1. User toggles switch
2. Dispatch `.user(.toggleNotifications(enabled))`
3. AppReducer updates state
4. Actual permission request (TODO)

#### Notification Settings Link (dòng 88-90)

Navigate to detailed notification preferences (currently placeholder).

---

### 4. About Section (dòng 94-117)

```swift
private var aboutSection: some View {
    Section("About") {
        SettingsRow(icon: "info.circle", title: "Version", value: store.config.appVersion)
        SettingsRow(icon: "number", title: "Build", value: store.config.buildNumber)

        NavigationLink {
            PrivacyPolicyView()
        } label: {
            Label("Privacy Policy", systemImage: "hand.raised")
        }

        NavigationLink {
            TermsOfServiceView()
        } label: {
            Label("Terms of Service", systemImage: "doc.text")
        }

        Button {
            // Open support
        } label: {
            Label("Support", systemImage: "questionmark.circle")
        }
    }
}
```

#### Version and Build (dòng 96-97)

```swift
SettingsRow(icon: "info.circle", title: "Version", value: store.config.appVersion)
SettingsRow(icon: "number", title: "Build", value: store.config.buildNumber)
```

**Display**:
```
ℹ️  Version         1.0.0
#️⃣  Build           1
```

**State Source**:
```swift
store.config.appVersion   // e.g., "1.0.0"
store.config.buildNumber  // e.g., "1"
```

#### Legal Links (dòng 99-110)

**Privacy Policy**: Navigate to privacy policy text
**Terms of Service**: Navigate to terms text

#### Support Button (dòng 112-115)

```swift
Button {
    // Open support
} label: {
    Label("Support", systemImage: "questionmark.circle")
}
```

**TODO**: Line 112 - Open support page/email

**Potential Implementation**:
```swift
Button {
    if let url = URL(string: "mailto:support@example.com") {
        UIApplication.shared.open(url)
    }
} label: {
    Label("Support", systemImage: "questionmark.circle")
}
```

---

### 5. Danger Zone Section (dòng 119-134)

```swift
private var dangerZoneSection: some View {
    Section("Danger Zone") {
        Button {
            store.send(.user(.logout))
        } label: {
            Label("Log Out", systemImage: "arrow.right.square")
                .foregroundColor(.theme.warning)
        }

        Button(role: .destructive) {
            // Handle delete account
        } label: {
            Label("Delete Account", systemImage: "trash")
        }
    }
}
```

#### Logout Button (dòng 121-126)

```swift
Button {
    store.send(.user(.logout))
} label: {
    Label("Log Out", systemImage: "arrow.right.square")
        .foregroundColor(.theme.warning)
}
```

**Action**: Dispatch `.user(.logout)`

**Flow** (Core/AppReducer.swift):
```swift
case .logout:
    state.user.profile = nil  // Clear profile
    // Clear tokens from Keychain (TODO)
    return .send(.navigation(.navigateTo(.login)))
```

**Result**:
1. Profile cleared
2. isAuthenticated = false
3. Navigate to LoginView
4. RootView re-renders

#### Delete Account Button (dòng 128-133)

```swift
Button(role: .destructive) {
    // Handle delete account
} label: {
    Label("Delete Account", systemImage: "trash")
}
```

**Role**: `.destructive` - Shows in red
**TODO**: Line 129 - Implement account deletion

**Proper Implementation**:
```swift
@State private var showDeleteConfirmation = false

Button(role: .destructive) {
    showDeleteConfirmation = true
} label: {
    Label("Delete Account", systemImage: "trash")
}
.alert("Delete Account", isPresented: $showDeleteConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Delete", role: .destructive) {
        deleteAccount()
    }
} message: {
    Text("Are you sure? This action cannot be undone.")
}
```

---

## Reusable Components

### SettingsRow (dòng 155-168)

```swift
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(.theme.textSecondary)
        }
    }
}
```

**Visual**:
```
ℹ️  Version         1.0.0
```

**Layout**:
- Label with icon and title
- Spacer
- Value text (secondary color)

**Usage**:
```swift
SettingsRow(icon: "info.circle", title: "Version", value: "1.0.0")
```

---

## Sub-Views

### LanguageSettingsView (dòng 172-204)

```swift
struct LanguageSettingsView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        List {
            ForEach(["en", "vi", "es", "fr"], id: \.self) { lang in
                Button {
                    store.send(.user(.changeLanguage(lang)))
                } label: {
                    HStack {
                        Text(languageName(lang))
                        Spacer()
                        if store.user.preferences.languageCode == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(.theme.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Language")
    }

    private func languageName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "vi": return "Tiếng Việt"
        case "es": return "Español"
        case "fr": return "Français"
        default: return code
        }
    }
}
```

**Supported Languages**:
- **en**: English
- **vi**: Tiếng Việt
- **es**: Español
- **fr**: Français

**Visual**:
```
Language

┌──────────────────────────────┐
│ English                  ✓   │  ← Selected
├──────────────────────────────┤
│ Tiếng Việt                   │
├──────────────────────────────┤
│ Español                      │
├──────────────────────────────┤
│ Français                     │
└──────────────────────────────┘
```

**Action**:
```swift
store.send(.user(.changeLanguage(lang)))
```

**Flow**:
1. User taps language
2. Dispatch action
3. AppReducer updates `languageCode`
4. Checkmark updates
5. App localizes strings (TODO)

---

### NotificationSettingsView (dòng 206-216)

```swift
struct NotificationSettingsView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        List {
            Text("Notification settings coming soon...")
                .foregroundColor(.theme.textSecondary)
        }
        .navigationTitle("Notifications")
    }
}
```

**Status**: Placeholder - Not implemented
**TODO**: Implement detailed notification preferences

**Future Content**:
- Email notifications
- Push notification categories
- Notification frequency
- Do Not Disturb schedule

---

### PrivacyPolicyView (dòng 218-231)

```swift
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.theme.headlineLarge)
                .padding()

            Text("Your privacy policy content here...")
                .font(.theme.bodyMedium)
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
```

**Status**: Placeholder text
**TODO**: Add actual privacy policy content

**Proper Implementation**:
- Load from remote URL
- Or include as local file
- Formatted text with sections
- Links to contact

---

### TermsOfServiceView (dòng 233-246)

```swift
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service")
                .font(.theme.headlineLarge)
                .padding()

            Text("Your terms of service content here...")
                .font(.theme.bodyMedium)
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
}
```

**Status**: Placeholder text
**TODO**: Add actual terms of service content

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**:
```swift
// User info
store.user.profile?.name
store.user.profile?.email

// Preferences
store.user.preferences.themeMode
store.user.preferences.languageCode
store.user.preferences.notificationsEnabled

// Config
store.config.appVersion
store.config.buildNumber
```

### Actions Dispatched

**User Preferences**:
```swift
store.send(.user(.changeThemeMode(.dark)))
store.send(.user(.changeLanguage("vi")))
store.send(.user(.toggleNotifications(true)))
```

**User Actions**:
```swift
store.send(.user(.logout))
store.send(.user(.deleteAccount))  // TODO
```

**Action Definitions** (Core/AppAction.swift):
```swift
public enum UserAction: Equatable {
    case changeThemeMode(ThemeMode)
    case changeLanguage(String)
    case toggleNotifications(Bool)
    case logout
    // ...
}
```

**Handlers** (Core/AppReducer.swift):
```swift
case .changeThemeMode(let mode):
    state.user.preferences.themeMode = mode
    // Save to storage (TODO)
    return .none

case .changeLanguage(let languageCode):
    state.user.preferences.languageCode = languageCode
    // Update localization (TODO)
    return .none

case .toggleNotifications(let enabled):
    state.user.preferences.notificationsEnabled = enabled
    // Update notification permissions (TODO)
    return .none

case .logout:
    state.user.profile = nil
    // Clear tokens (TODO)
    return .send(.navigation(.navigateTo(.login)))
```

---

## Two-Way Bindings Pattern

### Theme Binding (dòng 138-143)

```swift
private var themeBinding: Binding<ThemeMode> {
    Binding(
        get: { store.user.preferences.themeMode },
        set: { store.send(.user(.changeThemeMode($0))) }
    )
}
```

**Get**: Read current theme from AppState
**Set**: Dispatch action to change theme

**Usage**:
```swift
Picker("Theme", selection: themeBinding) {
    // Options
}
```

**Why Bindings?**:
- SwiftUI Picker/Toggle require `Binding<T>`
- TCA Store uses actions, not direct mutation
- Binding bridges SwiftUI two-way binding with TCA one-way flow

---

## Design System Usage

### Colors

```swift
Color.theme.primary         // Account icon, checkmarks
Color.theme.textPrimary     // User name, labels
Color.theme.textSecondary   // Email, values, language code
Color.theme.textTertiary    // Chevron
Color.theme.warning         // Logout button
```

### Typography

```swift
.font(.theme.bodyLarge)      // User name
.font(.theme.bodyMedium)     // Legal content
.font(.theme.caption)        // Email
.font(.theme.headlineLarge)  // Legal titles
```

### Spacing

```swift
Spacing.xs  // 4pt - Name/email spacing
```

---

## Best Practices

### 1. Bindings for Controls

```swift
// ✅ Good - Use bindings for Picker/Toggle
Picker("Theme", selection: themeBinding)
Toggle("Notifications", isOn: notificationsBinding)

// ❌ Bad - Direct state mutation (breaks TCA)
@State private var theme: ThemeMode
```

### 2. Confirmation for Destructive Actions

```swift
// ✅ Good - Confirm before deletion
.alert("Delete Account", isPresented: $showConfirmation) {
    Button("Delete", role: .destructive) { deleteAccount() }
}

// ❌ Bad - Delete immediately
Button("Delete") { deleteAccount() }
```

### 3. Read State from Store

```swift
// ✅ Good - Single source of truth
store.user.preferences.themeMode

// ❌ Bad - Duplicate state
@State private var themeMode: ThemeMode
```

---

## Testing

### Unit Tests

```swift
func testThemeChange() async {
    let store = TestStore(
        initialState: AppState()
    ) {
        AppReducer()
    }

    await store.send(.user(.changeThemeMode(.dark))) {
        $0.user.preferences.themeMode = .dark
    }
}

func testLogout() async {
    let store = TestStore(
        initialState: AppState(
            user: UserState(profile: mockProfile)
        )
    ) {
        AppReducer()
    }

    await store.send(.user(.logout)) {
        $0.user.profile = nil
    }

    await store.receive(.navigation(.navigateTo(.login)))
}
```

### UI Tests

```swift
func testSettingsThemeChange() throws {
    let app = XCUIApplication()
    app.launch()

    app.tabBars.buttons["Settings"].tap()

    let themePicker = app.buttons["Theme"]
    themePicker.tap()

    app.buttons["Dark"].tap()

    // Verify UI updated to dark mode
}

func testSettingsLogout() throws {
    let app = XCUIApplication()
    app.launch()

    app.tabBars.buttons["Settings"].tap()

    app.buttons["Log Out"].tap()

    // Verify navigated to login
    XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
}
```

---

## Preview

```swift
#Preview {
    NavigationStack {
        SettingsView(
            store: Store(
                initialState: AppState(
                    user: UserState(
                        profile: UserProfile(
                            id: "123",
                            email: "john.doe@example.com",
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
- Settings list
- All sections
- User info: "John Doe"
- All preferences and options

---

## Future Enhancements

### 1. Storage Preferences

```swift
// Storage usage
Section("Storage") {
    SettingsRow(icon: "internaldrive", title: "Cache Size", value: "128 MB")
    Button("Clear Cache") {
        clearCache()
    }
}
```

### 2. Appearance Customization

```swift
// Font size
Picker("Text Size", selection: $textSizeBinding) {
    Text("Small").tag(TextSize.small)
    Text("Medium").tag(TextSize.medium)
    Text("Large").tag(TextSize.large)
}
```

### 3. Advanced Notifications

```swift
// Notification categories
Section("Notifications") {
    Toggle("New Messages", isOn: $newMessagesEnabled)
    Toggle("Updates", isOn: $updatesEnabled)
    Toggle("Marketing", isOn: $marketingEnabled)
}
```

### 4. Data Export

```swift
Button("Export Data") {
    exportUserData()
}
```

### 5. App Lock

```swift
Toggle("Face ID Lock", isOn: $appLockEnabled)
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: UserState, UserPreferences, ConfigState
- **Core/AppAction**: UserAction
- **Design System**: Colors, Typography, Spacing

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Tab navigation
- [Core/README.md](../../Core/README.md) - AppState, UserPreferences
- [Profile/README.md](../Profile/README.md) - Profile editing

---

## TODO Items

**SettingsView.swift**:
- **Dòng 112**: Open support page (email, web form, or chat)
- **Dòng 129**: Handle delete account with confirmation
- Implement NotificationSettingsView content
- Add actual Privacy Policy content
- Add actual Terms of Service content

**AppReducer.swift** (Related TODOs):
- Save theme preference to storage
- Update localization system on language change
- Handle actual notification permission requests
- Clear tokens on logout

**Additional Enhancements**:
- Add storage/cache management
- Add appearance customization (font size, etc.)
- Add detailed notification preferences
- Add data export functionality
- Add app lock with biometrics
- Add account deactivation option
- Add help/FAQ section
- Add rate app prompt
- Add share app functionality

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
