import ComposableArchitecture
import XCTest
@testable import iOSTemplate

@MainActor
final class AppReducerTests: XCTestCase {

    // MARK: - Lifecycle Tests

    func test_appLaunched_shouldFetchRemoteConfig() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.appLaunched)

        // Then
        await store.receive(AppAction.config(.fetchRemoteConfig))

        // Wait for remote config to be fetched
        await store.receive(AppAction.config(.remoteConfigFetched([
            "feature_new_ui": "true",
            "min_app_version": "1.0.0"
        ]))) {
            $0.config.remoteConfig = [
                "feature_new_ui": "true",
                "min_app_version": "1.0.0"
            ]
        }
    }

    // MARK: - User Action Tests

    func test_loginSuccess_shouldUpdateUserAndNavigateToHome() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        let userProfile = UserProfile(
            id: "test-123",
            email: "test@example.com",
            name: "Test User"
        )

        // When
        await store.send(AppAction.user(.loginSuccess(userProfile))) {
            // Then
            $0.user.profile = userProfile
        }

        await store.receive(AppAction.navigation(.selectTab(.home))) {
            $0.navigation.selectedTab = .home
        }
    }

    func test_logout_shouldClearUserAndNavigateToLogin() async {
        // Given
        let userProfile = UserProfile(
            id: "test-123",
            email: "test@example.com",
            name: "Test User"
        )

        let store = TestStore(
            initialState: AppState(
                user: UserState(profile: userProfile)
            )
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.user(.logout)) {
            // Then
            $0.user.profile = nil
        }

        await store.receive(AppAction.navigation(.navigateTo(.login)))
    }

    func test_changeThemeMode_shouldUpdatePreferences() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.user(.changeThemeMode(.dark))) {
            // Then
            $0.user.preferences.themeMode = .dark
        }
    }

    // MARK: - Navigation Action Tests

    func test_selectTab_shouldUpdateSelectedTab() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.navigation(.selectTab(.profile))) {
            // Then
            $0.navigation.selectedTab = .profile
        }
    }

    func test_handleDeepLink_shouldProcessAndClearDeepLink() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        let deepLinkURL = URL(string: "myapp://profile/123")!

        // When
        await store.send(AppAction.navigation(.handleDeepLink(deepLinkURL))) {
            // Then
            $0.navigation.pendingDeepLink = deepLinkURL
        }

        // Should receive deepLinkHandled after processing
        await store.receive(AppAction.navigation(.deepLinkHandled)) {
            $0.navigation.pendingDeepLink = nil
        }
    }

    // MARK: - Network Action Tests

    func test_networkStatusChanged_shouldUpdateNetworkState() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.network(.statusChanged(isConnected: false, type: .none))) {
            // Then
            $0.network.isConnected = false
            $0.network.connectionType = .none
        }
    }

    func test_requestStarted_shouldIncrementPendingCount() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.network(.requestStarted)) {
            // Then
            $0.network.pendingRequestsCount = 1
        }
    }

    func test_requestCompleted_shouldDecrementPendingCount() async {
        // Given
        let store = TestStore(
            initialState: AppState(
                network: NetworkState(pendingRequestsCount: 2)
            )
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.network(.requestCompleted)) {
            // Then
            $0.network.pendingRequestsCount = 1
        }
    }

    // MARK: - Config Action Tests

    func test_fetchRemoteConfig_shouldFetchAndUpdateConfig() async {
        // Given
        let store = TestStore(
            initialState: AppState()
        ) {
            AppReducer()
        }

        // When
        await store.send(AppAction.config(.fetchRemoteConfig))

        // Then
        await store.receive(AppAction.config(.remoteConfigFetched([
            "feature_new_ui": "true",
            "min_app_version": "1.0.0"
        ]))) {
            $0.config.remoteConfig = [
                "feature_new_ui": "true",
                "min_app_version": "1.0.0"
            ]
        }
    }
}
