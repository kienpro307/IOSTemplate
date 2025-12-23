# Firebase Analytics Guide

## 📊 Tổng Quan

Firebase Analytics đã được integrate vào iOS Template với:
- ✅ Type-safe event tracking
- ✅ User properties management
- ✅ Screen tracking
- ✅ Debug mode support
- ✅ Dependency injection
- ✅ Predefined common events

## 🚀 Quick Start

### 1. Basic Usage

```swift
import iOSTemplate

class MyViewModel {
    // Inject analytics service
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    func userDidLogin(method: String) {
        // Track event
        analytics.trackEvent(.userLoggedIn(method: method))
    }
}
```

### 2. Track Custom Events

```swift
// Option 1: Predefined type-safe events
analytics.trackEvent(.userLoggedIn(method: "email"))
analytics.trackEvent(.purchaseCompleted(itemId: "premium", value: 9.99, currency: "USD"))
analytics.trackEvent(.featureUsed(name: "dark_mode", enabled: true))

// Option 2: Raw events (khi không có predefined event)
analytics.trackEvent(AnalyticsEvent(
    name: "custom_event",
    parameters: ["key": "value"]
))
```

### 3. Track Screens

```swift
struct HomeView: View {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    var body: some View {
        VStack {
            // Your UI
        }
        .onAppear {
            // Track screen view
            analytics.trackScreen("HomeScreen", parameters: nil)
        }
    }
}
```

### 4. Set User Properties

```swift
// Set user properties để segment users
analytics.setUserProperty("premium", forName: "user_type")
analytics.setUserProperty("ios", forName: "platform")
analytics.setUserProperty("v1.2.0", forName: "app_version")

// Set user ID (use hashed/anonymized ID)
analytics.setUserID("user_abc123_hashed")
```

## 🎯 Predefined Events

### Authentication Events

```swift
// User logged in
analytics.trackEvent(.userLoggedIn(method: "email"))
analytics.trackEvent(.userLoggedIn(method: "google"))
analytics.trackEvent(.userLoggedIn(method: "apple"))

// User signed up
analytics.trackEvent(.userSignedUp(method: "email"))

// User logged out
analytics.trackEvent(.userLoggedOut)
```

### Content Events

```swift
// Content viewed
analytics.trackEvent(.contentViewed(
    contentType: "article",
    contentId: "article_123"
))

// Content shared
analytics.trackEvent(.contentShared(
    contentType: "article",
    contentId: "article_123",
    method: "twitter"
))

// Search performed
analytics.trackEvent(.searchPerformed(
    query: "swift tutorial",
    resultsCount: 42
))
```

### E-commerce Events

```swift
// Item added to cart
analytics.trackEvent(.itemAddedToCart(
    itemId: "premium_monthly",
    itemName: "Premium Subscription",
    price: 9.99
))

// Purchase completed
analytics.trackEvent(.purchaseCompleted(
    itemId: "premium_monthly",
    value: 9.99,
    currency: "USD"
))
```

### Feature Usage Events

```swift
// Feature used
analytics.trackEvent(.featureUsed(
    name: "dark_mode",
    enabled: true
))

// Tutorial completed
analytics.trackEvent(.tutorialCompleted(tutorialId: "onboarding"))

// Level completed (for games)
analytics.trackEvent(.levelCompleted(
    levelId: "level_1",
    score: 1250
))
```

### Error Events

```swift
// Error occurred
analytics.trackEvent(.errorOccurred(
    errorCode: "AUTH_001",
    errorMessage: "Invalid credentials"
))

// API call failed
analytics.trackEvent(.apiCallFailed(
    endpoint: "/api/users",
    statusCode: 500
))
```

## 📱 Screen Tracking

### SwiftUI

```swift
struct ProfileView: View {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    var body: some View {
        VStack {
            // UI
        }
        .onAppear {
            analytics.trackScreen("ProfileScreen", parameters: nil)
        }
    }
}
```

### UIKit

```swift
class ProfileViewController: UIViewController {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.trackScreen("ProfileScreen", parameters: nil)
    }
}
```

### With Parameters

```swift
analytics.trackScreen("HomeScreen", parameters: [
    "tab": "explore",
    "user_segment": "premium",
    "ab_test_variant": "variant_b"
])
```

## 👤 User Properties

### Common User Properties

```swift
// User type/tier
analytics.setUserProperty("premium", forName: "user_type")
analytics.setUserProperty("free", forName: "user_type")

// User segment
analytics.setUserProperty("power_user", forName: "user_segment")
analytics.setUserProperty("casual", forName: "user_segment")

// Acquisition channel
analytics.setUserProperty("organic", forName: "acquisition_channel")
analytics.setUserProperty("paid_ads", forName: "acquisition_channel")

// Platform
analytics.setUserProperty("ios", forName: "platform")

// App version
analytics.setUserProperty("1.2.0", forName: "app_version")
```

### User ID

**IMPORTANT: Privacy Considerations**

```swift
// ✅ GOOD: Use hashed/anonymized ID
let hashedID = SHA256.hash(data: userEmail.data(using: .utf8)!)
    .compactMap { String(format: "%02x", $0) }
    .joined()
analytics.setUserID(hashedID)

// ❌ BAD: Don't use PII directly
analytics.setUserID(userEmail) // NO!
analytics.setUserID(phoneNumber) // NO!

// Clear user ID on logout
analytics.setUserID(nil)
```

