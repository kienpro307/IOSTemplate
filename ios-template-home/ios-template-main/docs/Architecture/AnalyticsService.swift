import Foundation
import FirebaseAnalytics

/// High-level Analytics service
///
/// Provides type-safe, convenient methods for tracking events
///
/// ## Usage:
/// ```swift
/// // Track screen
/// AnalyticsService.shared.trackScreen("home")
///
/// // Log custom event
/// AnalyticsService.shared.logEvent(.featureUsed, parameters: ["feature": "dark_mode"])
///
/// // Track user properties
/// AnalyticsService.shared.setUserID("user123")
/// AnalyticsService.shared.setUserProperty("premium", forName: "user_type")
/// ```
///
public final class AnalyticsService {
    
    // MARK: - Singleton
    
    public static let shared = AnalyticsService()
    
    private let firebaseManager: FirebaseManager
    
    public init(firebaseManager: FirebaseManager = .shared) {
        self.firebaseManager = firebaseManager
    }
    
    // MARK: - Event Logging
    
    /// Log custom event với parameters
    ///
    /// - Parameters:
    ///   - event: Type-safe analytics event
    ///   - parameters: Optional parameters dictionary
    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping event: \(event.name)")
            return
        }
        
        Analytics.logEvent(event.name, parameters: parameters)
        logDebug("[Analytics] Event logged: \(event.name)")
    }
    
    /// Log predefined event with string name
    ///
    /// - Parameters:
    ///   - name: Event name
    ///   - parameters: Optional parameters dictionary
    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping event: \(name)")
            return
        }
        
        Analytics.logEvent(name, parameters: parameters)
        logDebug("[Analytics] Event logged: \(name)")
    }
    
    // MARK: - Screen Tracking
    
    /// Track screen view
    ///
    /// - Parameters:
    ///   - screenName: Name of the screen (e.g., "home", "login")
    ///   - screenClass: Optional screen class (defaults to screenName)
    public func trackScreen(_ screenName: String, screenClass: String? = nil) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping screen: \(screenName)")
            return
        }
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        
        logDebug("[Analytics] Screen tracked: \(screenName)")
    }
    
    // MARK: - User Properties
    
    /// Set user ID
    ///
    /// - Parameter userID: User identifier (nil to clear)
    public func setUserID(_ userID: String?) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping setUserID")
            return
        }
        
        Analytics.setUserID(userID)
        logDebug("[Analytics] User ID set: \(userID ?? "nil")")
    }
    
    /// Set user property
    ///
    /// - Parameters:
    ///   - value: Property value (nil to clear)
    ///   - name: Property name
    public func setUserProperty(_ value: String?, forName name: String) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping user property: \(name)")
            return
        }
        
        Analytics.setUserProperty(value, forName: name)
        logDebug("[Analytics] User property set: \(name) = \(value ?? "nil")")
    }
    
    /// Set multiple user properties
    ///
    /// - Parameter properties: Dictionary of property names and values
    public func setUserProperties(_ properties: [String: String?]) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping user properties")
            return
        }
        
        properties.forEach { key, value in
            setUserProperty(value, forName: key)
        }
    }
    
    // MARK: - E-commerce Events
    
    /// Track purchase
    ///
    /// - Parameters:
    ///   - transactionID: Unique transaction identifier
    ///   - value: Total transaction value
    ///   - currency: Currency code (default: "USD")
    ///   - items: Optional array of purchased items
    public func trackPurchase(
        transactionID: String,
        value: Double,
        currency: String = "USD",
        items: [[String: Any]]? = nil
    ) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping purchase")
            return
        }
        
        var params: [String: Any] = [
            AnalyticsParameterTransactionID: transactionID,
            AnalyticsParameterValue: value,
            AnalyticsParameterCurrency: currency
        ]
        
        if let items = items {
            params[AnalyticsParameterItems] = items
        }
        
        Analytics.logEvent(AnalyticsEventPurchase, parameters: params)
        logDebug("[Analytics] Purchase tracked: \(transactionID) - \(value) \(currency)")
    }
    
    /// Track add to cart
    ///
    /// - Parameters:
    ///   - itemID: Item identifier
    ///   - itemName: Item name
    ///   - price: Item price
    ///   - currency: Currency code (default: "USD")
    public func trackAddToCart(
        itemID: String,
        itemName: String,
        price: Double,
        currency: String = "USD"
    ) {
        guard firebaseManager.isServiceEnabled(.analytics) else {
            logDebug("[Analytics] Service not enabled, skipping add to cart")
            return
        }
        
        Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
            AnalyticsParameterItemID: itemID,
            AnalyticsParameterItemName: itemName,
            AnalyticsParameterPrice: price,
            AnalyticsParameterCurrency: currency
        ])
        
        logDebug("[Analytics] Add to cart tracked: \(itemName)")
    }
    
    /// Track begin checkout
    ///
    /// - Parameters:
    ///   - value: Total cart value
    ///   - currency: Currency code (default: "USD")
    ///   - items: Optional array of cart items
    public func trackBeginCheckout(
        value: Double,
        currency: String = "USD",
        items: [[String: Any]]? = nil
    ) {
        guard firebaseManager.isServiceEnabled(.analytics) else { return }
        
        var params: [String: Any] = [
            AnalyticsParameterValue: value,
            AnalyticsParameterCurrency: currency
        ]
        
        if let items = items {
            params[AnalyticsParameterItems] = items
        }
        
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: params)
        logDebug("[Analytics] Begin checkout tracked: \(value) \(currency)")
    }
    
    // MARK: - Conversion Events
    
    /// Track sign up
    ///
    /// - Parameter method: Sign up method (e.g., "email", "google", "apple")
    public func trackSignUp(method: String) {
        logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// Track login
    ///
    /// - Parameter method: Login method (e.g., "email", "google", "apple")
    public func trackLogin(method: String) {
        logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// Track search
    ///
    /// - Parameter searchTerm: Search query string
    public func trackSearch(searchTerm: String) {
        logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm
        ])
    }
    
    /// Track share
    ///
    /// - Parameters:
    ///   - contentType: Type of content shared
    ///   - itemID: Optional item identifier
    ///   - method: Share method (e.g., "sms", "email", "social")
    public func trackShare(contentType: String, itemID: String? = nil, method: String? = nil) {
        var params: [String: Any] = [
            AnalyticsParameterContentType: contentType
        ]
        
        if let itemID = itemID {
            params[AnalyticsParameterItemID] = itemID
        }
        
        if let method = method {
            params[AnalyticsParameterMethod] = method
        }
        
        logEvent(AnalyticsEventShare, parameters: params)
    }
    
    /// Track tutorial begin
    public func trackTutorialBegin() {
        logEvent(AnalyticsEventTutorialBegin)
    }
    
    /// Track tutorial complete
    public func trackTutorialComplete() {
        logEvent(AnalyticsEventTutorialComplete)
    }
    
    // MARK: - App Lifecycle
    
    /// Track app open
    public func trackAppOpen() {
        logEvent(.appOpen)
    }
    
    /// Track app background
    public func trackAppBackground() {
        logEvent(.appBackground)
    }
    
    // MARK: - Helpers
    
    private func logDebug(_ message: String) {
        if firebaseManager.config?.isDebugMode == true {
            print(message)
        }
    }
}

