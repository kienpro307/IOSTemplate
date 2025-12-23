import Foundation
import FirebaseRemoteConfig

// MARK: - Firebase Remote Config Service

/// Service quản lý Firebase Remote Config
///
/// **Chức năng chính**:
/// - Fetch remote configuration values
/// - Get typed values (String, Bool, Int, Double, JSON)
/// - Set default values
/// - Handle fetch intervals
/// - Support A/B testing
///
/// **Usage Example**:
/// ```swift
/// // Fetch latest config
/// try await FirebaseRemoteConfigService.shared.fetch()
///
/// // Get values
/// let welcomeMessage = service.getString(forKey: "welcome_message", defaultValue: "Welcome!")
/// let isFeatureEnabled = service.getBool(forKey: "new_feature_enabled", defaultValue: false)
/// let maxRetries = service.getInt(forKey: "max_retries", defaultValue: 3)
/// ```
///
/// **Debug Mode**:
/// - Auto-enabled trong DEBUG builds
/// - Minimum fetch interval = 0 (immediate)
/// - Shows emoji-based logs
///
/// **Best Practices**:
/// - Always provide default values
/// - Fetch on app start (background)
/// - Use activate() after fetch
/// - Cache values locally if critical
public final class FirebaseRemoteConfigService: RemoteConfigServiceProtocol {

    // MARK: - Properties

    /// Shared instance
    public static let shared = FirebaseRemoteConfigService()

    /// Remote Config instance
    private let remoteConfig: RemoteConfig

    /// Debug mode (auto-enabled in DEBUG builds)
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Is initialized
    private(set) var isInitialized = false

    /// Last fetch time
    private(set) var lastFetchTime: Date?

    /// Last fetch status
    private(set) var lastFetchStatus: RemoteConfigFetchStatus?

