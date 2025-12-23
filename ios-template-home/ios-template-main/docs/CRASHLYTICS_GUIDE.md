# Firebase Crashlytics Guide

## 📊 Tổng Quan

Firebase Crashlytics đã được integrate vào iOS Template với:
- ✅ Automatic crash reporting
- ✅ Non-fatal error tracking
- ✅ Custom logging
- ✅ User context tracking
- ✅ Custom keys/values
- ✅ dSYM upload configuration
- ✅ Test crash methods (DEBUG only)

## 🚀 Quick Start

### 1. Basic Usage

```swift
import iOSTemplate

class MyViewModel {
    // Inject Crashlytics service
    @Injected(CrashlyticsServiceProtocol.self)
    var crashlytics: CrashlyticsServiceProtocol

    func handleError(_ error: Error) {
        // Record non-fatal error
        crashlytics.recordError(error, userInfo: [
            "context": "user_checkout",
            "items_count": 3
        ])
    }
}
```

### 2. Automatic Crash Reporting

Crashes được track **tự động** - không cần code gì thêm!

Khi app crashes:
1. Crash report saved locally
2. On next app launch, report uploaded to Firebase
3. Crash appears trong Firebase Console (5-10 phút)

### 3. Enable Crashlytics

Crashlytics đã enabled trong `FirebaseConfig`:

```swift
// Default config - Crashlytics enabled
let config = FirebaseConfig.auto
try FirebaseManager.shared.configure(with: config)
```

Để disable Crashlytics:
```swift
let config = FirebaseConfig(
    isCrashlyticsEnabled: false,  // Disable
    // ...other params
)
```

## 📝 Features

### 1. Record Non-Fatal Errors

Track errors mà không crash app:

```swift
@Injected var crashlytics: CrashlyticsServiceProtocol

do {
    try performRiskyOperation()
} catch {
    // Record error to Crashlytics
    crashlytics.recordError(error, userInfo: [
        "operation": "checkout",
        "user_tier": "premium",
        "cart_value": 99.99
    ])

    // App continues running
    showErrorToUser()
}
```

**Use Cases**:
- API failures
- Data corruption
- Invalid states
- Timeouts
- Unexpected conditions

### 2. Custom Logging

Log messages appear trong crash reports:

```swift
// Log user journey
crashlytics.log("User opened checkout")
crashlytics.log("User entered payment info")
crashlytics.log("User selected card payment")
crashlytics.log("Processing payment...")

// If crash happens, all logs appear in report
```

**Best Practices**:
- Log significant user actions
- Log state changes
- Log API calls
- Don't log sensitive data (passwords, tokens, PII)
- Keep logs concise

**Max Size**: 64KB total logs

### 3. Set User Context

Identify which users experiencing crashes:

```swift
// On login
crashlytics.setUserID("user_abc123_hashed")

// On logout
crashlytics.setUserID(nil)
```

**Privacy**:
- ✅ Use hashed/anonymized ID
- ❌ Don't use email
- ❌ Don't use phone number
- ❌ Don't use real name

### 4. Custom Keys

Add context to crash reports:

```swift
// Set individual keys
crashlytics.setCustomValue("premium", forKey: "user_tier")
crashlytics.setCustomValue(true, forKey: "dark_mode_enabled")
crashlytics.setCustomValue(42, forKey: "items_in_cart")

// Set multiple keys at once
crashlytics.setCustomValues([
    "user_tier": "premium",
    "app_version": "1.2.0",
    "is_first_launch": false
])
```

**Common Keys**:
- User tier (free, premium, enterprise)
- Feature flags states
- App state (foreground, background)
- Last action performed
- Configuration values

### 5. Test Crash (DEBUG Only)

Test Crashlytics setup:

```swift
#if DEBUG
struct DebugSettingsView: View {
    @Injected var crashlytics: CrashlyticsServiceProtocol

    var body: some View {
        Button("Test Crash") {
            crashlytics.testCrash()  // App crashes immediately
        }
        .foregroundColor(.red)
    }
}
#endif
```

