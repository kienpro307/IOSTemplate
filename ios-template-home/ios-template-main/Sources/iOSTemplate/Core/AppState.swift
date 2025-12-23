import ComposableArchitecture
import Foundation

/// Global app state chứa tất cả state của application
/// Đây là single source of truth cho toàn bộ app
@ObservableState
public struct AppState: Equatable {
    // MARK: - User State

    /// State liên quan đến user hiện tại
    public var user: UserState

    // MARK: - Configuration State

    /// Remote config và feature flags
    public var config: ConfigState

    // MARK: - Navigation State

    /// State điều khiển navigation trong app
    public var navigation: NavigationState

    // MARK: - Network State

    /// State về kết nối mạng
    public var network: NetworkState

    // MARK: - Monetization State

    /// State về monetization (IAP, Ads, Revenue)
    public var monetization: MonetizationState

    // MARK: - Initialization

    public init(
        user: UserState = UserState(),
        config: ConfigState = ConfigState(),
        navigation: NavigationState = NavigationState(),
        network: NetworkState = NetworkState(),
        monetization: MonetizationState = MonetizationState()
    ) {
        self.user = user
        self.config = config
        self.navigation = navigation
        self.network = network
        self.monetization = monetization
    }
}

// MARK: - User State

/// State liên quan đến user
public struct UserState: Equatable {
    /// User profile nếu đã đăng nhập
    public var profile: UserProfile?

    /// User preferences và settings
    public var preferences: UserPreferences

    /// Trạng thái authentication
    public var isAuthenticated: Bool {
        profile != nil
    }

    public init(
        profile: UserProfile? = nil,
        preferences: UserPreferences = UserPreferences()
    ) {
        self.profile = profile
        self.preferences = preferences
    }
}

/// User profile model
public struct UserProfile: Equatable, Codable {
    public let id: String
    public let email: String
    public var name: String
    public var avatarURL: URL?

    public init(
        id: String,
        email: String,
        name: String,
        avatarURL: URL? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.avatarURL = avatarURL
    }
}

/// User preferences
public struct UserPreferences: Equatable, Codable {
    /// Theme mode: auto, light, dark
    public var themeMode: ThemeMode

    /// Selected language code
    public var languageCode: String

    /// Notification settings
    public var notificationsEnabled: Bool

    public init(
        themeMode: ThemeMode = .auto,
        languageCode: String = "en",
        notificationsEnabled: Bool = true
    ) {
        self.themeMode = themeMode
        self.languageCode = languageCode
        self.notificationsEnabled = notificationsEnabled
    }
}

public enum ThemeMode: String, Equatable, Codable {
    case auto
    case light
    case dark
}

// MARK: - Config State

/// State cho remote config và feature flags
public struct ConfigState: Equatable {
    /// Remote config values
    public var remoteConfig: [String: String]

    /// Feature flags
    public var featureFlags: FeatureFlags

    /// App version info
    public var appVersion: String
    public var buildNumber: String

    public init(
        remoteConfig: [String: String] = [:],
        featureFlags: FeatureFlags = FeatureFlags(),
        appVersion: String = "1.0.0",
        buildNumber: String = "1"
    ) {
        self.remoteConfig = remoteConfig
        self.featureFlags = featureFlags
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
}

/// Feature flags structure
public struct FeatureFlags: Equatable {
    public var showOnboarding: Bool
    public var enableAnalytics: Bool
    public var enablePushNotifications: Bool

    public init(
        showOnboarding: Bool = true,
        enableAnalytics: Bool = true,
        enablePushNotifications: Bool = true
    ) {
        self.showOnboarding = showOnboarding
        self.enableAnalytics = enableAnalytics
        self.enablePushNotifications = enablePushNotifications
    }
}

// MARK: - Navigation State

/// State điều khiển navigation
public struct NavigationState: Equatable {
    /// Selected tab trong TabView
    public var selectedTab: AppTab

    /// Deep link đang xử lý
    public var pendingDeepLink: URL?

    public init(
        selectedTab: AppTab = .home,
        pendingDeepLink: URL? = nil
    ) {
        self.selectedTab = selectedTab
        self.pendingDeepLink = pendingDeepLink
    }
}

/// Tabs trong app
public enum AppTab: String, Equatable, CaseIterable {
    case home
    case explore
    case profile
    case settings

    public var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    public var iconName: String {
        switch self {
        case .home: return "house"
        case .explore: return "magnifyingglass"
        case .profile: return "person"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - Network State

/// State về network connectivity
public struct NetworkState: Equatable {
    /// Có kết nối internet không
    public var isConnected: Bool

    /// Connection type
    public var connectionType: ConnectionType

    /// Pending requests (để cancel khi cần)
    public var pendingRequestsCount: Int

    public init(
        isConnected: Bool = true,
        connectionType: ConnectionType = .wifi,
        pendingRequestsCount: Int = 0
    ) {
        self.isConnected = isConnected
        self.connectionType = connectionType
        self.pendingRequestsCount = pendingRequestsCount
    }
}

public enum ConnectionType: Equatable {
    case wifi
    case cellular
    case ethernet
    case none
}

// MARK: - Monetization State

/// State cho monetization features
public struct MonetizationState: Equatable {
    /// User has premium (via IAP or subscription)
    public var hasPremium: Bool

    /// User has removed ads
    public var hasRemovedAds: Bool

    /// Active subscription info
    public var activeSubscription: SubscriptionInfo?

    /// Purchased product IDs
    public var purchasedProducts: Set<String>

    /// Ads enabled
    public var adsEnabled: Bool

    /// Total revenue (local tracking)
    public var totalRevenue: Double

    public init(
        hasPremium: Bool = false,
        hasRemovedAds: Bool = false,
        activeSubscription: SubscriptionInfo? = nil,
        purchasedProducts: Set<String> = [],
        adsEnabled: Bool = true,
        totalRevenue: Double = 0
    ) {
        self.hasPremium = hasPremium
        self.hasRemovedAds = hasRemovedAds
        self.activeSubscription = activeSubscription
        self.purchasedProducts = purchasedProducts
        self.adsEnabled = adsEnabled
        self.totalRevenue = totalRevenue
    }
}

/// Subscription info
public struct SubscriptionInfo: Equatable, Codable {
    public let productId: String
    public let expirationDate: Date?
    public let isInGracePeriod: Bool

    public var isActive: Bool {
        guard let expirationDate = expirationDate else { return true }
        return Date() < expirationDate || isInGracePeriod
    }

    public init(
        productId: String,
        expirationDate: Date? = nil,
        isInGracePeriod: Bool = false
    ) {
        self.productId = productId
        self.expirationDate = expirationDate
        self.isInGracePeriod = isInGracePeriod
    }
}
