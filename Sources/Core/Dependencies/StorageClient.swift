import Foundation
import ComposableArchitecture

/// Protocol cho các thao tác lưu trữ dữ liệu
public protocol StorageClientProtocol: Sendable {
    /// Lưu giá trị cho key (hỗ trợ kiểu Codable và primitive types)
    func save<T: Codable>(_ value: T, forKey key: String) async throws
    
    /// Lấy giá trị theo key
    func load<T: Codable>(forKey key: String) async throws -> T?
    
    /// Xóa giá trị theo key
    func remove(forKey key: String) async throws
    
    /// Xóa tất cả dữ liệu
    func removeAll() async throws
    
    /// Kiểm tra key có tồn tại không
    func exists(forKey key: String) async -> Bool
}

// MARK: - Các khóa Storage
/// Định nghĩa các key thường dùng để lưu trữ
public enum StorageKey: String {
    // User Preferences (không có profile)
    case userId = "user_id"
    case userName = "user_name"
    public static let userPreferences = "user.preferences"

    // Settings
    case selectedTheme = "selected_theme"
    case selectedLanguage = "selected_language"
    case notificationsEnabled = "notifications_enabled"
    public static let themeMode = "settings.theme_mode"
    public static let languageCode = "settings.language_code"

    // Onboarding
    case hasCompletedOnboarding = "has_completed_onboarding"
    public static let onboardingVersion = "onboarding.version"

    // App State
    public static let lastAppVersion = "app.last_version"
    public static let lastLaunchDate = "app.last_launch_date"
    public static let launchCount = "app.launch_count"

    // Cache
    public static let lastCacheCleanupDate = "cache.last_cleanup"
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế với UserDefaults
public struct LiveStorageClient: StorageClientProtocol {
    /// Bọc UserDefaults trong SendableBox để đảm bảo thread-safe
    private let userDefaults: SendableBox<UserDefaults>
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = SendableBox(userDefaults)
    }
    
    public func save<T: Codable>(_ value: T, forKey key: String) async throws {
        // Nếu là primitive type, save trực tiếp (hiệu quả hơn)
        if let stringValue = value as? String {
            userDefaults.value.set(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            userDefaults.value.set(intValue, forKey: key)
        } else if let boolValue = value as? Bool {
            userDefaults.value.set(boolValue, forKey: key)
        } else if let doubleValue = value as? Double {
            userDefaults.value.set(doubleValue, forKey: key)
        } else {
            // Encode các kiểu phức tạp
            let data = try JSONEncoder().encode(value)
            userDefaults.value.set(data, forKey: key)
        }
        userDefaults.value.synchronize()
    }
    
    public func load<T: Codable>(forKey key: String) async throws -> T? {
        // Try primitive types first (hiệu quả hơn)
        if T.self == String.self {
            return userDefaults.value.string(forKey: key) as? T
        } else if T.self == Int.self {
            return userDefaults.value.integer(forKey: key) as? T
        } else if T.self == Bool.self {
            return userDefaults.value.bool(forKey: key) as? T
        } else if T.self == Double.self {
            return userDefaults.value.double(forKey: key) as? T
        }
        
        // Thử decode từ Data
        guard let data = userDefaults.value.data(forKey: key) else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        userDefaults.value.removeObject(forKey: key)
        userDefaults.value.synchronize()
    }
    
    public func removeAll() async throws {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.value.removePersistentDomain(forName: bundleID)
        }
        userDefaults.value.synchronize()
    }
    
    public func exists(forKey key: String) async -> Bool {
        userDefaults.value.object(forKey: key) != nil
    }
}

// MARK: - Triển khai Mock
/// Triển khai giả lập cho testing (dùng actor để thread-safe)
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
    
    public func exists(forKey key: String) async -> Bool {
        storage[key] != nil
    }
}

// MARK: - Helper: Hộp Sendable
/// Wrapper để chuyển đổi kiểu non-Sendable thành Sendable (an toàn vì UserDefaults đã thread-safe)
private final class SendableBox<T>: @unchecked Sendable {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

// MARK: - Khóa Dependency
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

// MARK: - Property Wrapper for UserDefaults

/// Property wrapper cho UserDefaults với type safety
/// Sử dụng StorageClient để lưu trữ
@propertyWrapper
public struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storageClient: any StorageClientProtocol

    public init(
        key: String,
        defaultValue: T,
        storageClient: (any StorageClientProtocol)? = nil
    ) {
        self.key = key
        self.defaultValue = defaultValue
        // Sử dụng dependency nếu có, nếu không dùng LiveStorageClient
        if let storageClient = storageClient {
            self.storageClient = storageClient
        } else {
            self.storageClient = LiveStorageClient()
        }
    }

    public var wrappedValue: T {
        get {
            // Synchronous get - cần await nhưng property wrapper không support async
            // Fallback: dùng UserDefaults trực tiếp cho get
            if let data = UserDefaults.standard.data(forKey: key) {
                if let value = try? JSONDecoder().decode(T.self, from: data) {
                    return value
                }
            }
            // Try primitive types
            if T.self == String.self, let value = UserDefaults.standard.string(forKey: key) as? T {
                return value
            }
            if T.self == Int.self, let value = UserDefaults.standard.integer(forKey: key) as? T {
                return value
            }
            if T.self == Bool.self, let value = UserDefaults.standard.bool(forKey: key) as? T {
                return value
            }
            if T.self == Double.self, let value = UserDefaults.standard.double(forKey: key) as? T {
                return value
            }
            return defaultValue
        }
        set {
            // Synchronous set - dùng UserDefaults trực tiếp
            if let stringValue = newValue as? String {
                UserDefaults.standard.set(stringValue, forKey: key)
            } else if let intValue = newValue as? Int {
                UserDefaults.standard.set(intValue, forKey: key)
            } else if let boolValue = newValue as? Bool {
                UserDefaults.standard.set(boolValue, forKey: key)
            } else if let doubleValue = newValue as? Double {
                UserDefaults.standard.set(doubleValue, forKey: key)
            } else if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}
