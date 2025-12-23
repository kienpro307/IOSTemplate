import Foundation
import SwiftUI

// MARK: - Localization Manager Protocol

/// Protocol for managing app localization
public protocol LocalizationManagerProtocol {
    /// Current language code
    var currentLanguage: String { get }

    /// Available languages
    var availableLanguages: [Language] { get }

    /// Change app language
    /// - Parameter languageCode: Language code (e.g., "en", "vi", "es")
    func changeLanguage(to languageCode: String)

    /// Get localized string
    /// - Parameters:
    ///   - key: Localization key
    ///   - comment: Comment for translator
    /// - Returns: Localized string
    func localizedString(forKey key: String, comment: String) -> String

    /// Get localized string with arguments
    /// - Parameters:
    ///   - key: Localization key
    ///   - arguments: Format arguments
    /// - Returns: Formatted localized string
    func localizedString(forKey key: String, arguments: CVarArg...) -> String
}

// MARK: - Language Model

/// Language model
public struct Language: Identifiable, Equatable {
    public let id: String // Language code (e.g., "en")
    public let name: String // Native name (e.g., "English")
    public let localizedName: String // Localized name
    public let flag: String // Flag emoji
    public let isRTL: Bool // Right-to-left

    public init(
        id: String,
        name: String,
        localizedName: String,
        flag: String,
        isRTL: Bool = false
    ) {
        self.id = id
        self.name = name
        self.localizedName = localizedName
        self.flag = flag
        self.isRTL = isRTL
    }
}

// MARK: - Localization Manager Implementation

/// Default implementation of Localization Manager
public final class LocalizationManager: LocalizationManagerProtocol, ObservableObject {
    // MARK: - Properties

    @Published public private(set) var currentLanguage: String

    private let userDefaultsStorage: StorageServiceProtocol
    private let languageKey = "app_language"

    // MARK: - Available Languages

    public let availableLanguages: [Language] = [
        Language(
            id: "en",
            name: "English",
            localizedName: "English",
            flag: "🇺🇸"
        ),
        Language(
            id: "vi",
            name: "Tiếng Việt",
            localizedName: "Vietnamese",
            flag: "🇻🇳"
        ),
        Language(
            id: "es",
            name: "Español",
            localizedName: "Spanish",
            flag: "🇪🇸"
        ),
        Language(
            id: "fr",
            name: "Français",
            localizedName: "French",
            flag: "🇫🇷"
        ),
        Language(
            id: "de",
            name: "Deutsch",
            localizedName: "German",
            flag: "🇩🇪"
        ),
        Language(
            id: "ja",
            name: "日本語",
            localizedName: "Japanese",
            flag: "🇯🇵"
        ),
        Language(
            id: "ko",
            name: "한국어",
            localizedName: "Korean",
            flag: "🇰🇷"
        ),
        Language(
            id: "zh-Hans",
            name: "简体中文",
            localizedName: "Chinese (Simplified)",
            flag: "🇨🇳"
        ),
        Language(
            id: "ar",
            name: "العربية",
            localizedName: "Arabic",
            flag: "🇸🇦",
            isRTL: true
        )
    ]

    // MARK: - Initialization

    public init(userDefaultsStorage: StorageServiceProtocol) {
        self.userDefaultsStorage = userDefaultsStorage

        // Load saved language or use device language
        if let savedLanguage: String = try? userDefaultsStorage.load(String.self, forKey: languageKey) {
            self.currentLanguage = savedLanguage
        } else {
            // Get device language
            let deviceLanguage = Locale.preferredLanguages.first ?? "en"
            let languageCode = String(deviceLanguage.prefix(2))
            self.currentLanguage = languageCode
        }
    }

    // MARK: - Public Methods

    public func changeLanguage(to languageCode: String) {
        guard availableLanguages.contains(where: { $0.id == languageCode }) else {
            print("⚠️ Language \(languageCode) not available")
            return
        }

        currentLanguage = languageCode

        // Save to storage
        try? userDefaultsStorage.save(languageCode, forKey: languageKey)

        // Post notification for UI update
        NotificationCenter.default.post(
            name: .languageChanged,
            object: nil,
            userInfo: ["language": languageCode]
        )

        print("✅ Language changed to: \(languageCode)")
    }

