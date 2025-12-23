import SwiftUI
import ComposableArchitecture

/// Configuration cho LoginView - cho phép customize cho mỗi app
///
/// Pattern: Parameterized Component
/// Cho phép reuse LoginView với branding và logic khác nhau
///
/// Ví dụ:
/// ```swift
/// let bankingConfig = LoginConfig(
///     title: "Banking Login",
///     logo: "bank.logo",
///     primaryColor: .green,
///     onLogin: { email, password in
///         // Banking-specific login logic
///     }
/// )
/// LoginView(store: store, config: bankingConfig)
/// ```
public struct LoginConfig {
    // MARK: - Properties

    /// Title hiển thị trên màn login
    public let title: String

    /// Subtitle/description
    public let subtitle: String

    /// SF Symbol icon name cho logo (nếu không dùng custom image)
    public let logoIcon: String?

    /// Primary color cho buttons và accents
    public let primaryColor: Color

    /// Background color
    public let backgroundColor: Color

    /// Text cho nút login
    public let loginButtonText: String

    /// Có hiện social login buttons không
    public let showSocialLogin: Bool

    /// Có hiện "Don't have account?" link không
    public let showSignUpLink: Bool

    /// Text cho sign up link
    public let signUpLinkText: String

    /// Closure xử lý login
    /// Parameters: (email, password)
    /// Mỗi app implement logic riêng (API call, validation, etc.)
    public let onLogin: (String, String) -> Void

    /// Closure xử lý sign up (optional)
    public let onSignUp: (() -> Void)?

    /// Closure xử lý social login (optional)
    public let onSocialLogin: ((SocialLoginProvider) -> Void)?

    // MARK: - Initialization

    /// Khởi tạo LoginConfig với đầy đủ tùy chỉnh
    public init(
        title: String = "Welcome Back",
        subtitle: String = "Sign in to continue",
        logoIcon: String? = "lock.shield",
        primaryColor: Color = Color.theme.primary,
        backgroundColor: Color = Color.theme.background,
        loginButtonText: String = "Sign In",
        showSocialLogin: Bool = true,
        showSignUpLink: Bool = true,
        signUpLinkText: String = "Sign Up",
        onLogin: @escaping (String, String) -> Void,
        onSignUp: (() -> Void)? = nil,
        onSocialLogin: ((SocialLoginProvider) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.logoIcon = logoIcon
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.loginButtonText = loginButtonText
        self.showSocialLogin = showSocialLogin
        self.showSignUpLink = showSignUpLink
        self.signUpLinkText = signUpLinkText
        self.onLogin = onLogin
        self.onSignUp = onSignUp
        self.onSocialLogin = onSocialLogin
    }
}

// MARK: - Default Configs

// Note: SocialProvider enum đã được define trong ServiceProtocols.swift
// Không cần redefine ở đây

public extension LoginConfig {
    /// Default config cho template
    static func `default`(onLogin: @escaping (String, String) -> Void) -> LoginConfig {
        LoginConfig(
            title: "Welcome Back",
            subtitle: "Sign in to continue",
            logoIcon: "lock.shield",
            onLogin: onLogin
        )
    }
}
