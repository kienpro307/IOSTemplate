import ComposableArchitecture
import Services

/// Reducer chính của ứng dụng - xử lý tất cả các hành động và cập nhật state
@Reducer
public struct AppReducer {
    public init() {}
    
    public typealias State = AppState
    public typealias Action = AppAction
    
    // MARK: - Dependencies
    /// Client xử lý network requests
    @Dependency(\.networkClient) var networkClient
    /// Client lưu trữ dữ liệu (UserDefaults)
    @Dependency(\.storageClient) var storageClient
    /// Client lưu trữ bảo mật (Keychain)
    @Dependency(\.keychainClient) var keychainClient
    /// Client xử lý Date (dễ mock cho testing)
    @Dependency(\.dateClient) var dateClient
    /// Analytics service để track events và screens
    @Dependency(\.analytics) var analytics
    /// Crashlytics service để record errors
    @Dependency(\.crashlytics) var crashlytics
    /// Remote Config service để fetch feature flags
    @Dependency(\.remoteConfig) var remoteConfig
    /// Push Notification service để handle notifications
    @Dependency(\.pushNotification) var pushNotification
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                print("📱 App appeared at: \(dateClient.now())")
                return .run { send in
                    // Fetch Remote Config on startup
                    do {
                        try await remoteConfig.fetchAndActivate()
                        print("✅ Remote Config fetched and activated")
                    } catch {
                        print("⚠️ Remote Config fetch failed: \(error.localizedDescription)")
                    }
                    
                    // Check onboarding status
                    if let hasCompleted: Bool = try? await storageClient.load(
                        forKey: StorageKey.hasCompletedOnboarding.rawValue
                    ) {
                        print("✅ Onboarding completed: \(hasCompleted)")
                    }
                    
                    // Request push notification permission (optional, không block)
                    Task {
                        let granted = await pushNotification.requestPermission()
                        if granted {
                            // Get FCM token
                            if let token = await pushNotification.getToken() {
                                print("📲 FCM Token: \(token)")
                            }
                        }
                    }
                }
                
            case .tabChanged(let tab):
                state.selectedTab = tab
                print("📍 Tab changed to: \(tab.title)")
                // Track tab change vào Analytics
                return .run { _ in
                    await analytics.trackScreen("Tab_\(tab.title)")
                    await analytics.trackEvent("tab_changed", parameters: [
                        "tab_name": tab.title,
                        "tab_id": tab.id
                    ])
                }
                
            case .tabAppeared(let tab):
                // Track tab screen vào Analytics khi tab appear
                return .run { _ in
                    await analytics.trackScreen("Tab_\(tab.title)")
                }
                
            case .screenAppeared(let destination):
                // Track screen vào Analytics khi screen appear
                return .run { _ in
                    await analytics.trackScreen("Screen_\(destination.id)")
                }
                
            case .present(let destination):
                state.presentedDestination = destination
                print("📤 Present: \(destination.title)")
                // Track screen presentation vào Analytics
                return .run { _ in
                    await analytics.trackScreen("Screen_\(destination.id)")
                    await analytics.trackEvent("screen_presented", parameters: [
                        "screen_name": destination.title,
                        "screen_id": destination.id
                    ])
                }
                
            case .dismiss:
                if let destination = state.presentedDestination {
                    print("📥 Dismiss: \(destination.title)")
                    // Track screen dismissal vào Analytics
                    return .run { _ in
                        await analytics.trackEvent("screen_dismissed", parameters: [
                            "screen_name": destination.title,
                            "screen_id": destination.id
                        ])
                    }
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
                
            case .fetchRemoteConfig:
                // Fetch Remote Config
                return .run { send in
                    do {
                        try await remoteConfig.fetchAndActivate()
                        await send(.remoteConfigFetched)
                    } catch {
                        print("⚠️ Remote Config fetch failed: \(error.localizedDescription)")
                    }
                }
                
            case .remoteConfigFetched:
                print("✅ Remote Config fetched successfully")
                return .none
                
            case .requestPushNotificationPermission:
                // Request push notification permission
                return .run { send in
                    let granted = await pushNotification.requestPermission()
                    await send(.pushNotificationPermissionGranted(granted))
                    
                    if granted {
                        // Get FCM token
                        let token = await pushNotification.getToken()
                        await send(.fcmTokenReceived(token))
                    }
                }
                
            case .pushNotificationPermissionGranted(let granted):
                print("🔔 Push notification permission: \(granted ? "granted" : "denied")")
                if granted {
                    // Register for remote notifications
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                return .none
                
            case .fcmTokenReceived(let token):
                if let token = token {
                    print("📲 FCM Token received: \(token)")
                }
                return .none
            }
        }
    }
}
