import ComposableArchitecture
import Foundation

/// Global store instance và factory methods
public enum AppStore {
    /// Create production store với live dependencies
    public static func live() -> StoreOf<AppReducer> {
        Store(
            initialState: AppState()
        ) {
            AppReducer()
                ._printChanges() // Debug mode - remove in production
        }
    }

    /// Create preview store cho SwiftUI previews
    public static func preview(
        state: AppState = AppState()
    ) -> StoreOf<AppReducer> {
        Store(
            initialState: state
        ) {
            AppReducer()
        }
    }

    /// Create test store cho testing
    public static func test(
        state: AppState = AppState()
    ) -> TestStore<AppState, AppAction> {
        TestStore(
            initialState: state
        ) {
            AppReducer()
        }
    }
}

// MARK: - Store Type Aliases

/// Type alias cho app store
public typealias AppStoreType = StoreOf<AppReducer>

/// Type alias cho view store
public typealias AppViewStore = ViewStore<AppState, AppAction>
