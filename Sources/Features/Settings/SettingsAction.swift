import ComposableArchitecture
import Foundation

/// Các hành động của Settings feature
@CasePathable
public enum SettingsAction: Equatable {
    /// View appeared - load preferences từ storage
    case onAppear
    
    /// Thay đổi theme mode
    case changeThemeMode(ThemeMode)
    
    /// Thay đổi language code
    case changeLanguage(String)
    
    /// Toggle notifications enabled
    case toggleNotifications(Bool)
    
    /// Preferences đã được load từ storage
    case preferencesLoaded(UserPreferences)
    
    /// Preferences đã được lưu vào storage
    case preferencesSaved
}

