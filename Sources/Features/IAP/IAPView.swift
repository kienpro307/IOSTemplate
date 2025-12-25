import SwiftUI
import ComposableArchitecture
import StoreKit
import Services
import UI

// MARK: - IAP View
/// View hiển thị danh sách products để purchase
/// Tái sử dụng design từ ios-template-home/Monetization/IAP/Views/PurchaseView.swift
public struct IAPView: View {
    @Perception.Bindable var store: StoreOf<IAPReducer>
    
    public init(store: StoreOf<IAPReducer>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        headerSection
                        
                        if store.isLoading && store.products.isEmpty {
                            loadingView
                        } else if store.products.isEmpty {
                            emptyView
                        } else {
                            // Premium Status Banner
                            if store.hasPremium {
                                premiumBanner
                            }
                            
                            // Products Section
                            productsSection
                            
                            // Subscriptions Section
                            subscriptionsSection
                            
                            // Restore Button
                            restoreButton
                        }
                        
                        // Error Message
                        if let errorMessage = store.errorMessage {
                            errorView(message: errorMessage)
                        }
                        
                        // Success Message
                        if let successMessage = store.successMessage {
                            successView(message: successMessage)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Premium")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            store.send(.dismiss)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                #else
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            store.send(.dismiss)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                #endif
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Nâng cấp Premium")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Mở khóa tất cả tính năng và loại bỏ quảng cáo")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Đang tải sản phẩm...")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Spacing.xxl)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Không có sản phẩm")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Không thể tải danh sách sản phẩm. Vui lòng thử lại sau.")
                .font(.body)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Button {
                store.send(.loadProducts)
            } label: {
                Label("Thử lại", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Premium Banner
    
    private var premiumBanner: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Premium Active")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Bạn đang sử dụng phiên bản Premium")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(CornerRadius.md)
    }
    
    // MARK: - Products Section
    
    @ViewBuilder
    private var productsSection: some View {
        let nonSubProducts = store.nonSubscriptionProducts
        if !nonSubProducts.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Mua một lần")
                    .font(.title3)
                    .fontWeight(.bold)
                
                ForEach(nonSubProducts) { product in
                    let isPurchased = store.purchasedProductIDs.contains(product.id)
                    ProductRowView(
                        product: product,
                        isPurchased: isPurchased,
                        isPurchasing: store.purchasingProductId == product.id
                    ) {
                        store.send(.purchase(product.id))
                    }
                }
            }
        }
    }
    
    // MARK: - Subscriptions Section
    
    @ViewBuilder
    private var subscriptionsSection: some View {
        let subProducts = store.subscriptionProducts
        if !subProducts.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Đăng ký")
                    .font(.title3)
                    .fontWeight(.bold)
                
                ForEach(subProducts) { product in
                    let isActive = store.activeSubscriptions.contains { $0.id == product.id }
                    SubscriptionRowView(
                        product: product,
                        isActive: isActive,
                        isPurchasing: store.purchasingProductId == product.id
                    ) {
                        store.send(.purchase(product.id))
                    }
                }
            }
        }
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button {
            store.send(.restorePurchases)
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Khôi phục giao dịch")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(CornerRadius.md)
        }
        .disabled(store.isLoading)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                store.send(.clearError)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(CornerRadius.sm)
    }
    
    // MARK: - Success View
    
    private func successView(message: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                store.send(.clearSuccess)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(CornerRadius.sm)
    }
}

// MARK: - Product Row View

struct ProductRowView: View {
    let product: IAPProductInfo
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else if isPurchasing {
                ProgressView()
            } else {
                Button(action: onPurchase) {
                    Text(product.displayPrice)
                        .font(.headline)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(CornerRadius.sm)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Subscription Row View

struct SubscriptionRowView: View {
    let product: IAPProductInfo
    let isActive: Bool
    let isPurchasing: Bool
    let onSubscribe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    
                    if isActive {
                        Text("Đang hoạt động")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let period = product.subscriptionPeriod {
                        Text("mỗi \(period)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Text(product.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            #if os(iOS)
            if !isActive {
                if isPurchasing {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                } else {
                    Button(action: onSubscribe) {
                        Text("Đăng ký")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.sm)
                    }
                }
            } else {
                Button {
                    // Open manage subscriptions
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        Task {
                            try? await StoreKit.AppStore.showManageSubscriptions(in: scene)
                        }
                    }
                } label: {
                    Text("Quản lý đăng ký")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(CornerRadius.sm)
                }
            }
            #else
            // macOS fallback
            if !isActive {
                if isPurchasing {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                } else {
                    Button(action: onSubscribe) {
                        Text("Đăng ký")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.sm)
                    }
                }
            }
            #endif
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    IAPView(
        store: Store(
            initialState: IAPState(
                products: [],
                hasPremium: false,
                hasRemovedAds: false
            )
        ) {
            IAPReducer()
        }
    )
}
#endif