    public func localizedString(forKey key: String, comment: String = "") -> String {
        // In production, this would load from Localizable.strings
        // For now, return the key as fallback
        return NSLocalizedString(key, comment: comment)
    }

    public func localizedString(forKey key: String, arguments: CVarArg...) -> String {
        let format = localizedString(forKey: key)
        return String(format: format, arguments: arguments)
    }

    // MARK: - Helper Methods

    /// Get language by code
    public func language(forCode code: String) -> Language? {
        availableLanguages.first { $0.id == code }
    }

    /// Get current language model
    public var currentLanguageModel: Language? {
        language(forCode: currentLanguage)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when app language changes
    static let languageChanged = Notification.Name("app.language.changed")
}

// MARK: - Localization Keys

/// Localization keys for type-safe access
public enum LocalizationKey: String {
    // MARK: - Common
    case ok = "common.ok"
    case cancel = "common.cancel"
    case save = "common.save"
    case delete = "common.delete"
    case edit = "common.edit"
    case done = "common.done"
    case close = "common.close"
    case back = "common.back"
    case next = "common.next"
    case skip = "common.skip"
    case retry = "common.retry"
    case error = "common.error"
    case success = "common.success"

    // MARK: - Authentication
    case loginTitle = "auth.login.title"
    case loginSubtitle = "auth.login.subtitle"
    case loginButton = "auth.login.button"
    case registerTitle = "auth.register.title"
    case registerButton = "auth.register.button"
    case forgotPassword = "auth.forgot_password"
    case logout = "auth.logout"

    // MARK: - Onboarding
    case onboardingWelcome = "onboarding.welcome.title"
    case onboardingGetStarted = "onboarding.get_started"

    // MARK: - Settings
    case settingsTitle = "settings.title"
    case settingsAccount = "settings.account"
    case settingsPreferences = "settings.preferences"
    case settingsLanguage = "settings.language"
    case settingsTheme = "settings.theme"
    case settingsNotifications = "settings.notifications"

    // MARK: - Errors
    case errorGeneric = "error.generic"
    case errorNetwork = "error.network"
    case errorInvalidInput = "error.invalid_input"

    public func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }

    public func localized(arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self.rawValue, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - String Extension

extension String {
    /// Localize string
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Localize string with arguments
    public func localized(arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - View Modifier

/// View modifier for localizable views
public struct LocalizableViewModifier: ViewModifier {
    @StateObject private var localizationManager: LocalizationManager

    public init(localizationManager: LocalizationManager) {
        _localizationManager = StateObject(wrappedValue: localizationManager)
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, layoutDirection)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                // Force view update when language changes
            }
    }

    private var layoutDirection: LayoutDirection {
        guard let language = localizationManager.currentLanguageModel else {
            return .leftToRight
        }
        return language.isRTL ? .rightToLeft : .leftToRight
    }
}

extension View {
    /// Apply localization support to view
    public func localizable(manager: LocalizationManager) -> some View {
        modifier(LocalizableViewModifier(localizationManager: manager))
    }
}

// MARK: - Mock Localization Manager

/// Mock implementation for testing
public final class MockLocalizationManager: LocalizationManagerProtocol {
    public var currentLanguage: String = "en"
    public let availableLanguages: [Language] = [
        Language(id: "en", name: "English", localizedName: "English", flag: "🇺🇸"),
        Language(id: "vi", name: "Tiếng Việt", localizedName: "Vietnamese", flag: "🇻🇳")
    ]

    public init() {}

    public func changeLanguage(to languageCode: String) {
        currentLanguage = languageCode
    }

    public func localizedString(forKey key: String, comment: String = "") -> String {
        return key
    }

    public func localizedString(forKey key: String, arguments: CVarArg...) -> String {
        return key
    }
}
