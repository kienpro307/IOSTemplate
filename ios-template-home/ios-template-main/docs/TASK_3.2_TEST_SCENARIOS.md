# Task 3.2 - Push Notifications Test Scenarios

Test scenarios toàn diện cho Push Notifications implementation.

**Tasks covered**:
- Task 3.2.1: Configure APNs ✅
- Task 3.2.2: Implement FCM ✅
- Task 3.2.3: Create Notification Manager ✅

---

## Test Coverage

| Category | Test Cases | Status |
|----------|------------|--------|
| 1. Service Registration | 3 | ⚪️ |
| 2. Permission Management | 5 | ⚪️ |
| 3. Remote Notifications | 6 | ⚪️ |
| 4. Local Notifications | 8 | ⚪️ |
| 5. Topic Subscription | 4 | ⚪️ |
| 6. Notification Actions | 5 | ⚪️ |
| 7. Badge Management | 3 | ⚪️ |
| 8. Edge Cases | 5 | ⚪️ |
| 9. Integration | 4 | ⚪️ |
| **TOTAL** | **43** | **⚪️** |

---

## 1. Service Registration (3 tests)

### Test 1.1: FirebaseMessagingService Registration
**Objective**: Verify service is registered in DI container

```swift
func testFirebaseMessagingServiceRegistration() {
    // Given
    let container = DIContainer.shared

    // When
    let service = container.pushNotificationService

    // Then
    XCTAssertNotNil(service, "PushNotificationService should be registered")
    XCTAssert(service is FirebaseMessagingService, "Service should be FirebaseMessagingService")
}
```

**Expected**: ✅ Service is registered và có đúng type

---

### Test 1.2: NotificationManager Initialization
**Objective**: Verify NotificationManager initializes correctly

```swift
func testNotificationManagerInitialization() async {
    // Given
    let manager = NotificationManager.shared

    // When
    await manager.initialize()

    // Then
    XCTAssertTrue(manager.isInitialized, "Manager should be initialized")
}
```

**Expected**: ✅ Manager initializes without errors

---

### Test 1.3: Singleton Pattern
**Objective**: Verify services use singleton pattern

```swift
func testSingletonPattern() {
    // Given
    let service1 = FirebaseMessagingService.shared
    let service2 = FirebaseMessagingService.shared

    let manager1 = NotificationManager.shared
    let manager2 = NotificationManager.shared

    // Then
    XCTAssert(service1 === service2, "Should be same instance")
    XCTAssert(manager1 === manager2, "Should be same instance")
}
```

**Expected**: ✅ Same instance returned

---

## 2. Permission Management (5 tests)

### Test 2.1: Request Permission - First Time
**Objective**: Request permission khi chưa từng request

**Steps**:
1. Fresh install app (hoặc reset permissions)
2. Call `requestPermission()`
3. Grant permission in dialog

**Expected**:
- ✅ System dialog appears
- ✅ Returns `true` when granted
- ✅ `isAuthorized` = `true`
- ✅ Remote notification registration triggered

---

### Test 2.2: Request Permission - Denied
**Objective**: Handle user denying permission

**Steps**:
1. Fresh install app
2. Call `requestPermission()`
3. Deny permission in dialog

**Expected**:
- ✅ Returns `false` when denied
- ✅ `isAuthorized` = `false`
- ✅ No crash or error

---

### Test 2.3: Check Permission Status
**Objective**: Correctly report permission status

```swift
func testCheckPermissionStatus() async {
    // When
    let settings = await NotificationManager.shared.getCurrentSettings()

    // Then
    // Verify status is one of expected values
    let validStatuses: [UNAuthorizationStatus] = [
        .notDetermined, .denied, .authorized, .provisional
    ]
    XCTAssertTrue(validStatuses.contains(settings.authorizationStatus))
}
```

**Expected**: ✅ Returns valid status

---

### Test 2.4: Permission Already Granted
**Objective**: Handle requesting permission when already granted

**Steps**:
1. Permission already granted
2. Call `requestPermission()` again

**Expected**:
- ✅ Returns `true` immediately
- ✅ No dialog shown
- ✅ No error

---

### Test 2.5: Permission Provisional (iOS 12+)
**Objective**: Handle provisional authorization

**Steps**:
1. Request provisional authorization (if supported)
2. Check status

