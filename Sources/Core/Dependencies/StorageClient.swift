import Foundation
import ComposableArchitecture

/// Protocol cho storage operations
public protocol StorageClientProtocol: Sendable {
    /// Lưu value cho key
    func save<T: Codable>(_ value: T, forKey key: String) async throws
    
    /// Lấy value theo key
    func load<T: Codable>(forKey key: String) async throws -> T?
    
    /// Xóa value theo key
    func remove(forKey key: String) async throws
    
    /// Xóa tất cả
    func removeAll() async throws
}

// MARK: - Storage Keys
public enum StorageKey: String {
    case userId = "user_id"
    case userName = "user_name"
    case hasCompletedOnboarding = "has_completed_onboarding"
    case selectedTheme = "selected_theme"
    case selectedLanguage = "selected_language"
    case notificationsEnabled = "notifications_enabled"
}

// MARK: - Live Implementation
/// Implementation với UserDefaults
public struct LiveStorageClient: StorageClientProtocol {
    // ✅ FIX: Wrap UserDefaults trong SendableBox
    private let userDefaults: SendableBox<UserDefaults>
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = SendableBox(userDefaults)
    }
    
    public func save<T: Codable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        userDefaults.value.set(data, forKey: key)
    }
    
    public func load<T: Codable>(forKey key: String) async throws -> T? {
        guard let data = userDefaults.value.data(forKey: key) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        userDefaults.value.removeObject(forKey: key)
    }
    
    public func removeAll() async throws {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.value.removePersistentDomain(forName: bundleID)
        }
    }
}

// MARK: - Mock Implementation
/// Mock storage cho testing (dùng actor để thread-safe)
public actor MockStorageClient: StorageClientProtocol {
    private var storage: [String: Data] = [:]
    
    public init() {}
    
    public func save<T: Codable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        storage[key] = data
    }
    
    public func load<T: Codable>(forKey key: String) async throws -> T? {
        guard let data = storage[key] else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        storage.removeValue(forKey: key)
    }
    
    public func removeAll() async throws {
        storage.removeAll()
    }
}

// MARK: - Helper: Sendable Box
/// Wrapper để làm non-Sendable type thành Sendable (an toàn vì UserDefaults đã thread-safe)
private final class SendableBox<T>: @unchecked Sendable {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

// MARK: - Dependency Key
private enum StorageClientKey: DependencyKey {
    static let liveValue: any StorageClientProtocol = LiveStorageClient()
    static let testValue: any StorageClientProtocol = MockStorageClient()
    static let previewValue: any StorageClientProtocol = MockStorageClient()
}

extension DependencyValues {
    public var storageClient: any StorageClientProtocol {
        get { self[StorageClientKey.self] }
        set { self[StorageClientKey.self] = newValue }
    }
}
