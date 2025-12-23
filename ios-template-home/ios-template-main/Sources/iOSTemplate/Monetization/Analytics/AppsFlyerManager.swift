import Foundation
import Combine

/// Manager cho AppsFlyer analytics và attribution
/// Note: AppsFlyer SDK cần được thêm vào project
/// Thêm vào Package.swift hoặc CocoaPods: pod 'AppsFlyerFramework'
@MainActor
public final class AppsFlyerManager: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var isInitialized = false
    @Published public private(set) var attributionData: AttributionData?
    @Published public private(set) var appsFlyerUID: String?

    // MARK: - Private Properties

    private var conversionDataCompletion: ((AttributionData) -> Void)?

    // MARK: - Initialization

    nonisolated public init() {}

    /// Initialize AppsFlyer
    public func initialize() {
        // Real implementation with AppsFlyer SDK:
        // AppsFlyerLib.shared().appsFlyerDevKey = AppsFlyerConfiguration.devKey
        // AppsFlyerLib.shared().appleAppID = AppsFlyerConfiguration.appleAppID
        // AppsFlyerLib.shared().isDebug = AppsFlyerConfiguration.isDebug
        // AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        // AppsFlyerLib.shared().delegate = self
        // AppsFlyerLib.shared().start()

        isInitialized = true
        print("✅ AppsFlyer initialized (Mock)")

        // Mock UID
        appsFlyerUID = UUID().uuidString
    }

    // MARK: - Event Tracking

    /// Log custom event
    public func logEvent(name: String, values: [String: Any]? = nil) {
        guard isInitialized else {
            print("⚠️ AppsFlyer not initialized")
            return
        }

        print("📊 AppsFlyer Event: \(name)")
        if let values = values {
            print("   Values: \(values)")
        }

        // Real implementation:
        // AppsFlyerLib.shared().logEvent(name, withValues: values)
    }

    // MARK: - Revenue Tracking

    /// Track revenue event
    public func trackRevenue(
        amount: Double,
        currency: String,
        productId: String,
        source: RevenueSource,
        transactionId: String? = nil,
        additionalData: [String: Any]? = nil
    ) {
        var eventValues: [String: Any] = [
            "af_revenue": amount,
            "af_currency": currency,
            "af_content_id": productId,
            "af_revenue_source": source.rawValue
        ]

        if let transactionId = transactionId {
            eventValues["af_receipt_id"] = transactionId
        }

        if let additionalData = additionalData {
            eventValues.merge(additionalData) { _, new in new }
        }

        logEvent(name: source.eventName, values: eventValues)
    }

    /// Track in-app purchase
    public func trackPurchase(
        productId: String,
        price: Double,
        currency: String,
        transactionId: String,
        quantity: Int = 1
    ) {
        let eventValues: [String: Any] = [
            "af_revenue": price,
            "af_currency": currency,
            "af_content_id": productId,
            "af_quantity": quantity,
            "af_receipt_id": transactionId
        ]

        logEvent(name: "af_purchase", values: eventValues)
    }

    /// Track subscription
    public func trackSubscription(
        productId: String,
        price: Double,
        currency: String,
        period: String,
        isNewSubscription: Bool
    ) {
        let eventValues: [String: Any] = [
            "af_revenue": price,
            "af_currency": currency,
            "af_content_id": productId,
            "af_subscription_period": period,
            "af_new_subscription": isNewSubscription
        ]

        logEvent(name: "af_subscribe", values: eventValues)
    }

    /// Track ad revenue
    public func trackAdRevenue(
        revenue: Double,
        currency: String,
        adNetwork: String,
        adUnit: String,
        placement: String
    ) {
        let eventValues: [String: Any] = [
            "af_revenue": revenue,
            "af_currency": currency,
            "af_ad_network": adNetwork,
            "af_ad_unit": adUnit,
            "af_placement": placement
        ]

        logEvent(name: "af_ad_revenue", values: eventValues)
    }

    // MARK: - User Properties

    /// Set customer user ID
    public func setCustomerUserId(_ userId: String) {
        print("👤 AppsFlyer User ID: \(userId)")

        // Real implementation:
        // AppsFlyerLib.shared().customerUserID = userId
    }

    /// Set user email (for attribution)
    public func setUserEmails(_ emails: [String]) {
        print("📧 AppsFlyer User Emails: \(emails)")

        // Real implementation:
        // AppsFlyerLib.shared().setUserEmails(emails, withCryptType: .none)
    }

    // MARK: - Deep Linking

    /// Handle deep link
    public func handleDeepLink(url: URL) {
        print("🔗 AppsFlyer Deep Link: \(url)")

        // Real implementation:
        // AppsFlyerLib.shared().handleOpen(url, options: nil)
    }

    /// Handle universal link
    public func handleUniversalLink(userActivity: Any) {
        print("🔗 AppsFlyer Universal Link")

        // Real implementation:
        // AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }

    // MARK: - Attribution

    /// Get conversion data
    public func getConversionData(completion: @escaping (AttributionData) -> Void) {
        conversionDataCompletion = completion

        // Mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            let mockData = AttributionData(
                campaign: "mock_campaign",
                mediaSource: "organic",
                channel: "App Store",
                installTime: Date()
            )

            self?.attributionData = mockData
            completion(mockData)
        }
    }
}

// MARK: - Standard Events

extension AppsFlyerManager {
    /// Standard event names
    public enum StandardEvent: String {
        case completeRegistration = "af_complete_registration"
        case tutorialCompletion = "af_tutorial_completion"
        case addToCart = "af_add_to_cart"
        case initiatedCheckout = "af_initiated_checkout"
        case purchase = "af_purchase"
        case subscribe = "af_subscribe"
        case startTrial = "af_start_trial"
        case levelAchieved = "af_level_achieved"
        case achievement = "af_achievement_unlocked"
        case spentCredits = "af_spent_credits"
        case search = "af_search"
        case rate = "af_rate"
        case share = "af_share"
        case invite = "af_invite"
        case login = "af_login"
        case update = "af_update"
        case openedFromPush = "af_opened_from_push"
        case adClick = "af_ad_click"
        case adView = "af_ad_view"
    }

    /// Log standard event
    public func logStandardEvent(_ event: StandardEvent, values: [String: Any]? = nil) {
        logEvent(name: event.rawValue, values: values)
    }
}
