import SwiftUI
import UI

/// Configuration cho OnboardingView - cho phép customize mọi app
///
/// Pattern: Parameterized Component
/// Cho phép reuse OnboardingView với content và logic khác nhau cho mỗi app
///
/// Ví dụ:
/// ```swift
/// let bankingConfig = OnboardingConfig(
///     pages: [
///         OnboardingPage(icon: "banknote", title: "Banking", ...)
///     ],
///     backgroundColor: .green.opacity(0.1),
///     finalButtonText: "Start Banking",
///     onComplete: { store.send(...) }
/// )
/// OnboardingView(store: store, config: bankingConfig)
/// ```
public struct OnboardingConfig: Equatable {
    // MARK: - Properties

    /// Danh sách pages để hiển thị
    public let pages: [OnboardingPage]

    /// Background color của onboarding (không dùng để so sánh Equatable)
    public let backgroundColor: Color

    /// Có hiện nút Skip không
    public let showSkipButton: Bool

    /// Text cho nút Skip
    public let skipButtonText: String

    /// Text cho nút Continue (giữa các pages)
    public let continueButtonText: String

    /// Text cho nút cuối cùng (page cuối)
    public let finalButtonText: String
    
    // MARK: - Equatable (Color không Equatable trên iOS 16, cần custom)
    
    public static func == (lhs: OnboardingConfig, rhs: OnboardingConfig) -> Bool {
        lhs.pages == rhs.pages &&
        lhs.showSkipButton == rhs.showSkipButton &&
        lhs.skipButtonText == rhs.skipButtonText &&
        lhs.continueButtonText == rhs.continueButtonText &&
        lhs.finalButtonText == rhs.finalButtonText
    }

    // MARK: - Initialization

    /// Khởi tạo OnboardingConfig với đầy đủ tùy chỉnh
    ///
    /// - Parameters:
    ///   - pages: Danh sách OnboardingPage
    ///   - backgroundColor: Màu background (default: theme background)
    ///   - showSkipButton: Hiện nút Skip (default: true)
    ///   - skipButtonText: Text nút Skip (default: "Skip")
    ///   - continueButtonText: Text nút Continue (default: "Continue")
    ///   - finalButtonText: Text nút cuối (default: "Get Started")
    public init(
        pages: [OnboardingPage],
        backgroundColor: Color = Color.theme.background,
        showSkipButton: Bool = true,
        skipButtonText: String = "Skip",
        continueButtonText: String = "Continue",
        finalButtonText: String = "Get Started"
    ) {
        self.pages = pages
        self.backgroundColor = backgroundColor
        self.showSkipButton = showSkipButton
        self.skipButtonText = skipButtonText
        self.continueButtonText = continueButtonText
        self.finalButtonText = finalButtonText
    }
}

// MARK: - OnboardingPage Model

/// Model cho mỗi page trong onboarding
public struct OnboardingPage: Equatable {
    /// SF Symbol icon name
    public let icon: String

    /// Title của page
    public let title: String

    /// Description/subtitle
    public let description: String

    /// Màu gradient cho icon (không dùng để so sánh Equatable)
    public let color: Color

    /// Khởi tạo OnboardingPage
    public init(
        icon: String,
        title: String,
        description: String,
        color: Color
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
    }
    
    // MARK: - Equatable (Color không Equatable trên iOS 16, cần custom)
    
    public static func == (lhs: OnboardingPage, rhs: OnboardingPage) -> Bool {
        lhs.icon == rhs.icon &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description
    }
}

// MARK: - Default Configs

public extension OnboardingConfig {
    /// Default config cho template - dùng khi không pass config
    static var `default`: OnboardingConfig {
        OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "sparkles",
                    title: "Welcome",
                    description: "Experience the best features in one place",
                    color: .theme.primary
                ),
                OnboardingPage(
                    icon: "lock.shield",
                    title: "Secure",
                    description: "Your data is encrypted and protected",
                    color: .theme.success
                ),
                OnboardingPage(
                    icon: "bolt.fill",
                    title: "Fast",
                    description: "Lightning-fast performance everywhere",
                    color: .theme.accent
                )
            ]
        )
    }
}

