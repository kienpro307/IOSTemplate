import Foundation
import StoreKit

// MARK: - StoreKit Manager
/// Manager cho StoreKit 2 operations
/// Tái sử dụng từ ios-template-home với async/await pattern
@MainActor
public final class StoreKitManager: Sendable {
    // MARK: - Singleton
    
    public static let shared = StoreKitManager()
    
    // MARK: - Properties
    
    /// Available products từ App Store
    public private(set) var products: [StoreKit.Product] = []
    
    /// Purchased product IDs
    public private(set) var purchasedProductIDs: Set<String> = []
    
    /// Active subscriptions
    public private(set) var activeSubscriptions: [StoreKit.Product] = []
    
    /// Loading state
    public private(set) var isLoading: Bool = false
    
    /// Error message
    public private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading

    /// Load products from App Store
    public func loadProducts() async throws -> [StoreKit.Product] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        // Kiểm tra configuration
        guard IAPConfiguration.shared.isConfigured else {
            errorMessage = "IAP Configuration not set up"
            throw IAPConfigurationError.notConfigured
        }

        do {
            let productIds = IAPConfiguration.shared.productIDs
            let storeProducts = try await StoreKit.Product.products(for: productIds)

            // Sort products by price
            products = storeProducts.sorted { $0.price < $1.price }

            // Update purchased products
            await updatePurchasedProducts()

            return products
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            throw IAPError.networkError
        }
    }
    
    /// Get product by ID
    public func getProduct(for productId: String) -> StoreKit.Product? {
        products.first { $0.id == productId }
    }
    
    // MARK: - Purchase Flow
    
    /// Purchase a product
    public func purchase(_ product: StoreKit.Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
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
                
                return transaction
                
            case .userCancelled:
                throw IAPError.userCancelled
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                return nil
                
            @unknown default:
                throw IAPError.unknown("Unknown purchase result")
            }
        } catch let error as IAPError {
            throw error
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw IAPError.purchaseFailed(error.localizedDescription)
        }
    }
    
    /// Purchase by product ID
    public func purchase(productId: String) async throws -> Transaction? {
        guard let product = getProduct(for: productId) else {
            throw IAPError.productNotFound
        }
        return try await purchase(product)
    }
    
    /// Check if product is purchased
    public func isPurchased(_ productId: String) -> Bool {
        purchasedProductIDs.contains(productId)
    }
    
    // MARK: - Subscription Management
    
    /// Check subscription status
    public func checkSubscriptionStatus() async {
        var activeSubscriptionProducts: [StoreKit.Product] = []
        
        for product in products where product.type == .autoRenewable {
            guard let subscription = product.subscription else { continue }
            
            // Check if user has an active subscription
            if let status = try? await subscription.status.first {
                switch status.state {
                case .subscribed, .inGracePeriod:
                    if isPurchased(product.id) {
                        activeSubscriptionProducts.append(product)
                    }
                default:
                    break
                }
            }
        }
        
        activeSubscriptions = activeSubscriptionProducts
    }
    
    /// Check if user has premium access
    /// Note: App chính cần override logic này nếu có requirement khác
    public func hasPremium() -> Bool {
        // Có active subscription = có premium
        !activeSubscriptions.isEmpty
    }

    /// Check if ads are removed
    /// Note: App chính cần override logic này nếu có requirement khác
    public func hasRemovedAds() -> Bool {
        // Mặc định: có subscription = remove ads
        hasPremium()
    }

    /// Check if specific product is purchased
    /// Use this for custom premium/remove ads logic in app
    /// - Parameter productID: Product ID to check
    /// - Returns: true if product is purchased
    public func hasProduct(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    public func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // In StoreKit 2, just update purchased products from transaction history
        // Transactions are automatically synced
        await updatePurchasedProducts()
    }
    
    // MARK: - Transaction Handling
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
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

// MARK: - StoreKit Product Extensions
extension StoreKit.Product {
    /// Formatted price string
    public var formattedPrice: String {
        displayPrice
    }
    
    /// Subscription period description
    public var subscriptionPeriodDescription: String? {
        guard let subscription = subscription else { return nil }
        let period = subscription.subscriptionPeriod
        
        switch period.unit {
        case .day:
            return period.value == 1 ? "day" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "week" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "month" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "year" : "\(period.value) years"
        @unknown default:
            return nil
        }
    }
}

