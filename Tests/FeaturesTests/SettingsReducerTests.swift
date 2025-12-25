import XCTest
import ComposableArchitecture
@testable import Features
@testable import Core

/// Unit tests cho SettingsReducer
@MainActor
final class SettingsReducerTests: XCTestCase {

    // MARK: - Test Preferences Loading

    /// Test load preferences từ storage khi onAppear
    func testOnAppearLoadsPreferences() async {
        let savedPreferences = UserPreferences(
            themeMode: .dark,
            languageCode: "vi",
            notificationsEnabled: false
        )

        let mockStorage = MockStorageClient()
        // Pre-save preferences
        try? await mockStorage.save(savedPreferences, forKey: StorageKey.userPreferences)

        let store = TestStore(
            initialState: SettingsState()
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.onAppear)

        await store.receive(.preferencesLoaded(savedPreferences)) {
            $0.preferences = savedPreferences
        }
    }

    /// Test onAppear khi không có preferences đã lưu
    func testOnAppearWithNoSavedPreferences() async {
        let mockStorage = MockStorageClient()

        let store = TestStore(
            initialState: SettingsState()
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = MockAnalyticsClient()
        }

        await store.send(.onAppear)
        // Không nhận .preferencesLoaded vì không có data
    }

    // MARK: - Test Theme Mode Change

    /// Test thay đổi theme mode sang dark
    func testChangeThemeModeToDark() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(themeMode: .light)
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.changeThemeMode(.dark)) {
            $0.preferences.themeMode = .dark
        }

        await store.receive(.preferencesSaved)
    }

    /// Test thay đổi theme mode sang light
    func testChangeThemeModeToLight() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(themeMode: .dark)
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.changeThemeMode(.light)) {
            $0.preferences.themeMode = .light
        }

        await store.receive(.preferencesSaved)
    }

    /// Test thay đổi theme mode sang auto
    func testChangeThemeModeToAuto() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(themeMode: .light)
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.changeThemeMode(.auto)) {
            $0.preferences.themeMode = .auto
        }

        await store.receive(.preferencesSaved)
    }

    // MARK: - Test Language Change

    /// Test thay đổi language sang tiếng Việt
    func testChangeLanguageToVietnamese() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(languageCode: "en")
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.changeLanguage("vi")) {
            $0.preferences.languageCode = "vi"
        }

        await store.receive(.preferencesSaved)
    }

    /// Test thay đổi language sang tiếng Anh
    func testChangeLanguageToEnglish() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(languageCode: "vi")
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.changeLanguage("en")) {
            $0.preferences.languageCode = "en"
        }

        await store.receive(.preferencesSaved)
    }

    // MARK: - Test Notifications Toggle

    /// Test bật notifications
    func testToggleNotificationsOn() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(notificationsEnabled: false)
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.toggleNotifications(true)) {
            $0.preferences.notificationsEnabled = true
        }

        await store.receive(.preferencesSaved)
    }

    /// Test tắt notifications
    func testToggleNotificationsOff() async {
        let mockStorage = MockStorageClient()
        let mockAnalytics = MockAnalyticsClient()

        let store = TestStore(
            initialState: SettingsState(
                preferences: UserPreferences(notificationsEnabled: true)
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.storageClient = mockStorage
            $0.analytics = mockAnalytics
        }

        await store.send(.toggleNotifications(false)) {
            $0.preferences.notificationsEnabled = false
        }

        await store.receive(.preferencesSaved)
    }

    // MARK: - Test Initial State

    /// Test initial state có default values
    func testInitialState() {
        let state = SettingsState()

        XCTAssertEqual(state.preferences.themeMode, .auto)
        XCTAssertEqual(state.preferences.languageCode, "en")
        XCTAssertTrue(state.preferences.notificationsEnabled)
    }

    /// Test initial state với custom preferences
    func testInitialStateWithCustomPreferences() {
        let customPreferences = UserPreferences(
            themeMode: .dark,
            languageCode: "vi",
            notificationsEnabled: false
        )

        let state = SettingsState(preferences: customPreferences)

        XCTAssertEqual(state.preferences.themeMode, .dark)
        XCTAssertEqual(state.preferences.languageCode, "vi")
        XCTAssertFalse(state.preferences.notificationsEnabled)
    }
}

// MARK: - Mock Dependencies

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

/// Mock Analytics Client cho testing
private struct MockAnalyticsClient: AnalyticsServiceProtocol {
    func configure() async {}
    func setUserID(_ userID: String?) async {}
    func setUserProperty(_ value: String?, forName name: String) async {}
    func trackEvent(_ name: String, parameters: [String: Any]?) async {}
    func trackScreen(_ screenName: String, screenClass: String?) async {}
}