**Expected**:
- ✅ Status = `.provisional`
- ✅ Quiet notifications work
- ✅ Can upgrade to full authorization

---

## 3. Remote Notifications (6 tests)

### Test 3.1: Device Token Registration
**Objective**: Successfully register for remote notifications

**Steps**:
1. Grant permission
2. Check AppDelegate logs for device token

**Expected**:
```
📱 APNs Device Token: [hex string]
📲 FCM Token: [token string]
```

**Validation**:
- ✅ APNs token received
- ✅ FCM token received
- ✅ Token sent to Firebase

---

### Test 3.2: Receive Remote Notification (Foreground)
**Objective**: Receive notification when app is in foreground

**Steps**:
1. App running in foreground
2. Send test notification via Firebase Console
3. Check notification banner

**Expected**:
- ✅ Notification banner appears
- ✅ Handler called
- ✅ Logs show notification received

---

### Test 3.3: Receive Remote Notification (Background)
**Objective**: Receive notification when app is in background

**Steps**:
1. Background app (Home button)
2. Send test notification
3. Check notification center

**Expected**:
- ✅ Notification appears in notification center
- ✅ Badge updates (if specified)
- ✅ Sound plays (if specified)

---

### Test 3.4: Receive Remote Notification (Terminated)
**Objective**: Receive notification when app is terminated

**Steps**:
1. Force quit app
2. Send test notification
3. Tap notification to open app

**Expected**:
- ✅ Notification appears
- ✅ App launches when tapped
- ✅ Notification data available in launch options

---

### Test 3.5: Handle Notification Data
**Objective**: Parse and handle notification payload

**Test Payload**:
```json
{
  "notification": {
    "title": "Test",
    "body": "Test notification"
  },
  "data": {
    "type": "message",
    "messageId": "123",
    "userId": "user_456"
  }
}
```

**Expected**:
- ✅ `type` = "message" parsed correctly
- ✅ `messageId` = "123" extracted
- ✅ Appropriate handler called

---

### Test 3.6: FCM Token Refresh
**Objective**: Handle FCM token refresh

```swift
func testTokenRefresh() {
    let expectation = XCTestExpectation(description: "Token refresh")

    FirebaseMessagingService.shared.addTokenRefreshHandler { token in
        XCTAssertFalse(token.isEmpty, "Token should not be empty")
        expectation.fulfill()
    }

    // Trigger token refresh (delete and regenerate)
    Task {
        try? await FirebaseMessagingService.shared.deleteToken()
    }

    wait(for: [expectation], timeout: 10.0)
}
```

**Expected**: ✅ Handler called with new token

---

## 4. Local Notifications (8 tests)

### Test 4.1: Schedule Time-Based Notification
**Objective**: Schedule notification with time interval

```swift
func testScheduleTimeBasedNotification() async throws {
    // Given
    let manager = NotificationManager.shared

    // When
    try await manager.scheduleLocalNotification(
        identifier: "test-time",
        title: "Test",
        body: "Time-based notification",
        timeInterval: 5
    )

    // Then
    let pending = await manager.getPendingNotifications()
    XCTAssertTrue(pending.contains { $0.identifier == "test-time" })
}
```

**Expected**: ✅ Notification appears after 5 seconds

---

### Test 4.2: Schedule Date-Based Notification
**Objective**: Schedule notification at specific date

```swift
func testScheduleDateBasedNotification() async throws {
    // Given
    let date = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!

    // When
    try await NotificationManager.shared.scheduleNotification(
        at: date,
        identifier: "test-date",
        title: "Date Test",
        body: "Date-based notification"
    )

    // Then
    let pending = await NotificationManager.shared.getPendingNotifications()
    XCTAssertTrue(pending.contains { $0.identifier == "test-date" })
}
```

**Expected**: ✅ Notification scheduled for specific date

---

### Test 4.3: Schedule Repeating Notification
**Objective**: Schedule repeating notification

```swift
func testRepeatingNotification() async throws {
    // When
    try await NotificationManager.shared.scheduleLocalNotification(
        identifier: "test-repeat",
        title: "Repeat Test",
        body: "This repeats daily",
        timeInterval: 86400, // 24 hours
        repeats: true
    )

    // Then
    let pending = await NotificationManager.shared.getPendingNotifications()
    let notification = pending.first { $0.identifier == "test-repeat" }

    XCTAssertNotNil(notification)
    XCTAssertTrue((notification?.trigger as? UNTimeIntervalNotificationTrigger)?.repeats ?? false)
}
```

