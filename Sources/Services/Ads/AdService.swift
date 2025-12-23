import Foundation
import ComposableArchitecture

/// Ad service protocol (AdMob)
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol AdServiceProtocol: Sendable {
    /// Load banner ad
    func loadBannerAd(adUnitId: String) async throws
    
    /// Load interstitial ad
    func loadInterstitialAd(adUnitId: String) async throws
    
    /// Show interstitial ad
    func showInterstitialAd() async throws
    
    /// Load rewarded ad
    func loadRewardedAd(adUnitId: String) async throws
    
    /// Show rewarded ad
    func showRewardedAd() async throws -> Bool
}

// MARK: - Placeholder Implementation
/// Placeholder - Sẽ implement sau khi có Google Mobile Ads SDK
public actor LiveAdService: AdServiceProtocol {
    public init() {}
    
    public func loadBannerAd(adUnitId: String) async throws {
        // TODO: Implement với Google Mobile Ads SDK
    }
    
    public func loadInterstitialAd(adUnitId: String) async throws {
        // TODO: Implement với Google Mobile Ads SDK
    }
    
    public func showInterstitialAd() async throws {
        // TODO: Implement với Google Mobile Ads SDK
    }
    
    public func loadRewardedAd(adUnitId: String) async throws {
        // TODO: Implement với Google Mobile Ads SDK
    }
    
    public func showRewardedAd() async throws -> Bool {
        // TODO: Implement với Google Mobile Ads SDK
        return false
    }
}

// MARK: - Mock Implementation
public actor MockAdService: AdServiceProtocol {
    public init() {}
    
    public func loadBannerAd(adUnitId: String) async throws {
        // Mock: không làm gì
    }
    
    public func loadInterstitialAd(adUnitId: String) async throws {
        // Mock: không làm gì
    }
    
    public func showInterstitialAd() async throws {
        // Mock: không làm gì
    }
    
    public func loadRewardedAd(adUnitId: String) async throws {
        // Mock: không làm gì
    }
    
    public func showRewardedAd() async throws -> Bool {
        return true
    }
}

// MARK: - Dependency Key
private enum AdServiceKey: DependencyKey {
    static let liveValue: AdServiceProtocol = LiveAdService()
    static let testValue: AdServiceProtocol = MockAdService()
    static let previewValue: AdServiceProtocol = MockAdService()
}

extension DependencyValues {
    public var adService: AdServiceProtocol {
        get { self[AdServiceKey.self] }
        set { self[AdServiceKey.self] = newValue }
    }
}

