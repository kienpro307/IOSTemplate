import Foundation

/// Định nghĩa các màn hình dùng chung cho tất cả apps
public enum Destination: Hashable, Identifiable {
    // MARK: - Giới thiệu & Chào mừng
    case onboarding
    case welcome
    
    // MARK: - Cài đặt
    case settings
    case settingsTheme
    case settingsLanguage
    case settingsNotifications
    
    // MARK: - Pháp lý & Thông tin
    case about
    case privacyPolicy
    case termsOfService
    case licenses
    
    // MARK: - Tiện ích chung
    case webView(url: URL, title: String?)
    
    // MARK: - Định danh duy nhất
    public var id: String {
        switch self {
        case .onboarding:
            return "onboarding"
        case .welcome:
            return "welcome"
        case .settings:
            return "settings"
        case .settingsTheme:
            return "settings_theme"
        case .settingsLanguage:
            return "settings_language"
        case .settingsNotifications:
            return "settings_notifications"
        case .about:
            return "about"
        case .privacyPolicy:
            return "privacy_policy"
        case .termsOfService:
            return "terms_of_service"
        case .licenses:
            return "licenses"
        case .webView(let url, _):
            return "webview_\(url.absoluteString)"
        }
    }
    
    /// Tiêu đề hiển thị của màn hình
    public var title: String {
        switch self {
        case .onboarding:
            return "Onboarding"
        case .welcome:
            return "Welcome"
        case .settings:
            return "Settings"
        case .settingsTheme:
            return "Theme"
        case .settingsLanguage:
            return "Language"
        case .settingsNotifications:
            return "Notifications"
        case .about:
            return "About"
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfService:
            return "Terms of Service"
        case .licenses:
            return "Open Source Licenses"
        case .webView(_, let title):
            return title ?? "Web"
        }
    }
}