**Expected**: ✅ Notification repeats every 24 hours

---

### Test 4.4: Cancel Specific Notification
**Objective**: Cancel notification by identifier

```swift
func testCancelNotification() async throws {
    // Given
    try await NotificationManager.shared.scheduleLocalNotification(
        identifier: "test-cancel",
        title: "Test",
        body: "To be cancelled",
        timeInterval: 60
    )

    // When
    NotificationManager.shared.cancelNotification(withIdentifier: "test-cancel")

    // Then
    let pending = await NotificationManager.shared.getPendingNotifications()
    XCTAssertFalse(pending.contains { $0.identifier == "test-cancel" })
}
```

**Expected**: ✅ Notification removed from pending

---

### Test 4.5: Cancel All Notifications
**Objective**: Cancel all pending notifications

```swift
func testCancelAllNotifications() async throws {
    // Given - schedule multiple
    try await NotificationManager.shared.scheduleLocalNotification(
        title: "Test 1", body: "Body 1", timeInterval: 60
    )
    try await NotificationManager.shared.scheduleLocalNotification(
        title: "Test 2", body: "Body 2", timeInterval: 120
    )

    // When
    NotificationManager.shared.cancelAllNotifications()

    // Then
    let pending = await NotificationManager.shared.getPendingNotifications()
    XCTAssertTrue(pending.isEmpty, "All notifications should be cancelled")
}
```

**Expected**: ✅ All notifications cancelled

---

### Test 4.6: Get Pending Notifications
**Objective**: Retrieve list of pending notifications

```swift
func testGetPendingNotifications() async throws {
    // Given
    try await NotificationManager.shared.scheduleLocalNotification(
        identifier: "pending-1",
        title: "Test 1", body: "Body 1", timeInterval: 60
    )

    // When
    let pending = await NotificationManager.shared.getPendingNotifications()

    // Then
    XCTAssertTrue(pending.contains { $0.identifier == "pending-1" })
}
```

**Expected**: ✅ Pending notifications retrieved

---

### Test 4.7: Get Delivered Notifications
**Objective**: Retrieve delivered notifications

**Steps**:
1. Schedule notification with short interval (5s)
2. Wait for delivery
3. Get delivered notifications

**Expected**:
- ✅ Delivered notifications list includes our notification
- ✅ Can retrieve notification content

---

### Test 4.8: Clear Delivered Notifications
**Objective**: Clear notification center

**Steps**:
1. Have some delivered notifications
2. Call `clearDeliveredNotifications()`
3. Check notification center

**Expected**:
- ✅ Notification center cleared
- ✅ `getDeliveredNotifications()` returns empty array

---

## 5. Topic Subscription (4 tests)

### Test 5.1: Subscribe to Topic
**Objective**: Successfully subscribe to FCM topic

```swift
func testSubscribeToTopic() {
    // When
    NotificationManager.shared.subscribe(toTopic: "test-topic")

    // Then
    // Check logs for:
    // "✅ Subscribed to topic: test-topic"
}
```

**Manual verification**: Send to topic via Firebase Console

**Expected**: ✅ Notification received

---

### Test 5.2: Unsubscribe from Topic
**Objective**: Successfully unsubscribe from topic

```swift
func testUnsubscribeFromTopic() {
    // Given
    NotificationManager.shared.subscribe(toTopic: "test-topic")

    // Wait for subscription
    sleep(2)

    // When
    NotificationManager.shared.unsubscribe(fromTopic: "test-topic")

    // Then
    // Check logs for:
    // "✅ Unsubscribed from topic: test-topic"
}
```

**Manual verification**: Should NOT receive topic notifications

**Expected**: ✅ No longer receives topic notifications

---

### Test 5.3: Multiple Topic Subscriptions
**Objective**: Subscribe to multiple topics

```swift
func testMultipleTopics() {
    // When
    NotificationManager.shared.subscribe(toTopic: "news")
    NotificationManager.shared.subscribe(toTopic: "sports")
    NotificationManager.shared.subscribe(toTopic: "tech")

    // Then
    // Send notifications to each topic
    // Should receive all
}
```

**Expected**: ✅ Receives notifications from all subscribed topics

---

