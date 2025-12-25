import Foundation
import ComposableArchitecture
import StoreKit
import Core

// MARK: - Payment Service Protocol
/// Protocol cho Payment service (StoreKit 2)
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol PaymentServiceProtocol: Sendable {
    /// Load available products từ App Store
    func loadProducts() async throws -> [IAPProductInfo]
    
    /// Purchase product by ID
    func purchase(_ productId: String) async throws -> PurchaseResult
    
    /// Restore purchases
    func restorePurchases() async throws -> [String]
    
    /// Check if product is purchased
    func isPurchased(_ productId: String) async -> Bool
    
    /// Check if user has premium access
    func hasPremium() async -> Bool
    
    /// Check if user has removed ads
    func hasRemovedAds() async -> Bool
    
    /// Get active subscriptions
    func getActiveSubscriptions() async -> [IAPProductInfo]
}

// MARK: - IAP Product Info
/// Thông tin sản phẩm IAP (không dùng trực tiếp StoreKit.Product để tránh phụ thuộc)
public struct IAPProductInfo: Equatable, Identifiable, Sendable {
    public let id: String
    public let displayName: String
    public let description: String
    public let displayPrice: String
    public let price: Decimal
    public let productType: ProductType
    public let subscriptionPeriod: String?
    
    public enum ProductType: String, Sendable {
        case consumable
        case nonConsumable
        case autoRenewable
        case nonRenewable
    }
    
    public init(
        id: String,
        displayName: String,
        description: String,
        displayPrice: String,
        price: Decimal,
        productType: ProductType,
        subscriptionPeriod: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayPrice = displayPrice
        self.price = price
        self.productType = productType
        self.subscriptionPeriod = subscriptionPeriod
    }
}

// MARK: - Purchase Result
/// Kết quả mua hàng
public struct PurchaseResult: Equatable, Sendable {
    public let productId: String
    public let transactionId: String
    public let purchaseDate: Date
    public let isSuccessful: Bool
    
    public init(
        productId: String,
        transactionId: String,
        purchaseDate: Date,
        isSuccessful: Bool
    ) {
        self.productId = productId
        self.transactionId = transactionId
        self.purchaseDate = purchaseDate
        self.isSuccessful = isSuccessful
    }
}

// MARK: - Live Implementation
/// Live implementation với StoreKit 2
public struct LivePaymentService: PaymentServiceProtocol {
    public init() {}
    
    @MainActor
    private var manager: StoreKitManager {
        StoreKitManager.shared
    }
    
    public func loadProducts() async throws -> [IAPProductInfo] {
        let products = try await manager.loadProducts()
        return products.map { product in
            IAPProductInfo(
                id: product.id,
                displayName: product.displayName,
                description: product.description,
                displayPrice: product.displayPrice,
                price: product.price,
                productType: mapProductType(product.type),
                subscriptionPeriod: product.subscriptionPeriodDescription
            )
        }
    }
    
    public func purchase(_ productId: String) async throws -> PurchaseResult {
        guard let transaction = try await manager.purchase(productId: productId) else {
            throw IAPError.purchaseFailed("No transaction returned")
        }
        
        return PurchaseResult(
            productId: transaction.productID,
            transactionId: String(transaction.id),
            purchaseDate: transaction.purchaseDate,
            isSuccessful: true
        )
    }
    
    public func restorePurchases() async throws -> [String] {
        try await manager.restorePurchases()
        return await Array(manager.purchasedProductIDs)
    }
    
    public func isPurchased(_ productId: String) async -> Bool {
        await manager.isPurchased(productId)
    }
    
    public func hasPremium() async -> Bool {
        await manager.hasPremium()
    }
    
    public func hasRemovedAds() async -> Bool {
        await manager.hasRemovedAds()
    }
    
    public func getActiveSubscriptions() async -> [IAPProductInfo] {
        await manager.activeSubscriptions.map { product in
            IAPProductInfo(
                id: product.id,
                displayName: product.displayName,
                description: product.description,
                displayPrice: product.displayPrice,
                price: product.price,
                productType: .autoRenewable,
                subscriptionPeriod: product.subscriptionPeriodDescription
            )
        }
    }
    
    // MARK: - Helpers
    
