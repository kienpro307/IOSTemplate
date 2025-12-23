# 💳 Thanh Toán In-App Purchase

## Product Types
- Consumable: Coins, credits
- Non-consumable: Remove ads, lifetime premium
- Auto-renewable subscriptions: Monthly/Yearly premium

## StoreKit 2 Integration
```swift
// Load products
let products = try await Product.products(for: productIds)

// Purchase
let result = try await product.purchase()

// Verify transaction
let transaction = try checkVerified(verification)
await transaction.finish()
```

## State
```swift
@ObservableState
struct TrangThaiThanhToan: Equatable {
    var sanPhams: [Product] = []
    var dangMua: Bool = false
    var daMuaPremium: Bool = false
    var dangKyHienTai: Product.SubscriptionInfo?
}
```

## Receipt Validation
- Server-side validation recommended
- Store entitlements securely
