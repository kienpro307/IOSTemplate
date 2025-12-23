import Foundation

// MARK: - Feature Flag Manager

/// Feature Flag Manager - Quản lý feature flags
///
/// **Chức năng**:
/// - Check if features are enabled/disabled
/// - Support A/B testing
/// - Local override for development
/// - Type-safe feature flag API
///
/// **Usage Example**:
/// ```swift
/// // Check if feature is enabled
/// if FeatureFlagManager.shared.isEnabled(.darkMode) {
///     enableDarkMode()
/// }
///
/// // Get feature configuration
/// let config = FeatureFlagManager.shared.getConfig(for: .newOnboarding)
///
/// // Override for testing
/// FeatureFlagManager.shared.override(.biometricLogin, enabled: true)
/// ```
///
/// **Best Practices**:
/// - Always check features at runtime (not compile-time)
/// - Provide fallback behavior when feature disabled
/// - Use descriptive feature names
/// - Document feature purpose
public final class FeatureFlagManager {

    // MARK: - Properties

    /// Shared instance
    public static let shared = FeatureFlagManager()

    /// Remote config service
    private var remoteConfig: RemoteConfigServiceProtocol?

    /// Local overrides (for development/testing)
    private var overrides: [FeatureFlag: Bool] = [:]

    /// Debug mode
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    // MARK: - Initialization

    private init() {
        // Get remote config from DI
        remoteConfig = DIContainer.shared.remoteConfigService
    }

    // MARK: - Public Methods

    /// Check if feature is enabled
    ///
    /// **Priority**:
    /// 1. Local override (if set)
    /// 2. Remote config value
    /// 3. Default value
    ///
    /// - Parameter feature: Feature to check
    /// - Returns: true if enabled
    public func isEnabled(_ feature: FeatureFlag) -> Bool {
        // Check local override first
        if let override = overrides[feature] {
            logDebug("🔧 Override '\(feature.name)': \(override)")
            return override
        }

        // Get from remote config
        guard let remoteConfig = remoteConfig else {
            logDebug("⚠️ Remote config not available, using default for '\(feature.name)'")
            return feature.defaultValue
        }

        let value = remoteConfig.getBool(
            forKey: feature.key,
            defaultValue: feature.defaultValue
        )

        logDebug("📋 Feature '\(feature.name)': \(value)")
        return value
    }

    /// Get feature configuration
    ///
    /// **Returns**:
    /// - isEnabled: Whether feature is enabled
    /// - source: Where value came from (override, remote, default)
    /// - metadata: Additional info
    ///
    /// - Parameter feature: Feature to check
    /// - Returns: FeatureConfig
    public func getConfig(for feature: FeatureFlag) -> FeatureConfig {
        let source: FeatureConfig.Source
        let isEnabled: Bool

        if let override = overrides[feature] {
            source = .override
            isEnabled = override
        } else if let remoteConfig = remoteConfig {
            source = .remote
            isEnabled = remoteConfig.getBool(
                forKey: feature.key,
                defaultValue: feature.defaultValue
            )
        } else {
            source = .default
            isEnabled = feature.defaultValue
        }

        return FeatureConfig(
            feature: feature,
            isEnabled: isEnabled,
            source: source,
            metadata: [:]
        )
    }

    /// Override feature flag (for development/testing)
    ///
    /// **Use cases**:
    /// - Development testing
    /// - QA testing
    /// - Debug builds
    ///
    /// **Warning**: Only works in DEBUG builds
    ///
    /// - Parameters:
    ///   - feature: Feature to override
    ///   - enabled: Override value
    public func override(_ feature: FeatureFlag, enabled: Bool) {
        #if DEBUG
        overrides[feature] = enabled
        logDebug("🔧 Override set '\(feature.name)': \(enabled)")
        #else
        logDebug("⚠️ Overrides only work in DEBUG builds")
        #endif
    }