**Validation Steps**:
1. Tap "Test Crash" button
2. App crashes
3. Relaunch app (crash report uploads)
4. Wait 5-10 minutes
5. Check Firebase Console → Crashlytics
6. Test crash should appear

## 🔧 Advanced Usage

### Error Tracking Pattern

Use custom error types:

```swift
enum AppCrashError: Error, LocalizedError {
    case networkFailure(statusCode: Int, endpoint: String)
    case dataCorruption(description: String)
    case invalidState(description: String)

    var errorDescription: String? {
        switch self {
        case .networkFailure(let code, let endpoint):
            return "Network failure: \(code) at \(endpoint)"
        case .dataCorruption(let desc):
            return "Data corruption: \(desc)"
        case .invalidState(let desc):
            return "Invalid state: \(desc)"
        }
    }
}

// Usage
if response.statusCode != 200 {
    let error = AppCrashError.networkFailure(
        statusCode: response.statusCode,
        endpoint: "/api/checkout"
    )
    crashlytics.recordError(error, userInfo: [
        "user_action": "checkout",
        "retry_count": retryCount
    ])
}
```

### Comprehensive Context Setting

Set context on app launch và user login:

```swift
// App launch
func setupCrashlytics() {
    crashlytics.setCustomValue(AppVersion.current, forKey: "app_version")
    crashlytics.setCustomValue(UIDevice.current.model, forKey: "device_model")
    crashlytics.setCustomValue(Locale.current.identifier, forKey: "locale")
}

// User login
func userDidLogin(user: User) {
    crashlytics.setUserID(user.hashedID)
    crashlytics.setCustomValue(user.tier, forKey: "user_tier")
    crashlytics.setCustomValue(user.isPremium, forKey: "is_premium")
    crashlytics.setCustomValue(user.createdAt, forKey: "user_created_at")
}

// User logout
func userDidLogout() {
    crashlytics.setUserID(nil)
    crashlytics.setCustomValue("logged_out", forKey: "user_tier")
}
```

### API Error Tracking

Comprehensive API error tracking:

```swift
func fetchData() async {
    crashlytics.log("API: Fetching user data")

    do {
        let data = try await apiClient.get("/users/me")
        crashlytics.log("API: User data fetched successfully")
    } catch {
        crashlytics.log("API: Failed to fetch user data")
        crashlytics.recordError(error, userInfo: [
            "endpoint": "/users/me",
            "method": "GET",
            "user_tier": currentUser.tier,
            "network_status": networkMonitor.status
        ])

        // Handle error...
    }
}
```

## 📱 dSYM Upload Configuration

dSYM files cần thiết để symbolicate crash reports (convert addresses → readable stack traces).

### Automatic Upload (Recommended)

**Using Firebase Crashlytics Run Script**:

1. Open Xcode project
2. Select target → Build Phases
3. Click **"+"** → **"New Run Script Phase"**
4. Name: "Upload dSYM to Firebase"
5. Add script:

```bash
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
```

6. Input Files:
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

7. Build Settings → Debug Information Format → **"DWARF with dSYM File"** (cho cả Debug và Release)

### Manual Upload

Nếu automatic upload fails:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Upload dSYM
firebase crashlytics:symbols:upload \
  --app=YOUR_IOS_APP_ID \
  path/to/dSYMs
```

**Find dSYMs**:
- Xcode Archive: `~/Library/Developer/Xcode/Archives`
- Build Products: `DerivedData/YourApp/Build/Products/Release-iphoneos/YourApp.app.dSYM`

### Validate dSYM Upload

1. Build app với Archive (Product → Archive)
2. Trigger test crash
3. Wait 5-10 minutes
4. Check Firebase Console → Crashlytics
5. Crash report should show **symbolicated** stack trace (readable class/method names)

If not symbolicated:
- ⚠️ dSYM not uploaded or wrong version
- Check Firebase Console → Crashlytics → dSYMs tab
- Re-upload dSYM manually

## 🐛 Debug Mode

Debug mode automatically enabled trong DEBUG builds.

### Console Logs

```
[FirebaseCrashlytics] 🐛 Crashlytics Debug Mode: ENABLED
[FirebaseCrashlytics] 💥 Non-fatal error recorded: Network error
   UserInfo: ["endpoint": "/users", "status_code": 500]
