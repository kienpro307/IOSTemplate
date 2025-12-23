import Foundation

/// AdMob configuration
public struct AdMobConfiguration {
    // MARK: - Ad Unit IDs

    /// App ID - Replace with your AdMob App ID
    public static let appID = "ca-app-pub-3940256099942544~1458002511" // Test App ID

    /// Banner ad unit ID
    public static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716" // Test Banner

    /// Interstitial ad unit ID
    public static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test Interstitial

    /// Rewarded ad unit ID
    public static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // Test Rewarded

    /// Native advanced ad unit ID
    public static let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511" // Test Native

    // MARK: - Ad Frequency Settings

    /// Minimum time between interstitial ads (in seconds)
    public static let interstitialMinInterval: TimeInterval = 60

    /// Maximum interstitial ads per session
    public static let maxInterstitialPerSession = 5

    /// Minimum time between rewarded ads (in seconds)
    public static let rewardedMinInterval: TimeInterval = 30

    // MARK: - Test Device IDs

    /// Test device IDs for testing ads
    public static let testDeviceIDs: [String] = [
        // Add your test device IDs here
        // Example: "33BE2250B43518CCDA7DE426D04EE231"
    ]

    // MARK: - Environment

    /// Is production environment
    public static var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
}

/// Ad placement trong app
public enum AdPlacement: String {
    case homeScreen = "home_screen"
    case articleDetail = "article_detail"
    case videoComplete = "video_complete"
    case levelComplete = "level_complete"
    case appOpen = "app_open"
    case settings = "settings"

    public var description: String {
        switch self {
        case .homeScreen: return "Home Screen"
        case .articleDetail: return "Article Detail"
        case .videoComplete: return "Video Complete"
        case .levelComplete: return "Level Complete"
        case .appOpen: return "App Open"
        case .settings: return "Settings"
        }
    }
}

/// Ad load state
public enum AdLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(Error)
    case presented

    public static func == (lhs: AdLoadState, rhs: AdLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.presented, .presented):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
