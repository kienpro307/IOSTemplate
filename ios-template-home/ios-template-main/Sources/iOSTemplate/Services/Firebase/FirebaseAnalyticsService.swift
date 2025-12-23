import Foundation
import FirebaseAnalytics

/// Firebase Analytics Service - Implementation của AnalyticsServiceProtocol
///
/// Service này wrap Firebase Analytics SDK và provide type-safe API
/// cho event tracking, user properties, và screen tracking.
///
/// ## Usage:
/// ```swift
/// @Injected var analytics: AnalyticsServiceProtocol
///
/// // Track custom event
/// analytics.trackEvent(.userLoggedIn(method: "email"))
///
/// // Track screen
/// analytics.trackScreen("HomeScreen", parameters: nil)
///
/// // Set user property
/// analytics.setUserProperty("premium", forName: "user_type")
///
/// // Set user ID
/// analytics.setUserID("user123")
/// ```
///
public final class FirebaseAnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Properties

    /// Singleton instance
    public static let shared = FirebaseAnalyticsService()

    /// Debug mode enabled
    private var isDebugMode: Bool = false

    // MARK: - Initialization

    private init() {
        #if DEBUG
        isDebugMode = true
        enableDebugMode()
        #endif
    }

    // MARK: - AnalyticsServiceProtocol

    /// Track custom event
    ///
    /// - Parameter event: AnalyticsEvent với name và parameters
    ///
    /// **Note**: Nếu sử dụng predefined events từ `AppAnalyticsEvent`,
    /// event name và parameters đã được validate và type-safe.
    public func trackEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)

        if isDebugMode {
            logDebug("📊 Event tracked: \(event.name)")
            if let params = event.parameters {
                logDebug("   Parameters: \(params)")
            }
        }
    }

    /// Track screen view
    ///
    /// - Parameters:
    ///   - screenName: Tên màn hình (e.g., "HomeScreen", "ProfileScreen")
    ///   - parameters: Optional parameters (e.g., user segment, A/B test variant)
    ///
    /// **Best Practice**: Gọi trong `onAppear()` của SwiftUI view hoặc `viewDidAppear()` của UIKit
    public func trackScreen(_ screenName: String, parameters: [String: Any]?) {
        var params = parameters ?? [:]
        params[AnalyticsParameterScreenName] = screenName
        params[AnalyticsParameterScreenClass] = screenName

        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)

        if isDebugMode {
            logDebug("📱 Screen viewed: \(screenName)")
            if let additionalParams = parameters, !additionalParams.isEmpty {
                logDebug("   Parameters: \(additionalParams)")
            }
        }
    }

    /// Set user property
    ///
    /// - Parameters:
    ///   - value: Property value (max 36 characters)
    ///   - name: Property name (max 24 characters)
    ///
    /// **Examples**:
    /// - User tier: "premium", "free"
    /// - User segment: "power_user", "casual"
    /// - Acquisition channel: "organic", "paid"
    ///
    /// **Note**: User properties persist across sessions và có thể dùng
    /// để segment users trong Firebase Console
    public func setUserProperty(_ value: String, forName name: String) {
        Analytics.setUserProperty(value, forName: name)

        if isDebugMode {
            logDebug("👤 User property set: \(name) = \(value)")
        }
    }

    /// Set user ID
    ///
    /// - Parameter userID: Unique user identifier (nil to clear)
    ///
    /// **Important**:
    /// - User ID phải unique và không chứa PII (Personally Identifiable Information)
    /// - Use hashed/anonymized ID, không dùng email hoặc phone number trực tiếp
    /// - User ID persist across app installs nếu user login lại
    ///
    /// **Privacy**: Đảm bảo tuân thủ GDPR, CCPA và privacy laws khác
    public func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)

        if isDebugMode {
            if let id = userID {
                logDebug("🆔 User ID set: \(id)")
            } else {
                logDebug("🆔 User ID cleared")
            }
        }
    }

    // MARK: - Debug Helpers

    /// Enable debug mode cho Firebase Analytics
    ///
    /// Debug mode cho phép:
    /// - Xem events real-time trong Firebase DebugView
    /// - Bypass upload intervals (events upload ngay lập tức)
    /// - Verbose logging
    ///
    /// **Note**: Chỉ enable trong DEBUG builds
    private func enableDebugMode() {
        // Firebase Analytics debug mode tự động enable trong DEBUG builds
        // với -FIRAnalyticsDebugEnabled trong scheme arguments
        logDebug("🐛 Analytics Debug Mode: ENABLED")
        logDebug("   View events in Firebase Console → DebugView")
    }

    private func logDebug(_ message: String) {
        if isDebugMode {
            print("[FirebaseAnalytics] \(message)")
        }
    }
}