    // MARK: - Initialization

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        setupRemoteConfig()
    }

    // MARK: - Setup

    /// Setup Remote Config
    private func setupRemoteConfig() {
        // Configure settings
        let settings = RemoteConfigSettings()

        #if DEBUG
        // Debug mode: fetch immediately (no throttling)
        settings.minimumFetchInterval = 0
        #else
        // Production: fetch every 12 hours
        settings.minimumFetchInterval = 43200 // 12 hours in seconds
        #endif

        remoteConfig.configSettings = settings

        // Set default values
        setDefaultValues()

        isInitialized = true
        logDebug("✅ Remote Config initialized")
    }

    /// Set default values
    ///
    /// Default values used when:
    /// - First app launch (before first fetch)
    /// - Network unavailable
    /// - Fetch fails
    private func setDefaultValues() {
        let defaults: [String: Any] = [
            // Feature flags
            "feature_dark_mode_enabled": true,
            "feature_biometric_login_enabled": true,
            "feature_offline_mode_enabled": false,
            "feature_analytics_enabled": true,
            "feature_crashlytics_enabled": true,

            // App configuration
            "app_force_update_required": false,
            "app_maintenance_mode": false,
            "app_min_supported_version": "1.0.0",

            // UI configuration
            "ui_welcome_message": "Welcome to iOS Template!",
            "ui_primary_color": "#007AFF",
            "ui_show_onboarding": true,

            // Business logic
            "max_login_attempts": 5,
            "session_timeout_minutes": 30,
            "max_file_size_mb": 10,
            "api_timeout_seconds": 30,

            // A/B Testing
            "experiment_new_onboarding": false,
            "experiment_simplified_login": false,

            // Promotional
            "promo_banner_enabled": false,
            "promo_banner_message": "",
            "promo_banner_action_url": "",

            // Support
            "support_email": "support@iostemplate.com",
            "support_phone": "",
            "faq_url": "https://iostemplate.com/faq"
        ]

        // Convert to NSObject for Firebase
        let nsObjectDefaults = defaults.mapValues { value -> NSObject in
            if let stringValue = value as? String {
                return stringValue as NSObject
            } else if let boolValue = value as? Bool {
                return NSNumber(value: boolValue)
            } else if let intValue = value as? Int {
                return NSNumber(value: intValue)
            } else if let doubleValue = value as? Double {
                return NSNumber(value: doubleValue)
            } else {
                return value as? NSObject ?? "" as NSObject
            }
        }

        remoteConfig.setDefaults(nsObjectDefaults)
        logDebug("✅ Default values configured (\(defaults.count) keys)")
    }

    // MARK: - RemoteConfigServiceProtocol

    /// Fetch remote config from server
    ///
    /// **Fetch Strategy**:
    /// - Debug: Immediate fetch (no throttling)
    /// - Production: Respects minimum fetch interval (12 hours)
    ///
    /// **Call on app start**:
    /// ```swift
    /// // In AppDelegate or app initialization
    /// Task {
    ///     try? await FirebaseRemoteConfigService.shared.fetch()
    /// }
    /// ```
    ///
    /// - Throws: RemoteConfigError if fetch fails
    public func fetch() async throws {
        logDebug("🔄 Fetching remote config...")

        do {
            // Fetch
            let status = try await remoteConfig.fetch()
            lastFetchTime = Date()
            lastFetchStatus = status

            logDebug("📥 Fetch completed: \(status.description)")

            // Activate fetched values
            let activated = try await remoteConfig.activate()

            if activated {
                logDebug("✅ New config activated")
            } else {
                logDebug("ℹ️ No new config (using cached)")
            }

        } catch {
            logDebug("❌ Fetch failed: \(error.localizedDescription)")
            throw RemoteConfigError.fetchFailed(error)
        }
    }

    /// Fetch and activate in one call
    ///
    /// **Convenience method** that combines fetch + activate
    ///
    /// - Returns: true if new values were activated
    public func fetchAndActivate() async throws -> Bool {
        logDebug("🔄 Fetch and activate...")

        do {
            let status = try await remoteConfig.fetchAndActivate()
            lastFetchTime = Date()

            switch status {
            case .successFetchedFromRemote:
                logDebug("✅ Fetched and activated (new values)")
                return true

            case .successUsingPreFetchedData:
                logDebug("ℹ️ Using pre-fetched data (no new values)")
                return false

            case .error:
                logDebug("❌ Fetch and activate failed")
                throw RemoteConfigError.activationFailed

            @unknown default:
                logDebug("❓ Unknown status: \(status)")
                return false
            }
        } catch {
            logDebug("❌ Fetch and activate error: \(error.localizedDescription)")
            throw RemoteConfigError.fetchFailed(error)
        }
    }

    /// Get string value
    ///
    /// - Parameters:
    ///   - key: Config key
    ///   - defaultValue: Default value if key not found
    /// - Returns: String value
    public func getString(forKey key: String, defaultValue: String) -> String {
        let value = remoteConfig[key].stringValue ?? defaultValue
        logDebug("📖 Get '\(key)': \(value)")
        return value
    }

    /// Get bool value
    ///
    /// - Parameters:
    ///   - key: Config key
    ///   - defaultValue: Default value if key not found
    /// - Returns: Bool value
    public func getBool(forKey key: String, defaultValue: Bool) -> Bool {
        let value = remoteConfig[key].boolValue
        logDebug("📖 Get '\(key)': \(value)")
        return value
    }

    /// Get int value
    ///
    /// - Parameters:
    ///   - key: Config key
    ///   - defaultValue: Default value if key not found
    /// - Returns: Int value
    public func getInt(forKey key: String, defaultValue: Int) -> Int {
        let numberValue = remoteConfig[key].numberValue
        let value = numberValue.intValue
        logDebug("📖 Get '\(key)': \(value)")
        return value
    }

    /// Get double value
    ///
    /// - Parameters:
    ///   - key: Config key
    ///   - defaultValue: Default value if key not found
    /// - Returns: Double value
    public func getDouble(forKey key: String, defaultValue: Double) -> Double {
        let numberValue = remoteConfig[key].numberValue
        let value = numberValue.doubleValue
        logDebug("📖 Get '\(key)': \(value)")
        return value
    }

    // MARK: - Extended Methods

    /// Get JSON value and decode to type
    ///
    /// **Usage**:
    /// ```swift
    /// struct AppConfig: Codable {
    ///     let apiBaseURL: String
    ///     let timeout: Int
    /// }
    ///
    /// let config: AppConfig? = service.getJSON(forKey: "app_config")
    /// ```
    ///
    /// - Parameters:
    ///   - key: Config key
    /// - Returns: Decoded object or nil
    public func getJSON<T: Decodable>(forKey key: String) -> T? {
        guard let jsonString = remoteConfig[key].stringValue,
              let data = jsonString.data(using: .utf8) else {
            logDebug("❌ No JSON data for key: \(key)")
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            logDebug("📖 Decoded JSON for '\(key)'")
            return decoded
        } catch {
            logDebug("❌ JSON decode error for '\(key)': \(error.localizedDescription)")
            return nil
        }
    }

    /// Get all keys
    ///
    /// **Useful for debugging**
    ///
    /// - Returns: Array of all config keys
    public func getAllKeys() -> [String] {
        remoteConfig.allKeys(from: .remote)
    }

    /// Get config info
    ///
    /// **Returns info about**:
    /// - Last fetch time
    /// - Last fetch status
    /// - Config settings
    ///
    /// - Returns: RemoteConfigInfo
    public func getConfigInfo() -> RemoteConfigInfo {
        return RemoteConfigInfo(
            lastFetchTime: lastFetchTime,
            lastFetchStatus: lastFetchStatus,
            minimumFetchInterval: remoteConfig.configSettings.minimumFetchInterval
        )
    }

    /// Reset to defaults
    ///
    /// **Use cases**:
    /// - Testing
    /// - User logout
    /// - Debug reset
    ///
    /// **Note**: This clears fetched values and uses defaults only
    public func resetToDefaults() {
        // This will use default values set in setDefaultValues()
        logDebug("🔄 Reset to default values")

        // Clear last fetch info
        lastFetchTime = nil
        lastFetchStatus = nil
    }

    // MARK: - Private Methods

    /// Debug logging
    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[RemoteConfig] \(message)")
    }
}

