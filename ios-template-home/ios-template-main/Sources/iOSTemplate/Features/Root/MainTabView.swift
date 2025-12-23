import SwiftUI
import ComposableArchitecture

/// Main tab view với 4 tabs: Home, Explore, Profile, Settings
public struct MainTabView: View {
    let store: StoreOf<AppReducer>

    @State private var selectedTab: AppTab = .home

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView(store: store)
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.iconName)
            }
            .tag(AppTab.home)

            // Explore Tab
            NavigationStack {
                ExploreView(store: store)
            }
            .tabItem {
                Label(AppTab.explore.title, systemImage: AppTab.explore.iconName)
            }
            .tag(AppTab.explore)

            // Profile Tab
            NavigationStack {
                ProfileView(store: store)
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.iconName)
            }
            .tag(AppTab.profile)

            // Settings Tab
            NavigationStack {
                SettingsView(store: store)
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
            }
            .tag(AppTab.settings)
        }
        .tint(.theme.primary)
        .onChange(of: selectedTab) { newValue in
            store.send(AppAction.navigation(.selectTab(newValue)))
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView(
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
