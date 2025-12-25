import ComposableArchitecture
import Core

/// Reducer xử lý logic của Onboarding feature
@Reducer
public struct OnboardingReducer {
    public init() {}
    
    public typealias State = OnboardingState
    public typealias Action = OnboardingAction
    
    // MARK: - Dependencies
    /// Client lưu trữ dữ liệu (UserDefaults)
    @Dependency(\.storageClient) var storageClient
    /// Analytics service để track events
    @Dependency(\.analytics) var analytics
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextPage:
                // Chuyển sang trang tiếp theo nếu chưa phải trang cuối
                if state.currentPage < state.config.pages.count - 1 {
                    let newPage = state.currentPage + 1
                    state.currentPage = newPage
                    // Capture values before closure
                    let pageTitle = state.config.pages[newPage].title
                    // Track page change vào Analytics
                    return .run { _ in
                        await analytics.trackEvent("onboarding_page_changed", parameters: [
                            "page_index": newPage,
                            "page_title": pageTitle
                        ])
                    }
                }
                return .none
                
            case .previousPage:
                // Chuyển về trang trước nếu chưa phải trang đầu
                if state.currentPage > 0 {
                    state.currentPage -= 1
                }
                return .none
                
            case .goToPage(let page):
                // Chuyển đến trang cụ thể (validate range)
                if page >= 0 && page < state.config.pages.count {
                    state.currentPage = page
                }
                return .none
                
            case .skip:
                // Skip onboarding - đánh dấu đã hoàn thành
                let completedPages = state.currentPage
                return .run { send in
                    // Lưu trạng thái đã hoàn thành
                    try? await storageClient.save(true, forKey: StorageKey.hasCompletedOnboarding.rawValue)
                    
                    // Track skip event vào Analytics
                    await analytics.trackEvent("onboarding_skipped", parameters: [
                        "completed_pages": completedPages
                    ])
                    
                    await send(.complete)
                }
                
            case .complete:
                // Hoàn thành onboarding
                state.hasCompleted = true
                let totalPages = state.config.pages.count
                return .run { _ in
                    // Lưu trạng thái đã hoàn thành
                    try? await storageClient.save(true, forKey: StorageKey.hasCompletedOnboarding.rawValue)
                    
                    // Track completion event vào Analytics
                    await analytics.trackEvent("onboarding_completed", parameters: [
                        "total_pages": totalPages,
                        "completed_pages": totalPages
                    ])
                }
            }
        }
    }
}

