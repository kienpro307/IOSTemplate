import XCTest
import ComposableArchitecture
@testable import Features
@testable import Core

/// Unit tests cho HomeReducer
@MainActor
final class HomeReducerTests: XCTestCase {

    // MARK: - Test Screen Tracking

    /// Test analytics được gọi khi màn hình xuất hiện
    func testOnAppear() async {
        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        // onAppear trả về .run effect cho analytics tracking
        // Không có action nào được emit sau đó
        await store.send(.onAppear)
    }

    // MARK: - Test User Interactions

    /// Test notification tapped tracking
    func testNotificationTapped() async {
        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.notificationTapped)
    }

    /// Test get started button tapped tracking
    func testGetStartedTapped() async {
        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.getStartedTapped)
    }

    /// Test quick action tapped tracking
    func testQuickActionTapped() async {
        let quickAction = QuickAction(
            icon: "star",
            title: "Test Action",
            color: .blue
        )

        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.quickActionTapped(quickAction))
    }

    /// Test activity tapped tracking
    func testActivityTapped() async {
        let activity = Activity(
            icon: "star",
            title: "Test Activity",
            subtitle: "Test subtitle",
            color: .green
        )

        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.activityTapped(activity))
    }

    /// Test see all tapped tracking
    func testSeeAllTapped() async {
        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.seeAllTapped)
    }

    // MARK: - Test Refresh Logic

    /// Test refresh bắt đầu và hoàn thành
    func testRefreshFlow() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: HomeState()
        ) {
            HomeReducer()
        } withDependencies: {
            $0.continuousClock = clock
            $0.analytics = MockAnalyticsClient()
        }

        // Bắt đầu refresh
        await store.send(.refresh) {
            $0.isLoading = true
        }

        // Advance clock 1 second
        await clock.advance(by: .seconds(1))

        // Nhận refreshCompleted
        await store.receive(.refreshCompleted) {
            $0.isLoading = false
        }
    }

    /// Test refresh hoàn thành
    func testRefreshCompleted() async {
        var initialState = HomeState()
        initialState.isLoading = true
        
        let store = TestStore(
            initialState: initialState
        ) {
            HomeReducer()
        } withDependencies: {
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.refreshCompleted) {
            $0.isLoading = false
        }
    }

    // MARK: - Test State Management

    /// Test initial state có default values
    func testInitialState() {
        let state = HomeState()

        XCTAssertEqual(state.quickActions.count, 4) // Default có 4 quick actions
        XCTAssertEqual(state.recentActivities.count, 3) // Default có 3 activities
        XCTAssertFalse(state.isLoading)
    }
}

// MARK: - Mock Analytics Client

/// Mock Analytics Client cho testing
private struct MockAnalyticsClient: AnalyticsServiceProtocol {
    func configure() async {}
    func setUserID(_ userID: String?) async {}
    func setUserProperty(_ value: String?, forName name: String) async {}
    func trackEvent(_ name: String, parameters: [String: Any]?) async {}
    func trackScreen(_ screenName: String, screenClass: String?) async {}
}
