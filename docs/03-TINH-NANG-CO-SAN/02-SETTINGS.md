# Settings Feature

Hướng dẫn thêm settings options.

---

## Tổng Quan

Settings screen có 3 sections:
- **Preferences** - Theme, language, notifications
- **Notifications** - Push notification settings
- **About** - App info, version, links

---

## Thêm Setting Option

### 1. Update State

**File:** `Sources/Features/Settings/SettingsState.swift`

```swift
public struct UserPreferences: Codable, Equatable {
    public var theme: ThemeMode = .system
    public var language: String = "en"
    public var enableNotifications: Bool = true
    public var newOption: Bool = false  // Add new option
}
```

### 2. Add Action

**File:** `Sources/Features/Settings/SettingsAction.swift`

```swift
public enum SettingsAction: Equatable {
    // ... existing actions ...
    case newOptionToggled(Bool)
}
```

### 3. Handle in Reducer

**File:** `Sources/Features/Settings/SettingsReducer.swift`

```swift
case .newOptionToggled(let enabled):
    state.preferences.newOption = enabled
    return .run { [preferences = state.preferences] _ in
        try? await storageClient.save("preferences", preferences)
    }
```

### 4. Add to View

**File:** `Sources/Features/Settings/SettingsView.swift`

```swift
Toggle("New Option", isOn: $store.preferences.newOption.sending(\.newOptionToggled))
```

---

## Xem Thêm

- [Onboarding](01-ONBOARDING.md)
- [Theme & UI](../02-HUONG-DAN-SU-DUNG/04-THEME-UI.md)

