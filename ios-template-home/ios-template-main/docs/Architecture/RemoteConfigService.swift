import Foundation
import FirebaseRemoteConfig

/// High-level Remote Config service
///
/// Provides async/await methods for fetching and accessing remote config
///
/// ## Usage:
/// ```swift
/// // Fetch and activate
/// try await RemoteConfigService.shared.fetchAndActivate()
///
/// // Get values (type-safe)
/// let showBanner = remoteConfig.getBool(.showBanner)
/// let apiURL = remoteConfig.getString(.apiBaseURL)
///
/// // Get JSON object
/// struct FeatureFlags: Codable {
///     let darkMode: Bool
///     let premiumEnabled: Bool
/// }
/// let flags = remoteConfig.getJSON(.featureFlags, as: FeatureFlags.self)
/// ```
///
public final class RemoteConfigService {
    
    // MARK: - Singleton
    
    public static let shared = RemoteConfigService()
    
    private let firebaseManager: FirebaseManager
    private let remoteConfig: RemoteConfig
    
    public init(firebaseManager: FirebaseManager = .shared) {
        self.firebaseManager = firebaseManager
        self.remoteConfig = RemoteConfig.remoteConfig()
    }
    
    // MARK: - Setup
    
    /// Setup with default values
    ///
    /// Call this early in app lifecycle to set fallback values
    ///
    /// - Parameter defaults: Dictionary of default values
    public func setupDefaults(_ defaults: [String: Any]) {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, skipping defaults")
            return
        }
        