    /// Clear override for feature
    ///
    /// - Parameter feature: Feature to clear
    public func clearOverride(for feature: FeatureFlag) {
        overrides.removeValue(forKey: feature)
        logDebug("🧹 Cleared override for '\(feature.name)'")
    }

    /// Clear all overrides
    public func clearAllOverrides() {
        overrides.removeAll()
        logDebug("🧹 Cleared all overrides")
    }

    /// Get all features status
    ///
    /// **Useful for**:
    /// - Debug screen
    /// - Admin panel
    /// - Testing overview
    ///
    /// - Returns: Dictionary of all features and their status
    public func getAllFeaturesStatus() -> [FeatureFlag: Bool] {
        var status: [FeatureFlag: Bool] = [:]

        for feature in FeatureFlag.allCases {
            status[feature] = isEnabled(feature)
        }

        return status
    }

    /// Refresh remote config
    ///
    /// **Call periodically** to get latest feature flags
    ///
    /// **Example**:
    /// ```swift
    /// // Refresh on app launch
    /// Task {
    ///     try? await FeatureFlagManager.shared.refresh()
    /// }
    /// ```
    public func refresh() async throws {
        guard let remoteConfig = remoteConfig else {
            throw FeatureFlagError.remoteConfigNotAvailable
        }

        try await remoteConfig.fetch()
        logDebug("🔄 Feature flags refreshed")
    }

    // MARK: - Convenience Methods

    /// Check multiple features (AND logic)
    ///
    /// **Returns true** only if ALL features are enabled
    ///
    /// - Parameter features: Features to check
    /// - Returns: true if all enabled
    public func areAllEnabled(_ features: [FeatureFlag]) -> Bool {
        features.allSatisfy { isEnabled($0) }
    }

    /// Check multiple features (OR logic)
    ///
    /// **Returns true** if ANY feature is enabled
    ///
    /// - Parameter features: Features to check
    /// - Returns: true if any enabled
    public func isAnyEnabled(_ features: [FeatureFlag]) -> Bool {
        features.contains { isEnabled($0) }
    }

    // MARK: - Private Methods

    /// Debug logging
    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[FeatureFlags] \(message)")
    }
}

// MARK: - Feature Flag

/// Feature flags enumeration
///
/// **Add new features here** to make them available app-wide
public enum FeatureFlag: String, CaseIterable, Hashable {

    // MARK: - UI Features

    case darkMode = "dark_mode"
    case biometricLogin = "biometric_login"
    case offlineMode = "offline_mode"
    case showOnboarding = "show_onboarding"

    // MARK: - Analytics & Monitoring

    case analytics = "analytics"
    case crashlytics = "crashlytics"
    case performanceMonitoring = "performance_monitoring"

    // MARK: - Experimental Features

    case newOnboarding = "new_onboarding"
    case simplifiedLogin = "simplified_login"

    // MARK: - Business Features

    case inAppPurchases = "in_app_purchases"
    case subscriptions = "subscriptions"
    case referralProgram = "referral_program"

    // MARK: - Properties

    /// Remote config key
    var key: String {
        switch self {
        case .darkMode:
            return RemoteConfigKey.featureDarkMode
        case .biometricLogin:
            return RemoteConfigKey.featureBiometricLogin
        case .offlineMode:
            return RemoteConfigKey.featureOfflineMode
        case .showOnboarding:
            return RemoteConfigKey.showOnboarding
        case .analytics:
            return RemoteConfigKey.featureAnalytics
        case .crashlytics:
            return RemoteConfigKey.featureCrashlytics
        case .performanceMonitoring:
            return "feature_performance_monitoring_enabled"
        case .newOnboarding:
            return RemoteConfigKey.experimentNewOnboarding
        case .simplifiedLogin:
            return RemoteConfigKey.experimentSimplifiedLogin
        case .inAppPurchases:
            return "feature_in_app_purchases_enabled"
        case .subscriptions:
            return "feature_subscriptions_enabled"
        case .referralProgram:
            return "feature_referral_program_enabled"
        }
    }