[FirebaseCrashlytics] 📝 Crashlytics log: User tapped checkout
[FirebaseCrashlytics] 🆔 Crashlytics user ID set: user_abc123
[FirebaseCrashlytics] 🔧 Crashlytics custom key set: user_tier = premium
```

### Debug Workflow

1. Run app trong Debug mode
2. Perform actions
3. Check console logs
4. Verify logs/errors/keys được set correctly
5. Trigger test crash (optional)

## 📊 Firebase Console

### View Crashes

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project
3. Navigate to: **Crashlytics**
4. View:
   - Crash-free users %
   - Total crashes
   - Crash groups (similar crashes grouped)
   - Individual crash reports

### Crash Report Details

Each crash report shows:
- **Stack trace** (symbolicated với dSYM)
- **Device info**: Model, OS version, orientation
- **App version**: Version và build number
- **Custom keys**: All keys set via `setCustomValue()`
- **User ID**: If set via `setUserID()`
- **Logs**: All messages logged via `log()`
- **Breadcrumbs**: App lifecycle events

### Crash Alerts

Setup alerts:
1. Firebase Console → Crashlytics → Settings
2. Enable email notifications
3. Set thresholds (e.g., alert if >1% users crash)

## 📈 Best Practices

### DO ✅

**Logging**:
- Log significant user actions
- Log state transitions
- Log API calls và results
- Log errors before they crash
- Keep logs concise và relevant

**Context**:
- Set user ID on login/logout
- Set custom keys cho important app state
- Update custom keys khi state changes
- Clear sensitive context on logout

**Error Tracking**:
- Record non-fatal errors
- Include relevant context trong userInfo
- Use custom error types
- Track API failures
- Track data validation failures

**Testing**:
- Test crash trong DEBUG builds
- Verify dSYM upload works
- Check crashes appear trong Console
- Validate stack traces symbolicated

### DON'T ❌

**Privacy**:
- ❌ Log passwords, tokens, API keys
- ❌ Log email addresses, phone numbers
- ❌ Log credit card numbers
- ❌ Log personal health information
- ❌ Use real user ID (use hashed instead)

**Performance**:
- ❌ Log excessively (64KB limit)
- ❌ Set too many custom keys (25 limit)
- ❌ Log in tight loops
- ❌ Log large data structures

**Testing**:
- ❌ Call testCrash() trong production code
- ❌ Force crashes to "test" in production
- ❌ Leave debug code trong release builds

## 🧪 Testing Checklist

### Setup Validation

- [ ] Firebase configured với Crashlytics enabled
- [ ] dSYM upload script added to Build Phases
- [ ] Debug Information Format = "DWARF with dSYM File"
- [ ] App builds successfully

### Functionality Testing

- [ ] Test crash: Crash appears trong Console (symbolicated)
- [ ] Non-fatal error: Error tracked trong Console
- [ ] Logs: Logs appear trong crash reports
- [ ] User ID: User ID visible trong reports
- [ ] Custom keys: Keys visible trong reports

### Production Readiness

- [ ] testCrash() chỉ available trong DEBUG builds
- [ ] No sensitive data logged
- [ ] dSYM upload automatic
- [ ] Crash alerts configured
- [ ] Team has access to Crashlytics Console

## 📊 Limits & Quotas

### Free Tier

- **Crashes**: Unlimited
- **Users**: Unlimited
- **Data retention**: 90 days
- **dSYM storage**: Unlimited

### Limits

- **Logs**: 64KB total per crash
- **Custom keys**: 64 keys max
- **Key name length**: 32 characters
- **Key value length**: 1024 characters
- **Non-fatal errors**: No limit (reasonable usage)

## 🔗 Resources

- [Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [iOS Integration Guide](https://firebase.google.com/docs/crashlytics/get-started?platform=ios)
- [Symbolication Guide](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports?platform=ios)
- [Best Practices](https://firebase.google.com/docs/crashlytics/best-practices)

---

**Last Updated**: November 2024
**Firebase SDK Version**: 10.19.0+
