import Foundation
import UserNotifications
import FirebaseMessaging
import ComposableArchitecture

/// Notification delegate để handle incoming push notifications
/// Theo cấu trúc trong ios-template-docs/03-TINH-NANG/03-THONG-BAO-DAY.md
@MainActor
public class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    // Note: Không thể dùng @Dependency trong NSObject subclass
    // Services sẽ được access qua DependencyValues._current hoặc inject từ bên ngoài
    
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
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification khi app đang ở foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Track notification vào Analytics (nếu có service)
        Task {
            do {
                let analytics = try DependencyValues._current.analytics
                await analytics.trackEvent("notification_received", parameters: [
                    "notification_id": notification.request.identifier,
                    "is_foreground": "true"
                ])
            } catch {
                // Analytics không available, chỉ log
                print("📲 Notification received (foreground): \(notification.request.identifier)")
            }
        }
        
        // Call custom handler nếu có
        onForegroundNotification?(notification)
        
        // Show notification banner ngay cả khi app đang mở
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    /// Handle notification khi user tap vào notification
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Track notification tap vào Analytics (nếu có service)
        Task {
            do {
                let analytics = try DependencyValues._current.analytics
                await analytics.trackEvent("notification_tapped", parameters: [
                    "notification_id": response.notification.request.identifier,
                    "action_identifier": response.actionIdentifier
                ])
            } catch {
                // Analytics không available, chỉ log
                print("📲 Notification tapped: \(response.notification.request.identifier)")
            }
        }
        
        // Call custom handler nếu có
        onNotificationTapped?(response)
        
        completionHandler()
    }
    
    // MARK: - MessagingDelegate
    
    /// Handle FCM token refresh
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("📲 FCM Token refreshed: \(token)")
        
        // Track token refresh vào Analytics (nếu có service)
        Task {
            do {
                let analytics = try DependencyValues._current.analytics
                await analytics.trackEvent("fcm_token_refreshed", parameters: [
                    "has_token": token.isEmpty ? "false" : "true"
                ])
            } catch {
                // Analytics không available, chỉ log
                print("📲 FCM Token refreshed")
            }
        }
        
        // Call custom handler nếu có
        onTokenRefresh?(token)
    }
}

