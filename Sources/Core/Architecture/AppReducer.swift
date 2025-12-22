import ComposableArchitecture

/// Reducer chính của ứng dụng
@Reducer
public struct AppReducer {
    public init() {}
    
    public typealias State = AppState
    public typealias Action = AppAction
    
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.dateClient) var dateClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                print("📱 App appeared at: \(dateClient.now())")
                return .run { send in
                    if let hasCompleted: Bool = try? await storageClient.load(
                        forKey: StorageKey.hasCompletedOnboarding.rawValue
                    ) {
                        print("✅ Onboarding completed: \(hasCompleted)")
                    }
                }
                
            case .tabChanged(let tab):
                state.selectedTab = tab
                print("📍 Tab changed to: \(tab.title)")
                return .none
                
            case .present(let destination):
                state.presentedDestination = destination
                print("📤 Present: \(destination.title)")
                return .none
                
            case .dismiss:
                if let destination = state.presentedDestination {
                    print("📥 Dismiss: \(destination.title)")
                }
                state.presentedDestination = nil
                return .none
                
            case .handleDeepLink(let deepLink):
                print("🔗 Handle deep link: \(deepLink)")
                guard let destination = deepLink.toDestination() else {
                    return .none
                }
                return .send(.present(destination))
                
            case .networkStatusChanged(let isConnected):
                state.isConnected = isConnected
                print(isConnected ? "🌐 Connected" : "📴 Disconnected")
                return .none
            }
        }
    }
}
