import XCTest
import ComposableArchitecture
@testable import Features
@testable import Core

/// Unit tests cho OnboardingReducer
@MainActor
final class OnboardingReducerTests: XCTestCase {

    // MARK: - Test Navigation

    /// Test chuyển sang trang tiếp theo
    func testNextPage() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 0
        
        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Chuyển từ trang 0 → 1
        await store.send(.nextPage) {
            $0.currentPage = 1
        }
        // Effect chạy analytics tracking, không emit action mới
    }

    /// Test không chuyển trang khi đang ở trang cuối
    func testNextPageAtLastPage() async {
        let config = OnboardingConfig.default
        let lastPageIndex = config.pages.count - 1
        
        var state = OnboardingState(config: config)
        state.currentPage = lastPageIndex

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Không thay đổi khi đã ở trang cuối
        await store.send(.nextPage)
    }

    /// Test quay lại trang trước
    func testPreviousPage() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 2

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Quay từ trang 2 → 1
        await store.send(.previousPage) {
            $0.currentPage = 1
        }
    }

    /// Test không quay lại khi đang ở trang đầu
    func testPreviousPageAtFirstPage() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 0

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Không thay đổi khi đã ở trang đầu
        await store.send(.previousPage)
    }

    /// Test chuyển đến trang cụ thể
    func testGoToPage() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 0

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Chuyển đến trang 2
        await store.send(.goToPage(2)) {
            $0.currentPage = 2
        }
    }

    /// Test validate range khi chuyển trang
    func testGoToPageInvalidIndex() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 0

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
            $0.storageClient = MockStorageClient()
        }

        // Không thay đổi khi index < 0
        await store.send(.goToPage(-1))

        // Không thay đổi khi index >= pages.count
        await store.send(.goToPage(100))
    }

    // MARK: - Test Completion

    /// Test skip onboarding
    func testSkip() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 1

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.storageClient = MockStorageClient()
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.skip)
        await store.receive(.complete) {
            $0.hasCompleted = true
        }
    }

    /// Test complete onboarding
    func testComplete() async {
        var state = OnboardingState(config: .default)
        state.currentPage = 2

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        } withDependencies: {
            $0.storageClient = MockStorageClient()
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.complete) {
            $0.hasCompleted = true
        }
    }

    // MARK: - Test Initial State

    /// Test initial state với default config
    func testInitialState() {
        let state = OnboardingState()

        XCTAssertEqual(state.currentPage, 0)
        XCTAssertFalse(state.hasCompleted)
        XCTAssertEqual(state.config.pages.count, 3) // Default có 3 pages
    }

    /// Test initial state với custom config
    func testInitialStateWithCustomConfig() {
        let customConfig = OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "star",
                    title: "Custom",
                    description: "Custom page",
                    color: .blue
                )
            ]
        )

        let state = OnboardingState(config: customConfig)

        XCTAssertEqual(state.currentPage, 0)
        XCTAssertFalse(state.hasCompleted)
        XCTAssertEqual(state.config.pages.count, 1)
    }
}

// MARK: - Mock Dependencies

/// Mock Analytics Client cho testing
private struct MockAnalyticsClient: AnalyticsServiceProtocol {
    func configure() async {}
    func setUserID(_ userID: String?) async {}
    func setUserProperty(_ value: String?, forName name: String) async {}
    func trackEvent(_ name: String, parameters: [String: Any]?) async {}
    func trackScreen(_ screenName: String, screenClass: String?) async {}
}

/// Mock Storage Client cho testing
private actor MockStorageClient: StorageClientProtocol {
    private var storage: [String: Data] = [:]

    func save<T: Codable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        storage[key] = data
    }

    func load<T: Codable>(forKey key: String) async throws -> T? {
        guard let data = storage[key] else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func remove(forKey key: String) async throws {
        storage.removeValue(forKey: key)
    }

    func removeAll() async throws {
        storage.removeAll()
    }

    func exists(forKey key: String) async -> Bool {
        storage[key] != nil
    }
}
