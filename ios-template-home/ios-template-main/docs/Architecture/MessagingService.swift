import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

/// High-level Firebase Cloud Messaging service
///
/// Provides convenient methods for push notifications and FCM
///
/// ## Usage:
/// ```swift
/// // Setup in AppDelegate or App init
/// MessagingService.shared.setup()
///
/// // Handle token updates
/// MessagingService.shared.onTokenUpdate = { token in
///     print("FCM Token: \(token)")
///     // Send to your backend
/// }
///
/// // Subscribe to topic
/// try await MessagingService.shared.subscribe(to: "news")
///
/// // Get current token
/// if let token = MessagingService.shared.fcmToken {
///     print("Token: \(token)")
/// }
/// ```
///
public final class MessagingService: NSObject {
    
    // MARK: - Singleton
    
    public static let shared = MessagingService()
    
    private let firebaseManager: FirebaseManager
    
    // MARK: - Properties
    
    /// Current FCM token
    public private(set) var fcmToken: String?
    
    /// APNs token (Apple Push Notification service)
    public private(set) var apnsToken: Data?
    
    /// Callback when token is updated
    public var onTokenUpdate: ((String) -> Void)?
    
    /// Callback when notification is received
    public var onNotificationReceived: (([AnyHashable: Any]) -> Void)?
    
    // MARK: - Initialization
    
    public override init() {
        self.firebaseManager = .shared
        super.init()
    }
    
    // MARK: - Setup
    
    /// Setup messaging service
    ///
    /// Call this early in app lifecycle (AppDelegate or App init)
    ///
    /// - Parameter autoRequestPermission: Automatically request notification permissions (default: true)
    public func setup(autoRequestPermission: Bool = true) {
        guard firebaseManager.isServiceEnabled(.messaging) else {
            logDebug("[Messaging] Service not enabled")
            return
        }
        
        // Set delegate
        Messaging.messaging().delegate = self
        
        // Request permissions
        if autoRequestPermission {
            requestPermissions()
        }
        
        // Get initial token
        fetchToken()
        
        logDebug("[Messaging] ✅ Setup completed")
    }
    
    // MARK: - Permissions
    
    /// Request notification permissions
    ///
    /// - Parameter options: Permission options (default: alert, sound, badge)
    public func requestPermissions(
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: options
        ) { [weak self] granted, error in
            if let error = error {
                self?.logDebug("[Messaging] ❌ Permission error: \(error)")
                return
            }
            
            if granted {
                self?.logDebug("[Messaging] ✅ Permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                self?.logDebug("[Messaging] ⚠️ Permission denied")
            }
        }
    }
    
    /// Check current notification authorization status
    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Check if notifications are authorized
    public func isAuthorized() async -> Bool {
        let status = await checkAuthorizationStatus()
        return status == .authorized || status == .provisional
    }
    
    // MARK: - Token Management
    
    /// Fetch FCM token
    ///
    /// Token is cached and available via `fcmToken` property
    public func fetchToken() {
        guard firebaseManager.isServiceEnabled(.messaging) else {
            logDebug("[Messaging] Service not enabled, skipping token fetch")
            return
        }
        
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logDebug("[Messaging] ❌ Error fetching token: \(error)")
                return
            }
            
