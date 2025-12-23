# Task 3.1.3 Test Scenarios - Firebase Crashlytics

## 📋 Test Overview

Comprehensive test scenarios cho Firebase Crashlytics implementation.

## ✅ Test Cases

### Test Group 1: Service Registration

#### TC-1.1: Crashlytics Service Registered in DI Container
**Steps**:
```swift
let crashlytics = DIContainer.shared.crashlyticsService
```
**Expected**:
- ✅ Returns FirebaseCrashlyticsService instance
- ✅ Not nil
- ✅ Singleton (same instance every time)

#### TC-1.2: @Injected Property Wrapper
**Steps**:
```swift
class TestClass {
    @Injected(CrashlyticsServiceProtocol.self)
    var crashlytics: CrashlyticsServiceProtocol
}
let test = TestClass()
let service = test.crashlytics
```
**Expected**:
- ✅ Property wrapper resolves correctly
- ✅ Returns FirebaseCrashlyticsService
- ✅ No crash

### Test Group 2: Non-Fatal Error Recording

#### TC-2.1: Record Simple Error
**Steps**:
```swift
let error = NSError(domain: "TestError", code: 100, userInfo: nil)
crashlytics.recordError(error)
```
**Expected**:
- ✅ Error recorded
- ✅ Debug log: "💥 Non-fatal error recorded: ..."
- ✅ Error appears trong Firebase Console

#### TC-2.2: Record Error With UserInfo
**Steps**:
```swift
let error = NSError(domain: "TestError", code: 100, userInfo: nil)
crashlytics.recordError(error, userInfo: [
    "endpoint": "/api/users",
    "status_code": 500
])
```
**Expected**:
- ✅ Error recorded với userInfo
- ✅ UserInfo logged to console
- ✅ UserInfo visible trong Firebase crash report

#### TC-2.3: Record Custom Error Type
**Steps**:
```swift
let error = AppCrashError.networkFailure(statusCode: 500, endpoint: "/api/checkout")
crashlytics.recordError(error, userInfo: ["user_action": "checkout"])
```
**Expected**:
- ✅ Custom error recorded
- ✅ Error description correct
- ✅ Appears trong Firebase

#### TC-2.4: Record Multiple Errors
**Steps**:
```swift
for i in 1...5 {
    let error = NSError(domain: "Test", code: i, userInfo: nil)
    crashlytics.recordError(error)
}
```
**Expected**:
- ✅ All errors recorded
- ✅ Each error logged separately
- ✅ All appear trong Firebase

### Test Group 3: Custom Logging

#### TC-3.1: Log Simple Message
**Steps**:
```swift
crashlytics.log("User tapped checkout button")
```
**Expected**:
- ✅ Message logged
- ✅ Debug log: "📝 Crashlytics log: User tapped checkout button"
- ✅ Message appears trong crash reports

#### TC-3.2: Log Multiple Messages
**Steps**:
```swift
crashlytics.log("Step 1: User opened checkout")
crashlytics.log("Step 2: User entered payment")
crashlytics.log("Step 3: Payment processing")
```
**Expected**:
- ✅ All messages logged
- ✅ Messages appear in order
- ✅ Messages visible trong crash report

#### TC-3.3: Log Formatted Message
**Steps**:
```swift
crashlytics.log(format: "User %@ completed checkout with $%.2f", "john_doe", 99.99)
```
**Expected**:
- ✅ Formatted message logged
- ✅ Variables interpolated correctly
- ✅ Message appears trong crash report

#### TC-3.4: Log Long Message
**Steps**:
```swift
let longMessage = String(repeating: "a", count: 1000)
crashlytics.log(longMessage)
```
**Expected**:
- ✅ Message logged
- ✅ No crash
- ✅ Message appears (may be truncated by Firebase)

### Test Group 4: User Context

#### TC-4.1: Set User ID
**Steps**:
```swift
crashlytics.setUserID("user_abc123_hashed")
```
**Expected**:
- ✅ User ID set
- ✅ Debug log: "🆔 Crashlytics user ID set: user_abc123_hashed"
- ✅ User ID visible trong crash reports

#### TC-4.2: Clear User ID
**Steps**:
```swift
crashlytics.setUserID("user_123")
crashlytics.setUserID(nil)
```
**Expected**:
- ✅ User ID cleared
- ✅ Debug log: "🆔 Crashlytics user ID cleared"
- ✅ User ID không appear trong subsequent crashes

#### TC-4.3: Update User ID
**Steps**:
```swift
crashlytics.setUserID("user_old")
// Later...
crashlytics.setUserID("user_new")
```
**Expected**:
- ✅ User ID updated
- ✅ Latest ID used trong crash reports

### Test Group 5: Custom Keys

