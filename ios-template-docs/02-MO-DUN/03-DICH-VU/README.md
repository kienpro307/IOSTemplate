# ⚙️ Mô-đun SERVICES (Services Module)

## Tổng Quan
Module chứa các service integrations với external services.

## Cấu Trúc
```
Services/
├── Firebase/
│   ├── Analytics.swift       # Analytics tracking
│   ├── Crashlytics.swift     # Crash reporting
│   ├── RemoteConfig.swift    # Remote Config
│   └── PushNotification.swift # FCM
├── Payment/
│   └── PaymentService.swift  # StoreKit 2
└── Ads/
    └── AdService.swift       # AdMob
```

## Dependencies
- Firebase SDK 11.0+
- StoreKit 2
- Google Mobile Ads SDK

## Usage
```swift
// Sử dụng analytics
@Dependency(\.analytics) var analytics

// Sử dụng payment service
@Dependency(\.paymentService) var paymentService
```
