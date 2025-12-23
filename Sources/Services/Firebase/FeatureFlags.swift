import Foundation
import ComposableArchitecture

/// Feature flags keys cho Remote Config
/// Theo cấu trúc trong ios-template-docs/06-KE-HOACH/05-PHASE-3-FIREBASE.md
public enum FeatureFlagKey: String, Sendable {
    // Feature toggles
    case darkModeEnabled = "feature_dark_mode_enabled"
    case biometricLoginEnabled = "feature_biometric_login_enabled"
    case offlineModeEnabled = "feature_offline_mode_enabled"
    case analyticsEnabled = "feature_analytics_enabled"
    case crashlyticsEnabled = "feature_crashlytics_enabled"
    
    // App configuration
    case forceUpdateRequired = "app_force_update_required"
    case maintenanceMode = "app_maintenance_mode"
    case minSupportedVersion = "app_min_supported_version"
    
    // UI configuration
    case welcomeMessage = "ui_welcome_message"
    case primaryColor = "ui_primary_color"
    case showOnboarding = "ui_show_onboarding"
    
    // Business logic
    case maxLoginAttempts = "max_login_attempts"
    case sessionTimeoutMinutes = "session_timeout_minutes"
    case maxFileSizeMB = "max_file_size_mb"
    case apiTimeoutSeconds = "api_timeout_seconds"
    
    // A/B Testing
    case experimentNewOnboarding = "experiment_new_onboarding"
    case experimentSimplifiedLogin = "experiment_simplified_login"
    
    // Promotional
    case promoBannerEnabled = "promo_banner_enabled"
    case promoBannerMessage = "promo_banner_message"
    case promoBannerActionURL = "promo_banner_action_url"
    
    // Support
    case supportEmail = "support_email"
    case supportPhone = "support_phone"
    case faqURL = "faq_url"
}

/// Helper để check feature flags từ Remote Config
public struct FeatureFlags {
    /// Remote Config service
    @Dependency(\.remoteConfig) private static var remoteConfig
    
    /// Get boolean feature flag
    public static func getBool(_ key: FeatureFlagKey) async -> Bool {
        await remoteConfig.getBool(key.rawValue)
    }
    
    /// Get string feature flag
    public static func getString(_ key: FeatureFlagKey) async -> String? {
        await remoteConfig.getString(key.rawValue)
    }
    
    /// Get integer feature flag
    public static func getInt(_ key: FeatureFlagKey) async -> Int {
        await remoteConfig.getInt(key.rawValue)
    }
    
    /// Fetch và activate Remote Config
    public static func fetchAndActivate() async throws {
        try await remoteConfig.fetchAndActivate()
    }
}

/// Convenience extensions cho các feature flags phổ biến
public extension FeatureFlags {
    /// Check nếu dark mode được enable
    static var isDarkModeEnabled: Bool {
        get async {
            await getBool(.darkModeEnabled)
        }
    }
    
    /// Check nếu biometric login được enable
    static var isBiometricLoginEnabled: Bool {
        get async {
            await getBool(.biometricLoginEnabled)
        }
    }
    
    /// Check nếu offline mode được enable
    static var isOfflineModeEnabled: Bool {
        get async {
            await getBool(.offlineModeEnabled)
        }
    }
    
    /// Check nếu app đang ở maintenance mode
    static var isMaintenanceMode: Bool {
        get async {
            await getBool(.maintenanceMode)
        }
    }
    
    /// Check nếu force update required
    static var isForceUpdateRequired: Bool {
        get async {
            await getBool(.forceUpdateRequired)
        }
    }
    
    /// Get minimum supported version
    static var minSupportedVersion: String? {
        get async {
            await getString(.minSupportedVersion)
        }
    }
}

