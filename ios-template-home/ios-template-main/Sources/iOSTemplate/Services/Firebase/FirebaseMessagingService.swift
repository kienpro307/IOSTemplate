import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

// MARK: - Firebase Messaging Service

/// Service quản lý Firebase Cloud Messaging (FCM)
///
/// **Chức năng chính**:
/// - Request notification permissions
/// - Register for remote notifications
/// - Handle FCM token management
/// - Subscribe/Unsubscribe topics
/// - Handle incoming notifications
///
/// **Usage Example**:
/// ```swift
/// // Request permission
/// let granted = try await FirebaseMessagingService.shared.requestPermission()
///
/// // Register for remote notifications
/// FirebaseMessagingService.shared.registerForRemoteNotifications()
///
/// // Subscribe to topic
/// FirebaseMessagingService.shared.subscribe(toTopic: "news")
///
/// // Handle notification
/// FirebaseMessagingService.shared.handleNotification(userInfo)
/// ```
///
/// **Debug Mode**:
/// - Auto-enabled trong DEBUG builds
/// - Shows emoji-based logs (📲 notifications, 🔔 permissions, etc.)
///
/// **Privacy Considerations**:
/// - FCM token is device-specific, not user-specific
/// - Don't send sensitive data via notifications
/// - Use notification data for action triggers only
public final class FirebaseMessagingService: NSObject, PushNotificationServiceProtocol {

    // MARK: - Properties

    /// Shared instance
    public static let shared = FirebaseMessagingService()

    /// Firebase Messaging instance
    private let messaging = Messaging.messaging()

    /// User Notification Center
    private let notificationCenter = UNUserNotificationCenter.current()

    /// Debug mode (auto-enabled in DEBUG builds)
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// FCM token (updated khi token changes)
    private(set) var fcmToken: String?

    /// Device token (APNs token)
    private(set) var deviceToken: Data?

    /// Notification handlers
    private var notificationHandlers: [(([AnyHashable: Any]) -> Void)] = []

    /// Token refresh handlers
    private var tokenRefreshHandlers: [((String) -> Void)] = []

    // MARK: - Initialization

    private override init() {
        super.init()
        setupMessaging()
    }

    // MARK: - Setup

    /// Setup Firebase Messaging
    private func setupMessaging() {
        // Set delegate
        messaging.delegate = self
        notificationCenter.delegate = self

        // Get current FCM token
        messaging.token { [weak self] token, error in
            if let error = error {
                self?.logDebug("❌ Error getting FCM token: \(error.localizedDescription)")
            } else if let token = token {
                self?.fcmToken = token
                self?.logDebug("📲 FCM Token: \(token)")
                self?.notifyTokenRefresh(token)
            }
        }

        logDebug("✅ Firebase Messaging Service initialized")
    }

    // MARK: - PushNotificationServiceProtocol

