import Foundation
import UserNotifications
import FirebaseMessaging
import ComposableArchitecture

/// Notification delegate để handle incoming push notifications
/// Theo cấu trúc trong ios-template-docs/03-TINH-NANG/03-THONG-BAO-DAY.md
public class NotificationDelegate: NSObject, ObservableObject {
    // Note: Không thể dùng @Dependency trong NSObject subclass
    // Analytics sẽ được access trực tiếp từ DependencyValues
    
    /// Callback khi nhận được notification trong foreground
    public var onForegroundNotification: ((UNNotification) -> Void)?
    
    /// Callback khi user tap vào notification
    public var onNotificationTapped: ((UNNotificationResponse) -> Void)?
    
    /// Callback khi FCM token refresh
    public var onTokenRefresh: ((String) -> Void)?
    
    public override init() {
        super.init()
        // Setup delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Private Helpers
    
    /// Track event vào analytics nếu available
    private func trackAnalyticsEvent(_ name: String, parameters: [String: Any]) {
        Task { @MainActor in
            let analytics = DependencyValues._current.analytics
            await analytics.trackEvent(name, parameters: parameters)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationDelegate: UNUserNotificationCenterDelegate {
    /// Handle notification khi app đang ở foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Track notification vào Analytics
        trackAnalyticsEvent("notification_received", parameters: [
            "notification_id": notification.request.identifier,
            "is_foreground": "true"
        ])
        
        // Call custom handler nếu có
        onForegroundNotification?(notification)
        
        // Show notification banner ngay cả khi app đang mở
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification khi user tap vào notification
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Track notification tap vào Analytics
        trackAnalyticsEvent("notification_tapped", parameters: [
            "notification_id": response.notification.request.identifier,
            "action_identifier": response.actionIdentifier
        ])
        
        // Call custom handler nếu có
        onNotificationTapped?(response)
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension NotificationDelegate: MessagingDelegate {
    /// Handle FCM token refresh
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("📲 FCM Token refreshed: \(token)")
        
        // Track token refresh vào Analytics
        trackAnalyticsEvent("fcm_token_refreshed", parameters: [
            "has_token": token.isEmpty ? "false" : "true"
        ])
        
        // Call custom handler nếu có
        onTokenRefresh?(token)
    }
}
