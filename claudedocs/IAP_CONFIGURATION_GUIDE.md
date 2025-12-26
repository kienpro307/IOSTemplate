# IAP Configuration Guide

## Tổng quan

IOSTemplate package hiện đã hỗ trợ **dynamic configuration** cho In-App Purchase (IAP). Điều này cho phép package được reusable cho nhiều app khác nhau mà không cần hardcode product IDs.

## Kiến trúc

```
┌─────────────────────────────────┐
│  Your App (pdftranslator)       │
│                                 │
│  App.swift                      │
│  ↓ IAPConfiguration.setup()     │
└─────────────────────────────────┘
           ↓ Configuration
┌─────────────────────────────────┐
│  IOSTemplate Package            │
│                                 │
│  IAPConfiguration.shared        │
│  ↓                              │
│  StoreKitManager                │
│  PaymentService                 │
└─────────────────────────────────┘
           ↓ Load Products
┌─────────────────────────────────┐
│  App Store                      │
└─────────────────────────────────┘
```

## Cách sử dụng trong App chính

### 1. Setup Configuration khi App khởi động

Trong file `App.swift` của app chính, gọi `IAPConfiguration.setup()` trước khi sử dụng bất kỳ IAP feature nào:

```swift
import SwiftUI
import IOSTemplate

@main
struct PDFTranslatorApp: App {
    init() {
        // Setup IAP Configuration
        IAPConfiguration.setup(
            productIDs: [
                "com.pdftranslator.premium.monthly",
                "com.pdftranslator.premium.yearly",
                "com.pdftranslator.removeads"
            ],
            subscriptionGroupID: "premium_subscriptions" // Optional
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Product ID Naming Convention

Để mock products hoạt động tốt (cho testing/preview), nên đặt tên product IDs theo convention:

#### Subscriptions
- Chứa `subscription` hoặc `sub` trong ID
- Chứa `monthly`/`month` cho monthly subscription
- Chứa `yearly`/`year` cho yearly subscription

Ví dụ:
```swift
"com.yourapp.subscription.monthly"
"com.yourapp.premium.yearly"
"com.yourapp.sub.weekly"
```

#### Consumables
- Chứa `consumable` hoặc `coins` trong ID

Ví dụ:
```swift
"com.yourapp.consumable.100coins"
"com.yourapp.coins.500"
```

#### Non-Consumables
- Bất kỳ ID nào không match conventions trên

Ví dụ:
```swift
"com.yourapp.removeads"
"com.yourapp.premium.unlock"
```

### 3. Validation

Configuration cung cấp validation helpers:

```swift
// Kiểm tra đã setup chưa
if IAPConfiguration.shared.isConfigured {
    print("✅ IAP đã được cấu hình")
}

// Kiểm tra product ID có trong config không
if IAPConfiguration.shared.contains("com.yourapp.premium") {
    print("✅ Product ID hợp lệ")
}
```

## Changes so với version cũ

### Before (Hardcoded)

```swift
// IAPProduct.swift
public enum IAPProduct: String, CaseIterable {
    case coins100 = "com.template.ios.coins.100"
    case removeAds = "com.template.ios.removeads"
    // ...
}

// StoreKitManager.swift
let productIds = IAPProduct.allProductIDs // ❌ Hardcoded
```

### After (Dynamic Configuration)

```swift
// IAPConfiguration.swift
IAPConfiguration.setup(productIDs: [...]) // ✅ Từ app chính

// StoreKitManager.swift
let productIds = IAPConfiguration.shared.productIDs // ✅ Dynamic
```

## Backward Compatibility

### IAPProduct enum vẫn tồn tại
File `IAPProduct.swift` vẫn được giữ lại để backward compatibility với code cũ sử dụng enum này. Tuy nhiên, **không nên sử dụng cho app mới**.

### Legacy Mock Products
Nếu không muốn setup configuration trong tests, có thể dùng:

```swift
MockPaymentService(
    mockProducts: MockPaymentService.legacyDefaultProducts
)
```

⚠️ **Deprecated**: Sử dụng `IAPConfiguration.setup()` và `defaultProducts` thay thế.

## Testing

### Unit Tests

```swift
import XCTest
@testable import IOSTemplate

class MyTests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Setup configuration cho tests
        IAPConfiguration.setup(
            productIDs: [
                "test.subscription.monthly",
                "test.removeads"
            ]
        )
    }

    func testPayment() async {
        let service = MockPaymentService()
        let products = try await service.loadProducts()

        // Mock products sẽ được tạo từ IAPConfiguration
        XCTAssertEqual(products.count, 2)
    }
}
```

### SwiftUI Previews

```swift
#Preview {
    ContentView()
        .onAppear {
            IAPConfiguration.setup(
                productIDs: [
                    "preview.subscription.monthly",
                    "preview.removeads"
                ]
            )
        }
}
```

## Error Handling

Nếu quên setup configuration, sẽ nhận error:

```swift
do {
    try await StoreKitManager.shared.loadProducts()
} catch IAPConfigurationError.notConfigured {
    print("❌ Chưa setup IAPConfiguration")
    // Call IAPConfiguration.setup() first
}
```

## Best Practices

### 1. Setup Early
Setup configuration **ngay trong `App.init()`** để đảm bảo mọi feature có thể sử dụng IAP.

### 2. Single Source of Truth
Lưu product IDs ở một nơi duy nhất (ví dụ: `Constants.swift`):

```swift
// Constants.swift
enum IAPProductIDs {
    static let monthlySubscription = "com.yourapp.premium.monthly"
    static let yearlySubscription = "com.yourapp.premium.yearly"
    static let removeAds = "com.yourapp.removeads"

    static let all = [
        monthlySubscription,
        yearlySubscription,
        removeAds
    ]
}

// App.swift
IAPConfiguration.setup(productIDs: IAPProductIDs.all)
```

### 3. Environment-Specific IDs
Sử dụng build configurations cho different environments:

```swift
#if DEBUG
let productIDs = [
    "com.yourapp.test.monthly",
    "com.yourapp.test.yearly"
]
#else
let productIDs = [
    "com.yourapp.premium.monthly",
    "com.yourapp.premium.yearly"
]
#endif

IAPConfiguration.setup(productIDs: productIDs)
```

## Migration Guide

Nếu đang sử dụng version cũ với hardcoded IAPProduct enum:

### Step 1: Identify Product IDs
Lấy product IDs hiện tại từ App Store Connect.

### Step 2: Setup Configuration
Thêm `IAPConfiguration.setup()` vào `App.init()`.

### Step 3: Remove IAPProduct References
Tìm và xóa các references đến `IAPProduct.premiumUnlock`, `IAPProduct.removeAds`, etc.

### Step 4: Use hasProduct() for Custom Logic
Thay vì:
```swift
if manager.isPurchased(IAPProduct.premiumUnlock.rawValue) {
    // Show premium features
}
```

Dùng:
```swift
if manager.hasProduct("com.yourapp.premium") {
    // Show premium features
}
```

### Step 5: Test Thoroughly
Test lại toàn bộ IAP flows để đảm bảo hoạt động đúng.

## Support

Nếu gặp vấn đề, kiểm tra:

1. ✅ `IAPConfiguration.setup()` đã được gọi trong `App.init()`
2. ✅ Product IDs match với App Store Connect
3. ✅ Configuration được setup **trước** khi gọi `loadProducts()`
4. ✅ Product ID naming convention đúng (cho mock testing)

## Version History

- **v1.1.0**: Added IAPConfiguration for dynamic product IDs
- **v1.0.x**: Hardcoded IAPProduct enum (deprecated)
