import Foundation
import StoreKit

/// Định nghĩa các IAP products trong app
public enum IAPProduct: String, CaseIterable {
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
    public var productType: Product.ProductType {
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
    public var description: String {
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
}

/// Product purchase info
public struct ProductPurchaseInfo: Equatable, Codable {
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

/// Purchase state
public enum PurchaseState: Equatable {
    case notPurchased
    case pending
    case purchased(ProductPurchaseInfo)
    case failed(Error)
    case deferred

    public static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.notPurchased, .notPurchased):
            return true
        case (.pending, .pending):
            return true
        case (.purchased(let lhsInfo), .purchased(let rhsInfo)):
            return lhsInfo == rhsInfo
        case (.failed, .failed):
            return true
        case (.deferred, .deferred):
            return true
        default:
            return false
        }
    }
}