// MARK: - Type-Safe Events

/// Type-safe analytics events
///
/// Use predefined events or create custom ones:
/// ```swift
/// // Predefined
/// analytics.logEvent(.appOpen)
///
/// // Custom
/// let customEvent = AnalyticsEvent(name: "custom_action")
/// analytics.logEvent(customEvent)
/// ```
public struct AnalyticsEvent {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

// MARK: - Common Events

public extension AnalyticsEvent {
    // App lifecycle
    static let appOpen = AnalyticsEvent(name: "app_open")
    static let appBackground = AnalyticsEvent(name: "app_background")
    static let appForeground = AnalyticsEvent(name: "app_foreground")
    
    // Features
    static let featureUsed = AnalyticsEvent(name: "feature_used")
    static let featureDiscovered = AnalyticsEvent(name: "feature_discovered")
    
    // Errors
    static let errorOccurred = AnalyticsEvent(name: "error_occurred")
    static let errorRecovered = AnalyticsEvent(name: "error_recovered")
    
    // Onboarding
    static let onboardingStarted = AnalyticsEvent(name: "onboarding_started")
    static let onboardingCompleted = AnalyticsEvent(name: "onboarding_completed")
    static let onboardingSkipped = AnalyticsEvent(name: "onboarding_skipped")
    
    // Settings
    static let settingsOpened = AnalyticsEvent(name: "settings_opened")
    static let settingChanged = AnalyticsEvent(name: "setting_changed")
    
    // Content
    static let contentViewed = AnalyticsEvent(name: "content_viewed")
    static let contentShared = AnalyticsEvent(name: "content_shared")
    static let contentLiked = AnalyticsEvent(name: "content_liked")
}