## 🐛 Debug Mode

### Enable Debug Mode

Debug mode automatically enabled trong DEBUG builds.

**Xcode Scheme Arguments:**
1. Edit Scheme → Run → Arguments
2. Add argument: `-FIRAnalyticsDebugEnabled`

### View Events in Firebase Console

1. Open Firebase Console
2. Navigate to: **Analytics → DebugView**
3. Filter by device ID
4. Events appear **real-time** (no delay)

### Console Logs

Debug builds print events to console:

```
[FirebaseAnalytics] 📊 Event tracked: login
   Parameters: ["method": "email"]
[FirebaseAnalytics] 📱 Screen viewed: HomeScreen
[FirebaseAnalytics] 👤 User property set: user_type = premium
[FirebaseAnalytics] 🆔 User ID set: abc123_hashed
```

## 🎨 Adding Custom Events

### Step 1: Add to AppAnalyticsEvent Enum

```swift
// In FirebaseAnalyticsService.swift
public enum AppAnalyticsEvent {
    // ... existing events

    // Your new event
    case videoWatched(videoId: String, duration: TimeInterval)
}
```

### Step 2: Add Conversion Logic

```swift
extension AppAnalyticsEvent {
    var event: AnalyticsEvent {
        switch self {
        // ... existing cases

        case .videoWatched(let videoId, let duration):
            return AnalyticsEvent(
                name: "video_watched",
                parameters: [
                    "video_id": videoId,
                    "duration": duration
                ]
            )
        }
    }
}
```

### Step 3: Use It

```swift
analytics.trackEvent(.videoWatched(
    videoId: "video_123",
    duration: 125.5
))
```

## 📊 Best Practices

### Event Naming

✅ **DO:**
- Use snake_case: `user_logged_in`, `purchase_completed`
- Be descriptive: `video_watched` not `vw`
- Use Firebase standard events when possible: `login`, `sign_up`, `purchase`

❌ **DON'T:**
- Use camelCase: `userLoggedIn` (NO!)
- Use spaces: `user logged in` (NO!)
- Use special characters: `user@login` (NO!)

### Parameter Naming

✅ **DO:**
- Use Firebase standard parameters: `item_id`, `value`, `currency`
- Use snake_case: `video_duration`, `search_query`
- Limit to 25 parameters per event
- Keep parameter names under 40 characters

❌ **DON'T:**
- Exceed 100 characters for parameter values
- Use reserved prefixes: `firebase_`, `google_`, `ga_`

### User Properties

✅ **DO:**
- Set meaningful properties: `user_type`, `subscription_status`
- Update when values change
- Use up to 25 user properties
- Keep names under 24 characters
- Keep values under 36 characters

❌ **DON'T:**
- Store PII (email, phone, name)
- Use excessive user properties (Firebase limit: 25)

### Privacy

✅ **DO:**
- Hash/anonymize user IDs
- Follow GDPR/CCPA regulations
- Respect user privacy settings
- Clear analytics data on logout
- Implement opt-out mechanism

❌ **DON'T:**
- Track PII without consent
- Send sensitive data in events
- Track children under 13 without parental consent

## 🧪 Testing

### Verify Events in DebugView

1. Run app in Debug mode
2. Perform action that triggers event
3. Check console for log
4. Check Firebase DebugView (events appear within seconds)

### Example Test Flow

```swift
// 1. Track event
analytics.trackEvent(.userLoggedIn(method: "email"))

// 2. Check console
// Expected: [FirebaseAnalytics] 📊 Event tracked: login

// 3. Check Firebase DebugView
// Expected: Event "login" with parameter "method=email"
```

### Common Issues

**Issue: Events không appear trong DebugView**
- ✅ Check internet connection
- ✅ Verify `-FIRAnalyticsDebugEnabled` argument
- ✅ Check device is selected in DebugView filter
- ✅ Wait 30 seconds (small delay possible)

**Issue: Events không appear trong Analytics (production)**
- ✅ Wait 24 hours (production events có delay)
- ✅ Verify Analytics enabled trong FirebaseConfig
- ✅ Check app connected to Firebase Console

## 📈 Analytics in Production

### Event Upload

- **Debug mode**: Events upload immediately
- **Production**: Events batched và upload periodically
- **Delay**: Up to 24 hours before appearing in reports

### Limits

- **Events per app**: 500 distinct event types
- **Parameters per event**: 25 parameters
- **User properties**: 25 properties
- **Event name length**: 40 characters
- **Parameter name length**: 40 characters
- **Parameter value length**: 100 characters

### Quotas

- **Free tier**: 10M events per month (unlimited for Analytics)
- **No limit** on number of events trong free tier
- **No limit** on number of users

## 🔗 Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [iOS Analytics Guide](https://firebase.google.com/docs/analytics/get-started?platform=ios)
- [Analytics Events Reference](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics)
- [Best Practices](https://firebase.google.com/docs/analytics/best-practices)

---

**Last Updated**: November 2024
**Firebase SDK Version**: 10.19.0+