        setDefaults(defaults)
        logDebug("[RemoteConfig] Defaults set: \(defaults.count) keys")
    }
    
    /// Setup with default values from plist
    ///
    /// - Parameter plistName: Name of plist file (without extension)
    public func setupDefaultsFromPlist(_ plistName: String) {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, skipping defaults")
            return
        }
        
        setDefaultsFromPlist(plistName)
        logDebug("[RemoteConfig] Defaults loaded from plist: \(plistName)")
    }
    
    // MARK: - Fetch & Activate
    
    /// Fetch and activate remote config (async/await)
    ///
    /// This is the recommended method - fetches latest values and activates them
    ///
    /// - Returns: RemoteConfigFetchAndActivateStatus
    /// - Throws: FirebaseError if fetch fails
    @discardableResult
    public func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            throw FirebaseError.serviceNotEnabled("RemoteConfig")
        }
        
        logDebug("[RemoteConfig] Fetching and activating...")
        
        let status = try await remoteConfig.fetchAndActivate()
        
        switch status {
        case .successFetchedFromRemote:
            logDebug("[RemoteConfig] ✅ Fetched from remote and activated")
        case .successUsingPreFetchedData:
            logDebug("[RemoteConfig] ✅ Using pre-fetched data")
        case .error:
            throw FirebaseError.configurationFailed(
                NSError(
                    domain: "RemoteConfig",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch and activate"]
                )
            )
        @unknown default:
            logDebug("[RemoteConfig] ⚠️ Unknown status: \(status)")
        }
        
        return status
    }
    
    /// Fetch remote config without activating
    ///
    /// Use this when you want to fetch in background and activate later
    ///
    /// - Throws: FirebaseError if fetch fails
    public func fetch() async throws {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            throw FirebaseError.serviceNotEnabled("RemoteConfig")
        }
        
        logDebug("[RemoteConfig] Fetching...")
        
        try await remoteConfig.fetch()
        logDebug("[RemoteConfig] ✅ Fetch completed")
    }
    
    /// Fetch with custom expiration
    ///
    /// - Parameter expirationDuration: Cache expiration in seconds
    /// - Throws: FirebaseError if fetch fails
    public func fetch(withExpirationDuration expirationDuration: TimeInterval) async throws {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            throw FirebaseError.serviceNotEnabled("RemoteConfig")
        }
        
        logDebug("[RemoteConfig] Fetching with expiration: \(expirationDuration)s")
        
        try await remoteConfig.fetch(withExpirationDuration: expirationDuration)
        logDebug("[RemoteConfig] ✅ Fetch completed")
    }
    
    /// Activate fetched configs
    ///
    /// Apply previously fetched configs
    ///
    /// - Returns: True if new configs were activated
    /// - Throws: FirebaseError if activate fails
    @discardableResult
    public func activate() async throws -> Bool {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            throw FirebaseError.serviceNotEnabled("RemoteConfig")
        }
        
        logDebug("[RemoteConfig] Activating...")
        
        let activated = try await remoteConfig.activate()
        
        if activated {
            logDebug("[RemoteConfig] ✅ New configs activated")
        } else {
            logDebug("[RemoteConfig] ℹ️ No new configs to activate")
        }
        
        return activated
    }
    
    // MARK: - Value Getters (Type-Safe with RemoteConfigKey)
    
    /// Get string value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: String value or empty string if not found
    public func getString(_ key: RemoteConfigKey) -> String {
        getString(key.rawValue)
    }
    
    /// Get string value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: String value or empty string if not found
    public func getString(_ key: String) -> String {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning empty string for: \(key)")
            return ""
        }
        
        let value = remoteConfig.configValue(forKey: key).stringValue ?? ""
        logDebug("[RemoteConfig] getString(\(key)) = \(value)")
        return value
    }
    
    /// Get bool value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: Bool value or false if not found
    public func getBool(_ key: RemoteConfigKey) -> Bool {
        getBool(key.rawValue)
    }
    
    /// Get bool value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: Bool value or false if not found
    public func getBool(_ key: String) -> Bool {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning false for: \(key)")
            return false
        }
        
        let value = remoteConfig.configValue(forKey: key).boolValue
        logDebug("[RemoteConfig] getBool(\(key)) = \(value)")
        return value
    }
    
    /// Get number value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: NSNumber value or 0 if not found
    public func getNumber(_ key: RemoteConfigKey) -> NSNumber {
        getNumber(key.rawValue)
    }
    
    /// Get number value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: NSNumber value or 0 if not found
    public func getNumber(_ key: String) -> NSNumber {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning 0 for: \(key)")
            return 0
        }
        
        let value = remoteConfig.configValue(forKey: key).numberValue
        logDebug("[RemoteConfig] getNumber(\(key)) = \(value)")
        return value
    }
    
    /// Get int value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: Int value or 0 if not found
    public func getInt(_ key: RemoteConfigKey) -> Int {
        getInt(key.rawValue)
    }
    
    /// Get int value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: Int value or 0 if not found
    public func getInt(_ key: String) -> Int {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning 0 for: \(key)")
            return 0
        }
        
        let value = remoteConfig.configValue(forKey: key).numberValue.intValue
        logDebug("[RemoteConfig] getInt(\(key)) = \(value)")
        return value
    }
    
    /// Get double value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: Double value or 0.0 if not found
    public func getDouble(_ key: RemoteConfigKey) -> Double {
        getDouble(key.rawValue)
    }
    
    /// Get double value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: Double value or 0.0 if not found
    public func getDouble(_ key: String) -> Double {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning 0.0 for: \(key)")
            return 0.0
        }
        
        let value = remoteConfig.configValue(forKey: key).numberValue.doubleValue
        logDebug("[RemoteConfig] getDouble(\(key)) = \(value)")
        return value
    }
    
    /// Get data value using type-safe key
    ///
    /// - Parameter key: Remote config key
    /// - Returns: Data value or empty Data if not found
    public func getData(_ key: RemoteConfigKey) -> Data {
        getData(key.rawValue)
    }
    
    /// Get data value using string key
    ///
    /// - Parameter key: Key name
    /// - Returns: Data value or empty Data if not found
    public func getData(_ key: String) -> Data {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning empty data for: \(key)")
            return Data()
        }
        
        let value = remoteConfig.configValue(forKey: key).dataValue
        logDebug("[RemoteConfig] getData(\(key)) = \(value.count) bytes")
        return value
    }
    
    // MARK: - JSON Decoding
    
    /// Get JSON value decoded to Decodable type using type-safe key
    ///
    /// - Parameters:
    ///   - key: Remote config key
    ///   - type: Type to decode to
    /// - Returns: Decoded value or nil if decode fails
    public func getJSON<T: Decodable>(_ key: RemoteConfigKey, as type: T.Type) -> T? {
        getJSON(key.rawValue, as: type)
    }
    
    /// Get JSON value decoded to Decodable type using string key
    ///
    /// - Parameters:
    ///   - key: Key name
    ///   - type: Type to decode to
    /// - Returns: Decoded value or nil if decode fails
    public func getJSON<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else {
            logDebug("[RemoteConfig] Service not enabled, returning nil for: \(key)")
            return nil
        }
        
        let jsonString = getString(key)
        guard !jsonString.isEmpty else {
            logDebug("[RemoteConfig] Empty JSON string for: \(key)")
            return nil
        }
        
        guard let data = jsonString.data(using: .utf8) else {
            logDebug("[RemoteConfig] Failed to convert JSON string to data for: \(key)")
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            logDebug("[RemoteConfig] ✅ JSON decoded for: \(key)")
            return decoded
        } catch {
            logDebug("[RemoteConfig] ❌ JSON decode failed for: \(key) - \(error)")
            return nil
        }
    }
    
    // MARK: - Default Values
    
    /// Set default values
    ///
    /// - Parameter defaults: Dictionary of default values
    public func setDefaults(_ defaults: [String: Any]) {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else { return }
        remoteConfig.setDefaults(defaults as? [String: NSObject])
    }
    
    /// Set default values from plist
    ///
    /// - Parameter plistName: Name of plist file (without extension)
    public func setDefaultsFromPlist(_ plistName: String) {
        guard firebaseManager.isServiceEnabled(.remoteConfig) else { return }
        remoteConfig.setDefaults(fromPlist: plistName)
    }
    
    // MARK: - Status
    
    /// Get last fetch time
    public var lastFetchTime: Date? {
        return remoteConfig.lastFetchTime
    }
    
    /// Get last fetch status
    public var lastFetchStatus: RemoteConfigFetchStatus {
        return remoteConfig.lastFetchStatus
    }
    
    /// Check if configs are fresh (fetched recently)
    ///
    /// - Parameter maxAge: Maximum age in seconds (default: 1 hour)
    /// - Returns: True if configs are fresh
    public func isConfigFresh(maxAge: TimeInterval = 3600) -> Bool {
        guard let lastFetchTime = lastFetchTime else { return false }
        return Date().timeIntervalSince(lastFetchTime) < maxAge
    }
    
    // MARK: - All Values
    
    /// Get all config keys
    public var allKeys: Set<String> {
        return remoteConfig.allKeys(from: .remote)
    }
    
    // MARK: - Helpers
    
    private func logDebug(_ message: String) {
        if firebaseManager.config?.isDebugMode == true {
            print(message)
        }
    }
}