// MARK: - Predefined Analytics Events

/// Predefined analytics events cho app
///
/// **Pattern: Type-Safe Events**
///
/// Thay vì pass raw strings, use enum cases với associated values.
/// Điều này đảm bảo:
/// - Type safety
/// - Auto-completion
/// - Compile-time checking
/// - Consistent naming
///
/// ## Usage:
/// ```swift
/// analytics.trackEvent(.userLoggedIn(method: "email"))
/// analytics.trackEvent(.purchaseCompleted(itemId: "premium_monthly", value: 9.99))
/// analytics.trackEvent(.featureUsed(name: "dark_mode", enabled: true))
/// ```
///
public enum AppAnalyticsEvent {
    // MARK: - Authentication Events

    /// User logged in
    case userLoggedIn(method: String) // "email", "google", "apple"

    /// User signed up
    case userSignedUp(method: String)

    /// User logged out
    case userLoggedOut

    // MARK: - Content Events

    /// Content viewed
    case contentViewed(contentType: String, contentId: String)

    /// Content shared
    case contentShared(contentType: String, contentId: String, method: String)

    /// Search performed
    case searchPerformed(query: String, resultsCount: Int)

    // MARK: - E-commerce Events (if applicable)

    /// Item added to cart
    case itemAddedToCart(itemId: String, itemName: String, price: Double)

    /// Purchase completed
    case purchaseCompleted(itemId: String, value: Double, currency: String)

    // MARK: - Feature Usage Events

    /// Feature used
    case featureUsed(name: String, enabled: Bool)

    /// Tutorial completed
    case tutorialCompleted(tutorialId: String)

    /// Level completed (for games)
    case levelCompleted(levelId: String, score: Int)

    // MARK: - Error Events

    /// Error occurred
    case errorOccurred(errorCode: String, errorMessage: String)

    /// API call failed
    case apiCallFailed(endpoint: String, statusCode: Int)

    // MARK: - Custom Event

    /// Custom event với raw name và parameters
    /// Use này khi không có predefined event phù hợp
    case custom(name: String, parameters: [String: Any]?)
}

// MARK: - AnalyticsEvent Conversion