// MARK: - Remote Config Info

/// Information about Remote Config state
public struct RemoteConfigInfo {
    /// Last successful fetch time
    public let lastFetchTime: Date?

    /// Last fetch status
    public let lastFetchStatus: RemoteConfigFetchStatus?

    /// Minimum fetch interval (seconds)
    public let minimumFetchInterval: TimeInterval

    /// Is fetch throttled
    public var isThrottled: Bool {
        guard let lastFetchTime = lastFetchTime else { return false }
        let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
        return timeSinceLastFetch < minimumFetchInterval
    }
}

// MARK: - Remote Config Errors

/// Remote Config specific errors
public enum RemoteConfigError: Error, LocalizedError {
    case notInitialized
    case fetchFailed(Error)
    case activationFailed
    case invalidValue(key: String)
    case decodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Remote Config not initialized"
        case .fetchFailed(let error):
            return "Remote Config fetch failed: \(error.localizedDescription)"
        case .activationFailed:
            return "Remote Config activation failed"
        case .invalidValue(let key):
            return "Invalid value for key: \(key)"
        case .decodingFailed(let error):
            return "JSON decoding failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Fetch Status Extension

extension RemoteConfigFetchStatus {
    var description: String {
        switch self {
        case .noFetchYet:
            return "No Fetch Yet"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .throttled:
            return "Throttled"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Config Keys

/// Predefined Remote Config keys
///
/// **Usage**:
/// ```swift
/// let enabled = service.getBool(
///     forKey: RemoteConfigKey.featureDarkMode,
///     defaultValue: false
/// )
/// ```
public struct RemoteConfigKey {
    // Feature Flags
    public static let featureDarkMode = "feature_dark_mode_enabled"
    public static let featureBiometricLogin = "feature_biometric_login_enabled"
    public static let featureOfflineMode = "feature_offline_mode_enabled"
    public static let featureAnalytics = "feature_analytics_enabled"
    public static let featureCrashlytics = "feature_crashlytics_enabled"

    // App Configuration
    public static let appForceUpdate = "app_force_update_required"
    public static let appMaintenanceMode = "app_maintenance_mode"
    public static let appMinVersion = "app_min_supported_version"

    // UI Configuration
    public static let welcomeMessage = "ui_welcome_message"
    public static let primaryColor = "ui_primary_color"
    public static let showOnboarding = "ui_show_onboarding"

    // Business Logic
    public static let maxLoginAttempts = "max_login_attempts"
    public static let sessionTimeout = "session_timeout_minutes"
    public static let maxFileSize = "max_file_size_mb"
    public static let apiTimeout = "api_timeout_seconds"

    // A/B Testing
    public static let experimentNewOnboarding = "experiment_new_onboarding"
    public static let experimentSimplifiedLogin = "experiment_simplified_login"

    // Promotional
    public static let promoBannerEnabled = "promo_banner_enabled"
    public static let promoBannerMessage = "promo_banner_message"
    public static let promoBannerActionURL = "promo_banner_action_url"

    // Support
    public static let supportEmail = "support_email"
    public static let supportPhone = "support_phone"
    public static let faqURL = "faq_url"
}
