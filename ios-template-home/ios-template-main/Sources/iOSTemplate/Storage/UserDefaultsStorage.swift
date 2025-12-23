import Foundation

/// UserDefaults wrapper với type safety và Codable support
public final class UserDefaultsStorage: StorageServiceProtocol {

    // MARK: - Properties

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    public init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - StorageServiceProtocol

    public func save<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            // Nếu là primitive type, save trực tiếp
            if let stringValue = value as? String {
                defaults.set(stringValue, forKey: key)
            } else if let intValue = value as? Int {
                defaults.set(intValue, forKey: key)
            } else if let boolValue = value as? Bool {
                defaults.set(boolValue, forKey: key)
            } else if let doubleValue = value as? Double {
                defaults.set(doubleValue, forKey: key)
            } else {
                // Encode complex types
                let data = try encoder.encode(value)
                defaults.set(data, forKey: key)
            }
            defaults.synchronize()
        } catch {
            throw StorageError.encodingFailed
        }
    }

    public func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        // Try primitive types first
        if T.self == String.self {
            return defaults.string(forKey: key) as? T
        } else if T.self == Int.self {
            return defaults.integer(forKey: key) as? T
        } else if T.self == Bool.self {
            return defaults.bool(forKey: key) as? T
        } else if T.self == Double.self {
            return defaults.double(forKey: key) as? T
        }

        // Try to decode from Data
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        do {
            let value = try decoder.decode(T.self, from: data)
            return value
        } catch {
            throw StorageError.decodingFailed
        }
    }

    public func delete(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }

    public func clear() {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        defaults.synchronize()
    }

    public func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}

// MARK: - Storage Keys

/// Centralized storage keys
public enum StorageKey {
    // User
    public static let userProfile = "user.profile"
    public static let userPreferences = "user.preferences"

    // Settings
    public static let themeMode = "settings.theme_mode"
    public static let languageCode = "settings.language_code"
    public static let notificationsEnabled = "settings.notifications_enabled"

    // Onboarding
    public static let hasCompletedOnboarding = "onboarding.completed"
    public static let onboardingVersion = "onboarding.version"

    // App State
    public static let lastAppVersion = "app.last_version"
    public static let lastLaunchDate = "app.last_launch_date"
    public static let launchCount = "app.launch_count"

    // Cache
    public static let lastCacheCleanupDate = "cache.last_cleanup"
}

// MARK: - Property Wrapper for UserDefaults

/// Property wrapper cho UserDefaults với type safety
@propertyWrapper
public struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaultsStorage

    public init(
        key: String,
        defaultValue: T,
        storage: UserDefaultsStorage = UserDefaultsStorage()
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: T {
        get {
            (try? storage.load(T.self, forKey: key)) ?? defaultValue
        }
        set {
            try? storage.save(newValue, forKey: key)
        }
    }
}

// MARK: - Example Usage

/*
 Usage Example:

 class SettingsManager {
     @UserDefault(key: StorageKey.themeMode, defaultValue: "auto")
     var themeMode: String

     @UserDefault(key: StorageKey.notificationsEnabled, defaultValue: true)
     var notificationsEnabled: Bool

     @UserDefault(key: StorageKey.launchCount, defaultValue: 0)
     var launchCount: Int
 }

 let settings = SettingsManager()
 settings.themeMode = "dark"
 print(settings.themeMode) // "dark"
 settings.launchCount += 1
 */
