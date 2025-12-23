import Foundation
import ComposableArchitecture
import Core

/// Payment service protocol (StoreKit 2)
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol PaymentServiceProtocol: Sendable {
    /// Purchase product
    func purchase(_ productId: String) async throws -> Bool
    
    /// Restore purchases
    func restorePurchases() async throws
    
    /// Get available products
    func getProducts(_ productIds: [String]) async throws -> [Product]
    
    /// Check if product is purchased
    func isPurchased(_ productId: String) async -> Bool
}

// MARK: - Product Model
public struct Product: Equatable {
    public let id: String
    public let displayName: String
    public let price: Decimal
    public let priceLocale: Locale
    
    public init(id: String, displayName: String, price: Decimal, priceLocale: Locale) {
        self.id = id
        self.displayName = displayName
        self.price = price
        self.priceLocale = priceLocale
    }
}

// MARK: - Placeholder Implementation
/// Placeholder - Sẽ implement sau với StoreKit 2
public actor LivePaymentService: PaymentServiceProtocol {
    public init() {}
    
    public func purchase(_ productId: String) async throws -> Bool {
        // TODO: Implement với StoreKit 2
        throw SystemError.unknown("Not implemented")
    }
    
    public func restorePurchases() async throws {
        // TODO: Implement với StoreKit 2
    }
    
    public func getProducts(_ productIds: [String]) async throws -> [Product] {
        // TODO: Implement với StoreKit 2
        return []
    }
    
    public func isPurchased(_ productId: String) async -> Bool {
        // TODO: Implement với StoreKit 2
        return false
    }
}

// MARK: - Mock Implementation
public actor MockPaymentService: PaymentServiceProtocol {
    public init() {}
    
    public func purchase(_ productId: String) async throws -> Bool {
        return true
    }
    
    public func restorePurchases() async throws {
        // Mock: không làm gì
    }
    
    public func getProducts(_ productIds: [String]) async throws -> [Product] {
        return []
    }
    
    public func isPurchased(_ productId: String) async -> Bool {
        return false
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