extension AppAnalyticsEvent {
    /// Convert to AnalyticsEvent
    var event: AnalyticsEvent {
        switch self {
        // Authentication
        case .userLoggedIn(let method):
            return AnalyticsEvent(
                name: AnalyticsEventLogin,
                parameters: [AnalyticsParameterMethod: method]
            )

        case .userSignedUp(let method):
            return AnalyticsEvent(
                name: AnalyticsEventSignUp,
                parameters: [AnalyticsParameterMethod: method]
            )

        case .userLoggedOut:
            return AnalyticsEvent(name: "user_logged_out", parameters: nil)

        // Content
        case .contentViewed(let contentType, let contentId):
            return AnalyticsEvent(
                name: AnalyticsEventSelectContent,
                parameters: [
                    AnalyticsParameterContentType: contentType,
                    AnalyticsParameterItemID: contentId
                ]
            )

        case .contentShared(let contentType, let contentId, let method):
            return AnalyticsEvent(
                name: AnalyticsEventShare,
                parameters: [
                    AnalyticsParameterContentType: contentType,
                    AnalyticsParameterItemID: contentId,
                    AnalyticsParameterMethod: method
                ]
            )

        case .searchPerformed(let query, let resultsCount):
            return AnalyticsEvent(
                name: AnalyticsEventSearch,
                parameters: [
                    AnalyticsParameterSearchTerm: query,
                    "results_count": resultsCount
                ]
            )

        // E-commerce
        case .itemAddedToCart(let itemId, let itemName, let price):
            return AnalyticsEvent(
                name: AnalyticsEventAddToCart,
                parameters: [
                    AnalyticsParameterItemID: itemId,
                    AnalyticsParameterItemName: itemName,
                    AnalyticsParameterPrice: price
                ]
            )

        case .purchaseCompleted(let itemId, let value, let currency):
            return AnalyticsEvent(
                name: AnalyticsEventPurchase,
                parameters: [
                    AnalyticsParameterItemID: itemId,
                    AnalyticsParameterValue: value,
                    AnalyticsParameterCurrency: currency
                ]
            )

        // Feature Usage
        case .featureUsed(let name, let enabled):
            return AnalyticsEvent(
                name: "feature_used",
                parameters: [
                    "feature_name": name,
                    "enabled": enabled
                ]
            )

        case .tutorialCompleted(let tutorialId):
            return AnalyticsEvent(
                name: AnalyticsEventTutorialComplete,
                parameters: [AnalyticsParameterItemID: tutorialId]
            )

        case .levelCompleted(let levelId, let score):
            return AnalyticsEvent(
                name: AnalyticsEventLevelEnd,
                parameters: [
                    AnalyticsParameterLevelName: levelId,
                    AnalyticsParameterScore: score
                ]
            )

        // Errors
        case .errorOccurred(let errorCode, let errorMessage):
            return AnalyticsEvent(
                name: "error_occurred",
                parameters: [
                    "error_code": errorCode,
                    "error_message": errorMessage
                ]
            )

        case .apiCallFailed(let endpoint, let statusCode):
            return AnalyticsEvent(
                name: "api_call_failed",
                parameters: [
                    "endpoint": endpoint,
                    "status_code": statusCode
                ]
            )

        // Custom
        case .custom(let name, let parameters):
            return AnalyticsEvent(name: name, parameters: parameters)
        }
    }
}

// MARK: - Convenience Extension

public extension AnalyticsServiceProtocol {
    /// Track predefined app event
    ///
    /// Type-safe wrapper around trackEvent()
    ///
    /// - Parameter appEvent: AppAnalyticsEvent enum case
    func trackEvent(_ appEvent: AppAnalyticsEvent) {
        trackEvent(appEvent.event)
    }
}

// MARK: - Monetization Support

extension FirebaseAnalyticsService: MonetizationAnalyticsProtocol {
    /// Log event với name và parameters (for monetization integration)
    public func logEvent(name: String, parameters: [String: Any]) {
        Analytics.logEvent(name, parameters: parameters)

        if isDebugMode {
            logDebug("📊 Event tracked: \(name)")
            logDebug("   Parameters: \(parameters)")
        }
    }

    /// Log revenue event
    public func logRevenue(
        amount: Double,
        currency: String,
        productId: String,
        transactionId: String
    ) {
        let parameters: [String: Any] = [
            AnalyticsParameterValue: amount,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItemID: productId,
            AnalyticsParameterTransactionID: transactionId
        ]

        Analytics.logEvent(AnalyticsEventPurchase, parameters: parameters)

        if isDebugMode {
            logDebug("💰 Revenue tracked: \(amount) \(currency)")
            logDebug("   Product ID: \(productId)")
            logDebug("   Transaction ID: \(transactionId)")
        }
    }
}

/// Protocol extension để support monetization tracking for Firebase
extension FirebaseAnalyticsService: FirebaseAnalyticsServiceProtocol {
    /// Log purchase event với full details
    public func logPurchase(
        value: Double,
        currency: String,
        transactionId: String,
        items: [[String: Any]]
    ) {
        let parameters: [String: Any] = [
            AnalyticsParameterValue: value,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterTransactionID: transactionId,
            AnalyticsParameterItems: items
        ]

        Analytics.logEvent(AnalyticsEventPurchase, parameters: parameters)

        if isDebugMode {
            logDebug("💰 Purchase tracked: \(value) \(currency)")
            logDebug("   Transaction ID: \(transactionId)")
            logDebug("   Items: \(items)")
        }
    }
}

// Note: MonetizationAnalyticsProtocol and FirebaseAnalyticsServiceProtocol
// are defined in Sources/iOSTemplate/Monetization/MonetizationProtocols.swift
