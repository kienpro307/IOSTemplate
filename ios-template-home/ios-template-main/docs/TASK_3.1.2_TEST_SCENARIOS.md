# Task 3.1.2 Test Scenarios - Firebase Analytics

## 📋 Test Overview

Comprehensive test scenarios cho Firebase Analytics implementation.

## ✅ Test Cases

### Test Group 1: Service Registration

#### TC-1.1: Analytics Service Registered in DI Container
**Steps**:
```swift
let analytics = DIContainer.shared.analyticsService
```
**Expected**:
- ✅ Returns FirebaseAnalyticsService instance
- ✅ Not nil
- ✅ Singleton (same instance every time)

#### TC-1.2: @Injected Property Wrapper
**Steps**:
```swift
class TestClass {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol
}
let test = TestClass()
let service = test.analytics
```
**Expected**:
- ✅ Property wrapper resolves correctly
- ✅ Returns FirebaseAnalyticsService
- ✅ No crash

### Test Group 2: Event Tracking

#### TC-2.1: Track Predefined Event - User Login
**Steps**:
```swift
analytics.trackEvent(.userLoggedIn(method: "email"))
```
**Expected**:
- ✅ No crash
- ✅ Debug log appears: "📊 Event tracked: login"
- ✅ Parameters logged: ["method": "email"]
- ✅ Event appears in Firebase DebugView

#### TC-2.2: Track Multiple Events
**Steps**:
```swift
analytics.trackEvent(.userLoggedIn(method: "email"))
analytics.trackEvent(.contentViewed(contentType: "article", contentId: "123"))
analytics.trackEvent(.purchaseCompleted(itemId: "premium", value: 9.99, currency: "USD"))
```
**Expected**:
- ✅ All events tracked
- ✅ All events logged separately
- ✅ All events appear in DebugView

#### TC-2.3: Track Raw Event
**Steps**:
```swift
analytics.trackEvent(AnalyticsEvent(
    name: "custom_event",
    parameters: ["key1": "value1", "key2": 123]
))
```
**Expected**:
- ✅ Event tracked
- ✅ Custom parameters included
- ✅ Appears in DebugView

#### TC-2.4: Track Event Without Parameters
**Steps**:
```swift
analytics.trackEvent(.userLoggedOut)
```
**Expected**:
- ✅ Event tracked
- ✅ No parameters
- ✅ No crash

#### TC-2.5: Track Event With Complex Parameters
**Steps**:
```swift
analytics.trackEvent(.searchPerformed(query: "swift tutorial", resultsCount: 42))
```
**Expected**:
- ✅ Event tracked
- ✅ Multiple parameters: search_term, results_count
- ✅ Int value handled correctly

### Test Group 3: Screen Tracking

#### TC-3.1: Track Screen - Basic
**Steps**:
```swift
analytics.trackScreen("HomeScreen", parameters: nil)
```
**Expected**:
- ✅ Screen view event tracked
- ✅ Debug log: "📱 Screen viewed: HomeScreen"
- ✅ Firebase event: screen_view
- ✅ Parameters: screen_name=HomeScreen, screen_class=HomeScreen

#### TC-3.2: Track Screen - With Parameters
**Steps**:
```swift
analytics.trackScreen("HomeScreen", parameters: [
    "tab": "explore",
    "user_segment": "premium"
])
```
**Expected**:
- ✅ Screen tracked
- ✅ Additional parameters included
- ✅ screen_name still set correctly

#### TC-3.3: Track Multiple Screens in Sequence
**Steps**:
```swift
analytics.trackScreen("HomeScreen", parameters: nil)
analytics.trackScreen("ProfileScreen", parameters: nil)
analytics.trackScreen("SettingsScreen", parameters: nil)
```
**Expected**:
- ✅ All screens tracked
- ✅ Each screen logged separately
- ✅ User journey visible in Firebase

### Test Group 4: User Properties

#### TC-4.1: Set User Property - Basic
**Steps**:
```swift
analytics.setUserProperty("premium", forName: "user_type")
```
**Expected**:
- ✅ Property set
- ✅ Debug log: "👤 User property set: user_type = premium"
- ✅ Property visible in Firebase User Properties

