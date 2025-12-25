# Navigation Guide

Hướng dẫn sử dụng navigation system trong iOS Template với TCA.

---

## Tổng Quan

Template sử dụng **enum-based navigation** pattern với:

- ✅ **Tab Navigation** - TabView cho main screens
- ✅ **NavigationStack** - Push/pop screens
- ✅ **Modal Presentation** - Sheets và full screen covers
- ✅ **Deep Links** - URL-based navigation

---

## Tab Navigation

### Tab Structure

App có 4 tabs chính:

```swift
public enum Tab: String, CaseIterable {
    case home = "home"
    case search = "search"
    case notifications = "notifications"
    case settings = "settings"
}
```

### Switch Tabs

**Từ View:**

```swift
// Gửi action để switch tab
store.send(.tabChanged(.settings))
```

**Từ Reducer:**

```swift
case .openSettings:
    // Change tab programmatically
    state.selectedTab = .settings
    return .none
```

---

## NavigationStack

### Destination Enum

**File:** `Sources/Core/Navigation/Destination.swift`

```swift
public enum Destination: Hashable, Identifiable {
    // Settings
    case settings
    case settingsTheme
    case settingsLanguage
    
    // Legal
    case privacyPolicy
    case termsOfService
    
    // Utility
    case webView(url: URL, title: String?)
}
```

### Push Screen

**Trong View:**

```swift
NavigationLink(value: Destination.settings) {
    Text("Open Settings")
}

// Hoặc programmatic:
.navigationDestination(for: Destination.self) { destination in
    switch destination {
    case .settings:
        SettingsView(store: ...)
    case .privacyPolicy:
        WebView(url: URL(string: "...")!)
    // ...
    }
}
```

**Trong Reducer:**

```swift
case .openSettings:
    // Push destination
    state.presentedDestination = .settings
    return .none
```

---

## Modal Presentation

### Sheets

**Trong AppState:**

```swift
public struct AppState {
    /// Màn hình hiển thị dạng sheet
    public var presentedSheet: Destination?
}
```

**Trong View:**

```swift
.sheet(item: $store.presentedSheet.sending(\.sheetDismissed)) { destination in
    switch destination {
    case .iap:
        IAPView(store: ...)
    default:
        EmptyView()
    }
}
```

**Mở sheet từ Reducer:**

```swift
case .showPremium:
    state.presentedSheet = .iap
    return .none
    
case .sheetDismissed:
    state.presentedSheet = nil
    return .none
```

### Full Screen Cover

```swift
.fullScreenCover(item: $store.presentedFullScreen) { destination in
    // Full screen view
}
```

---

## Deep Links

### URL Schemes

**Format:** `yourapp://[host]/[path]?[params]`

**Examples:**

```
yourapp://settings
yourapp://profile/123
yourapp://web?url=https://example.com
```

### Parse Deep Link

**File:** `Sources/Core/Navigation/DeepLink.swift`

```swift
public enum DeepLink: Equatable {
    case settings
    case profile(id: String)
    case webView(url: URL)
    
    public init?(url: URL) {
        guard url.scheme == "yourapp" else {
            return nil
        }
        
        let host = url.host ?? ""
        
        switch host {
        case "settings":
            self = .settings
        case "profile":
            let id = url.pathComponents.dropFirst().first ?? ""
            self = .profile(id: id)
        // ...
        }
    }
}
```

### Handle Deep Link

**Trong AppReducer:**

```swift
case .handleDeepLink(let url):
    guard let deepLink = DeepLink(url: url),
          let destination = deepLink.toDestination() else {
        return .none
    }
    
    // Navigate to destination
    state.presentedDestination = destination
    return .none
```

**Trong RootView:**

```swift
.onOpenURL { url in
    store.send(.handleDeepLink(url))
}
```

---

## Best Practices

### Navigation State

```swift
// ✅ Centralized navigation state
public struct AppState {
    public var selectedTab: Tab
    public var presentedSheet: Destination?
    public var navigationPath: [Destination] = []
}

// ❌ Scattered navigation state
// Don't manage navigation in multiple places
```

### Dismissing Modals

```swift
// ✅ Proper dismissal with action
.sheet(item: $store.presentedSheet.sending(\.sheetDismissed))

case .sheetDismissed:
    state.presentedSheet = nil
    // Cleanup if needed
    return .none

// ❌ Direct binding without action
.sheet(item: $store.presentedSheet)  // Can't track dismissal
```

---

## Xem Thêm

- [Tạo Feature Mới](01-TAO-TINH-NANG-MOI.md)
- [Cấu Trúc Dự Án](../01-BAT-DAU/02-CAU-TRUC-DU-AN.md)

