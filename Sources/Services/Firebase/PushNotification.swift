import Foundation
import ComposableArchitecture
import FirebaseMessaging
import UserNotifications

/// Push Notification service protocol (FCM)
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol PushNotificationServiceProtocol: Sendable {
    /// Request permission
    func requestPermission() async -> Bool
    
    /// Get FCM token
    func getToken() async -> String?
    
    /// Subscribe to topic
    func subscribe(to topic: String) async throws
    
    /// Unsubscribe from topic
    func unsubscribe(from topic: String) async throws
}

// MARK: - Live Implementation với Firebase Messaging
/// Live implementation sử dụng Firebase Messaging SDK
public actor LivePushNotificationService: PushNotificationServiceProtocol {
    private let messaging: Messaging
    private let notificationCenter: UNUserNotificationCenter
    private let isDebugMode: Bool
    
    public init(isDebugMode: Bool = false) {
        self.messaging = Messaging.messaging()
        self.notificationCenter = UNUserNotificationCenter.current()
        #if DEBUG
        self.isDebugMode = true
        #else
        self.isDebugMode = isDebugMode
        #endif
    }
    
    public func requestPermission() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            
            if isDebugMode {
                print("[PushNotification] 🔔 Permission: \(granted ? "granted" : "denied")")
            }
            
            return granted
        } catch {
            if isDebugMode {
                print("[PushNotification] ❌ Permission error: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    public func getToken() async -> String? {
        do {
            let token = try await messaging.token()
            
            if isDebugMode {
                print("[PushNotification] 📲 FCM Token: \(token)")
            }
            
            return token
        } catch {
            if isDebugMode {
                print("[PushNotification] ❌ Token error: \(error.localizedDescription)")
            }
            return nil
        }
    }
    
    public func subscribe(to topic: String) async throws {
        try await messaging.subscribe(toTopic: topic)
        
        if isDebugMode {
            print("[PushNotification] ✅ Subscribed to: \(topic)")
        }
    }
    
    public func unsubscribe(from topic: String) async throws {
        try await messaging.unsubscribe(fromTopic: topic)
        
        if isDebugMode {
            print("[PushNotification] ✅ Unsubscribed from: \(topic)")
        }
    }
}

// MARK: - Mock Implementation
public actor MockPushNotificationService: PushNotificationServiceProtocol {
    public init() {}
    
    public func requestPermission() async -> Bool {
        return true
    }
    
    public func getToken() async -> String? {
        return "mock-token"
    }
    
    public func subscribe(to topic: String) async throws {
        // Mock: không làm gì
    }
    
    public func unsubscribe(from topic: String) async throws {
        // Mock: không làm gì
    }
}

// MARK: - Dependency Key
private enum PushNotificationServiceKey: DependencyKey {
    static let liveValue: PushNotificationServiceProtocol = LivePushNotificationService()
    static let testValue: PushNotificationServiceProtocol = MockPushNotificationService()
    static let previewValue: PushNotificationServiceProtocol = MockPushNotificationService()
}

extension DependencyValues {
    public var pushNotification: PushNotificationServiceProtocol {
        get { self[PushNotificationServiceKey.self] }
        set { self[PushNotificationServiceKey.self] = newValue }
    }
}

