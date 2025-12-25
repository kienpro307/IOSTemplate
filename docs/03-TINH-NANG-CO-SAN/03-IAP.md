# In-App Purchase

Hướng dẫn setup và sử dụng IAP với StoreKit 2.

---

## Setup Products

### 1. App Store Connect

1. [App Store Connect](https://appstoreconnect.apple.com)
2. Your App → In-App Purchases
3. Create products (subscription, consumable, non-consumable)

### 2. Update Product IDs

**File:** `Sources/Services/Payment/IAPProduct.swift`

```swift
public enum IAPProduct: String, CaseIterable {
    case premiumMonthly = "com.yourapp.premium.monthly"
    case premiumYearly = "com.yourapp.premium.yearly"
    case coins100 = "com.yourapp.coins.100"
}
```

---

## Purchase Flow

### Show IAP Screen

```swift
// From Settings
Button("Premium") {
    store.send(.showPremium)
}
```

### Handle Purchase

IAP logic đã được implement trong `IAPReducer`. Auto-handle:
- ✅ Load products
- ✅ Purchase flow
- ✅ Restore purchases
- ✅ Error handling

---

## Test IAP

### Sandbox Testing

1. App Store Connect → Users and Access → Sandbox Testers
2. Create test account
3. Settings → App Store → Sandbox Account → Sign in
4. Test purchases in app (free, no charge)

---

## Xem Thêm

- [Firebase](04-FIREBASE.md)