#### TC-4.2: Set Multiple User Properties
**Steps**:
```swift
analytics.setUserProperty("premium", forName: "user_type")
analytics.setUserProperty("ios", forName: "platform")
analytics.setUserProperty("1.2.0", forName: "app_version")
```
**Expected**:
- ✅ All properties set
- ✅ Each property logged
- ✅ All properties visible in Firebase

#### TC-4.3: Update Existing User Property
**Steps**:
```swift
analytics.setUserProperty("free", forName: "user_type")
// Later...
analytics.setUserProperty("premium", forName: "user_type")
```
**Expected**:
- ✅ Property updated to new value
- ✅ Latest value persists

#### TC-4.4: Set User ID
**Steps**:
```swift
analytics.setUserID("user_abc123_hashed")
```
**Expected**:
- ✅ User ID set
- ✅ Debug log: "🆔 User ID set: user_abc123_hashed"
- ✅ User ID visible in Firebase

#### TC-4.5: Clear User ID
**Steps**:
```swift
analytics.setUserID("user_123")
analytics.setUserID(nil) // Clear
```
**Expected**:
- ✅ User ID cleared
- ✅ Debug log: "🆔 User ID cleared"

### Test Group 5: Type Safety

#### TC-5.1: Compile-Time Type Safety
**Steps**:
```swift
// This should compile:
analytics.trackEvent(.userLoggedIn(method: "email"))

// This should NOT compile (wrong parameter type):
// analytics.trackEvent(.userLoggedIn(method: 123)) // Error!
```
**Expected**:
- ✅ Correct usage compiles
- ✅ Incorrect usage fails at compile time

#### TC-5.2: Auto-Completion Works
**Steps**:
1. Type `analytics.trackEvent(.`
2. Check auto-completion list
**Expected**:
- ✅ All AppAnalyticsEvent cases appear
- ✅ Associated values shown
- ✅ Easy to discover available events

### Test Group 6: Debug Mode

#### TC-6.1: Debug Mode Enabled in DEBUG Builds
**Steps**:
```swift
// Run in DEBUG configuration
let service = FirebaseAnalyticsService.shared
// Check console
```
**Expected**:
- ✅ Console log: "🐛 Analytics Debug Mode: ENABLED"
- ✅ "View events in Firebase Console → DebugView"

#### TC-6.2: Debug Logging Works
**Steps**:
```swift
analytics.trackEvent(.userLoggedIn(method: "email"))
```
**Expected**:
- ✅ Console log appears immediately
- ✅ Log format: "[FirebaseAnalytics] 📊 Event tracked: login"
- ✅ Parameters logged

#### TC-6.3: Events Appear in DebugView
**Steps**:
1. Run app in DEBUG mode
2. Track event
3. Open Firebase Console → DebugView
4. Select device
**Expected**:
- ✅ Event appears within 10 seconds
- ✅ All parameters visible
- ✅ Real-time updates

### Test Group 7: Integration Tests

#### TC-7.1: Track Event from View
**Steps**:
```swift
struct TestView: View {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    var body: some View {
        Button("Track") {
            analytics.trackEvent(.userLoggedIn(method: "email"))
        }
    }
}
// Tap button
```
**Expected**:
- ✅ Event tracked on button tap
- ✅ No crash
- ✅ Event appears in DebugView

#### TC-7.2: Track Screen from onAppear
**Steps**:
```swift
struct TestView: View {
    @Injected(AnalyticsServiceProtocol.self)
    var analytics: AnalyticsServiceProtocol

    var body: some View {
        Text("Test")
            .onAppear {
                analytics.trackScreen("TestScreen", parameters: nil)
            }
    }
}
// Navigate to view
```
**Expected**:
- ✅ Screen tracked on appear
- ✅ Event in DebugView

#### TC-7.3: Analytics After Firebase Config
**Steps**:
```swift
// In app init
try FirebaseManager.shared.configure(with: .auto)
// Then use analytics
analytics.trackEvent(.userLoggedIn(method: "email"))
```
**Expected**:
- ✅ Analytics works after Firebase configured
- ✅ No crash
- ✅ Events tracked correctly

### Test Group 8: Edge Cases

#### TC-8.1: Empty String Parameters
**Steps**:
```swift
analytics.trackEvent(.userLoggedIn(method: ""))
```
**Expected**:
- ✅ Event tracked
- ✅ Empty string handled
- ✅ No crash

