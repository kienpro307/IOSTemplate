# Push Notifications Guide

Hướng dẫn toàn diện về Push Notifications trong iOS Template Project sử dụng Firebase Cloud Messaging (FCM) và Apple Push Notification service (APNs).

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Setup & Configuration](#setup--configuration)
4. [Request Permission](#request-permission)
5. [Remote Notifications](#remote-notifications)
6. [Local Notifications](#local-notifications)
7. [Topic Subscription](#topic-subscription)
8. [Notification Actions](#notification-actions)
9. [AppDelegate Integration](#appdelegate-integration)
10. [Testing](#testing)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)

---

## Overview

### Kiến trúc Push Notifications

```
┌─────────────────────────────────────────────────────┐
│                 NotificationManager                  │
│  (Coordinator - Quản lý toàn bộ notifications)      │
└──────────────┬──────────────────────┬────────────────┘
               │                      │
               ▼                      ▼
┌──────────────────────┐   ┌────────────────────────┐
│ FirebaseMessaging    │   │  UNUserNotification    │
│ Service              │   │  Center                │
│ (Remote Notifications)│   │  (Local Notifications) │
└──────────┬───────────┘   └────────────────────────┘
           │
           ▼
┌──────────────────────┐
│ Firebase Cloud       │
│ Messaging (FCM)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Apple Push           │
│ Notification (APNs)  │
└──────────────────────┘
```

### Components

1. **NotificationManager**: Central coordinator cho tất cả notification operations
2. **FirebaseMessagingService**: Handle remote notifications via FCM
3. **PushNotificationServiceProtocol**: Protocol định nghĩa push notification operations
4. **UNUserNotificationCenter**: Native iOS notification center

---

## Quick Start

### 1. Initialize trong AppDelegate

```swift
import UIKit
import iOSTemplate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize NotificationManager
        Task {
            await NotificationManager.shared.initialize()
        }

        return true
    }
}
```

### 2. Request Permission

```swift
// Request notification permission
let granted = await NotificationManager.shared.requestPermission()

if granted {
    print("✅ Notification permission granted")
} else {
    print("⚠️ Notification permission denied")
}
```

### 3. Handle Device Token

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    NotificationManager.shared.handleDeviceToken(deviceToken)
}
```

### 4. Handle Remote Notification

```swift
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) {
    NotificationManager.shared.handleRemoteNotification(userInfo)
}
```

---

## Setup & Configuration

### Prerequisites

#### 1. Apple Developer Account Setup

**Enable Push Notifications**:
1. Đăng nhập [Apple Developer Portal](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → Identifiers
3. Select your App ID
4. Enable **Push Notifications** capability
5. Configure (Development + Production)

**Generate APNs Key** (Recommended):
1. Keys → Create a new key (+)
2. Key Name: "iOS Template APNs Key"
3. Enable **Apple Push Notifications service (APNs)**
4. Download `.p8` file (lưu an toàn!)
5. Note: Key ID và Team ID

**Hoặc Generate APNs Certificate** (Traditional):
1. Certificates → Create certificate (+)
2. Select: Apple Push Notification service SSL
3. Upload CSR file
4. Download certificate
5. Install vào Keychain

#### 2. Firebase Console Setup

**Upload APNs Key to Firebase**:
1. Mở [Firebase Console](https://console.firebase.google.com)
2. Project Settings → Cloud Messaging
3. iOS app configuration → APNs Authentication Key
4. Upload `.p8` file
5. Enter Key ID và Team ID

**Hoặc Upload APNs Certificate**:
1. Export certificate từ Keychain (.p12 file)
2. Upload to Firebase Console
3. Enter password

#### 3. Xcode Project Setup

**Enable Push Notifications Capability**:
1. Select target → Signing & Capabilities
2. Click **+ Capability**
3. Add **Push Notifications**

**Enable Background Modes**:
1. Add **Background Modes** capability
2. Enable:
   - ✅ **Remote notifications**
   - ✅ **Background fetch** (optional)

**Add GoogleService-Info.plist**:
1. Download từ Firebase Console
2. Add to Xcode project (target membership: ✅ iOSTemplateApp)

---

## Request Permission

### Basic Request

```swift
// Request permission
let granted = await NotificationManager.shared.requestPermission()

if granted {
    // Permission granted - notifications enabled
    print("✅ Notifications enabled")
} else {
    // Permission denied - show alternative
    print("⚠️ Notifications disabled")
}
```

### Check Current Settings

```swift
// Get current settings
let settings = await NotificationManager.shared.getCurrentSettings()

switch settings.authorizationStatus {
case .notDetermined:
    // Chưa request permission - show onboarding
    print("⚪️ Not determined - show permission request")

case .denied:
    // User denied - prompt to enable in Settings
    print("❌ Denied - guide user to Settings")

case .authorized:
    // Authorized - notifications enabled
    print("✅ Authorized")

case .provisional:
    // Provisional authorization (iOS 12+)
    print("🔵 Provisional - quiet notifications")

case .ephemeral:
    // App Clip authorization
    print("🟡 Ephemeral - App Clip only")

@unknown default:
    print("❓ Unknown status")
}
```

### Guide User to Settings

```swift
import SwiftUI

struct NotificationSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Notifications Disabled")
                .font(.title2)
                .bold()

            Text("Enable notifications to stay updated")
                .foregroundColor(.secondary)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

---

## Remote Notifications

### Send via Firebase Console

**Test Notification**:
1. Firebase Console → Cloud Messaging → Send test message
2. Enter FCM token (check console logs)
3. Add notification title và body
4. Send

**Campaign Notification**:
1. Cloud Messaging → New notification
2. Configure:
   - Notification title
   - Notification body
   - Image (optional)
3. Target: Select app
4. Schedule (optional)
5. Send

### Send via Server (API)

**FCM HTTP v1 API**:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
-H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Hello from Server",
      "body": "This is a test notification"
    },
    "data": {
      "type": "message",
      "messageId": "123",
      "userId": "user_456"
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1
        }
      }
    }
  }
}'
```

**Legacy FCM API**:
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "DEVICE_FCM_TOKEN",
  "notification": {
    "title": "Hello",
    "body": "Test notification"
  },
  "data": {
    "type": "message",
    "customData": "value"
  }
}'
```

### Handle Notification Payload

```swift
// Add handler in FirebaseMessagingService
FirebaseMessagingService.shared.addNotificationHandler { userInfo in
    // Parse notification data
    if let type = userInfo["type"] as? String {
        switch type {
        case "message":
            handleNewMessage(userInfo)
        case "alert":
            handleAlert(userInfo)
        case "update":
            handleAppUpdate(userInfo)
        default:
            print("Unknown notification type: \(type)")
        }
    }
}

func handleNewMessage(_ userInfo: [AnyHashable: Any]) {
    guard let messageId = userInfo["messageId"] as? String else { return }

    // Fetch message details
    // Update UI
    // Play sound
    print("New message: \(messageId)")
}
```

### FCM Token Management

```swift
// Add token refresh handler
FirebaseMessagingService.shared.addTokenRefreshHandler { token in
    // Send token to your backend
    Task {
        try? await updateFCMToken(token)
    }
}

func updateFCMToken(_ token: String) async throws {
    // API call to your backend
    let url = URL(string: "https://your-api.com/users/fcm-token")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = ["fcmToken": token]
    request.httpBody = try JSONEncoder().encode(body)

    let (_, response) = try await URLSession.shared.data(for: request)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw NSError(domain: "FCMError", code: -1)
    }
}
```

---

## Local Notifications

### Schedule Time-Based Notification

```swift
// Schedule notification after 60 seconds
try await NotificationManager.shared.scheduleLocalNotification(
    title: "Reminder",
    body: "Time to check your tasks!",
    timeInterval: 60
)

// Schedule repeating notification (daily)
try await NotificationManager.shared.scheduleLocalNotification(
    identifier: "daily-reminder",
    title: "Daily Reminder",
    body: "Don't forget to review your goals",
    timeInterval: 86400, // 24 hours
    repeats: true,
    badge: 1
)
```

### Schedule Date-Based Notification

```swift
// Schedule at specific time (9:00 AM tomorrow)
var components = DateComponents()
components.hour = 9
components.minute = 0

let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
let date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!

try await NotificationManager.shared.scheduleNotification(
    at: date,
    title: "Good Morning",
    body: "Time to start your day!"
)
```

### Notification with Actions

```swift
// Schedule with category (enables actions)
try await NotificationManager.shared.scheduleLocalNotification(
    identifier: "task-reminder",
    title: "Task Reminder",
    body: "Complete your daily review",
    timeInterval: 3600,
    categoryIdentifier: NotificationCategory.reminder.rawValue,
    userInfo: ["taskId": "123"]
)
```

### Manage Notifications

```swift
// Get pending notifications
let pending = await NotificationManager.shared.getPendingNotifications()
print("Pending: \(pending.count)")

// Cancel specific notification
NotificationManager.shared.cancelNotification(withIdentifier: "daily-reminder")

// Cancel all notifications
NotificationManager.shared.cancelAllNotifications()

// Get delivered notifications
let delivered = await NotificationManager.shared.getDeliveredNotifications()
print("Delivered: \(delivered.count)")

// Clear all delivered notifications
NotificationManager.shared.clearDeliveredNotifications()
```

### Badge Management

```swift
// Set badge number
NotificationManager.shared.setBadge(5)

// Clear badge
NotificationManager.shared.clearBadge()

// Badge in notification
try await NotificationManager.shared.scheduleLocalNotification(
    title: "New Message",
    body: "You have 3 unread messages",
    timeInterval: 10,
    badge: 3
)
```

---

## Topic Subscription

### Subscribe to Topics

```swift
// Subscribe to general topics
NotificationManager.shared.subscribe(toTopic: "news")
NotificationManager.shared.subscribe(toTopic: "sports")
NotificationManager.shared.subscribe(toTopic: "breaking-news")

// Subscribe to user-specific topic
let userID = "user_123"
NotificationManager.shared.subscribe(toTopic: "user-\(userID)")

// Subscribe to language-specific topic
let language = Locale.current.languageCode ?? "en"
NotificationManager.shared.subscribe(toTopic: "news-\(language)")
```

### Unsubscribe from Topics

```swift
// Unsubscribe from topic
NotificationManager.shared.unsubscribe(fromTopic: "news")

// Unsubscribe when user logs out
func handleLogout() {
    let userID = getCurrentUserID()
    NotificationManager.shared.unsubscribe(fromTopic: "user-\(userID)")
}
```

### Topic Naming Best Practices

✅ **DO**:
- Use lowercase: `news`, `sports`
- Use hyphens: `breaking-news`, `user-updates`
- Keep it simple: `ios-updates`
- Be specific: `news-us`, `sports-football`

❌ **DON'T**:
- Use special characters: `news@alerts`
- Use spaces: `breaking news`
- Use uppercase: `NEWS`
- Use PII: `user-john.doe@email.com`

---

## Notification Actions

### Predefined Categories

Project có 3 predefined categories:

#### 1. Message Category

```swift
// Actions: Reply, Mark as Read

try await NotificationManager.shared.scheduleLocalNotification(
    title: "New Message",
    body: "John: Hey, are you available?",
    timeInterval: 10,
    categoryIdentifier: NotificationCategory.message.rawValue,
    userInfo: ["messageId": "msg_123", "senderId": "user_456"]
)
```

#### 2. Reminder Category

```swift
// Actions: Complete, Snooze

try await NotificationManager.shared.scheduleLocalNotification(
    title: "Task Reminder",
    body: "Complete daily review",
    timeInterval: 3600,
    categoryIdentifier: NotificationCategory.reminder.rawValue,
    userInfo: ["taskId": "task_789"]
)
```

#### 3. Alert Category

```swift
// Actions: View, Dismiss

try await NotificationManager.shared.scheduleLocalNotification(
    title: "Security Alert",
    body: "New login detected",
    timeInterval: 5,
    categoryIdentifier: NotificationCategory.alert.rawValue,
    userInfo: ["alertType": "new_login"]
)
```

### Handle Actions trong AppDelegate

```swift
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case NotificationAction.reply.rawValue:
            if let textResponse = response as? UNTextInputNotificationResponse {
                handleReply(text: textResponse.userText, userInfo: userInfo)
            }

        case NotificationAction.markAsRead.rawValue:
            handleMarkAsRead(userInfo: userInfo)

        case NotificationAction.complete.rawValue:
            handleComplete(userInfo: userInfo)

        case NotificationAction.snooze.rawValue:
            handleSnooze(userInfo: userInfo)

        case NotificationAction.view.rawValue:
            handleView(userInfo: userInfo)

        case NotificationAction.dismiss.rawValue:
            handleDismiss(userInfo: userInfo)

        case UNNotificationDefaultActionIdentifier:
            // User tapped notification banner
            handleNotificationTap(userInfo: userInfo)

        default:
            break
        }

        completionHandler()
    }
}

func handleReply(text: String, userInfo: [AnyHashable: Any]) {
    guard let messageId = userInfo["messageId"] as? String else { return }

    // Send reply to server
    Task {
        try? await sendMessageReply(messageId: messageId, text: text)
    }
}
```

---

## AppDelegate Integration

### Complete AppDelegate Example

```swift
import UIKit
import iOSTemplate
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize NotificationManager
        Task {
            await NotificationManager.shared.initialize()

            // Auto-request permission (or do it later in onboarding)
            _ = await NotificationManager.shared.requestPermission()
        }

        return true
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Pass token to NotificationManager
        NotificationManager.shared.handleDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Handle remote notification
        NotificationManager.shared.handleRemoteNotification(userInfo)

        // Indicate result
        completionHandler(.newData)
    }
}
```

---

## Testing

### 1. Test Local Notifications

```swift
// Test basic notification
try await NotificationManager.shared.scheduleLocalNotification(
    title: "Test Notification",
    body: "This is a test",
    timeInterval: 5
)

// Test with badge
try await NotificationManager.shared.scheduleLocalNotification(
    title: "Badge Test",
    body: "Badge should show 5",
    timeInterval: 10,
    badge: 5
)

// Test with actions
try await NotificationManager.shared.scheduleLocalNotification(
    title: "Action Test",
    body: "Try the actions",
    timeInterval: 15,
    categoryIdentifier: NotificationCategory.reminder.rawValue
)
```

### 2. Test Remote Notifications

**Option 1: Firebase Console**
1. Cloud Messaging → Send test message
2. Enter FCM token (from logs)
3. Send

**Option 2: Terminal Command**
```bash
# Get FCM token from app logs
# Send test notification
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "YOUR_FCM_TOKEN",
  "notification": {
    "title": "Test",
    "body": "Hello from terminal"
  }
}'
```

### 3. Test Topics

```swift
// Subscribe
NotificationManager.shared.subscribe(toTopic: "test-topic")

// Send via Firebase Console:
// Cloud Messaging → Send to topic → "test-topic"
```

### 4. Test Permission States

```swift
// Test permission denied
// 1. Deny permission in iOS Settings
// 2. Request permission → should return false
// 3. Check settings → status should be .denied
```

---

## Best Practices

### ✅ DO

1. **Request permission thoughtfully**
   ```swift
   // Don't request immediately - explain value first
   func showNotificationOnboarding() {
       // Show UI explaining benefits
       // Then request permission
   }
   ```

2. **Handle permission denied gracefully**
   ```swift
   let granted = await manager.requestPermission()
   if !granted {
       // Show alternative (in-app notifications, email, etc.)
   }
   ```

3. **Clean up on logout**
   ```swift
   func handleLogout() {
       // Unsubscribe from user-specific topics
       manager.unsubscribe(fromTopic: "user-\(userID)")

       // Clear badge
       manager.clearBadge()

       // Optional: Delete FCM token
       try? await FirebaseMessagingService.shared.deleteToken()
   }
   ```

4. **Use meaningful identifiers**
   ```swift
   // Good
   try await manager.scheduleLocalNotification(
       identifier: "daily-review-9am",
       title: "Daily Review",
       body: "Time to review your goals",
       timeInterval: calculateTimeUntil9AM()
   )
   ```

5. **Test thoroughly**
   - Test on real device (notifications don't work on simulator)
   - Test all notification states (foreground, background, terminated)
   - Test all actions
   - Test permission states

### ❌ DON'T

1. **Don't spam users**
   ```swift
   // Bad - too many notifications
   for i in 1...100 {
       try await manager.scheduleLocalNotification(...)
   }
   ```

2. **Don't send sensitive data**
   ```swift
   // Bad - sensitive info in notification
   notification = {
       "title": "Password reset",
       "body": "Your new password is: 123456"  // ❌
   }

   // Good - use action to view in app
   notification = {
       "title": "Password reset",
       "body": "Tap to view details"  // ✅
   }
   ```

3. **Don't use notifications for critical actions**
   ```swift
   // Bad - relying on notification for critical operation
   // Notifications can be disabled by user

   // Good - use in-app alerts for critical actions
   ```

4. **Don't ignore permission states**
   ```swift
   // Bad - blindly scheduling notifications
   try await manager.scheduleLocalNotification(...)

   // Good - check permission first
   let settings = await manager.getCurrentSettings()
   if settings.authorizationStatus == .authorized {
       try await manager.scheduleLocalNotification(...)
   }
   ```

---

## Troubleshooting

### Issue 1: Notifications not appearing

**Symptoms**: Notifications scheduled but not showing

**Solutions**:
1. Check permission status
   ```swift
   let settings = await manager.getCurrentSettings()
   print("Status: \(settings.authorizationStatus)")
   ```

2. Check Do Not Disturb / Focus mode
   - iOS Settings → Focus → Check if enabled

3. Check notification settings
   - iOS Settings → Your App → Notifications → Allow Notifications = ON

4. Verify device (simulator doesn't support remote notifications)

### Issue 2: No FCM token

**Symptoms**: `fcmToken` is nil

**Solutions**:
1. Check Firebase configuration
   ```swift
   // Verify GoogleService-Info.plist is included
   ```

2. Check APNs certificate/key in Firebase Console

3. Wait for token (can take a few seconds)
   ```swift
   FirebaseMessagingService.shared.addTokenRefreshHandler { token in
       print("Token ready: \(token)")
   }
   ```

### Issue 3: Remote notifications not received

**Symptoms**: Can't receive notifications from server

**Solutions**:
1. Verify APNs setup in Firebase Console

2. Check device token registration
   ```swift
   // Should see in logs:
   // "APNs Device Token: xxx"
   // "FCM Token: xxx"
   ```

3. Test with Firebase Console first (before custom server)

4. Verify payload format
   ```json
   {
     "notification": {
       "title": "Title",
       "body": "Body"
     },
     "data": {
       "custom": "data"
     }
   }
   ```

### Issue 4: Actions not working

**Symptoms**: Notification actions don't appear

**Solutions**:
1. Verify category identifier matches
   ```swift
   categoryIdentifier: NotificationCategory.message.rawValue
   ```

2. Check if categories are registered
   ```swift
   // Should see in logs during initialization:
   // "Notification categories configured"
   ```

3. Ensure UNUserNotificationCenterDelegate is set

### Issue 5: Badge not updating

**Symptoms**: App badge doesn't update

**Solutions**:
1. Check badge permission
   ```swift
   let settings = await manager.getCurrentSettings()
   print("Badge enabled: \(settings.badgeSetting)")
   ```

2. Update on main thread
   ```swift
   DispatchQueue.main.async {
       manager.setBadge(5)
   }
   ```

3. Clear when app opens
   ```swift
   func applicationDidBecomeActive() {
       manager.clearBadge()
   }
   ```

---

## Additional Resources

### Apple Documentation
- [User Notifications Framework](https://developer.apple.com/documentation/usernotifications)
- [APNs Overview](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/)

### Firebase Documentation
- [FCM iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [FCM Topics](https://firebase.google.com/docs/cloud-messaging/ios/topic-messaging)

### Testing Tools
- [APNs Tool](https://github.com/onmyway133/PushNotifications) - Test APNs from Mac
- [Pusher](https://github.com/noodlewerk/NWPusher) - APNs testing tool

---

**Next Steps**: Check [TASK_3.2_TEST_SCENARIOS.md](TASK_3.2_TEST_SCENARIOS.md) for comprehensive testing checklist.
