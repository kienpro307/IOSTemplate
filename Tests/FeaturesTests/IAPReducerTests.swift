import XCTest
import ComposableArchitecture
@testable import Features
@testable import Core
@testable import Services

/// Unit tests cho IAPReducer
@MainActor
final class IAPReducerTests: XCTestCase {

    // MARK: - Test Product Loading

    /// Test load products thành công
    func testLoadProductsSuccess() async {
        let mockProducts = [
            IAPProductInfo(
                id: "premium_monthly",
                displayName: "Premium Monthly",
                description: "Premium subscription",
                displayPrice: "49.000 ₫",
                price: 49000,
                productType: .autoRenewable,
                subscriptionPeriod: "month"
            )
        ]

        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: mockProducts,
                mockPurchasedProductIDs: []
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.loadProducts) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.productsLoaded(mockProducts)) {
            $0.isLoading = false
            $0.products = mockProducts
        }

        await store.receive(.updatePremiumStatus(hasPremium: false, hasRemovedAds: false))
        await store.receive(.updateActiveSubscriptions([]))
    }

    /// Test load products thất bại
    func testLoadProductsFailed() async {
        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                shouldFailLoadProducts: true
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.loadProducts) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.productsLoadFailed("Product not found")) {
            $0.isLoading = false
            $0.errorMessage = "Product not found"
        }
    }

    /// Test onAppear triggers loadProducts
    func testOnAppear() async {
        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(mockProducts: [])
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.onAppear)
        
        await store.receive(.loadProducts) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.productsLoaded([])) {
            $0.isLoading = false
            $0.products = []
        }

        await store.receive(.updatePremiumStatus(hasPremium: false, hasRemovedAds: false))
        await store.receive(.updateActiveSubscriptions([]))
    }

    // MARK: - Test Purchase Flow

    /// Test purchase thành công
    func testPurchaseSuccess() async {
        let productId = "premium_monthly"
        let purchaseResult = PurchaseResult(
            productId: productId,
            transactionId: "tx_123",
            purchaseDate: Date(),
            isSuccessful: true
        )

        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                purchaseResult: purchaseResult
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.purchase(productId)) {
            $0.purchasingProductId = productId
            $0.errorMessage = nil
            $0.successMessage = nil
        }

        await store.receive(.purchaseCompleted(purchaseResult)) {
            $0.purchasingProductId = nil
            $0.purchasedProductIDs.insert(productId)
            $0.successMessage = "Mua hàng thành công!"
        }

        // After purchase, reload products
        await store.receive(.loadProducts) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.productsLoaded([])) {
            $0.isLoading = false
            $0.products = []
        }

        await store.receive(.updatePremiumStatus(hasPremium: false, hasRemovedAds: false))
        await store.receive(.updateActiveSubscriptions([]))
    }

    /// Test purchase bị cancel
    func testPurchaseCancelled() async {
        let productId = "premium_monthly"

        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                shouldCancelPurchase: true
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.purchase(productId)) {
            $0.purchasingProductId = productId
            $0.errorMessage = nil
            $0.successMessage = nil
        }

        await store.receive(.purchaseCancelled) {
            $0.purchasingProductId = nil
        }
    }

    /// Test purchase thất bại
    func testPurchaseFailed() async {
        let productId = "premium_monthly"

        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                shouldFailPurchase: true
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.purchase(productId)) {
            $0.purchasingProductId = productId
            $0.errorMessage = nil
            $0.successMessage = nil
        }

        await store.receive(.purchaseFailed("Mock purchase failed")) {
            $0.purchasingProductId = nil
            $0.errorMessage = "Mua hàng thất bại: Mock purchase failed"
        }
    }

    // MARK: - Test Restore Purchases

    /// Test restore purchases thành công
    func testRestorePurchasesSuccess() async {
        let restoredProductIds = ["premium_monthly", "remove_ads"]
        
        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                mockPurchasedProductIDs: Set(restoredProductIds)
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.restorePurchases) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.restoreCompleted(restoredProductIds)) {
            $0.isLoading = false
            $0.purchasedProductIDs = Set(restoredProductIds)
            $0.successMessage = "Đã khôi phục 2 giao dịch thành công!"
        }

        // After restore, reload products
        await store.receive(.loadProducts) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.productsLoaded([])) {
            $0.isLoading = false
            $0.products = []
        }

        await store.receive(.updatePremiumStatus(hasPremium: false, hasRemovedAds: false))
        await store.receive(.updateActiveSubscriptions([]))
    }

    /// Test restore purchases thất bại
    func testRestorePurchasesFailed() async {
        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        } withDependencies: {
            $0.paymentService = MockPaymentService(
                mockProducts: [],
                shouldFailRestore: true
            )
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.restorePurchases) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(.restoreFailed("Failed to restore purchases")) {
            $0.isLoading = false
            $0.errorMessage = "Khôi phục thất bại: Failed to restore purchases"
        }
    }

    // MARK: - Test Premium Status

    /// Test update premium status
    func testUpdatePremiumStatus() async {
        let store = TestStore(
            initialState: IAPState(hasPremium: false, hasRemovedAds: false)
        ) {
            IAPReducer()
        }

        await store.send(.updatePremiumStatus(hasPremium: true, hasRemovedAds: true)) {
            $0.hasPremium = true
            $0.hasRemovedAds = true
        }
    }

    /// Test update active subscriptions
    func testUpdateActiveSubscriptions() async {
        let subscriptions = [
            IAPProductInfo(
                id: "premium_monthly",
                displayName: "Premium Monthly",
                description: "Premium subscription",
                displayPrice: "$4.99",
                price: 4.99,
                productType: .autoRenewable,
                subscriptionPeriod: "month"
            )
        ]

        let store = TestStore(
            initialState: IAPState()
        ) {
            IAPReducer()
        }

        await store.send(.updateActiveSubscriptions(subscriptions)) {
            $0.activeSubscriptions = subscriptions
        }
    }

    // MARK: - Test Initial State

    /// Test initial state
    func testInitialState() {
        let state = IAPState()

        XCTAssertTrue(state.products.isEmpty)
        XCTAssertTrue(state.purchasedProductIDs.isEmpty)
        XCTAssertTrue(state.activeSubscriptions.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.purchasingProductId)
        XCTAssertNil(state.errorMessage)
        XCTAssertNil(state.successMessage)
        XCTAssertFalse(state.hasPremium)
        XCTAssertFalse(state.hasRemovedAds)
    }
}