#### TC-5.1: Set String Value
**Steps**:
```swift
crashlytics.setCustomValue("premium", forKey: "user_tier")
```
**Expected**:
- ✅ Key set
- ✅ Debug log: "🔧 Crashlytics custom key set: user_tier = premium"
- ✅ Key visible trong crash reports

#### TC-5.2: Set Int Value
**Steps**:
```swift
crashlytics.setCustomValue(42, forKey: "items_in_cart")
```
**Expected**:
- ✅ Int value set correctly
- ✅ Value appears as number trong crash report

#### TC-5.3: Set Bool Value
**Steps**:
```swift
crashlytics.setCustomValue(true, forKey: "dark_mode_enabled")
```
**Expected**:
- ✅ Bool value set correctly
- ✅ Value appears as true/false

#### TC-5.4: Set Float/Double Value
**Steps**:
```swift
crashlytics.setCustomValue(3.14, forKey: "app_rating")
crashlytics.setCustomValue(Float(1.5), forKey: "zoom_level")
```
**Expected**:
- ✅ Decimal values set correctly
- ✅ Precision maintained

#### TC-5.5: Set Multiple Custom Values
**Steps**:
```swift
crashlytics.setCustomValues([
    "user_tier": "premium",
    "is_first_launch": false,
    "app_version": "1.2.0"
])
```
**Expected**:
- ✅ All keys set
- ✅ Each key logged
- ✅ All keys visible trong crash reports

#### TC-5.6: Update Existing Key
**Steps**:
```swift
crashlytics.setCustomValue("free", forKey: "user_tier")
crashlytics.setCustomValue("premium", forKey: "user_tier")
```
**Expected**:
- ✅ Key updated to new value
- ✅ Latest value used trong crash reports

### Test Group 6: Test Crash

#### TC-6.1: Test Crash in DEBUG Build
**Steps**:
```swift
#if DEBUG
crashlytics.testCrash()
#endif
```
**Expected**:
- ✅ Debug log: "💣 TEST CRASH TRIGGERED - App will crash now!"
- ✅ App crashes immediately
- ✅ On relaunch, crash report uploads
- ✅ Crash appears trong Firebase Console (5-10 min)
- ✅ Stack trace symbolicated

#### TC-6.2: Test Crash in RELEASE Build
**Steps**:
```swift
// Build in Release mode
crashlytics.testCrash()
```
**Expected**:
- ✅ Warning logged: "testCrash() called in RELEASE build - ignoring"
- ✅ App does NOT crash
- ✅ Safety mechanism works

### Test Group 7: Integration Tests

#### TC-7.1: Full Error Flow
**Steps**:
```swift
// 1. Set context
crashlytics.setUserID("user_123")
crashlytics.setCustomValue("premium", forKey: "user_tier")

// 2. Log journey
crashlytics.log("User started checkout")
crashlytics.log("User entered payment")

// 3. Error occurs
let error = NSError(domain: "Checkout", code: 500, userInfo: nil)
crashlytics.recordError(error, userInfo: ["step": "payment"])
```
**Expected**:
- ✅ All context set
- ✅ Error recorded với full context
- ✅ Error report shows: user ID, custom keys, logs, error details

#### TC-7.2: Crash Report Contains All Context
**Steps**:
1. Set user ID
2. Set custom keys
3. Log messages
4. Trigger crash
5. Relaunch app
6. Check Firebase Console
**Expected**:
- ✅ Crash report shows user ID
- ✅ All custom keys visible
- ✅ All logged messages visible
- ✅ Stack trace symbolicated

#### TC-7.3: Service Available After Firebase Config
**Steps**:
```swift
// In app init
try FirebaseManager.shared.configure(with: .auto)
// Then use Crashlytics
crashlytics.recordError(someError)
```
**Expected**:
- ✅ Crashlytics works after Firebase configured
- ✅ No crash
- ✅ Error tracked correctly

### Test Group 8: Edge Cases

#### TC-8.1: Record Error With Nil UserInfo
**Steps**:
```swift
crashlytics.recordError(error, userInfo: nil)
```
**Expected**:
- ✅ Error recorded
- ✅ No crash
- ✅ UserInfo shows as nil trong report

#### TC-8.2: Log Empty String
**Steps**:
```swift
crashlytics.log("")
```
**Expected**:
- ✅ Empty string logged
- ✅ No crash
- ✅ Empty line trong crash log

#### TC-8.3: Set Empty String Value
**Steps**:
```swift
crashlytics.setCustomValue("", forKey: "test_key")
```
**Expected**:
- ✅ Empty string set
- ✅ No crash
- ✅ Key appears với empty value

#### TC-8.4: Set Nil User ID Multiple Times
**Steps**:
```swift
crashlytics.setUserID(nil)
crashlytics.setUserID(nil)
crashlytics.setUserID(nil)
```
**Expected**:
- ✅ No crash
- ✅ Each call logged