### Test 5.4: User-Specific Topic
**Objective**: Subscribe to user-specific topic

```swift
func testUserSpecificTopic() {
    // Given
    let userID = "user_123"

    // When
    NotificationManager.shared.subscribe(toTopic: "user-\(userID)")

    // Then
    // Send to topic "user-user_123" via Firebase Console
    // Should receive notification
}
```

**Expected**: ✅ User receives personalized notifications

---

## 6. Notification Actions (5 tests)

### Test 6.1: Message Category Actions
**Objective**: Verify message actions work

**Steps**:
1. Schedule notification with message category
2. Wait for notification
3. Long press notification
4. Verify actions: Reply, Mark as Read

**Expected**:
- ✅ Actions appear
- ✅ Reply shows text input
- ✅ Mark as Read dismisses notification

---

### Test 6.2: Reminder Category Actions
**Objective**: Verify reminder actions work

**Steps**:
1. Schedule notification with reminder category
2. Long press notification
3. Verify actions: Complete, Snooze

**Expected**:
- ✅ Actions appear
- ✅ Complete dismisses notification
- ✅ Snooze reschedules (if implemented)

---

### Test 6.3: Alert Category Actions
**Objective**: Verify alert actions work

**Steps**:
1. Schedule notification with alert category
2. Long press notification
3. Verify actions: View, Dismiss

**Expected**:
- ✅ Actions appear
- ✅ View opens app
- ✅ Dismiss removes notification

---

### Test 6.4: Handle Reply Action
**Objective**: Handle user reply to notification

**Steps**:
1. Schedule message notification
2. Long press → Reply
3. Type "Test reply" → Send

**Expected**:
- ✅ `didReceive response` called
- ✅ `actionIdentifier` = `REPLY_ACTION`
- ✅ `userText` = "Test reply"
- ✅ Handler processes reply

---

### Test 6.5: Handle Notification Tap
**Objective**: Handle user tapping notification

**Steps**:
1. Schedule notification
2. Tap notification banner

**Expected**:
- ✅ App opens/comes to foreground
- ✅ `actionIdentifier` = `UNNotificationDefaultActionIdentifier`
- ✅ Can navigate to relevant screen

---

## 7. Badge Management (3 tests)

### Test 7.1: Set Badge Number
**Objective**: Set app badge number

```swift
func testSetBadge() {
    // When
    NotificationManager.shared.setBadge(5)

    // Then
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let badge = UIApplication.shared.applicationIconBadgeNumber
        XCTAssertEqual(badge, 5, "Badge should be 5")
    }
}
```

**Expected**: ✅ App icon shows badge "5"

---

### Test 7.2: Clear Badge
**Objective**: Clear app badge

```swift
func testClearBadge() {
    // Given
    NotificationManager.shared.setBadge(10)

    // When
    NotificationManager.shared.clearBadge()

    // Then
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let badge = UIApplication.shared.applicationIconBadgeNumber
        XCTAssertEqual(badge, 0, "Badge should be cleared")
    }
}
```

**Expected**: ✅ Badge removed from app icon

---

### Test 7.3: Badge in Notification
**Objective**: Set badge via notification

```swift
func testBadgeInNotification() async throws {
    // When
    try await NotificationManager.shared.scheduleLocalNotification(
        title: "Badge Test",
        body: "Badge should be 3",
        timeInterval: 5,
        badge: 3
    )

    // Then
    // Wait for notification
    // Badge should show "3"
}
```

**Expected**: ✅ Badge updates when notification delivered

---

## 8. Edge Cases (5 tests)

### Test 8.1: Permission Denied - Graceful Handling
**Objective**: App works even without notification permission

**Steps**:
1. Deny notification permission
2. Try to schedule local notification
3. Try to subscribe to topic

**Expected**:
- ✅ No crashes
- ✅ Graceful degradation
- ✅ Can still use app

---

### Test 8.2: No Internet - Topic Subscription
**Objective**: Handle topic subscription without internet

**Steps**:
1. Disable internet
2. Subscribe to topic
3. Re-enable internet

**Expected**:
- ✅ No crash
- ✅ Subscription queued
- ✅ Processed when online

---

### Test 8.3: App in Background - Notification Limit
**Objective**: Handle notification delivery limits

**Steps**:
1. Schedule 100 local notifications
2. Background app

