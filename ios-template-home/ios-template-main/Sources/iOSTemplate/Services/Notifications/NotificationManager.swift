import Foundation
import UserNotifications
import UIKit

// MARK: - Notification Manager

/// Notification Manager - Quản lý toàn bộ push notifications
///
/// **Chức năng**:
/// - Initialize và configure push notifications
/// - Request permissions
/// - Handle local và remote notifications
/// - Subscribe/Unsubscribe topics
/// - Schedule local notifications
/// - Handle notification actions
///
/// **Usage Example**:
/// ```swift
/// // Initialize in AppDelegate
/// await NotificationManager.shared.initialize()
///
/// // Request permission
/// let granted = await NotificationManager.shared.requestPermission()
///
/// // Schedule local notification
/// try await NotificationManager.shared.scheduleLocalNotification(
///     title: "Reminder",
///     body: "Time to check your tasks!",
///     timeInterval: 60
/// )
///
/// // Subscribe to topic
/// NotificationManager.shared.subscribe(toTopic: "news")
/// ```
///
/// **Integration**:
/// Cần integrate với AppDelegate/SceneDelegate để handle lifecycle events
public final class NotificationManager {

    // MARK: - Properties

    /// Shared instance
    public static let shared = NotificationManager()

    /// Push notification service (FCM)
    private var pushService: PushNotificationServiceProtocol?

    /// User Notification Center
    private let notificationCenter = UNUserNotificationCenter.current()

    /// Is initialized
    private(set) var isInitialized = false

    /// Current notification settings
    private(set) var notificationSettings: UNNotificationSettings?

    /// Debug mode
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Initialize notification manager
    ///
    /// **Call from AppDelegate**:
    /// ```swift
    /// func application(_ application: UIApplication,
    ///                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ///     Task {
    ///         await NotificationManager.shared.initialize()
    ///     }
    ///     return true
    /// }
    /// ```
    public func initialize() async {
        guard !isInitialized else {
            logDebug("⚠️ NotificationManager already initialized")
            return
        }

        // Get push service from DI container
        pushService = DIContainer.shared.pushNotificationService

        // Setup notification categories and actions
        setupNotificationCategories()

        // Refresh notification settings
        await refreshSettings()

        isInitialized = true
        logDebug("✅ NotificationManager initialized")
    }

    // MARK: - Permissions

    /// Request notification permission
    ///
    /// **Permissions requested**:
    /// - Alert: Show banner/alert
    /// - Badge: Update app badge
    /// - Sound: Play notification sound
    ///
    /// - Returns: true if granted, false if denied
    public func requestPermission() async -> Bool {
        guard let pushService = pushService else {
            logDebug("❌ Push service not available")
            return false
        }

        do {
            let granted = try await pushService.requestPermission()

            if granted {
                // Register for remote notifications
                pushService.registerForRemoteNotifications()
            }

            // Refresh settings
            await refreshSettings()

            return granted
        } catch {
            logDebug("❌ Error requesting permission: \(error.localizedDescription)")
            return false
        }
    }

    /// Get current notification settings
    public func getCurrentSettings() async -> UNNotificationSettings {
        await notificationCenter.notificationSettings()
    }

    /// Check if notifications are authorized
    public var isAuthorized: Bool {
        notificationSettings?.authorizationStatus == .authorized
    }

    // MARK: - Remote Notifications

    /// Handle device token from APNs
    ///
    /// **Call from AppDelegate**:
    /// ```swift
    /// func application(_ application: UIApplication,
    ///                  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ///     NotificationManager.shared.handleDeviceToken(deviceToken)
    /// }
    /// ```
    public func handleDeviceToken(_ token: Data) {
        pushService?.handleDeviceToken(token)
    }

