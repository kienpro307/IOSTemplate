# Phase 5: Monetization Implementation

## Overview
Phase 5 implements complete monetization features including In-App Purchases (IAP), Advertisement integration (AdMob), and Revenue Tracking (AppsFlyer).

## Implementation Status: ✅ COMPLETED

---

## 📦 Components Implemented

### 1. In-App Purchase (IAP) - StoreKit 2

#### Files Created:
- `Sources/iOSTemplate/Monetization/IAP/IAPProduct.swift`
- `Sources/iOSTemplate/Monetization/IAP/StoreKitManager.swift`
- `Sources/iOSTemplate/Monetization/IAP/IAPService.swift`
- `Sources/iOSTemplate/Monetization/IAP/StoreKit.storekit`
- `Sources/iOSTemplate/Monetization/IAP/Views/PurchaseView.swift`

#### Features:
✅ Product definitions (Consumable, Non-Consumable, Subscriptions)
✅ StoreKit 2 integration with modern async/await API
✅ Transaction verification and validation
✅ Subscription management with grace period handling
✅ Restore purchases functionality
✅ SwiftUI purchase UI components
✅ Type-safe product IDs

#### Product Types Configured:
1. **Consumable Products**:
   - 100 Coins ($0.99)
   - 500 Coins ($3.99)
   - 1000 Coins ($6.99)

2. **Non-Consumable Products**:
   - Remove Ads ($4.99)
   - Premium Unlock ($9.99)

3. **Auto-Renewable Subscriptions**:
   - Monthly Subscription ($4.99/month) with 1-week free trial
   - Yearly Subscription ($39.99/year) with 1-week free trial (33% savings)

#### Usage Example:
```swift
// Initialize StoreKit Manager
let storeKitManager = StoreKitManager()

// Load products
await storeKitManager.loadProducts()

// Purchase a product
if let product = storeKitManager.products.first {
    let transaction = try await storeKitManager.purchase(product)
}

// Check if user has premium
let iapService = DIContainer.shared.iapService
let hasPremium = await iapService?.hasPremium()

// Restore purchases
await storeKitManager.restorePurchases()
```

---

### 2. Advertisement Integration (AdMob)

#### Files Created:
- `Sources/iOSTemplate/Monetization/Ads/AdMobConfiguration.swift`
- `Sources/iOSTemplate/Monetization/Ads/AdMobManager.swift`
- `Sources/iOSTemplate/Monetization/Ads/Views/BannerAdView.swift`
- `Sources/iOSTemplate/Monetization/Ads/Views/RewardedAdButton.swift`

#### Features:
✅ AdMob SDK integration structure (mock implementation)
✅ Banner ads support
✅ Interstitial ads with frequency capping
✅ Rewarded video ads
✅ Ad placement tracking
✅ Ad frequency control (60s between interstitials, max 5 per session)
✅ SwiftUI ad components

#### Ad Types Supported:
1. **Banner Ads**: 320x50, 320x100, 300x250, 468x60, 728x90, Adaptive
2. **Interstitial Ads**: Full-screen ads with frequency control
3. **Rewarded Video Ads**: Watch ad to earn rewards (coins, lives, etc.)

#### Configuration:
```swift
AdMobConfiguration.appID = "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"
AdMobConfiguration.bannerAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
AdMobConfiguration.interstitialAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
AdMobConfiguration.rewardedAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
```

#### Usage Example:
```swift
// Show banner ad
BannerAdView(adSize: .banner)

// Show rewarded ad
RewardedAdButton(
    title: "Watch Ad",
    rewardDescription: "Get 100 coins"
) { rewardAmount in
    print("User earned: \(rewardAmount) coins")
}

// Show interstitial
let adManager = AdMobManager()
adManager.loadInterstitialAd(for: .levelComplete)
adManager.showInterstitialAd()
```

#### Note on Google Mobile Ads SDK:
⚠️ **Action Required**: Add Google Mobile Ads SDK to your project via CocoaPods:

```ruby
# Podfile
pod 'Google-Mobile-Ads-SDK'
```

Then run:
```bash
pod install
```

The current implementation provides mock functionality for development. Replace mock code with actual Google Mobile Ads SDK calls.

---

### 3. Revenue Tracking (AppsFlyer)

#### Files Created:
- `Sources/iOSTemplate/Monetization/Analytics/AppsFlyerConfiguration.swift`
- `Sources/iOSTemplate/Monetization/Analytics/AppsFlyerManager.swift`
- `Sources/iOSTemplate/Monetization/Analytics/RevenueTracker.swift`

#### Features:
✅ AppsFlyer SDK integration structure
✅ Revenue event tracking (IAP, Ads, Subscriptions)
✅ Attribution tracking
✅ Deep linking support
✅ User property tracking
✅ Custom event logging
✅ LTV calculation support

#### Revenue Sources Tracked:
- In-App Purchases
- AdMob Revenue
- Subscription Revenue
- Custom Revenue Sources

#### Configuration:
```swift
AppsFlyerConfiguration.devKey = "YOUR_APPSFLYER_DEV_KEY"
AppsFlyerConfiguration.appleAppID = "123456789"
```

