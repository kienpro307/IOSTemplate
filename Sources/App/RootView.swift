import SwiftUI
import ComposableArchitecture
import Core

/// Root view của app - hiển thị tab navigation
struct RootView: View {
    @Perception.Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabChanged)) {
            ForEach(AppState.Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    /// Nội dung cho mỗi tab
    @ViewBuilder
    private func tabContent(for tab: AppState.Tab) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: tab.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)
                
                Text(tab.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming soon...")
                    .foregroundStyle(.secondary)
                
                // Debug info
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
            .navigationTitle(tab.title)
        }
    }
}

// MARK: - Preview
#Preview {
    RootView(
        store: Store(initialState: AppState()) {
            AppReducer()
        }
    )
}
