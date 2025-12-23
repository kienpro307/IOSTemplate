import Foundation

/// AppsFlyer configuration
public struct AppsFlyerConfiguration {
    // MARK: - Configuration

    /// AppsFlyer Dev Key - Replace with your actual key
    public static let devKey = "YOUR_APPSFLYER_DEV_KEY"

    /// Apple App ID
    public static let appleAppID = "123456789"

    // MARK: - Settings

    /// Enable debug mode
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Minimum time between sessions (in seconds)
    public static let minTimeBetweenSessions: TimeInterval = 5

    /// Wait for ATT User authorization (iOS 14+)
    public static let waitForATT = true

    // MARK: - Deep Linking

    /// Deep link scheme
    public static let deepLinkScheme = "iostemplate"

    /// Universal link domains
    public static let universalLinkDomains = [
        "iostemplate.onelink.me"
    ]
}

/// Revenue source
public enum RevenueSource: String {
    case iap = "in_app_purchase"
    case adMob = "admob"
    case subscription = "subscription"
    case other = "other"

    public var eventName: String {
        switch self {
        case .iap: return "af_purchase"
        case .adMob: return "af_ad_revenue"
        case .subscription: return "af_subscribe"
        case .other: return "af_revenue"
        }
    }
}

/// Attribution data
public struct AttributionData: Codable {
    public let campaign: String?
    public let mediaSource: String?
    public let channel: String?
    public let adGroup: String?
    public let adSet: String?
    public let installTime: Date?

    public init(
        campaign: String? = nil,
        mediaSource: String? = nil,
        channel: String? = nil,
        adGroup: String? = nil,
        adSet: String? = nil,
        installTime: Date? = nil
    ) {
        self.campaign = campaign
        self.mediaSource = mediaSource
        self.channel = channel
        self.adGroup = adGroup
        self.adSet = adSet
        self.installTime = installTime
    }
}