// MARK: - Type-Safe Config Keys

/// Type-safe remote config keys
///
/// Use predefined keys or create custom ones:
/// ```swift
/// // Predefined
/// let url = remoteConfig.getString(.apiBaseURL)
///
/// // Custom
/// extension RemoteConfigKey {
///     static let customKey: RemoteConfigKey = "my_custom_key"
/// }
/// let value = remoteConfig.getString(.customKey)
/// ```
public struct RemoteConfigKey: RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

// MARK: - Common Config Keys

public extension RemoteConfigKey {
    // MARK: - Feature Flags
    
    /// Enable biometric authentication
    static let enableBiometrics: RemoteConfigKey = "enable_biometrics"
    
    /// Enable dark mode
    static let enableDarkMode: RemoteConfigKey = "enable_dark_mode"
    
    /// Maintenance mode flag
    static let maintenanceMode: RemoteConfigKey = "maintenance_mode"
    
    /// Enable new feature
    static let enableNewFeature: RemoteConfigKey = "enable_new_feature"
    
    // MARK: - API Configuration
    
    /// API base URL
    static let apiBaseURL: RemoteConfigKey = "api_base_url"
    
    /// API timeout in seconds
    static let apiTimeout: RemoteConfigKey = "api_timeout"
    
    /// API version
    static let apiVersion: RemoteConfigKey = "api_version"
    
    // MARK: - UI Configuration
    
    /// Primary color hex
    static let primaryColor: RemoteConfigKey = "primary_color"
    
    /// Show banner flag
    static let showBanner: RemoteConfigKey = "show_banner"
    
    /// Banner message
    static let bannerMessage: RemoteConfigKey = "banner_message"
    
    /// Banner action URL
    static let bannerActionURL: RemoteConfigKey = "banner_action_url"
    
    // MARK: - Business Configuration
    
    /// Minimum app version required
    static let minAppVersion: RemoteConfigKey = "min_app_version"
    
    /// Force update flag
    static let forceUpdate: RemoteConfigKey = "force_update"
    
    /// Update message
    static let updateMessage: RemoteConfigKey = "update_message"
    
    /// Support email
    static let supportEmail: RemoteConfigKey = "support_email"
    
    /// Support phone
    static let supportPhone: RemoteConfigKey = "support_phone"
    
    // MARK: - Feature Configuration
    
    /// Maximum file upload size in MB
    static let maxUploadSizeMB: RemoteConfigKey = "max_upload_size_mb"
    
    /// Enable analytics
    static let enableAnalytics: RemoteConfigKey = "enable_analytics"
    
    /// Enable push notifications
    static let enablePushNotifications: RemoteConfigKey = "enable_push_notifications"
    
    // MARK: - Content
    
    /// Welcome message
    static let welcomeMessage: RemoteConfigKey = "welcome_message"
    
    /// Terms of service URL
    static let termsURL: RemoteConfigKey = "terms_url"
    
    /// Privacy policy URL
    static let privacyURL: RemoteConfigKey = "privacy_url"
}

// MARK: - Convenience Methods

public extension RemoteConfigService {
    /// Quick check if feature is enabled
    ///
    /// - Parameter key: Feature flag key
    /// - Returns: True if enabled
    func isFeatureEnabled(_ key: RemoteConfigKey) -> Bool {
        return getBool(key)
    }
    
    /// Get URL from string config
    ///
    /// - Parameter key: Config key
    /// - Returns: URL or nil if invalid
    func getURL(_ key: RemoteConfigKey) -> URL? {
        let urlString = getString(key)
        return URL(string: urlString)
    }
    
    /// Get color from hex string
    ///
    /// - Parameter key: Config key
    /// - Returns: UIColor or nil if invalid hex
    func getColor(_ key: RemoteConfigKey) -> UIColor? {
        let hex = getString(key)
        return UIColor(hexString: hex)
    }
}

// MARK: - UIColor Hex Extension

extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        
        var color: UInt64 = 0
        guard scanner.scanHexInt64(&color) else { return nil }
        
        let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(color & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
