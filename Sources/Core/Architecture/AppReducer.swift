import ComposableArchitecture

/// Reducer chính của ứng dụng - xử lý tất cả logic
@Reducer
public struct AppReducer {
    public init() {}
    
    // MARK: - State & Action types
    public typealias State = AppState
    public typealias Action = AppAction
    
    // MARK: - Dependencies
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.keychainClient) var keychainClient
    @Dependency(\.dateClient) var dateClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Khởi tạo app
                print("📱 App appeared at: \(dateClient.now())")
                
                // Demo: Load saved data
                return .run { send in
                    // Load onboarding status
                    if let hasCompleted: Bool = try? await storageClient.load(
                        forKey: StorageKey.hasCompletedOnboarding.rawValue
                    ) {
                        print("✅ Onboarding completed: \(hasCompleted)")
                    }
                }
                
            case .tabChanged(let tab):
                // Chuyển tab
                state.selectedTab = tab
                print("📍 Tab changed to: \(tab.title)")
                return .none
                
            case .networkStatusChanged(let isConnected):
                // Cập nhật trạng thái mạng
                state.isConnected = isConnected
                print(isConnected ? "🌐 Connected" : "📴 Disconnected")
                return .none
            }
        }
    }
}