#### TC-8.2: Very Long Parameter Values
**Steps**:
```swift
let longString = String(repeating: "a", count: 200)
analytics.trackEvent(AnalyticsEvent(
    name: "test_event",
    parameters: ["long_param": longString]
))
```
**Expected**:
- ✅ Event tracked
- ✅ Firebase truncates to 100 chars
- ✅ No crash

#### TC-8.3: Special Characters in Parameters
**Steps**:
```swift
analytics.trackEvent(AnalyticsEvent(
    name: "test_event",
    parameters: [
        "emoji": "🎉🚀",
        "special": "!@#$%^&*()"
    ]
))
```
**Expected**:
- ✅ Event tracked
- ✅ Special chars handled
- ✅ Emoji handled

#### TC-8.4: Nil Parameters
**Steps**:
```swift
analytics.trackScreen("TestScreen", parameters: nil)
```
**Expected**:
- ✅ Screen tracked
- ✅ Only screen_name/screen_class set
- ✅ No crash

#### TC-8.5: Many Parameters
**Steps**:
```swift
var params: [String: Any] = [:]
for i in 1...30 {
    params["param_\(i)"] = "value_\(i)"
}
analytics.trackEvent(AnalyticsEvent(name: "test", parameters: params))
```
**Expected**:
- ✅ Event tracked
- ✅ Firebase limits to 25 parameters (documented)
- ✅ No crash

### Test Group 9: Privacy & Security

#### TC-9.1: No PII in Events
**Manual Review**:
- Review all predefined events
**Expected**:
- ✅ No email fields
- ✅ No phone number fields
- ✅ No personal names
- ✅ Only anonymized IDs

#### TC-9.2: User ID Hashing (Documentation)
**Manual Review**:
- Check ANALYTICS_GUIDE.md
**Expected**:
- ✅ Examples show hashed IDs
- ✅ Warning against using PII
- ✅ Clear privacy guidelines

## 📊 Test Results Summary

### Checklist

- [ ] **TC-1**: Service Registration (2 tests)
- [ ] **TC-2**: Event Tracking (5 tests)
- [ ] **TC-3**: Screen Tracking (3 tests)
- [ ] **TC-4**: User Properties (5 tests)
- [ ] **TC-5**: Type Safety (2 tests)
- [ ] **TC-6**: Debug Mode (3 tests)
- [ ] **TC-7**: Integration (3 tests)
- [ ] **TC-8**: Edge Cases (5 tests)
- [ ] **TC-9**: Privacy & Security (2 tests)

**Total**: 30 test cases

### Task 3.1.2 Completion Criteria

Per original requirements:
- [x] Default events tracking ✅
- [x] Custom events defined ✅ (AppAnalyticsEvent enum)
- [x] User properties set ✅
- [x] Debug mode for testing ✅

### Production Readiness

- [x] Type-safe API
- [x] Comprehensive documentation
- [x] Debug logging
- [x] Edge cases handled
- [x] Privacy considerations documented
- [x] DI integration
- [x] Pattern compliance

## 🎯 Validation

### Firebase DebugView Validation

1. Run app in DEBUG mode
2. Perform actions:
   - Login → Check `login` event
   - View screen → Check `screen_view` event
   - Set user property → Check user properties panel
3. All events should appear within 10 seconds

### Console Log Validation

Check for logs:
```
[FirebaseAnalytics] 🐛 Analytics Debug Mode: ENABLED
[FirebaseAnalytics] 📊 Event tracked: login
[FirebaseAnalytics] 📱 Screen viewed: HomeScreen
[FirebaseAnalytics] 👤 User property set: user_type = premium
[FirebaseAnalytics] 🆔 User ID set: abc123
```

### Production Validation

1. Wait 24 hours after release
2. Check Firebase Console → Analytics → Events
3. Verify events appearing
4. Check user properties in Audience Builder

## ✅ Sign-Off

**Task 3.1.2 - Setup Analytics: READY FOR TESTING**

All implementation complete:
- ✅ FirebaseAnalyticsService implemented
- ✅ Type-safe AppAnalyticsEvent enum
- ✅ DI integration
- ✅ Comprehensive documentation
- ✅ Test scenarios defined
- ✅ Pattern compliance

**Ready to proceed to Task 3.1.3 - Configure Crashlytics**
