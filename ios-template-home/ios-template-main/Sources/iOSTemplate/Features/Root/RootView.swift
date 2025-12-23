import SwiftUI
import ComposableArchitecture

/// Root view của application
/// Điều khiển navigation và routing chính
public struct RootView: View {
    let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Group {
                if store.user.isAuthenticated {
                    // Authenticated - Show main app
                    MainTabView(store: store)
                } else {
                    // Not authenticated - Show login/onboarding
                    if store.config.featureFlags.showOnboarding {
                        OnboardingView(store: store)
                    } else {
                        LoginView(store: store)
                    }
                }
            }
            .onAppear {
                store.send(AppAction.appLaunched)
            }
            .onChange(of: store.navigation.selectedTab) { newTab in
                handleTabChange(newTab)
            }
        }
    }

    private func handleTabChange(_ tab: AppTab) {
        // Handle tab change analytics, etc.
        print("Tab changed to: \(tab.title)")
    }
}

// MARK: - Preview

#Preview("Authenticated") {
    RootView(
        store: Store(
            initialState: AppState(
                user: UserState(
                    profile: UserProfile(
                        id: "123",
                        email: "test@example.com",
                        name: "Test User"
                    )
                )
            )
        ) {
            AppReducer()
        }
    )
}

#Preview("Not Authenticated") {
    RootView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
