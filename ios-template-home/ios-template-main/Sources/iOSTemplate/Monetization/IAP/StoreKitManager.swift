import Foundation
import StoreKit
import Combine

/// Manager cho StoreKit 2 operations
@MainActor
public final class StoreKitManager: ObservableObject {
    // MARK: - Published Properties

    /// Available products
    @Published public private(set) var products: [Product] = []

    /// Purchased product IDs
    @Published public private(set) var purchasedProductIDs: Set<String> = []

    /// Active subscriptions
    @Published public private(set) var activeSubscriptions: [Product] = []

    /// Loading state
    @Published public private(set) var isLoading: Bool = false

    /// Error message
    @Published public private(set) var errorMessage: String?

    // MARK: - Private Properties

    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    nonisolated public init() {
        // Start listening for transaction updates
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.updateListenerTask = self.listenForTransactions()
            await self.loadProducts()
            await self.updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    /// Load products from App Store
    public func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIds = IAPProduct.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: productIds)

            // Sort products by price
            products = storeProducts.sorted { $0.price < $1.price }

            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase Flow

    /// Purchase a product
    public func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update purchased products
                await updatePurchasedProducts()

                // Finish the transaction
                await transaction.finish()

                isLoading = false
                return transaction

            case .userCancelled:
                isLoading = false
                return nil

            case .pending:
                errorMessage = "Purchase is pending approval"
                isLoading = false
                return nil

            @unknown default:
                errorMessage = "Unknown purchase result"
                isLoading = false
                return nil
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    /// Check if product is purchased
    public func isPurchased(_ product: Product) async -> Bool {
        return purchasedProductIDs.contains(product.id)
    }

    // MARK: - Subscription Management

    /// Check subscription status
    public func checkSubscriptionStatus() async {
        var activeSubscriptionProducts: [Product] = []

        for product in products where product.type == .autoRenewable {
            guard let subscription = product.subscription else { continue }

            // Check if user has an active subscription
            if let status = try? await subscription.status.first {
                switch status.state {
                case .subscribed, .inGracePeriod:
                    if await isPurchased(product) {
                        activeSubscriptionProducts.append(product)
                    }
                default:
                    break
                }
            }
        }

        activeSubscriptions = activeSubscriptionProducts
    }

    /// Get subscription info
    public func getSubscriptionInfo(for product: Product) async -> StoreKitSubscriptionInfo? {
        guard product.type == .autoRenewable,
              let subscription = product.subscription else {
            return nil
        }

        guard let status = try? await subscription.status.first else {
            return nil
        }

        let transaction = try? checkVerified(status.transaction)

        // Verify and unwrap renewalInfo
        guard let renewalInfo = try? checkVerified(status.renewalInfo) else {
            return nil
        }

        return StoreKitSubscriptionInfo(
            productId: product.id,
            state: renewalInfo.willAutoRenew ? .subscribed : .expired,
            renewalInfo: renewalInfo,
            transaction: transaction
        )
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    public func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        // In StoreKit 2, just update purchased products from transaction history
        // No need to call sync() - transactions are automatically synced
        await updatePurchasedProducts()
        isLoading = false
    }

    // MARK: - Transaction Handling

    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Update purchased products
                    await self.updatePurchasedProducts()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }

    /// Update purchased products from transaction history
    private func updatePurchasedProducts() async {
        var purchasedProducts: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else {
                continue
            }

            // Check if transaction is not revoked
            if transaction.revocationDate == nil {
                purchasedProducts.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedProducts

        // Update subscription status
        await checkSubscriptionStatus()
    }

    /// Verify transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw IAPError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Supporting Types

/// StoreKit subscription information (detailed)
public struct StoreKitSubscriptionInfo {
    public let productId: String
    public let state: Product.SubscriptionInfo.RenewalState
    public let renewalInfo: Product.SubscriptionInfo.RenewalInfo
    public let transaction: Transaction?
}

/// In-App Purchase errors
public enum IAPError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
    case restoreFailed

    public var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        case .restoreFailed:
            return "Failed to restore purchases"
        }
    }
}