    /// Handle remote notification
    ///
    /// **Call from AppDelegate**:
    /// ```swift
    /// func application(_ application: UIApplication,
    ///                  didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    ///     NotificationManager.shared.handleRemoteNotification(userInfo)
    /// }
    /// ```
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        pushService?.handleNotification(userInfo)
    }

    /// Subscribe to topic
    ///
    /// **Topic naming**:
    /// - Use lowercase
    /// - Use hyphens for multi-word topics
    /// - Examples: "news", "sports", "breaking-news"
    ///
    /// - Parameter topic: Topic name
    public func subscribe(toTopic topic: String) {
        pushService?.subscribe(toTopic: topic)
    }

    /// Unsubscribe from topic
    public func unsubscribe(fromTopic topic: String) {
        pushService?.unsubscribe(fromTopic: topic)
    }

    // MARK: - Local Notifications

    /// Schedule local notification
    ///
    /// **Example**:
    /// ```swift
    /// // Schedule after 60 seconds
    /// try await manager.scheduleLocalNotification(
    ///     title: "Reminder",
    ///     body: "Time to check your tasks!",
    ///     timeInterval: 60
    /// )
    ///
    /// // Schedule with custom identifier
    /// try await manager.scheduleLocalNotification(
    ///     identifier: "daily-reminder",
    ///     title: "Daily Reminder",
    ///     body: "Don't forget to review your goals",
    ///     timeInterval: 86400, // 24 hours
    ///     repeats: true
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - identifier: Unique identifier (auto-generated if nil)
    ///   - title: Notification title
    ///   - body: Notification body
    ///   - timeInterval: Time interval in seconds
    ///   - repeats: Repeat notification (default: false)
    ///   - badge: Badge number (optional)
    ///   - sound: Notification sound (default: .default)
    ///   - categoryIdentifier: Category identifier for actions (optional)
    ///   - userInfo: Additional data (optional)
    public func scheduleLocalNotification(
        identifier: String? = nil,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool = false,
        badge: Int? = nil,
        sound: UNNotificationSound = .default,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) async throws {
        // Create content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }

        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }

        if let userInfo = userInfo {
            content.userInfo = userInfo
        }

        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: repeats
        )

        // Create request
        let notificationIdentifier = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        try await notificationCenter.add(request)

        logDebug("✅ Scheduled local notification: \(title)")
    }

    /// Schedule notification at specific date
    ///
    /// **Example**:
    /// ```swift
    /// // Schedule at specific date
    /// let date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    /// try await manager.scheduleNotification(
    ///     at: date,
    ///     title: "Good Morning",
    ///     body: "Time to start your day!"
    /// )
    /// ```
    public func scheduleNotification(
        at date: Date,
        identifier: String? = nil,
        title: String,
        body: String,
        repeats: Bool = false,
        badge: Int? = nil,
        sound: UNNotificationSound = .default,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) async throws {
        // Create content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }

        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }

        if let userInfo = userInfo {
            content.userInfo = userInfo
        }

        // Create trigger
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: repeats
        )

        // Create request
        let notificationIdentifier = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        try await notificationCenter.add(request)

        logDebug("✅ Scheduled notification at: \(date)")
    }

    /// Cancel notification by identifier
    public func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        logDebug("🗑️ Cancelled notification: \(identifier)")
    }

    /// Cancel all pending notifications
    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        logDebug("🗑️ Cancelled all pending notifications")
    }

    /// Get pending notifications
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    /// Get delivered notifications
    public func getDeliveredNotifications() async -> [UNNotification] {
        await notificationCenter.deliveredNotifications()
    }

    /// Clear all delivered notifications
    public func clearDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        logDebug("🧹 Cleared all delivered notifications")
    }

    /// Set app badge number
    public func setBadge(_ number: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = number
        }
    }

    /// Clear app badge
    public func clearBadge() {
        setBadge(0)
    }

    // MARK: - Private Methods

    /// Setup notification categories and actions
    private func setupNotificationCategories() {
        // Category: Message
        let replyAction = UNTextInputNotificationAction(
            identifier: NotificationAction.reply.rawValue,
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply..."
        )

        let markAsReadAction = UNNotificationAction(
            identifier: NotificationAction.markAsRead.rawValue,
            title: "Mark as Read",
            options: []
        )

        let messageCategory = UNNotificationCategory(
            identifier: NotificationCategory.message.rawValue,
            actions: [replyAction, markAsReadAction],
            intentIdentifiers: [],
            options: []
        )

        // Category: Reminder
        let completeAction = UNNotificationAction(
            identifier: NotificationAction.complete.rawValue,
            title: "Complete",
            options: []
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze.rawValue,
            title: "Snooze",
            options: []
        )

        let reminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.reminder.rawValue,
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Category: Alert
        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss.rawValue,
            title: "Dismiss",
            options: [.destructive]
        )

        let viewAction = UNNotificationAction(
            identifier: NotificationAction.view.rawValue,
            title: "View",
            options: [.foreground]
        )

        let alertCategory = UNNotificationCategory(
            identifier: NotificationCategory.alert.rawValue,
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // Register categories
        notificationCenter.setNotificationCategories([
            messageCategory,
            reminderCategory,
            alertCategory
        ])

        logDebug("✅ Notification categories configured")
    }

    /// Refresh notification settings
    private func refreshSettings() async {
        notificationSettings = await getCurrentSettings()
        logDebug("📋 Notification settings refreshed: \(notificationSettings?.authorizationStatus.description ?? "unknown")")
    }

    /// Debug logging
    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[NotificationManager] \(message)")
    }
}

// MARK: - Notification Categories

/// Predefined notification categories
public enum NotificationCategory: String {
    case message = "MESSAGE_CATEGORY"
    case reminder = "REMINDER_CATEGORY"
    case alert = "ALERT_CATEGORY"
}

// MARK: - Notification Actions

/// Predefined notification actions
public enum NotificationAction: String {
    case reply = "REPLY_ACTION"
    case markAsRead = "MARK_AS_READ_ACTION"
    case complete = "COMPLETE_ACTION"
    case snooze = "SNOOZE_ACTION"
    case dismiss = "DISMISS_ACTION"
    case view = "VIEW_ACTION"
}

// MARK: - Authorization Status Extension

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
}
