// MARK: - [FeatureName]Tests.swift
// Template cho Unit Tests - Code tiếng Anh, comment tiếng Việt

import XCTest
import ComposableArchitecture
@testable import App

final class FeatureNameReducerTests: XCTestCase {
    
    // MARK: - Test Fetch Success
    /// Kiểm tra tải dữ liệu thành công
    @MainActor
    func testFetchItemsSuccess() async {
        // Given - Chuẩn bị dữ liệu mock
        let mockItems = [Item.mock]
        
        let store = TestStore(
            initialState: FeatureNameReducer.State()
        ) {
            FeatureNameReducer()
        } withDependencies: {
            $0.itemService = MockItemService(items: mockItems)
        }
        
        // When - Thực hiện action
        await store.send(.onAppear)
        
        await store.receive(\.fetchItems) {
            // Then - Kiểm tra state đang loading
            $0.loadingState = .loading
        }
        
        // Nhận response thành công
        await store.receive(\.itemsResponse.success) {
            $0.loadingState = .loaded
            $0.items = mockItems
        }
    }
    
    // MARK: - Test Fetch Failure
    /// Kiểm tra tải dữ liệu thất bại
    @MainActor
    func testFetchItemsFailure() async {
        // Given
        let mockError = NSError(domain: "test", code: 500)
        
        let store = TestStore(
            initialState: FeatureNameReducer.State()
        ) {
            FeatureNameReducer()
        } withDependencies: {
            $0.itemService = MockItemService(mockError: mockError)
        }
        
        // When
        await store.send(.onAppear)
        
        await store.receive(\.fetchItems) {
            $0.loadingState = .loading
        }
        
        // Then - Nhận response lỗi
        await store.receive(\.itemsResponse.failure) {
            $0.loadingState = .failed(mockError.localizedDescription)
            $0.error = mockError.localizedDescription
        }
    }
    
    // MARK: - Test Item Tapped
    /// Kiểm tra khi tap vào item
    @MainActor
    func testItemTapped() async {
        // Given
        let item = Item.mock
        
        let store = TestStore(
            initialState: FeatureNameReducer.State(items: [item])
        ) {
            FeatureNameReducer()
        }
        
        // When
        await store.send(.itemTapped(item)) {
            // Then - Mở detail view
            $0.detail = DetailReducer.State(item: item)
        }
    }
    
    // MARK: - Test Refresh
    /// Kiểm tra làm mới dữ liệu
    @MainActor
    func testRefresh() async {
        // Given
        let store = TestStore(
            initialState: FeatureNameReducer.State(currentPage: 3)
        ) {
            FeatureNameReducer()
        } withDependencies: {
            $0.itemService = MockItemService(items: [])
        }
        
        // When
        await store.send(.refreshButtonTapped) {
            // Then - Reset về trang 1
            $0.currentPage = 1
            $0.hasMoreData = true
        }
        
        await store.receive(\.fetchItems) {
            $0.loadingState = .loading
        }
        
        await store.receive(\.itemsResponse.success) {
            $0.loadingState = .loaded
            $0.hasMoreData = false
        }
    }
}
