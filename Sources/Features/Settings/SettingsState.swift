import ComposableArchitecture
import Foundation

/// Trạng thái của Settings feature
@ObservableState
public struct SettingsState: Equatable {
    /// User preferences (theme, language, notifications)
    public var preferences: UserPreferences
    
    /// App configuration (version, build number)
    public var appConfig: AppConfig
    
    public init(
        preferences: UserPreferences = UserPreferences(),
        appConfig: AppConfig = AppConfig()
    ) {
        self.preferences = preferences
        self.appConfig = appConfig
    }
}

// MARK: - User Preferences

/// User preferences model
public struct UserPreferences: Equatable, Codable {
    /// Theme mode: auto, light, dark
    public var themeMode: ThemeMode
    
    /// Selected language code (e.g., "en", "vi")
    public var languageCode: String
    
    /// Notification settings enabled
    public var notificationsEnabled: Bool
    
    public init(
        themeMode: ThemeMode = .auto,
        languageCode: String = "en",
        notificationsEnabled: Bool = true
    ) {
        self.themeMode = themeMode
        self.languageCode = languageCode
        self.notificationsEnabled = notificationsEnabled
    }
}

// MARK: - Theme Mode

/// Theme mode enum
public enum ThemeMode: String, Equatable, Codable, CaseIterable {
    case auto
    case light
    case dark
    
    public var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - App Config

/// App configuration model
public struct AppConfig: Equatable {
    /// App version (e.g., "1.0.0")
    public var appVersion: String
    
    /// Build number (e.g., "1")
    public var buildNumber: String
    
    public init(
        appVersion: String? = nil,
        buildNumber: String? = nil
    ) {
        // Lấy từ Bundle nếu không được cung cấp
        if let version = appVersion {
            self.appVersion = version
        } else {
            self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }
        
        if let build = buildNumber {
            self.buildNumber = build
        } else {
            self.buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        }
    }
}