#### Usage Example:
```swift
// Initialize AppsFlyer
let appsFlyerManager = AppsFlyerManager()
appsFlyerManager.initialize()

// Track IAP purchase
let revenueTracker = RevenueTracker()
revenueTracker.trackIAPPurchase(
    productId: "com.template.ios.premium",
    price: 9.99,
    currency: "USD",
    transactionId: "1000000123456789"
)

// Track subscription
revenueTracker.trackSubscription(
    productId: "com.template.ios.subscription.monthly",
    price: 4.99,
    currency: "USD",
    period: .monthly,
    isNewSubscription: true,
    transactionId: "1000000123456790"
)

// Track ad revenue
revenueTracker.trackAdRevenue(
    revenue: 0.05,
    currency: "USD",
    adNetwork: "admob",
    adUnit: "banner_home",
    placement: "home_screen"
)

// Get revenue summary
let summary = revenueTracker.getRevenueSummary()
print("Total Revenue: \(summary.formattedTotal)")
```

#### Note on AppsFlyer SDK:
⚠️ **Action Required**: Add AppsFlyer SDK to your project:

**Via Swift Package Manager**:
```
https://github.com/AppsFlyerSDK/AppsFlyerFramework
```

**Or via CocoaPods**:
```ruby
pod 'AppsFlyerFramework'
```

---

## 🔄 App State Integration

### MonetizationState
Added to `AppState.swift`:

```swift
public struct MonetizationState: Equatable {
    public var hasPremium: Bool
    public var hasRemovedAds: Bool
    public var activeSubscription: SubscriptionInfo?
    public var purchasedProducts: Set<String>
    public var adsEnabled: Bool
    public var totalRevenue: Double
}
```

### Usage in App:
```swift
// Access monetization state
store.state.monetization.hasPremium
store.state.monetization.hasRemovedAds
store.state.monetization.activeSubscription
```

---

## 🏗️ Dependency Injection

### Services Registered in DI Container:

```swift
// IAP Service
DIContainer.shared.iapService

// AdMob Manager
DIContainer.shared.adMobManager

// AppsFlyer Manager
DIContainer.shared.appsFlyerManager

// Revenue Tracker
DIContainer.shared.revenueTracker
```

### Using @Injected:
```swift
@Injected(IAPServiceProtocol.self)
var iapService: IAPServiceProtocol

@Injected(AdMobManager.self)
var adMobManager: AdMobManager
```

---

## 🧪 Testing

### StoreKit Testing:
1. Use `StoreKit.storekit` configuration file
2. Enable StoreKit testing in Xcode scheme
3. Test all purchase flows in sandbox

### Test Products:
All products use Apple's test ad unit IDs for development:
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

---

## 📝 Next Steps

### For Production:

1. **App Store Connect**:
   - Create IAP products matching `IAPProduct` enum
   - Configure product IDs, pricing, and metadata
   - Submit products for review

2. **AdMob Setup**:
   - Create AdMob account
   - Register app and get App ID
   - Create ad units for each format
   - Replace test IDs with production IDs
   - Add `Google-Mobile-Ads-SDK` to project

3. **AppsFlyer Setup**:
   - Create AppsFlyer account
   - Get Dev Key and App ID
   - Configure attribution settings
   - Set up conversion tracking
   - Add `AppsFlyerFramework` to project
   - Replace mock implementations with real SDK calls

4. **Testing**:
   - Test all purchase flows in sandbox
   - Verify receipt validation
   - Test subscription renewal and grace period
   - Test ad display and frequency capping
   - Verify revenue tracking in dashboards

5. **Analytics**:
   - Set up conversion funnels
   - Monitor LTV metrics
   - Track revenue by source
   - A/B test pricing and placements

---

## 🔐 Privacy & Compliance

### App Store Requirements:
- Add In-App Purchase capability in Xcode
- Update Privacy Policy for data collection
- Add App Tracking Transparency (ATT) for iOS 14+
- Comply with GDPR, CCPA regulations

### Privacy Policy Considerations:
- Data collected by AdMob
- Attribution tracking by AppsFlyer
- Purchase history storage
- User analytics and segmentation

---

## ✅ Acceptance Criteria - Phase 5

### TASK 5.1: In-App Purchase Implementation ✅
- [x] 5.1.1 - Products configured with StoreKit configuration file
- [x] 5.1.2 - Purchase flow implemented with StoreKit 2
- [x] 5.1.3 - Subscription management with grace period handling
- [x] 5.1.4 - Restore purchases functionality

### TASK 5.2: Advertisement Integration ✅
- [x] 5.2.1 - AdMob SDK structure and configuration
- [x] 5.2.2 - Banner, Interstitial, and Rewarded ads
- [x] 5.2.3 - Ad frequency control and user experience optimization

### TASK 5.3: Revenue Tracking ✅
- [x] 5.3.1 - AppsFlyer SDK structure and setup
- [x] 5.3.2 - Revenue analytics for all monetization sources

---

## 📚 Documentation References

- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [AdMob iOS Quick Start](https://developers.google.com/admob/ios/quick-start)
- [AppsFlyer iOS SDK Integration](https://dev.appsflyer.com/hc/docs/ios-sdk-integration-overview)
- [App Store In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)

---

## 🐛 Known Issues & TODOs

- [ ] Replace AdMob mock implementation with real Google Mobile Ads SDK
- [ ] Replace AppsFlyer mock implementation with real SDK
- [ ] Add receipt validation server-side
- [ ] Implement promotional offers and subscription offers
- [ ] Add native ads support
- [ ] Implement offer codes for subscriptions
- [ ] Add A/B testing for pricing
- [ ] Implement win-back campaigns for churned users

---

**Phase 5 Status**: ✅ **COMPLETED**

All core monetization features have been implemented and are ready for integration with production SDKs.
