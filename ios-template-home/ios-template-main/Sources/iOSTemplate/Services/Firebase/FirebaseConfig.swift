import Foundation

/// Configuration cho Firebase services
///
/// **Pattern: Parameterized Component**
///
/// Config này cho phép customize Firebase initialization cho từng app.
/// Mỗi app có thể có Firebase project riêng và config riêng.
///
/// ## Usage:
/// ```swift
/// // Banking App
/// let bankingConfig = FirebaseConfig(
///     plistName: "GoogleService-Info-Banking",
///     isAnalyticsEnabled: true,
///     isCrashlyticsEnabled: true
/// )
/// FirebaseManager.shared.configure(with: bankingConfig)
///
/// // Fitness App
/// let fitnessConfig = FirebaseConfig(
///     plistName: "GoogleService-Info-Fitness",
///     isAnalyticsEnabled: true,
///     isCrashlyticsEnabled: false  // Không dùng Crashlytics
/// )
/// FirebaseManager.shared.configure(with: fitnessConfig)
/// ```
///
public struct FirebaseConfig {
    // MARK: - Configuration Properties

    /// Tên file GoogleService-Info.plist
    /// Cho phép mỗi app có Firebase project riêng
    public let plistName: String

    /// Enable/disable Analytics
    public let isAnalyticsEnabled: Bool

    /// Enable/disable Crashlytics
    public let isCrashlyticsEnabled: Bool

    /// Enable/disable Messaging (Push Notifications)
    public let isMessagingEnabled: Bool

    /// Enable/disable Remote Config
    public let isRemoteConfigEnabled: Bool

    /// Enable/disable Performance Monitoring
    public let isPerformanceEnabled: Bool

    /// Analytics log level
    public let analyticsLogLevel: AnalyticsLogLevel

    /// Remote Config fetch timeout (seconds)
    public let remoteConfigFetchTimeout: TimeInterval

    /// Remote Config cache expiration (seconds)
    public let remoteConfigCacheExpiration: TimeInterval

    /// Enable debug mode
    public let isDebugMode: Bool

    // MARK: - Initialization

    /// Khởi tạo FirebaseConfig với đầy đủ customization
    ///
    /// - Parameters:
    ///   - plistName: Tên file GoogleService-Info.plist (không cần extension)
    ///   - isAnalyticsEnabled: Enable Analytics (default: true)
    ///   - isCrashlyticsEnabled: Enable Crashlytics (default: true)
    ///   - isMessagingEnabled: Enable FCM (default: true)
    ///   - isRemoteConfigEnabled: Enable Remote Config (default: true)
    ///   - isPerformanceEnabled: Enable Performance Monitoring (default: true)
    ///   - analyticsLogLevel: Log level cho Analytics
    ///   - remoteConfigFetchTimeout: Timeout cho fetch remote config (seconds, > 0)
    ///   - remoteConfigCacheExpiration: Cache expiration cho remote config (seconds, >= 0)
    ///   - isDebugMode: Enable debug mode
    public init(
        plistName: String = "GoogleService-Info",
        isAnalyticsEnabled: Bool = true,
        isCrashlyticsEnabled: Bool = true,
        isMessagingEnabled: Bool = true,
        isRemoteConfigEnabled: Bool = true,
        isPerformanceEnabled: Bool = true,
        analyticsLogLevel: AnalyticsLogLevel = .info,
        remoteConfigFetchTimeout: TimeInterval = 60,
        remoteConfigCacheExpiration: TimeInterval = 3600, // 1 hour
        isDebugMode: Bool = false
    ) {
        self.plistName = plistName
        self.isAnalyticsEnabled = isAnalyticsEnabled
        self.isCrashlyticsEnabled = isCrashlyticsEnabled
        self.isMessagingEnabled = isMessagingEnabled
        self.isRemoteConfigEnabled = isRemoteConfigEnabled
        self.isPerformanceEnabled = isPerformanceEnabled
        self.analyticsLogLevel = analyticsLogLevel
        // Validate timeout values
        self.remoteConfigFetchTimeout = max(1, remoteConfigFetchTimeout) // Minimum 1 second
        self.remoteConfigCacheExpiration = max(0, remoteConfigCacheExpiration) // >= 0
        self.isDebugMode = isDebugMode
    }
}

// MARK: - Analytics Log Level

/// Log level cho Analytics
///
/// **Note**: Đây là log level cho FirebaseManager's internal logging,
/// không phải Firebase Analytics SDK logging level.
/// Firebase Analytics SDK không expose public API để set log level.
///
/// - verbose/debug: Enable analytics collection với verbose logging
/// - info/warning/error: Enable analytics collection
/// - none: Disable analytics collection
public enum AnalyticsLogLevel {
    case verbose
    case debug
    case info
    case warning
    case error
    case none
}

// MARK: - Default Configs

public extension FirebaseConfig {
    /// Default config cho template - Enable tất cả features
    static var `default`: FirebaseConfig {
        FirebaseConfig()
    }

    /// Production config - Tối ưu cho production
    static var production: FirebaseConfig {
        FirebaseConfig(
            analyticsLogLevel: .error,
            remoteConfigCacheExpiration: 43200, // 12 hours
            isDebugMode: false
        )
    }

    /// Development config - Tối ưu cho development
    static var development: FirebaseConfig {
        FirebaseConfig(
            analyticsLogLevel: .verbose,
            remoteConfigCacheExpiration: 0, // No cache in dev
            isDebugMode: true
        )
    }

    /// Minimal config - Chỉ Analytics
    static var minimal: FirebaseConfig {
        FirebaseConfig(
            isAnalyticsEnabled: true,
            isCrashlyticsEnabled: false,
            isMessagingEnabled: false,
            isRemoteConfigEnabled: false,
            isPerformanceEnabled: false
        )
    }
}

// MARK: - Environment Detection

public extension FirebaseConfig {
    /// Tự động detect environment và return config phù hợp
    static var auto: FirebaseConfig {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
