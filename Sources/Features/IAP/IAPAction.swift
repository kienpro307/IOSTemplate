import ComposableArchitecture
import Foundation
import Services

// MARK: - IAP Action
/// Các hành động của In-App Purchase feature
@CasePathable
public enum IAPAction: Equatable {
    /// View appeared - load products
    case onAppear
    
    /// Load products from App Store
    case loadProducts
    
    /// Products loaded successfully
    case productsLoaded([IAPProductInfo])
    
    /// Products load failed
    case productsLoadFailed(String)
    
    /// Purchase a product
    case purchase(String)
    
    /// Purchase completed successfully
    case purchaseCompleted(PurchaseResult)
    
    /// Purchase failed
    case purchaseFailed(String)
    
    /// User cancelled purchase
    case purchaseCancelled
    
    /// Restore purchases
    case restorePurchases
    
    /// Restore completed successfully
    case restoreCompleted([String])
    
    /// Restore failed
    case restoreFailed(String)
    
    /// Update premium status
    case updatePremiumStatus(hasPremium: Bool, hasRemovedAds: Bool)
    
    /// Update active subscriptions
    case updateActiveSubscriptions([IAPProductInfo])
    
    /// Clear error message
    case clearError
    
    /// Clear success message
    case clearSuccess
    
    /// Dismiss IAP view
    case dismiss
}

