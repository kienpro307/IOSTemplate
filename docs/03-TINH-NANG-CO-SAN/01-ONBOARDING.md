# Onboarding Feature

Hướng dẫn customize onboarding flow.

---

## Tổng Quan

Onboarding tự động hiển thị lần đầu user mở app. Có 3 screens mặc định.

---

## Customize Content

### Edit Pages

**File:** `Sources/Features/Onboarding/OnboardingConfig.swift`

```swift
public static let defaultPages: [OnboardingPage] = [
    OnboardingPage(
        title: "Your Title",
        subtitle: "Your subtitle",
        imageName: "your.icon",
        systemImage: true
    ),
    // Add more pages...
]
```

### Change Number of Pages

Thêm/xóa pages trong array `defaultPages`.

---

## Skip Onboarding

Trong `AppState.swift`:

```swift
public var hasCompletedOnboarding: Bool = true  // Skip onboarding
```

---

## Reset Onboarding

```swift
// Clear UserDefaults
UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

// Hoặc trong simulator
xcrun simctl erase all
```

---

## Xem Thêm

- [Settings](02-SETTINGS.md)
- [IAP](03-IAP.md)

