import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseRemoteConfig
import FirebasePerformance

/// Firebase Manager - Quản lý Firebase initialization và configuration
///
/// **Pattern: Singleton + Parameterized Configuration**
///
/// Manager này handle việc initialize Firebase với custom config.
/// Mỗi app có thể customize Firebase features qua FirebaseConfig.
///
/// ## Usage:
/// ```swift
/// // App initialization
/// let config = FirebaseConfig.auto  // Auto detect environment
/// try FirebaseManager.shared.configure(with: config)
///
/// // Check if configured
/// if FirebaseManager.shared.isConfigured {
///     // Firebase ready
/// }
/// ```
///
public final class FirebaseManager {
    // MARK: - Singleton

    public static let shared = FirebaseManager()

    // MARK: - Properties

    /// Current configuration
    private(set) var config: FirebaseConfig?

    /// Configuration status
    public private(set) var isConfigured: Bool = false

    /// Initialization error nếu có
    public private(set) var initializationError: Error?

    // MARK: - Initialization

    private init() {}

    // MARK: - Configuration

    /// Configure Firebase với custom config
    ///
    /// - Parameter config: FirebaseConfig để customize Firebase
    /// - Throws: FirebaseError nếu configuration fails
    ///
    /// **Note**: Method này nên được gọi trong AppDelegate hoặc App init,
    /// trước khi sử dụng bất kỳ Firebase service nào.
    ///
    /// **Thread Safety**: Method này thread-safe, có thể gọi từ bất kỳ thread nào.
    /// Chỉ configuration đầu tiên sẽ được apply, các lần sau sẽ bị ignore.
    public func configure(with config: FirebaseConfig) throws {
        // Thread-safe check và set
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        // Prevent double configuration
        guard !isConfigured else {
            logWarning("Firebase already configured. Skipping...")
            return
        }

        self.config = config

        do {
            // Configure Firebase Core
            try configureFirebaseCore(plistName: config.plistName)

            // Configure individual services based on config
            if config.isAnalyticsEnabled {
                configureAnalytics(logLevel: config.analyticsLogLevel)
            }

            if config.isCrashlyticsEnabled {
                configureCrashlytics()
            }

            if config.isMessagingEnabled {
                configureMessaging()
            }

            if config.isRemoteConfigEnabled {
                configureRemoteConfig(
                    fetchTimeout: config.remoteConfigFetchTimeout,
                    cacheExpiration: config.remoteConfigCacheExpiration
                )
            }

            if config.isPerformanceEnabled {
                configurePerformance()
            }

            isConfigured = true
            logInfo("✅ Firebase configured successfully with config: \(config.plistName)")

        } catch {
            initializationError = error
            logError("❌ Firebase configuration failed: \(error.localizedDescription)")
            throw FirebaseError.configurationFailed(error)
        }
    }

    // MARK: - Private Configuration Methods

    private func configureFirebaseCore(plistName: String) throws {
        // Check if plist exists first
        guard Bundle.main.path(forResource: plistName, ofType: "plist") != nil else {
            throw FirebaseError.plistNotFound(plistName)
        }

        // Configure with custom plist if not default
        if plistName != "GoogleService-Info" {
            guard let filePath = Bundle.main.path(forResource: plistName, ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: filePath) else {
                throw FirebaseError.invalidPlist(plistName)
            }
            FirebaseApp.configure(options: options)
        } else {
            // Use default configuration
            FirebaseApp.configure()
        }

        logInfo("Firebase Core configured")
    }

    private func configureAnalytics(logLevel: AnalyticsLogLevel) {
        // Set analytics log level
        switch logLevel {
        case .verbose, .debug:
            Analytics.setAnalyticsCollectionEnabled(true)
        case .none:
            Analytics.setAnalyticsCollectionEnabled(false)
        default:
            Analytics.setAnalyticsCollectionEnabled(true)
        }

        logInfo("Firebase Analytics configured with log level: \(logLevel)")
    }

    private func configureCrashlytics() {
        // Crashlytics tự động enable khi có trong app
        // Có thể set custom keys, user identifier sau
        logInfo("Firebase Crashlytics configured")
    }

    private func configureMessaging() {
        // Messaging configuration sẽ được handle bởi PushNotificationService
        // Đây chỉ là setup cơ bản
        logInfo("Firebase Messaging configured")
    }

    private func configureRemoteConfig(fetchTimeout: TimeInterval, cacheExpiration: TimeInterval) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = cacheExpiration

        remoteConfig.configSettings = settings

        logInfo("Firebase Remote Config configured (cache: \(cacheExpiration)s)")
    }

    private func configurePerformance() {
        // Performance Monitoring tự động enable
        // Có thể add custom traces sau
        logInfo("Firebase Performance Monitoring configured")
    }

    // MARK: - Helpers

    private func logInfo(_ message: String) {
        if config?.isDebugMode == true {
            print("[FirebaseManager] ℹ️ \(message)")
        }
    }

    private func logWarning(_ message: String) {
        if config?.isDebugMode == true {
            print("[FirebaseManager] ⚠️ \(message)")
        }
    }

    private func logError(_ message: String) {
        print("[FirebaseManager] ❌ \(message)")
    }
}

// MARK: - Firebase Errors

/// Errors liên quan đến Firebase configuration
public enum FirebaseError: Error, LocalizedError {
    case notConfigured
    case configurationFailed(Error)
    case plistNotFound(String)
    case invalidPlist(String)
    case serviceNotEnabled(String)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Firebase has not been configured. Call FirebaseManager.shared.configure() first."
        case .configurationFailed(let error):
            return "Firebase configuration failed: \(error.localizedDescription)"
        case .plistNotFound(let name):
            return "GoogleService-Info plist not found: \(name).plist"
        case .invalidPlist(let name):
            return "Invalid GoogleService-Info plist: \(name).plist"
        case .serviceNotEnabled(let service):
            return "Firebase service not enabled in config: \(service)"
        }
    }
}

// MARK: - Public Helpers

public extension FirebaseManager {
    /// Check nếu specific service đã enabled
    func isServiceEnabled(_ service: FirebaseService) -> Bool {
        guard let config = config else { return false }

        switch service {
        case .analytics:
            return config.isAnalyticsEnabled
        case .crashlytics:
            return config.isCrashlyticsEnabled
        case .messaging:
            return config.isMessagingEnabled
        case .remoteConfig:
            return config.isRemoteConfigEnabled
        case .performance:
            return config.isPerformanceEnabled
        }
    }
}

/// Firebase services có thể enable/disable
public enum FirebaseService {
    case analytics
    case crashlytics
    case messaging
    case remoteConfig
    case performance
}

