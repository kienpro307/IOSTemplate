import Foundation

// MARK: - IAP Configuration
/// Cấu hình In-App Purchase được cung cấp bởi app chính
/// Cho phép package IOSTemplate reusable cho nhiều app khác nhau
public struct IAPConfiguration: Sendable {
    // MARK: - Properties

    /// Danh sách product IDs cần load từ App Store
    public let productIDs: [String]

    /// Optional subscription group ID (nếu app có subscription)
    public let subscriptionGroupID: String?

    // MARK: - Singleton

    /// Shared configuration instance
    public private(set) static var shared: IAPConfiguration = .default

    /// Default configuration (empty - app chính phải setup)
    private static let `default` = IAPConfiguration(
        productIDs: [],
        subscriptionGroupID: nil
    )

    // MARK: - Initialization

    /// Khởi tạo configuration với product IDs
    /// - Parameters:
    ///   - productIDs: Danh sách product IDs cần load
    ///   - subscriptionGroupID: Optional subscription group ID
    public init(
        productIDs: [String],
        subscriptionGroupID: String? = nil
    ) {
        self.productIDs = productIDs
        self.subscriptionGroupID = subscriptionGroupID
    }

    // MARK: - Setup

    /// Setup global configuration (gọi từ app chính khi khởi động)
    /// - Parameters:
    ///   - productIDs: Danh sách product IDs cần load
    ///   - subscriptionGroupID: Optional subscription group ID
    ///
    /// Example:
    /// ```swift
    /// // Trong App.swift của app chính
    /// IAPConfiguration.setup(
    ///     productIDs: [
    ///         "com.yourapp.premium.monthly",
    ///         "com.yourapp.premium.yearly",
    ///         "com.yourapp.removeads"
    ///     ],
    ///     subscriptionGroupID: "premium_subscriptions"
    /// )
    /// ```
    public static func setup(
        productIDs: [String],
        subscriptionGroupID: String? = nil
    ) {
        shared = IAPConfiguration(
            productIDs: productIDs,
            subscriptionGroupID: subscriptionGroupID
        )
    }

    // MARK: - Validation

    /// Kiểm tra configuration đã được setup chưa
    public var isConfigured: Bool {
        !productIDs.isEmpty
    }

    /// Kiểm tra product ID có trong configuration không
    /// - Parameter productID: Product ID cần kiểm tra
    /// - Returns: true nếu product ID có trong configuration
    public func contains(_ productID: String) -> Bool {
        productIDs.contains(productID)
    }
}

// MARK: - Configuration Error
/// Lỗi liên quan đến configuration
public enum IAPConfigurationError: Error, Equatable {
    case notConfigured
    case invalidProductID(String)

    public var localizedDescription: String {
        switch self {
        case .notConfigured:
            return "IAP Configuration has not been set up. Call IAPConfiguration.setup() first."
        case .invalidProductID(let productID):
            return "Product ID '\(productID)' is not in the configuration."
        }
    }
}