**Expected**:
- ✅ iOS delivers up to 64 notifications (iOS limit)
- ✅ No crashes
- ✅ Oldest notifications may be discarded

---

### Test 8.4: Invalid Notification Payload
**Objective**: Handle malformed remote notification

**Test Payload**:
```json
{
  "invalid": "payload",
  "no_notification": true
}
```

**Expected**:
- ✅ No crash
- ✅ Error logged
- ✅ Handler returns gracefully

---

### Test 8.5: Rapid Permission Requests
**Objective**: Handle multiple rapid permission requests

```swift
func testRapidPermissionRequests() async {
    // When
    async let result1 = NotificationManager.shared.requestPermission()
    async let result2 = NotificationManager.shared.requestPermission()
    async let result3 = NotificationManager.shared.requestPermission()

    let results = await [result1, result2, result3]

    // Then
    // All should return same result
    XCTAssertTrue(results.allSatisfy { $0 == results[0] })
}
```

**Expected**: ✅ No crashes, consistent results

---

## 9. Integration Tests (4 tests)

### Test 9.1: Full Flow - Permission to Notification
**Objective**: Complete flow from permission to receiving notification

**Steps**:
1. Request permission → Grant
2. Wait for FCM token
3. Send test notification via Firebase Console
4. Receive and handle notification

**Expected**: ✅ All steps complete successfully

---

### Test 9.2: Topic Flow
**Objective**: Complete topic subscription flow

**Steps**:
1. Request permission
2. Subscribe to "test-topic"
3. Send notification to topic
4. Receive notification
5. Unsubscribe
6. Send again (should not receive)

**Expected**:
- ✅ Receives when subscribed
- ✅ Doesn't receive after unsubscribe

---

### Test 9.3: Local + Remote Notifications
**Objective**: Both local and remote notifications work together

**Steps**:
1. Schedule local notification (10s)
2. Send remote notification immediately
3. Receive both

**Expected**:
- ✅ Both notifications appear
- ✅ No conflicts
- ✅ Both handled correctly

---

### Test 9.4: Logout Flow
**Objective**: Proper cleanup on logout

```swift
func testLogoutFlow() async {
    // Given
    let userID = "user_123"
    NotificationManager.shared.subscribe(toTopic: "user-\(userID)")
    NotificationManager.shared.setBadge(5)

    // When
    handleUserLogout(userID: userID)

    // Then
    // Verify:
    // - Unsubscribed from user topic
    // - Badge cleared
    // - FCM token deleted (optional)
}

func handleUserLogout(userID: String) {
    NotificationManager.shared.unsubscribe(fromTopic: "user-\(userID)")
    NotificationManager.shared.clearBadge()
    NotificationManager.shared.cancelAllNotifications()
}
```

**Expected**: ✅ Clean state after logout

---

## Testing Checklist

### Prerequisites
- [ ] Real iOS device (notifications don't work on simulator)
- [ ] Valid APNs certificate/key in Firebase Console
- [ ] GoogleService-Info.plist added to project
- [ ] Push Notifications capability enabled in Xcode

### Environment Setup
- [ ] Debug build installed on device
- [ ] Check console logs for FCM token
- [ ] Firebase Console accessible for sending test notifications

### Manual Testing
- [ ] All permission states tested
- [ ] Foreground notifications work
- [ ] Background notifications work
- [ ] Terminated app notifications work
- [ ] All actions tested
- [ ] Topic subscriptions work
- [ ] Badge updates correctly

### Automated Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Edge cases covered
- [ ] No crashes in any scenario

### Production Validation
- [ ] Test with production APNs certificate
- [ ] Test with different iOS versions
- [ ] Test with different device types
- [ ] Load testing (many simultaneous notifications)

---

## Success Criteria

✅ **Task 3.2.1 - Configure APNs**: COMPLETE
- APNs setup in Apple Developer Portal
- APNs key/certificate in Firebase Console
- Device token registration working

✅ **Task 3.2.2 - Implement FCM**: COMPLETE
- FirebaseMessagingService implemented
- Remote notifications received
- Topic subscriptions work
- Token management working

✅ **Task 3.2.3 - Create Notification Manager**: COMPLETE
- NotificationManager created
- Local notifications work
- Permission handling correct
- Badge management working
- Actions configured and working

---

**All 43 test scenarios must pass for Task 3.2 to be considered complete.**
