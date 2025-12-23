import SwiftUI
import ComposableArchitecture
import Core

/// Root view của app - hiển thị tab navigation
struct RootView: View {
    @Perception.Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selectedTab.sending(\.tabChanged)) {
                ForEach(AppState.Tab.allCases, id: \.self) { tab in
                    tabView(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .sheet(
                item: Binding(
                    get: { store.presentedDestination },
                    set: { newValue in
                        if newValue == nil {
                            store.send(.dismiss)
                        }
                    }
                )
            ) { destination in
                modalView(for: destination)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onOpenURL { url in
                if let deepLink = DeepLink(url: url) {
                    store.send(.handleDeepLink(deepLink))
                }
            }
        }
    }
    
    // MARK: - Hiển thị Tab
    @ViewBuilder
    private func tabView(for tab: AppState.Tab) -> some View {
        NavigationStack {
            tabRootContent(for: tab)
                .navigationTitle(tab.title)
        }
    }
    
    // MARK: - Nội dung chính của Tab
    @ViewBuilder
    private func tabRootContent(for tab: AppState.Tab) -> some View {
        VStack(spacing: 20) {
            Image(systemName: tab.icon)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text(tab.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tab root screen")
                .foregroundStyle(.secondary)
            
            // Các nút điều hướng mẫu
            VStack(spacing: 12) {
                NavigationLink(value: Destination.settings) {
                    Text("Open Settings")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show About (Modal)") {
                    store.send(.present(.about))
                }
                .buttonStyle(.bordered)
                
                NavigationLink(value: Destination.privacyPolicy) {
                    Text("Privacy Policy")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Thông tin debug
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Info:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("Network: \(store.isConnected ? "Connected ✅" : "Disconnected ❌")")
                    .font(.caption)
                Text("Version: \(store.appVersion)")
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .navigationDestination(for: Destination.self) { destination in
            destinationView(for: destination)
        }
    }
    
    // MARK: - Hiển thị màn hình đích
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        VStack(spacing: 20) {
            Image(systemName: iconForDestination(destination))
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text(destination.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            destinationDescription(for: destination)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Nested navigation (nếu không phải onboarding)
            if destination != .onboarding {
                VStack(spacing: 12) {
                    NavigationLink(value: Destination.settings) {
                        Text("Open Settings")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .navigationTitle(destination.title)
    }
    
    // MARK: - Hiển thị Modal
    @ViewBuilder
    private func modalView(for destination: Destination) -> some View {
        NavigationStack {
            destinationView(for: destination)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            store.send(.dismiss)
                        }
                    }
                }
        }
    }
    
    // MARK: - Các hàm tiện ích
    @ViewBuilder
    private func destinationDescription(for destination: Destination) -> some View {
        switch destination {
        case .webView(let url, _):
            Text("URL: \(url.absoluteString)")
        case .onboarding:
            Text("First time user experience")
        case .settings:
            Text("App preferences and configurations")
        case .privacyPolicy:
            Text("How we handle your data")
        case .termsOfService:
            Text("Terms and conditions")
        case .about:
            Text("About this app")
        default:
            Text("Common screen for all apps")
        }
    }
    
    private func iconForDestination(_ destination: Destination) -> String {
        switch destination {
        case .onboarding, .welcome:
            return "hand.wave"
        case .settings, .settingsTheme, .settingsLanguage, .settingsNotifications:
            return "gear"
        case .about:
            return "info.circle"
        case .privacyPolicy:
            return "hand.raised"
        case .termsOfService:
            return "doc.text"
        case .licenses:
            return "list.bullet"
        case .webView:
            return "safari"
        }
    }
}

// MARK: - Xem trước
#Preview {
    RootView(
        store: Store(initialState: AppState()) {
            AppReducer()
        }
    )
}