            if let token = token {
                self.logDebug("[Messaging] ✅ FCM Token: \(token)")
                self.fcmToken = token
                self.onTokenUpdate?(token)
            }
        }
    }
    
    /// Delete FCM token
    ///
    /// Use when user logs out or opts out of notifications
    public func deleteToken() async throws {
        guard firebaseManager.isServiceEnabled(.messaging) else {
            throw FirebaseError.serviceNotEnabled("Messaging")
        }
        
        try await Messaging.messaging().deleteToken()
        self.fcmToken = nil
        logDebug("[Messaging] ✅ Token deleted")
    }
    
    /// Set APNs token
    ///
    /// Call this from AppDelegate's didRegisterForRemoteNotificationsWithDeviceToken
    ///
    /// - Parameter token: APNs device token
    public func setAPNsToken(_ token: Data) {
        self.apnsToken = token
        Messaging.messaging().apnsToken = token
        logDebug("[Messaging] ✅ APNs token set")
    }
    
    // MARK: - Topics
    
    /// Subscribe to topic
    ///
    /// - Parameter topic: Topic name (e.g., "news", "sports")
    public func subscribe(to topic: String) async throws {
        guard firebaseManager.isServiceEnabled(.messaging) else {
            throw FirebaseError.serviceNotEnabled("Messaging")
        }
        
        try await Messaging.messaging().subscribe(toTopic: topic)
        logDebug("[Messaging] ✅ Subscribed to topic: \(topic)")
    }
    
    /// Unsubscribe from topic
    ///
    /// - Parameter topic: Topic name
    public func unsubscribe(from topic: String) async throws {
        guard firebaseManager.isServiceEnabled(.messaging) else {
            throw FirebaseError.serviceNotEnabled("Messaging")
        }
        
        try await Messaging.messaging().unsubscribe(fromTopic: topic)
        logDebug("[Messaging] ✅ Unsubscribed from topic: \(topic)")
    }
    
    /// Subscribe to multiple topics
    ///
    /// - Parameter topics: Array of topic names
    public func subscribe(to topics: [String]) async throws {
        for topic in topics {
            try await subscribe(to: topic)
        }
    }
    
    /// Unsubscribe from multiple topics
    ///
    /// - Parameter topics: Array of topic names
    public func unsubscribe(from topics: [String]) async throws {
        for topic in topics {
            try await unsubscribe(from: topic)
        }
    }
    
    // MARK: - Message Handling
    
    /// Handle notification data
    ///
    /// Call this from AppDelegate's didReceiveRemoteNotification
    ///
    /// - Parameter userInfo: Notification payload
    public func handleNotification(_ userInfo: [AnyHashable: Any]) {
        logDebug("[Messaging] 📩 Notification received")
        onNotificationReceived?(userInfo)
        
        // Extract common fields
        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? String {
                logDebug("[Messaging] Alert: \(alert)")
            } else if let alert = aps["alert"] as? [String: Any],
                      let body = alert["body"] as? String {
                logDebug("[Messaging] Body: \(body)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func logDebug(_ message: String) {
        if firebaseManager.config?.isDebugMode == true {
            print(message)
        }
    }
}

// MARK: - MessagingDelegate

extension MessagingService: MessagingDelegate {
    public func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        logDebug("[Messaging] 🔄 Token refreshed")
        
        if let token = fcmToken {
            self.fcmToken = token
            onTokenUpdate?(token)
            logDebug("[Messaging] New token: \(token)")
        }
    }
}

// MARK: - AppDelegate Integration Helpers

public extension MessagingService {
    /// Setup notification center delegate
    ///
    /// Call this in AppDelegate's didFinishLaunchingWithOptions
    ///
    /// - Parameter delegate: UNUserNotificationCenterDelegate
    func setupNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
        logDebug("[Messaging] Notification delegate set")
    }
}

// MARK: - Topic Management Helper

/// Helper for managing topic subscriptions
public struct TopicManager {
    private let messagingService: MessagingService
    
    public init(messagingService: MessagingService = .shared) {
        self.messagingService = messagingService
    }
    
    /// Subscribe to user-specific topics based on preferences
    ///
    /// - Parameter preferences: User preferences
    public func subscribeBasedOnPreferences(_ preferences: UserPreferences) async throws {
        var topics: [String] = []
        
        if preferences.newsEnabled {
            topics.append("news")
        }
        
        if preferences.promotionsEnabled {
            topics.append("promotions")
        }
        
        if preferences.updatesEnabled {
            topics.append("updates")
        }
        
        try await messagingService.subscribe(to: topics)
    }
    
    /// Unsubscribe from all topics
    public func unsubscribeFromAll(_ topics: [String]) async throws {
        try await messagingService.unsubscribe(from: topics)
    }
}

/// User notification preferences
public struct UserPreferences {
    public var newsEnabled: Bool
    public var promotionsEnabled: Bool
    public var updatesEnabled: Bool
    
    public init(
        newsEnabled: Bool = false,
        promotionsEnabled: Bool = false,
        updatesEnabled: Bool = false
    ) {
        self.newsEnabled = newsEnabled
        self.promotionsEnabled = promotionsEnabled
        self.updatesEnabled = updatesEnabled
    }
}

// MARK: - Notification Payload Parser

/// Helper for parsing notification payloads
public struct NotificationPayload {
    public let title: String?
    public let body: String?
    public let badge: Int?
    public let sound: String?
    public let customData: [String: Any]
    
    public init(userInfo: [AnyHashable: Any]) {
        var title: String?
        var body: String?
        var badge: Int?
        var sound: String?
        
        if let aps = userInfo["aps"] as? [String: Any] {
            // Parse alert
            if let alertString = aps["alert"] as? String {
                body = alertString
            } else if let alert = aps["alert"] as? [String: Any] {
                title = alert["title"] as? String
                body = alert["body"] as? String
            }
            
            // Parse badge
            badge = aps["badge"] as? Int
            
            // Parse sound
            sound = aps["sound"] as? String
        }
        
        self.title = title
        self.body = body
        self.badge = badge
        self.sound = sound
        
        // Extract custom data (everything except "aps")
        var customData: [String: Any] = [:]
        for (key, value) in userInfo {
            if let stringKey = key as? String, stringKey != "aps" {
                customData[stringKey] = value
            }
        }
        self.customData = customData
    }
}

public extension MessagingService {
    /// Parse notification payload
    ///
    /// - Parameter userInfo: Raw notification data
    /// - Returns: Parsed payload
    func parsePayload(_ userInfo: [AnyHashable: Any]) -> NotificationPayload {
        return NotificationPayload(userInfo: userInfo)
    }
}