    /// Request notification permission from user
    ///
    /// **Permission Types**:
    /// - Alert: Show banner/alert
    /// - Badge: Update app badge
    /// - Sound: Play notification sound
    ///
    /// - Returns: true if granted, false if denied
    public func requestPermission() async throws -> Bool {
        logDebug("🔔 Requesting notification permission...")

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]

        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)

            if granted {
                logDebug("✅ Notification permission granted")
            } else {
                logDebug("⚠️ Notification permission denied")
            }

            return granted
        } catch {
            logDebug("❌ Error requesting permission: \(error.localizedDescription)")
            throw error
        }
    }

    /// Register for remote notifications
    ///
    /// **Call this after**:
    /// 1. Requesting permission
    /// 2. User grants permission
    ///
    /// **Note**: Must be called on main thread
    public func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            #if !targetEnvironment(simulator)
            UIApplication.shared.registerForRemoteNotifications()
            self.logDebug("📲 Registering for remote notifications...")
            #else
            self.logDebug("⚠️ Remote notifications not available on simulator")
            #endif
        }
    }

    /// Handle device token from APNs
    ///
    /// **Call from AppDelegate**:
    /// ```swift
    /// func application(_ application: UIApplication,
    ///                  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ///     FirebaseMessagingService.shared.handleDeviceToken(deviceToken)
    /// }
    /// ```
    ///
    /// - Parameter token: APNs device token
    public func handleDeviceToken(_ token: Data) {
        self.deviceToken = token

        // Convert to hex string for logging
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        logDebug("📱 APNs Device Token: \(tokenString)")

        // Set APNs token to Firebase Messaging
        messaging.apnsToken = token
    }

    /// Handle incoming notification
    ///
    /// **Call from AppDelegate**:
    /// ```swift
    /// func application(_ application: UIApplication,
    ///                  didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    ///     FirebaseMessagingService.shared.handleNotification(userInfo)
    /// }
    /// ```
    ///
    /// - Parameter userInfo: Notification payload
    public func handleNotification(_ userInfo: [AnyHashable: Any]) {
        logDebug("📬 Received notification")

        if isDebugMode {
            logDebug("Notification data: \(userInfo)")
        }

        // Notify handlers
        notifyNotificationReceived(userInfo)

        // Parse notification
        if let notificationType = parseNotificationType(userInfo) {
            handleNotificationType(notificationType, userInfo: userInfo)
        }
    }

    /// Subscribe to topic
    ///
    /// **Topic Naming**:
    /// - Use lowercase: "news", "sports", "tech"
    /// - Use hyphens: "breaking-news", "user-updates"
    /// - Avoid special characters
    ///
    /// **Example**:
    /// ```swift
    /// // Subscribe to news topic
    /// service.subscribe(toTopic: "news")
    ///
    /// // Subscribe to user-specific topic
    /// service.subscribe(toTopic: "user-\(userID)")
    /// ```
    ///
    /// - Parameter topic: Topic name
    public func subscribe(toTopic topic: String) {
        messaging.subscribe(toTopic: topic) { [weak self] error in
            if let error = error {
                self?.logDebug("❌ Error subscribing to topic '\(topic)': \(error.localizedDescription)")
            } else {
                self?.logDebug("✅ Subscribed to topic: \(topic)")
            }
        }
    }

    /// Unsubscribe from topic
    ///
    /// - Parameter topic: Topic name
    public func unsubscribe(fromTopic topic: String) {
        messaging.unsubscribe(fromTopic: topic) { [weak self] error in
            if let error = error {
                self?.logDebug("❌ Error unsubscribing from topic '\(topic)': \(error.localizedDescription)")
            } else {
                self?.logDebug("✅ Unsubscribed from topic: \(topic)")
            }
        }
    }

    // MARK: - Public Methods

    /// Add notification handler
    ///
    /// **Usage**:
    /// ```swift
    /// service.addNotificationHandler { userInfo in
    ///     // Handle notification
    ///     if let message = userInfo["message"] as? String {
    ///         print("Received: \(message)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter handler: Notification handler closure
    public func addNotificationHandler(_ handler: @escaping ([AnyHashable: Any]) -> Void) {
        notificationHandlers.append(handler)
    }

    /// Add token refresh handler
    ///
    /// **Usage**:
    /// ```swift
    /// service.addTokenRefreshHandler { token in
    ///     // Send token to your backend
    ///     await api.updateFCMToken(token)
    /// }
    /// ```
    ///
    /// - Parameter handler: Token refresh handler closure
    public func addTokenRefreshHandler(_ handler: @escaping (String) -> Void) {
        tokenRefreshHandlers.append(handler)
    }

    /// Delete FCM token
    ///
    /// **Use cases**:
    /// - User logs out
    /// - User disables notifications
    /// - Testing token refresh
    ///
    /// **Note**: New token will be generated automatically
    public func deleteToken() async throws {
        do {
            try await messaging.deleteToken()
            fcmToken = nil
            logDebug("🗑️ FCM token deleted")
        } catch {
            logDebug("❌ Error deleting token: \(error.localizedDescription)")
            throw error
        }
    }

    /// Get current notification settings
    ///
    /// **Check before showing notification**:
    /// ```swift
    /// let settings = await service.getNotificationSettings()
    /// if settings.authorizationStatus == .authorized {
    ///     // Show notification
    /// }
    /// ```
    ///
    /// - Returns: Current notification settings
    public func getNotificationSettings() async -> UNNotificationSettings {
        await notificationCenter.notificationSettings()
    }

    // MARK: - Private Methods

    /// Parse notification type from payload
    private func parseNotificationType(_ userInfo: [AnyHashable: Any]) -> NotificationType? {
        guard let typeString = userInfo["type"] as? String else {
            return nil
        }

        return NotificationType(rawValue: typeString)
    }

    /// Handle specific notification type
    private func handleNotificationType(_ type: NotificationType, userInfo: [AnyHashable: Any]) {
        logDebug("📋 Notification type: \(type.rawValue)")

        switch type {
        case .message:
            handleMessageNotification(userInfo)
        case .alert:
            handleAlertNotification(userInfo)
        case .update:
            handleUpdateNotification(userInfo)
        case .marketing:
            handleMarketingNotification(userInfo)
        }
    }

    /// Handle message notification
    private func handleMessageNotification(_ userInfo: [AnyHashable: Any]) {
        // Extract message data
        if let message = userInfo["message"] as? String {
            logDebug("💬 Message: \(message)")
        }
    }

    /// Handle alert notification
    private func handleAlertNotification(_ userInfo: [AnyHashable: Any]) {
        // Extract alert data
        if let alert = userInfo["alert"] as? String {
            logDebug("⚠️ Alert: \(alert)")
        }
    }

    /// Handle update notification
    private func handleUpdateNotification(_ userInfo: [AnyHashable: Any]) {
        // Extract update data
        if let updateInfo = userInfo["update"] as? String {
            logDebug("🔄 Update: \(updateInfo)")
        }
    }

    /// Handle marketing notification
    private func handleMarketingNotification(_ userInfo: [AnyHashable: Any]) {
        // Extract marketing data
        if let campaign = userInfo["campaign"] as? String {
            logDebug("📢 Marketing campaign: \(campaign)")
        }
    }

    /// Notify token refresh handlers
    private func notifyTokenRefresh(_ token: String) {
        for handler in tokenRefreshHandlers {
            handler(token)
        }
    }

    /// Notify notification received handlers
    private func notifyNotificationReceived(_ userInfo: [AnyHashable: Any]) {
        for handler in notificationHandlers {
            handler(userInfo)
        }
    }

    /// Debug logging
    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[FirebaseMessaging] \(message)")
    }
}

// MARK: - MessagingDelegate

extension FirebaseMessagingService: MessagingDelegate {

    /// Handle FCM token refresh
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }

        self.fcmToken = fcmToken
        logDebug("🔄 FCM Token refreshed: \(fcmToken)")

        // Notify handlers
        notifyTokenRefresh(fcmToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension FirebaseMessagingService: UNUserNotificationCenterDelegate {

    /// Handle notification when app is in foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        logDebug("📬 Notification received (foreground)")

        // Handle notification
        handleNotification(userInfo)

        // Show notification banner in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        logDebug("👆 Notification tapped")

        // Handle notification
        handleNotification(userInfo)

        completionHandler()
    }
}

// MARK: - Notification Type

/// Notification types
public enum NotificationType: String {
    case message = "message"
    case alert = "alert"
    case update = "update"
    case marketing = "marketing"
}

// MARK: - Notification Errors

/// Push notification errors
public enum PushNotificationError: Error, LocalizedError {
    case permissionDenied
    case tokenNotAvailable
    case invalidPayload
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission denied by user"
        case .tokenNotAvailable:
            return "FCM token not available"
        case .invalidPayload:
            return "Invalid notification payload"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
