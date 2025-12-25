# Xóa Tính Năng Không Cần

Hướng dẫn remove features không sử dụng.

---

## Xóa Firebase

### 1. Remove Dependency

**Package.swift:**

```swift
// Comment out or remove
// .package(url: "https://github.com/firebase/firebase-ios-sdk.git", ...)
```

### 2. Remove Files

```bash
rm -rf Sources/Services/Firebase/
```

### 3. Remove Initialization

**Sources/App/Main.swift:**

```swift
// Comment out
// FirebaseManager.shared.configure()
```

---

## Xóa IAP

### 1. Remove Files

```bash
rm -rf Sources/Services/Payment/
rm -rf Sources/Features/IAP/
```

### 2. Remove from AppState

**Sources/App/AppState.swift:**

```swift
// Remove
// public var iap: IAPState?
```

### 3. Remove from AppReducer

Remove IAP reducer scope và actions.

---

## Xóa Onboarding

### 1. Remove Files

```bash
rm -rf Sources/Features/Onboarding/
```

### 2. Always Show Main Screen

**Sources/App/RootView.swift:**

```swift
// Remove onboarding check
// if !store.hasCompletedOnboarding { ... }

// Always show main content
TabView { ... }
```

---

## Xem Thêm

- [Thêm Dependency](02-THEM-DEPENDENCY.md)
- [Đổi Tên App](01-DOI-TEN-APP.md)

