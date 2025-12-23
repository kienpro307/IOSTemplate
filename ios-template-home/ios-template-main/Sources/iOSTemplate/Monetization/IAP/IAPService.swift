import Foundation
import StoreKit
import Combine

/// Protocol cho IAP service
public protocol IAPServiceProtocol {
    /// Load available products
    func loadProducts() async

    /// Purchase a product
    func purchase(productId: String) async throws -> Bool

    /// Restore purchases
    func restorePurchases() async throws

    /// Check if user has premium
    func hasPremium() async -> Bool

    /// Check if ads are removed
    func hasRemovedAds() async -> Bool

    /// Get active subscription
    func getActiveSubscription() async -> Product?
}

/// IAP Service implementation
@MainActor
public final class IAPService: IAPServiceProtocol {
    // MARK: - Properties

    private let storeKitManager: StoreKitManager
    private let analyticsService: MonetizationAnalyticsProtocol?

    // MARK: - Initialization

    nonisolated public init(
        storeKitManager: StoreKitManager,
        analyticsService: MonetizationAnalyticsProtocol? = nil
    ) {
        self.storeKitManager = storeKitManager
        self.analyticsService = analyticsService
    }

    // MARK: - IAPServiceProtocol

    public func loadProducts() async {
        await storeKitManager.loadProducts()
    }

    public func purchase(productId: String) async throws -> Bool {
        // Track purchase attempt
        analyticsService?.logEvent(
            name: "iap_purchase_attempt",
            parameters: ["product_id": productId]
        )

        guard let product = storeKitManager.products.first(where: { $0.id == productId }) else {
            throw IAPError.productNotFound
        }

        do {
            let transaction = try await storeKitManager.purchase(product)

            if let transaction = transaction {
                // Track successful purchase
                analyticsService?.logEvent(
                    name: "iap_purchase_success",
                    parameters: [
                        "product_id": productId,
                        "transaction_id": String(transaction.id),
                        "price": product.price,
                        "currency": product.priceFormatStyle.currencyCode ?? "USD"
                    ]
                )

                // Track revenue
                analyticsService?.logRevenue(
                    amount: Double(truncating: product.price as NSNumber),
                    currency: product.priceFormatStyle.currencyCode ?? "USD",
                    productId: productId,
                    transactionId: String(transaction.id)
                )

                return true
            }

            return false
        } catch {
            // Track failed purchase
            analyticsService?.logEvent(
                name: "iap_purchase_failed",
                parameters: [
                    "product_id": productId,
                    "error": error.localizedDescription
                ]
            )

            throw error
        }
    }

    public func restorePurchases() async throws {
        analyticsService?.logEvent(name: "iap_restore_attempt", parameters: [:])

        await storeKitManager.restorePurchases()

        analyticsService?.logEvent(name: "iap_restore_success", parameters: [:])
    }

    public func hasPremium() async -> Bool {
        // Check if user has premium unlock or active subscription
        let hasPremiumUnlock = storeKitManager.purchasedProductIDs.contains(IAPProduct.premiumUnlock.rawValue)
        let hasActiveSubscription = !storeKitManager.activeSubscriptions.isEmpty

        return hasPremiumUnlock || hasActiveSubscription
    }

    public func hasRemovedAds() async -> Bool {
        // Check if user purchased remove ads or has premium
        let hasRemoveAds = storeKitManager.purchasedProductIDs.contains(IAPProduct.removeAds.rawValue)
        let hasPremium = await hasPremium()

        return hasRemoveAds || hasPremium
    }

    public func getActiveSubscription() async -> Product? {
        return storeKitManager.activeSubscriptions.first
    }
}

// Note: MonetizationAnalyticsProtocol is defined in MonetizationProtocols.swift
