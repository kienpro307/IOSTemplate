import ComposableArchitecture
import Foundation

/// Tất cả actions trong app
/// Actions represent events that can happen in the app
public enum AppAction: Equatable {
    // MARK: - Lifecycle Actions

    /// App đã launch
    case appLaunched

    /// App vào foreground
    case appDidBecomeActive

    /// App vào background
    case appDidEnterBackground

    /// App sẽ terminate
    case appWillTerminate

    // MARK: - User Actions

    /// Actions liên quan đến user
    case user(UserAction)

    // MARK: - Navigation Actions

    /// Actions điều khiển navigation
    case navigation(NavigationAction)

    // MARK: - Network Actions

    /// Actions liên quan đến network
    case network(NetworkAction)

    // MARK: - Config Actions

    /// Actions cho remote config
    case config(ConfigAction)
}

// MARK: - User Actions

/// Actions liên quan đến user
public enum UserAction: Equatable {
    // MARK: - Authentication Actions

    /// User request login với email/password
    case login(email: String, password: String)

    /// User đăng nhập thành công
    case loginSuccess(UserProfile)

    /// Login failed
    case loginFailure(String)

    /// User request registration
    case register(name: String, email: String, password: String)

    /// Registration success
    case registrationSuccess(UserProfile)

    /// Registration failed
    case registrationFailure(String)

    /// User request password reset
    case forgotPassword(email: String)

    /// Password reset email sent
    case passwordResetEmailSent

    /// Social login (Apple, Google, Facebook)
    case socialLogin(SocialLoginProvider)

    /// Social login success
    case socialLoginSuccess(UserProfile)

    /// Social login failed
    case socialLoginFailure(String)

    /// User đăng xuất
    case logout

    /// Update user profile
    case updateProfile(UserProfile)

    /// Update preferences
    case updatePreferences(UserPreferences)

    /// Thay đổi theme mode
    case changeThemeMode(ThemeMode)

    /// Thay đổi language
    case changeLanguage(String)

    /// Toggle notifications
    case toggleNotifications(Bool)
}

/// Social login providers
public enum SocialLoginProvider: String, Equatable {
    case apple
    case google
    case facebook
}

// MARK: - Navigation Actions

/// Actions điều khiển navigation
public enum NavigationAction: Equatable {
    /// Chọn tab
    case selectTab(AppTab)

    /// Handle deep link
    case handleDeepLink(URL)

    /// Deep link đã xử lý xong
    case deepLinkHandled

    /// Navigate to screen
    case navigateTo(Destination)

    /// Go back
    case goBack

    /// Dismiss modal
    case dismiss
}

/// Destinations trong app
public enum Destination: Equatable {
    case home
    case profile
    case settings
    case login
    case onboarding
}

// MARK: - Network Actions

/// Actions liên quan đến network
public enum NetworkAction: Equatable {
    /// Network status changed
    case statusChanged(isConnected: Bool, type: ConnectionType)

    /// Request started
    case requestStarted

    /// Request completed
    case requestCompleted

    /// Network error occurred
    case error
}

// MARK: - Config Actions

/// Actions cho remote config
public enum ConfigAction: Equatable {
    /// Fetch remote config
    case fetchRemoteConfig

    /// Remote config fetched
    case remoteConfigFetched([String: String])

    /// Update feature flag
    case updateFeatureFlag(key: String, value: Bool)

    /// Config fetch failed
    case fetchFailed(Error)

    public static func == (lhs: ConfigAction, rhs: ConfigAction) -> Bool {
        switch (lhs, rhs) {
        case (.fetchRemoteConfig, .fetchRemoteConfig):
            return true
        case let (.remoteConfigFetched(lhsConfig), .remoteConfigFetched(rhsConfig)):
            return lhsConfig == rhsConfig
        case let (.updateFeatureFlag(lhsKey, lhsValue), .updateFeatureFlag(rhsKey, rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case (.fetchFailed, .fetchFailed):
            return true
        default:
            return false
        }
    }
}
