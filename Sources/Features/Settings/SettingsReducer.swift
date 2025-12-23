import ComposableArchitecture
import Core

/// Reducer xử lý logic của Settings feature
@Reducer
public struct SettingsReducer {
    public init() {}
    
    public typealias State = SettingsState
    public typealias Action = SettingsAction
    
    // MARK: - Dependencies
    /// Storage client để lưu/load preferences
    @Dependency(\.storageClient) var storageClient
    /// Analytics service để track events
    @Dependency(\.analytics) var analytics
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Load preferences từ storage khi view appear
                return .run { send in
                    // Load preferences từ storage
                    if let preferences: UserPreferences = try? await storageClient.load(
                        forKey: StorageKey.userPreferences
                    ) {
                        await send(.preferencesLoaded(preferences))
                    }
                }
                
            case .changeThemeMode(let mode):
                // Thay đổi theme mode
                state.preferences.themeMode = mode
                // Lưu vào storage
                return .run { [preferences = state.preferences] send in
                    try? await storageClient.save(preferences, forKey: StorageKey.userPreferences)
                    await send(.preferencesSaved)
                    
                    // Track event vào Analytics
                    await analytics.trackEvent("settings_theme_changed", parameters: [
                        "theme_mode": mode.rawValue
                    ])
                }
                
            case .changeLanguage(let languageCode):
                // Thay đổi language
                state.preferences.languageCode = languageCode
                // Lưu vào storage
                return .run { [preferences = state.preferences] send in
                    try? await storageClient.save(preferences, forKey: StorageKey.userPreferences)
                    await send(.preferencesSaved)
                    
                    // Track event vào Analytics
                    await analytics.trackEvent("settings_language_changed", parameters: [
                        "language_code": languageCode
                    ])
                }
                
            case .toggleNotifications(let enabled):
                // Toggle notifications
                state.preferences.notificationsEnabled = enabled
                // Lưu vào storage
                return .run { [preferences = state.preferences] send in
                    try? await storageClient.save(preferences, forKey: StorageKey.userPreferences)
                    await send(.preferencesSaved)
                    
                    // Track event vào Analytics
                    await analytics.trackEvent("settings_notifications_toggled", parameters: [
                        "enabled": String(enabled)
                    ])
                }
                
            case .preferencesLoaded(let preferences):
                // Preferences đã được load từ storage
                state.preferences = preferences
                return .none
                
            case .preferencesSaved:
                // Preferences đã được lưu vào storage
                return .none
            }
        }
    }
}