// MARK: - Mock Dependencies

/// Mock Payment Service cho testing
private struct MockPaymentService: PaymentServiceProtocol {
    var mockProducts: [IAPProductInfo]
    var mockPurchasedProductIDs: Set<String>
    var purchaseResult: PurchaseResult?
    var shouldFailLoadProducts: Bool
    var shouldFailPurchase: Bool
    var shouldCancelPurchase: Bool
    var shouldFailRestore: Bool

    init(
        mockProducts: [IAPProductInfo] = [],
        mockPurchasedProductIDs: Set<String> = [],
        purchaseResult: PurchaseResult? = nil,
        shouldFailLoadProducts: Bool = false,
        shouldFailPurchase: Bool = false,
        shouldCancelPurchase: Bool = false,
        shouldFailRestore: Bool = false
    ) {
        self.mockProducts = mockProducts
        self.mockPurchasedProductIDs = mockPurchasedProductIDs
        self.purchaseResult = purchaseResult
        self.shouldFailLoadProducts = shouldFailLoadProducts
        self.shouldFailPurchase = shouldFailPurchase
        self.shouldCancelPurchase = shouldCancelPurchase
        self.shouldFailRestore = shouldFailRestore
    }

    func loadProducts() async throws -> [IAPProductInfo] {
        if shouldFailLoadProducts {
            throw IAPError.productNotFound
        }
        return mockProducts
    }

    func purchase(_ productId: String) async throws -> PurchaseResult {
        if shouldCancelPurchase {
            throw IAPError.userCancelled
        }
        if shouldFailPurchase {
            throw IAPError.purchaseFailed("Mock purchase failed")
        }
        return purchaseResult ?? PurchaseResult(
            productId: productId,
            transactionId: "tx_mock",
            purchaseDate: Date(),
            isSuccessful: true
        )
    }

    func restorePurchases() async throws -> [String] {
        if shouldFailRestore {
            throw IAPError.restoreFailed
        }
        return Array(mockPurchasedProductIDs)
    }

    func isPurchased(_ productId: String) async -> Bool {
        mockPurchasedProductIDs.contains(productId)
    }

    func hasPremium() async -> Bool { false }
    func hasRemovedAds() async -> Bool { false }
    func getActiveSubscriptions() async -> [IAPProductInfo] { [] }
}

/// Mock Analytics Client cho testing
private struct MockAnalyticsClient: AnalyticsServiceProtocol {
    func configure() async {}
    func setUserID(_ userID: String?) async {}
    func setUserProperty(_ value: String?, forName name: String) async {}
    func trackEvent(_ name: String, parameters: [String: Any]?) async {}
    func trackScreen(_ screenName: String, screenClass: String?) async {}
}
