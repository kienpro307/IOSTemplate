import Foundation
import Combine

/// Manager cho AdMob operations
/// Note: Google Mobile Ads SDK cần được thêm vào project qua CocoaPods
/// Thêm vào Podfile: pod 'Google-Mobile-Ads-SDK'
@MainActor
public final class AdMobManager: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var isInitialized = false
    @Published public private(set) var adsEnabled = true
    @Published public private(set) var interstitialLoadState: AdLoadState = .idle
    @Published public private(set) var rewardedLoadState: AdLoadState = .idle

    // MARK: - Private Properties

    private var interstitialAdCount = 0
    private var lastInterstitialTime: Date?
    private var lastRewardedTime: Date?

    // MARK: - Initialization

    nonisolated public init() {
        // Constructor
    }

    /// Initialize AdMob SDK
    public func initialize() {
        // Note: Actual initialization sẽ cần Google Mobile Ads SDK
        // GADMobileAds.sharedInstance().start { [weak self] status in
        //     self?.isInitialized = true
        // }

        // For now, mark as initialized
        isInitialized = true
        print("✅ AdMob initialized (Mock)")
    }

    /// Enable or disable ads
    public func setAdsEnabled(_ enabled: Bool) {
        adsEnabled = enabled
    }

    // MARK: - Interstitial Ads

    /// Load interstitial ad
    public func loadInterstitialAd(for placement: AdPlacement) {
        guard adsEnabled else {
            print("⚠️ Ads are disabled")
            return
        }

        guard canShowInterstitial() else {
            print("⚠️ Cannot show interstitial yet (frequency limit)")
            return
        }

        interstitialLoadState = .loading

        // Mock loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.interstitialLoadState = .loaded
            print("✅ Interstitial ad loaded for placement: \(placement.description)")
        }

        // Real implementation:
        // let request = GADRequest()
        // GADInterstitialAd.load(withAdUnitID: AdMobConfiguration.interstitialAdUnitID, request: request) { [weak self] ad, error in
        //     if let error = error {
        //         self?.interstitialLoadState = .failed(error)
        //     } else {
        //         self?.interstitialLoadState = .loaded
        //     }
        // }
    }

    /// Show interstitial ad
    public func showInterstitialAd(from viewController: Any? = nil) -> Bool {
        guard adsEnabled else { return false }
        guard interstitialLoadState == .loaded else { return false }
        guard canShowInterstitial() else { return false }

        interstitialLoadState = .presented
        lastInterstitialTime = Date()
        interstitialAdCount += 1

        print("✅ Showing interstitial ad")

        // Reset state after presentation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.interstitialLoadState = .idle
        }

        return true

        // Real implementation:
        // guard let rootViewController = viewController as? UIViewController else { return false }
        // interstitialAd?.present(fromRootViewController: rootViewController)
    }

    /// Check if can show interstitial
    private func canShowInterstitial() -> Bool {
        // Check session limit
        if interstitialAdCount >= AdMobConfiguration.maxInterstitialPerSession {
            return false
        }

        // Check time interval
        if let lastTime = lastInterstitialTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < AdMobConfiguration.interstitialMinInterval {
                return false
            }
        }

        return true
    }

    // MARK: - Rewarded Ads

    /// Load rewarded ad
    public func loadRewardedAd() {
        guard adsEnabled else { return }

        rewardedLoadState = .loading

        // Mock loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.rewardedLoadState = .loaded
            print("✅ Rewarded ad loaded")
        }

        // Real implementation:
        // let request = GADRequest()
        // GADRewardedAd.load(withAdUnitID: AdMobConfiguration.rewardedAdUnitID, request: request) { [weak self] ad, error in
        //     if let error = error {
        //         self?.rewardedLoadState = .failed(error)
        //     } else {
        //         self?.rewardedLoadState = .loaded
        //     }
        // }
    }

    /// Show rewarded ad
    public func showRewardedAd(
        from viewController: Any? = nil,
        completion: @escaping (Bool, Int) -> Void
    ) {
        guard adsEnabled else {
            completion(false, 0)
            return
        }

        guard rewardedLoadState == .loaded else {
            completion(false, 0)
            return
        }

        guard canShowRewarded() else {
            completion(false, 0)
            return
        }

        rewardedLoadState = .presented
        lastRewardedTime = Date()

        print("✅ Showing rewarded ad")

        // Mock reward
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.rewardedLoadState = .idle
            completion(true, 100) // 100 coins reward
        }

        // Real implementation:
        // guard let rootViewController = viewController as? UIViewController else {
        //     completion(false, 0)
        //     return
        // }
        // rewardedAd?.present(fromRootViewController: rootViewController) { [weak self] in
        //     let reward = self?.rewardedAd?.adReward
        //     completion(true, reward?.amount.intValue ?? 0)
        // }
    }

    /// Check if can show rewarded ad
    private func canShowRewarded() -> Bool {
        if let lastTime = lastRewardedTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < AdMobConfiguration.rewardedMinInterval {
                return false
            }
        }
        return true
    }

    // MARK: - Reset

    /// Reset ad counters (call khi start new session)
    public func resetCounters() {
        interstitialAdCount = 0
        lastInterstitialTime = nil
        lastRewardedTime = nil
    }
}
