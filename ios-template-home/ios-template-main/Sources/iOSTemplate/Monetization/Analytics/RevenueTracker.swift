import Foundation
import Combine

/// Service để track revenue từ tất cả sources
@MainActor
public final class RevenueTracker: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var totalRevenue: Double = 0
    @Published public private(set) var iapRevenue: Double = 0
    @Published public private(set) var adRevenue: Double = 0
    @Published public private(set) var subscriptionRevenue: Double = 0

    // MARK: - Dependencies

    private let appsFlyerManager: AppsFlyerManager
    private let analyticsService: FirebaseAnalyticsServiceProtocol?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    nonisolated public init(
        appsFlyerManager: AppsFlyerManager,
        analyticsService: FirebaseAnalyticsServiceProtocol? = nil
    ) {
        self.appsFlyerManager = appsFlyerManager
        self.analyticsService = analyticsService
    }

    // MARK: - Revenue Tracking

    /// Track IAP purchase
    public func trackIAPPurchase(
        productId: String,
        price: Double,
        currency: String,
        transactionId: String,
        quantity: Int = 1
    ) {
        // Update local revenue
        iapRevenue += price
        totalRevenue += price

        // Track in AppsFlyer
        appsFlyerManager.trackPurchase(
            productId: productId,
            price: price,
            currency: currency,
            transactionId: transactionId,
            quantity: quantity
        )

        // Track in Firebase
        analyticsService?.logPurchase(
            value: price,
            currency: currency,
            transactionId: transactionId,
            items: [
                [
                    "item_id": productId,
                    "item_name": productId,
                    "price": price,
                    "quantity": quantity
                ]
            ]
        )

        print("💰 IAP Revenue tracked: \(price) \(currency)")
    }

    /// Track subscription
    public func trackSubscription(
        productId: String,
        price: Double,
        currency: String,
        period: SubscriptionPeriod,
        isNewSubscription: Bool,
        transactionId: String
    ) {
        // Update local revenue
        subscriptionRevenue += price
        totalRevenue += price

        // Track in AppsFlyer
        appsFlyerManager.trackSubscription(
            productId: productId,
            price: price,
            currency: currency,
            period: period.rawValue,
            isNewSubscription: isNewSubscription
        )

        // Track in Firebase
        analyticsService?.logPurchase(
            value: price,
            currency: currency,
            transactionId: transactionId,
            items: [
                [
                    "item_id": productId,
                    "item_name": "Subscription: \(period.rawValue)",
                    "price": price,
                    "quantity": 1,
                    "subscription_period": period.rawValue,
                    "is_new_subscription": isNewSubscription
                ]
            ]
        )

        print("💰 Subscription Revenue tracked: \(price) \(currency)")
    }

    /// Track ad revenue
    public func trackAdRevenue(
        revenue: Double,
        currency: String,
        adNetwork: String,
        adUnit: String,
        placement: String
    ) {
        // Update local revenue
        adRevenue += revenue
        totalRevenue += revenue

        // Track in AppsFlyer
        appsFlyerManager.trackAdRevenue(
            revenue: revenue,
            currency: currency,
            adNetwork: adNetwork,
            adUnit: adUnit,
            placement: placement
        )

        // Track in Firebase (as a custom event for ad revenue)
        analyticsService?.logPurchase(
            value: revenue,
            currency: currency,
            transactionId: "ad_\(Date().timeIntervalSince1970)",
            items: [
                [
                    "item_id": "ad_revenue",
                    "item_name": "Ad Revenue: \(adNetwork)",
                    "price": revenue,
                    "quantity": 1,
                    "ad_network": adNetwork,
                    "ad_unit": adUnit,
                    "placement": placement
                ]
            ]
        )

        print("💰 Ad Revenue tracked: \(revenue) \(currency)")
    }

    // MARK: - Analytics

    /// Get revenue summary
    public func getRevenueSummary() -> RevenueSummary {
        return RevenueSummary(
            total: totalRevenue,
            iap: iapRevenue,
            ads: adRevenue,
            subscriptions: subscriptionRevenue
        )
    }

    /// Reset revenue counters
    public func resetCounters() {
        totalRevenue = 0
        iapRevenue = 0
        adRevenue = 0
        subscriptionRevenue = 0
    }
}

// MARK: - Supporting Types

/// Subscription period
public enum SubscriptionPeriod: String {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

/// Revenue summary
public struct RevenueSummary: Codable {
    public let total: Double
    public let iap: Double
    public let ads: Double
    public let subscriptions: Double

    public var formattedTotal: String {
        String(format: "$%.2f", total)
    }
}

// Note: FirebaseAnalyticsServiceProtocol is defined in MonetizationProtocols.swift