#### TC-8.5: Set Many Custom Keys
**Steps**:
```swift
for i in 1...100 {
    crashlytics.setCustomValue("value_\(i)", forKey: "key_\(i)")
}
```
**Expected**:
- ✅ All keys set
- ✅ Firebase limits to first 64 keys (documented)
- ✅ No crash

### Test Group 9: Debug Mode

#### TC-9.1: Debug Mode Enabled in DEBUG
**Steps**:
```swift
// Run in DEBUG configuration
let service = FirebaseCrashlyticsService.shared
// Check console
```
**Expected**:
- ✅ Console log: "🐛 Crashlytics Debug Mode: ENABLED"
- ✅ Logs appear for all operations

#### TC-9.2: Debug Logging for All Operations
**Steps**:
```swift
crashlytics.recordError(error)
crashlytics.log("message")
crashlytics.setUserID("user_123")
crashlytics.setCustomValue("value", forKey: "key")
```
**Expected**:
- ✅ Each operation logged với appropriate emoji
- ✅ Console logs clear và helpful

### Test Group 10: dSYM & Symbolication

#### TC-10.1: dSYM Upload Script Exists
**Manual Check**:
- Open Xcode project
- Check Build Phases
- Verify "Upload dSYM" run script exists
**Expected**:
- ✅ Run script present
- ✅ Script path correct
- ✅ Input files configured

#### TC-10.2: Crash Stack Trace Symbolicated
**Steps**:
1. Archive app
2. Trigger test crash
3. Relaunch
4. Check Firebase Console crash report
**Expected**:
- ✅ Stack trace shows readable class names
- ✅ Method names visible (not memory addresses)
- ✅ Line numbers shown

**If not symbolicated**:
- ⚠️ dSYM not uploaded
- Upload manually và verify

## 📊 Test Results Summary

### Checklist

- [ ] **TC-1**: Service Registration (2 tests)
- [ ] **TC-2**: Non-Fatal Errors (4 tests)
- [ ] **TC-3**: Custom Logging (4 tests)
- [ ] **TC-4**: User Context (3 tests)
- [ ] **TC-5**: Custom Keys (6 tests)
- [ ] **TC-6**: Test Crash (2 tests)
- [ ] **TC-7**: Integration (3 tests)
- [ ] **TC-8**: Edge Cases (5 tests)
- [ ] **TC-9**: Debug Mode (2 tests)
- [ ] **TC-10**: dSYM & Symbolication (2 tests)

**Total**: 33 test cases

### Task 3.1.3 Completion Criteria

Per original requirements:
- [x] Crashlytics enabled ✅
- [x] dSYM upload configured ✅
- [x] Custom logs added ✅
- [x] Non-fatal error reporting ✅

### Additional Features Implemented
- [x] User context tracking
- [x] Custom keys support
- [x] Test crash methods (DEBUG only)
- [x] Comprehensive documentation
- [x] Debug logging
- [x] DI integration

## 🎯 Validation

### Firebase Console Validation

1. **Test Crash**:
   - Trigger test crash
   - Relaunch app
   - Wait 5-10 minutes
   - Check Firebase Console → Crashlytics
   - Crash should appear với symbolicated stack trace

2. **Non-Fatal Error**:
   - Trigger non-fatal error
   - Wait 5-10 minutes
   - Check Firebase Console → Crashlytics → Non-fatal errors
   - Error should appear

3. **Custom Keys**:
   - Set custom keys
   - Trigger crash
   - Check crash report
   - Custom keys visible trong "Keys" section

4. **Logs**:
   - Log messages
   - Trigger crash
   - Check crash report
   - Logs visible trong "Logs" section

### Console Log Validation

Check for logs trong DEBUG builds:
```
[FirebaseCrashlytics] 🐛 Crashlytics Debug Mode: ENABLED
[FirebaseCrashlytics] 💥 Non-fatal error recorded: Error message
[FirebaseCrashlytics] 📝 Crashlytics log: User action
[FirebaseCrashlytics] 🆔 Crashlytics user ID set: user_123
[FirebaseCrashlytics] 🔧 Crashlytics custom key set: key = value
```

### Production Validation

1. Release app to TestFlight/App Store
2. Monitor crashes trong Firebase Console
3. Verify:
   - Crashes appear với symbolicated stacks
   - Custom keys present
   - Logs included
   - User IDs visible

## ✅ Sign-Off

**Task 3.1.3 - Configure Crashlytics: READY FOR TESTING**

All implementation complete:
- ✅ FirebaseCrashlyticsService implemented
- ✅ CrashlyticsServiceProtocol defined
- ✅ DI integration
- ✅ Comprehensive documentation
- ✅ Test scenarios defined
- ✅ dSYM upload guide
- ✅ Pattern compliance

**Validation**: Test crash appears in Firebase Console

**Ready to proceed to next task**