    private func mapProductType(_ type: StoreKit.Product.ProductType) -> IAPProductInfo.ProductType {
        switch type {
        case .consumable:
            return .consumable
        case .nonConsumable:
            return .nonConsumable
        case .autoRenewable:
            return .autoRenewable
        case .nonRenewable:
            return .nonRenewable
        default:
            return .nonConsumable
        }
    }
}

// MARK: - Mock Implementation
/// Mock implementation cho testing và preview
public struct MockPaymentService: PaymentServiceProtocol {
    public var mockProducts: [IAPProductInfo]
    public var mockPurchasedProductIDs: Set<String>
    public var shouldFailPurchase: Bool
    public var shouldFailRestore: Bool
    
    public init(
        mockProducts: [IAPProductInfo] = MockPaymentService.defaultProducts,
        mockPurchasedProductIDs: Set<String> = [],
        shouldFailPurchase: Bool = false,
        shouldFailRestore: Bool = false
    ) {
        self.mockProducts = mockProducts
        self.mockPurchasedProductIDs = mockPurchasedProductIDs
        self.shouldFailPurchase = shouldFailPurchase
        self.shouldFailRestore = shouldFailRestore
    }
    
    public func loadProducts() async throws -> [IAPProductInfo] {
        return mockProducts
    }
    
    public func purchase(_ productId: String) async throws -> PurchaseResult {
        if shouldFailPurchase {
            throw IAPError.purchaseFailed("Mock purchase failed")
        }
        
        return PurchaseResult(
            productId: productId,
            transactionId: UUID().uuidString,
            purchaseDate: Date(),
            isSuccessful: true
        )
    }
    
    public func restorePurchases() async throws -> [String] {
        if shouldFailRestore {
            throw IAPError.restoreFailed
        }
        return Array(mockPurchasedProductIDs)
    }
    
    public func isPurchased(_ productId: String) async -> Bool {
        mockPurchasedProductIDs.contains(productId)
    }
    
    public func hasPremium() async -> Bool {
        mockPurchasedProductIDs.contains(IAPProduct.premiumUnlock.rawValue) ||
        mockPurchasedProductIDs.contains(IAPProduct.subscriptionMonthly.rawValue) ||
        mockPurchasedProductIDs.contains(IAPProduct.subscriptionYearly.rawValue)
    }
    
    public func hasRemovedAds() async -> Bool {
        await hasPremium() || mockPurchasedProductIDs.contains(IAPProduct.removeAds.rawValue)
    }
    
    public func getActiveSubscriptions() async -> [IAPProductInfo] {
        mockProducts.filter { product in
            product.productType == .autoRenewable &&
            mockPurchasedProductIDs.contains(product.id)
        }
    }
    
    // MARK: - Default Mock Products
    
    public static var defaultProducts: [IAPProductInfo] {
        [
            IAPProductInfo(
                id: IAPProduct.removeAds.rawValue,
                displayName: "Remove Ads",
                description: "Remove all advertisements permanently",
                displayPrice: "$2.99",
                price: 2.99,
                productType: .nonConsumable
            ),
            IAPProductInfo(
                id: IAPProduct.premiumUnlock.rawValue,
                displayName: "Premium Unlock",
                description: "Unlock all premium features",
                displayPrice: "$9.99",
                price: 9.99,
                productType: .nonConsumable
            ),
            IAPProductInfo(
                id: IAPProduct.subscriptionMonthly.rawValue,
                displayName: "Monthly Subscription",
                description: "Access all premium features for one month",
                displayPrice: "$4.99",
                price: 4.99,
                productType: .autoRenewable,
                subscriptionPeriod: "month"
            ),
            IAPProductInfo(
                id: IAPProduct.subscriptionYearly.rawValue,
                displayName: "Yearly Subscription",
                description: "Access all premium features for one year (Save 40%)",
                displayPrice: "$29.99",
                price: 29.99,
                productType: .autoRenewable,
                subscriptionPeriod: "year"
            )
        ]
    }
}

// MARK: - Dependency Key
private enum PaymentServiceKey: DependencyKey {
    static let liveValue: PaymentServiceProtocol = LivePaymentService()
    static let testValue: PaymentServiceProtocol = MockPaymentService()
    static let previewValue: PaymentServiceProtocol = MockPaymentService()
}

extension DependencyValues {
    public var paymentService: PaymentServiceProtocol {
        get { self[PaymentServiceKey.self] }
        set { self[PaymentServiceKey.self] = newValue }
    }
}
