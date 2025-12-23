# 👋 Onboarding

## Flow
```
Welcome → Feature 1 → Feature 2 → Feature 3 → Permissions → Done
```

## Screens
1. Welcome screen
2. Feature highlights (3-4 screens)
3. Permission requests (Notifications, Tracking)
4. Complete / Skip to main app

## State
```swift
@ObservableState
struct TrangThaiGioiThieu: Equatable {
    var trangHienTai: Int = 0
    var daHoanThanh: Bool = false
    var cacTrang: [TrangGioiThieu] = []
}
```

## Persistence
- Track onboarding completion in UserDefaults
- Never show again after completion
