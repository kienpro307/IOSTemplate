# 🔔 Thông Báo Đẩy (Push Notifications)

## Setup
1. Enable Push Notifications capability
2. Configure APNs certificates
3. Setup Firebase Cloud Messaging

## Flow
```
Request Permission → Get FCM Token → Subscribe Topics → Handle Messages
```

## Message Handling
```swift
// Foreground
func userNotificationCenter(_ center: UNUserNotificationCenter,
                           willPresent notification: UNNotification)

// Background tap
func userNotificationCenter(_ center: UNUserNotificationCenter,
                           didReceive response: UNNotificationResponse)
```

## Notification Types
- Alert notifications
- Silent/Background notifications
- Rich notifications (images, actions)
