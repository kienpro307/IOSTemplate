import SwiftUI
import StoreKit
import UIKit

/// View hiển thị danh sách products để purchase
public struct PurchaseView: View {
    @StateObject private var storeKitManager = StoreKitManager()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if storeKitManager.isLoading {
                        ProgressView("Loading products...")
                            .padding()
                    } else if storeKitManager.products.isEmpty {
                        emptyView
                    } else {
                        productsSection
                        subscriptionsSection
                        restoreButton
                    }

                    if let errorMessage = storeKitManager.errorMessage {
                        errorView(message: errorMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Subviews

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No products available")
                .font(.headline)
                .foregroundColor(.secondary)

            Button("Retry") {
                Task {
                    await storeKitManager.loadProducts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In-App Purchases")
                .font(.title2)
                .fontWeight(.bold)

            // Non-subscription products
            ForEach(storeKitManager.products.filter { $0.type != .autoRenewable }, id: \.id) { product in
                ProductRow(
                    product: product,
                    isPurchased: storeKitManager.purchasedProductIDs.contains(product.id)
                ) {
                    await purchaseProduct(product)
                }
            }
        }
    }

    private var subscriptionsSection: some View {
        Group {
            if !storeKitManager.products.filter({ $0.type == .autoRenewable }).isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subscriptions")
                        .font(.title2)
                        .fontWeight(.bold)

                    ForEach(storeKitManager.products.filter { $0.type == .autoRenewable }, id: \.id) { product in
                        SubscriptionRow(
                            product: product,
                            isActive: storeKitManager.activeSubscriptions.contains(where: { $0.id == product.id })
                        ) {
                            await purchaseProduct(product)
                        }
                    }
                }
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await storeKitManager.restorePurchases()
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Restore Purchases")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(12)
        }
        .disabled(storeKitManager.isLoading)
    }

    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Actions

    private func purchaseProduct(_ product: Product) async {
        do {
            _ = try await storeKitManager.purchase(product)
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
}

// MARK: - Product Row

struct ProductRow: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () async -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)

                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Button {
                    Task {
                        await onPurchase()
                    }
                } label: {
                    Text(product.displayPrice)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Subscription Row

struct SubscriptionRow: View {
    let product: Product
    let isActive: Bool
    let onSubscribe: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)

                    if isActive {
                        Text("Active Subscription")
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

                    if let subscription = product.subscription {
                        Text("per \(subscription.subscriptionPeriod.unit.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(product.description)
                .font(.caption)
                .foregroundColor(.secondary)

            if !isActive {
                Button {
                    Task {
                        await onSubscribe()
                    }
                } label: {
                    Text("Subscribe")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button {
                    // Open manage subscriptions
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        Task {
                            if #available(iOS 15.0, *) {
                                try? await StoreKit.AppStore.showManageSubscriptions(in: scene)
                            }
                        }
                    }
                } label: {
                    Text("Manage Subscription")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

// MARK: - Extensions

extension Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "period"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
#endif
