import ComposableArchitecture
import Foundation
import Services

// MARK: - IAP State
/// Trạng thái của In-App Purchase feature
@ObservableState
public struct IAPState: Equatable, Identifiable {
    public var id: UUID = UUID()
    /// Available products từ App Store
    public var products: [IAPProductInfo]
    
    /// Purchased product IDs
    public var purchasedProductIDs: Set<String>
    
    /// Active subscriptions
    public var activeSubscriptions: [IAPProductInfo]
    
    /// Loading state
    public var isLoading: Bool
    
    /// Current purchase in progress
    public var purchasingProductId: String?
    
    /// Error message
    public var errorMessage: String?
    
    /// Success message
    public var successMessage: String?
    
    /// Has premium access
    public var hasPremium: Bool
    
    /// Has removed ads
    public var hasRemovedAds: Bool
    
    public init(
        products: [IAPProductInfo] = [],
        purchasedProductIDs: Set<String> = [],
        activeSubscriptions: [IAPProductInfo] = [],
        isLoading: Bool = false,
        purchasingProductId: String? = nil,
        errorMessage: String? = nil,
        successMessage: String? = nil,
        hasPremium: Bool = false,
        hasRemovedAds: Bool = false
    ) {
        self.products = products
        self.purchasedProductIDs = purchasedProductIDs
        self.activeSubscriptions = activeSubscriptions
        self.isLoading = isLoading
        self.purchasingProductId = purchasingProductId
        self.errorMessage = errorMessage
        self.successMessage = successMessage
        self.hasPremium = hasPremium
        self.hasRemovedAds = hasRemovedAds
    }
    
    // MARK: - Computed Properties
    
    /// Non-subscription products (consumables và non-consumables)
    public var nonSubscriptionProducts: [IAPProductInfo] {
        products.filter { $0.productType != .autoRenewable }
    }
    
    /// Subscription products
    public var subscriptionProducts: [IAPProductInfo] {
        products.filter { $0.productType == .autoRenewable }
    }
    
    /// Check if a specific product is purchased
    public func isPurchased(_ productId: String) -> Bool {
        purchasedProductIDs.contains(productId)
    }
    
    /// Check if a subscription is active
    public func isSubscriptionActive(_ productId: String) -> Bool {
        activeSubscriptions.contains { $0.id == productId }
    }
}

