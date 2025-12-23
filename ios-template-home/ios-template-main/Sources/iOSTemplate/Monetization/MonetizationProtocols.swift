import Foundation

// MARK: - Monetization Analytics Protocol

/// Protocol cho monetization analytics (để avoid circular dependency)
/// Used by IAPService to track revenue events
public protocol MonetizationAnalyticsProtocol {
    /// Log a custom event
    func logEvent(name: String, parameters: [String: Any])

    /// Log revenue from purchases
    func logRevenue(amount: Double, currency: String, productId: String, transactionId: String)
}

// MARK: - Firebase Analytics Service Protocol

/// Protocol cho Firebase Analytics monetization tracking
/// Used by RevenueTracker to track detailed purchase events
public protocol FirebaseAnalyticsServiceProtocol {
    /// Log a purchase event with full item details
    func logPurchase(value: Double, currency: String, transactionId: String, items: [[String: Any]])
}
