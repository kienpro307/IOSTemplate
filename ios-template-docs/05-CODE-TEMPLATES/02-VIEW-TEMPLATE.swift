// MARK: - [FeatureName]View.swift
// Template cho SwiftUI View với TCA - Code tiếng Anh, comment tiếng Việt

import ComposableArchitecture
import SwiftUI

struct FeatureNameView: View {
    // MARK: - Properties
    @Bindable var store: StoreOf<FeatureNameReducer>
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            headerView
            contentView
            footerView
        }
        .padding()
        .navigationTitle("Title")
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        Text("Header")
            .font(.headline)
    }
    
    // MARK: - Content
    /// Hiển thị nội dung dựa trên trạng thái
    @ViewBuilder
    private var contentView: some View {
        switch store.loadingState {
        case .idle:
            emptyStateView
            
        case .loading:
            loadingView
            
        case .loaded:
            listView
            
        case .failed(let message):
            errorView(message: message)
        }
    }
    
    // MARK: - List View
    /// Danh sách items
    private var listView: some View {
        List {
            ForEach(store.items) { item in
                ItemRowView(item: item)
                    .onTapGesture {
                        store.send(.itemTapped(item))
                    }
            }
            
            // Load more trigger
            if store.hasMoreData {
                ProgressView()
                    .onAppear {
                        store.send(.loadMoreTriggered)
                    }
            }
        }
        .refreshable {
            store.send(.refreshButtonTapped)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Đang tải...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        ContentUnavailableView(
            "Chưa có dữ liệu",
            systemImage: "tray",
            description: Text("Kéo xuống để tải dữ liệu")
        )
    }
    
    // MARK: - Error View
    /// Hiển thị lỗi với nút thử lại
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Đã xảy ra lỗi")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Thử lại") {
                store.send(.refreshButtonTapped)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Footer
    private var footerView: some View {
        Button("Action") {
            store.send(.refreshButtonTapped)
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Item Row
struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FeatureNameView(
            store: Store(initialState: FeatureNameReducer.State()) {
                FeatureNameReducer()
            }
        )
    }
}
