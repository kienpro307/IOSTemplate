// MARK: - [FeatureName]Reducer.swift
// Template cho TCA Reducer - Code tiếng Anh, comment tiếng Việt

import ComposableArchitecture
import Foundation

@Reducer
struct FeatureNameReducer {
    // MARK: - State
    /// Trạng thái của feature
    @ObservableState
    struct State: Equatable {
        // Dữ liệu chính
        var items: [Item] = []
        var selectedItem: Item?
        
        // Trạng thái loading
        var loadingState: LoadingState = .idle
        
        // Lỗi
        var error: String?
        
        // Pagination
        var currentPage: Int = 1
        var hasMoreData: Bool = true
        
        // Child states (optional)
        @Presents var detail: DetailReducer.State?
    }
    
    // MARK: - Loading State
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
    }
    
    // MARK: - Action
    /// Các hành động có thể xảy ra
    enum Action: Equatable {
        // User actions - Hành động từ người dùng
        case onAppear
        case onDisappear
        case refreshButtonTapped
        case itemTapped(Item)
        case loadMoreTriggered
        
        // Internal actions - Hành động nội bộ
        case fetchItems
        case itemsResponse(Result<[Item], Error>)
        
        // Child actions
        case detail(PresentationAction<DetailReducer.Action>)
        
        // Delegate actions - Gửi lên parent
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case itemSelected(Item)
            case didComplete
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.itemService) var itemService
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Cancellation
    enum CancelID {
        case fetchItems
    }
    
    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // MARK: User Actions
            case .onAppear:
                // Tải dữ liệu khi view xuất hiện
                guard state.loadingState == .idle else { return .none }
                return .send(.fetchItems)
                
            case .onDisappear:
                // Hủy các request đang chạy
                return .cancel(id: CancelID.fetchItems)
                
            case .refreshButtonTapped:
                // Làm mới dữ liệu
                state.currentPage = 1
                state.hasMoreData = true
                return .send(.fetchItems)
                
            case .itemTapped(let item):
                // Mở chi tiết item
                state.detail = DetailReducer.State(item: item)
                return .none
                
            case .loadMoreTriggered:
                // Tải thêm dữ liệu
                guard !state.loadingState.isLoading, state.hasMoreData else {
                    return .none
                }
                state.currentPage += 1
                return .send(.fetchItems)
                
            // MARK: Internal Actions
            case .fetchItems:
                state.loadingState = .loading
                state.error = nil
                
                return .run { [page = state.currentPage] send in
                    do {
                        let items = try await itemService.fetchItems(page: page)
                        await send(.itemsResponse(.success(items)))
                    } catch {
                        await send(.itemsResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.fetchItems)
                
            case .itemsResponse(.success(let newItems)):
                state.loadingState = .loaded
                if state.currentPage == 1 {
                    state.items = newItems
                } else {
                    state.items.append(contentsOf: newItems)
                }
                state.hasMoreData = !newItems.isEmpty
                return .none
                
            case .itemsResponse(.failure(let error)):
                state.loadingState = .failed(error.localizedDescription)
                state.error = error.localizedDescription
                return .none
                
            // MARK: Child Actions
            case .detail(.presented(.delegate(.didUpdate(let item)))):
                // Cập nhật item khi child thay đổi
                if let index = state.items.firstIndex(where: { $0.id == item.id }) {
                    state.items[index] = item
                }
                return .none
                
            case .detail:
                return .none
                
            // MARK: Delegate Actions
            case .delegate:
                // Parent sẽ handle
                return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            DetailReducer()
        }
    }
}

// MARK: - Equatable for Error
extension FeatureNameReducer.Action {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear),
             (.onDisappear, .onDisappear),
             (.refreshButtonTapped, .refreshButtonTapped),
             (.fetchItems, .fetchItems),
             (.loadMoreTriggered, .loadMoreTriggered):
            return true
        case (.itemTapped(let l), .itemTapped(let r)):
            return l == r
        case (.itemsResponse(.success(let l)), .itemsResponse(.success(let r))):
            return l == r
        case (.itemsResponse(.failure), .itemsResponse(.failure)):
            return true
        case (.delegate(let l), .delegate(let r)):
            return l == r
        default:
            return false
        }
    }
}
