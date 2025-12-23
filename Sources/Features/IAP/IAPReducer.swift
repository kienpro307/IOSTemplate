import ComposableArchitecture
import Foundation
import Core
import Services

// MARK: - IAP Reducer
/// Reducer cho In-App Purchase feature
@Reducer
public struct IAPReducer {
    @Dependency(\.paymentService) var paymentService
    @Dependency(\.analytics) var analytics
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Track screen view
                analytics.trackScreen("purchase_screen")
                return .send(.loadProducts)
                
            case .loadProducts:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let products = try await paymentService.loadProducts()
                        await send(.productsLoaded(products))
                        
                        // Update premium status
                        let hasPremium = await paymentService.hasPremium()
                        let hasRemovedAds = await paymentService.hasRemovedAds()
                        await send(.updatePremiumStatus(hasPremium: hasPremium, hasRemovedAds: hasRemovedAds))
                        
                        // Update active subscriptions
                        let subscriptions = await paymentService.getActiveSubscriptions()
                        await send(.updateActiveSubscriptions(subscriptions))
                    } catch {
                        await send(.productsLoadFailed(error.localizedDescription))
                    }
                }
                
            case .productsLoaded(let products):
                state.isLoading = false
                state.products = products
                return .none
                
            case .productsLoadFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                
                analytics.trackEvent(
                    "iap_load_failed",
                    parameters: ["error": message]
                )
                return .none
                
            case .purchase(let productId):
                state.purchasingProductId = productId
                state.errorMessage = nil
                state.successMessage = nil
                
                analytics.trackEvent(
                    "iap_purchase_started",
                    parameters: ["product_id": productId]
                )
                
                return .run { send in
                    do {
                        let result = try await paymentService.purchase(productId)
                        await send(.purchaseCompleted(result))
                    } catch let error as IAPError where error == .userCancelled {
                        await send(.purchaseCancelled)
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }
                
            case .purchaseCompleted(let result):
                state.purchasingProductId = nil
                state.purchasedProductIDs.insert(result.productId)
                state.successMessage = "Mua hàng thành công!"
                
                analytics.trackEvent(
                    "iap_purchase_success",
                    parameters: [
                        "product_id": result.productId,
                        "transaction_id": result.transactionId
                    ]
                )
                
                // Reload to update premium status
                return .send(.loadProducts)
                
            case .purchaseFailed(let message):
                state.purchasingProductId = nil
                state.errorMessage = "Mua hàng thất bại: \(message)"
                
                analytics.trackEvent(
                    "iap_purchase_failed",
                    parameters: ["error": message]
                )
                return .none
                
            case .purchaseCancelled:
                state.purchasingProductId = nil
                
                analytics.trackEvent("iap_purchase_cancelled", parameters: [:])
                return .none
                
            case .restorePurchases:
                state.isLoading = true
                state.errorMessage = nil
                
                analytics.trackEvent("iap_restore_started", parameters: [:])
                
                return .run { send in
                    do {
                        let restoredProductIds = try await paymentService.restorePurchases()
                        await send(.restoreCompleted(restoredProductIds))
                    } catch {
                        await send(.restoreFailed(error.localizedDescription))
                    }
                }
                
            case .restoreCompleted(let productIds):
                state.isLoading = false
                state.purchasedProductIDs = Set(productIds)
                
                if productIds.isEmpty {
                    state.successMessage = "Không tìm thấy giao dịch nào để khôi phục."
                } else {
                    state.successMessage = "Đã khôi phục \(productIds.count) giao dịch thành công!"
                }
                
                analytics.trackEvent(
                    "iap_restore_success",
                    parameters: ["restored_count": productIds.count]
                )
                
                // Reload to update premium status
                return .send(.loadProducts)
                
            case .restoreFailed(let message):
                state.isLoading = false
                state.errorMessage = "Khôi phục thất bại: \(message)"
                
                analytics.trackEvent(
                    "iap_restore_failed",
                    parameters: ["error": message]
                )
                return .none
                
            case .updatePremiumStatus(let hasPremium, let hasRemovedAds):
                state.hasPremium = hasPremium
                state.hasRemovedAds = hasRemovedAds
                return .none
                
            case .updateActiveSubscriptions(let subscriptions):
                state.activeSubscriptions = subscriptions
                return .none
                
            case .clearError:
                state.errorMessage = nil
                return .none
                
            case .clearSuccess:
                state.successMessage = nil
                return .none
                
            case .dismiss:
                // Handled by parent reducer
                return .none
            }
        }
    }
}