    /// Human-readable name
    var name: String {
        rawValue.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    /// Default value (used when remote config unavailable)
    var defaultValue: Bool {
        switch self {
        // UI features - enabled by default
        case .darkMode, .biometricLogin, .showOnboarding:
            return true

        // Analytics - enabled by default
        case .analytics, .crashlytics, .performanceMonitoring:
            return true

        // Experimental - disabled by default
        case .newOnboarding, .simplifiedLogin:
            return false

        // Business features - disabled by default (require setup)
        case .inAppPurchases, .subscriptions, .referralProgram:
            return false

        // Other features
        case .offlineMode:
            return false
        }
    }

    /// Feature description
    var description: String {
        switch self {
        case .darkMode:
            return "Enable dark mode UI"
        case .biometricLogin:
            return "Enable Face ID/Touch ID login"
        case .offlineMode:
            return "Enable offline functionality"
        case .showOnboarding:
            return "Show onboarding screens to new users"
        case .analytics:
            return "Enable Firebase Analytics tracking"
        case .crashlytics:
            return "Enable Crashlytics error reporting"
        case .performanceMonitoring:
            return "Enable Firebase Performance monitoring"
        case .newOnboarding:
            return "A/B test: New onboarding flow"
        case .simplifiedLogin:
            return "A/B test: Simplified login screen"
        case .inAppPurchases:
            return "Enable in-app purchases"
        case .subscriptions:
            return "Enable subscription system"
        case .referralProgram:
            return "Enable referral program"
        }
    }

    /// Feature category
    var category: FeatureCategory {
        switch self {
        case .darkMode, .showOnboarding:
            return .ui
        case .biometricLogin:
            return .authentication
        case .analytics, .crashlytics, .performanceMonitoring:
            return .monitoring
        case .newOnboarding, .simplifiedLogin:
            return .experimental
        case .inAppPurchases, .subscriptions, .referralProgram:
            return .business
        case .offlineMode:
            return .functionality
        }
    }
}

// MARK: - Feature Category

/// Feature categories for organization
public enum FeatureCategory: String {
    case ui = "UI"
    case authentication = "Authentication"
    case functionality = "Functionality"
    case monitoring = "Monitoring"
    case experimental = "Experimental"
    case business = "Business"
}

// MARK: - Feature Config

/// Feature configuration details
public struct FeatureConfig {
    /// The feature
    public let feature: FeatureFlag

    /// Is enabled
    public let isEnabled: Bool

    /// Source of value
    public let source: Source

    /// Additional metadata
    public let metadata: [String: Any]

    /// Value source
    public enum Source: String {
        case override = "Local Override"
        case remote = "Remote Config"
        case `default` = "Default Value"
    }
}

// MARK: - Feature Flag Errors

/// Feature flag specific errors
public enum FeatureFlagError: Error, LocalizedError {
    case remoteConfigNotAvailable
    case invalidFeatureKey(String)

    public var errorDescription: String? {
        switch self {
        case .remoteConfigNotAvailable:
            return "Remote Config service not available"
        case .invalidFeatureKey(let key):
            return "Invalid feature key: \(key)"
        }
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
import SwiftUI

/// Property wrapper for feature flags in SwiftUI
///
/// **Usage**:
/// ```swift
/// struct MyView: View {
///     @FeatureFlag(.darkMode) var isDarkModeEnabled
///
///     var body: some View {
///         if isDarkModeEnabled {
///             Text("Dark mode is enabled!")
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct FeatureFlagWrapper: DynamicProperty {
    private let feature: FeatureFlag

    @State private var isEnabled: Bool

    public init(_ feature: FeatureFlag) {
        self.feature = feature
        _isEnabled = State(initialValue: FeatureFlagManager.shared.isEnabled(feature))
    }

    public var wrappedValue: Bool {
        isEnabled
    }

    public func update() {
        isEnabled = FeatureFlagManager.shared.isEnabled(feature)
    }
}
#endif
