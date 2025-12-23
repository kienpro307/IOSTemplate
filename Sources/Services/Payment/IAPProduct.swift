import Foundation
import StoreKit

// MARK: - IAP Products
/// Định nghĩa các IAP products trong app
/// Tái sử dụng từ ios-template-home với TCA adaptation
public enum IAPProduct: String, CaseIterable, Sendable {
    // MARK: - Consumable Products
    
    /// 100 coins
    case coins100 = "com.template.ios.coins.100"
    
    /// 500 coins
    case coins500 = "com.template.ios.coins.500"
    
    /// 1000 coins
    case coins1000 = "com.template.ios.coins.1000"
    
    // MARK: - Non-Consumable Products
    
    /// Remove ads permanently
    case removeAds = "com.template.ios.removeads"
    
    /// Premium features unlock
    case premiumUnlock = "com.template.ios.premium"
    
    // MARK: - Auto-Renewable Subscriptions
    
    /// Monthly subscription
    case subscriptionMonthly = "com.template.ios.subscription.monthly"
    
    /// Yearly subscription
    case subscriptionYearly = "com.template.ios.subscription.yearly"
    
    // MARK: - Product Info
    
    /// Product type
    public var productType: StoreKit.Product.ProductType {
        switch self {
        case .coins100, .coins500, .coins1000:
            return .consumable
        case .removeAds, .premiumUnlock:
            return .nonConsumable
        case .subscriptionMonthly, .subscriptionYearly:
            return .autoRenewable
        }
    }
    
    /// Display name
    public var displayName: String {
        switch self {
        case .coins100: return "100 Coins"
        case .coins500: return "500 Coins"
        case .coins1000: return "1000 Coins"
        case .removeAds: return "Remove Ads"
        case .premiumUnlock: return "Premium Unlock"
        case .subscriptionMonthly: return "Monthly Subscription"
        case .subscriptionYearly: return "Yearly Subscription"
        }
    }
    
    /// Description
    public var productDescription: String {
        switch self {
        case .coins100: return "Purchase 100 coins"
        case .coins500: return "Purchase 500 coins (Best Value!)"
        case .coins1000: return "Purchase 1000 coins (Ultimate Pack)"
        case .removeAds: return "Remove all advertisements permanently"
        case .premiumUnlock: return "Unlock all premium features"
        case .subscriptionMonthly: return "Access all premium features for one month"
        case .subscriptionYearly: return "Access all premium features for one year (Save 40%)"
        }
    }
    
    /// Is subscription
    public var isSubscription: Bool {
        productType == .autoRenewable
    }
    
    /// Is consumable
    public var isConsumable: Bool {
        productType == .consumable
    }
    
    /// All product IDs
    public static var allProductIDs: [String] {
        allCases.map { $0.rawValue }
    }
    
    /// Subscription products only
    public static var subscriptionProducts: [IAPProduct] {
        allCases.filter { $0.isSubscription }
    }
    
    /// Non-subscription products only
    public static var nonSubscriptionProducts: [IAPProduct] {
        allCases.filter { !$0.isSubscription }
    }
}

// MARK: - Product Purchase Info
/// Thông tin mua hàng
public struct ProductPurchaseInfo: Equatable, Codable, Sendable {
    public let productId: String
    public let transactionId: String
    public let purchaseDate: Date
    public let expirationDate: Date?
    public let isActive: Bool
    
    public init(
        productId: String,
        transactionId: String,
        purchaseDate: Date,
        expirationDate: Date? = nil,
        isActive: Bool = true
    ) {
        self.productId = productId
        self.transactionId = transactionId
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isActive = isActive
    }
}

// MARK: - Purchase State
/// Trạng thái mua hàng
public enum PurchaseState: Equatable, Sendable {
    case notPurchased
    case pending
    case purchased(ProductPurchaseInfo)
    case failed(String)
    case deferred
}

// MARK: - IAP Error
/// Lỗi In-App Purchase
public enum IAPError: Error, Equatable, Sendable {
    case failedVerification
    case productNotFound
    case purchaseFailed(String)
    case restoreFailed
    case userCancelled
    case networkError
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed:
            return "Failed to restore purchases"
        case .userCancelled:
            return "Purchase was cancelled"
        case .networkError:
            return "Network error occurred"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    /// User-friendly message
    public var userMessage: String {
        switch self {
        case .failedVerification:
            return "Không thể xác minh giao dịch. Vui lòng thử lại."
        case .productNotFound:
            return "Sản phẩm không tìm thấy. Vui lòng thử lại sau."
        case .purchaseFailed:
            return "Mua hàng thất bại. Vui lòng thử lại."
        case .restoreFailed:
            return "Không thể khôi phục giao dịch. Vui lòng thử lại."
        case .userCancelled:
            return "Bạn đã hủy giao dịch."
        case .networkError:
            return "Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại."
        case .unknown:
            return "Đã xảy ra lỗi. Vui lòng thử lại."
        }
    }
}

