import SwiftUI
import ComposableArchitecture
import iOSTemplate

/// Main iOS App entry point
@main
struct iOSTemplateApp: App {

    // MARK: - Properties

    /// App store - single source of truth
    let store: StoreOf<AppReducer>

    // MARK: - Initialization

    init() {
        // Initialize DI Container
        _ = DIContainer.shared

        // Configure Firebase BEFORE creating store
        // Firebase nên được init sớm nhất có thể
        Self.configureFirebase()

        // Create app store
        self.store = Store(
            initialState: AppState()
        ) {
            AppReducer()
                ._printChanges() // Debug mode - xem state changes
        }

        // Setup initial configuration
        setupApp()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }

    // MARK: - Setup

    private func setupApp() {
        // Configure app-wide settings
        print("🚀 iOSTemplate App Starting...")
    }

    // MARK: - Firebase Configuration

    /// Configure Firebase với environment-specific settings
    ///
    /// Tự động detect Debug/Release và apply config phù hợp:
    /// - Debug: Development config với verbose logging
    /// - Release: Production config với minimal logging
    private static func configureFirebase() {
        do {
            // Auto-detect environment và sử dụng config phù hợp
            let config = FirebaseConfig.auto

            // Configure Firebase Manager
            try FirebaseManager.shared.configure(with: config)

            print("✅ Firebase configured successfully")
            print("📊 Analytics: \(config.isAnalyticsEnabled ? "enabled" : "disabled")")
            print("💥 Crashlytics: \(config.isCrashlyticsEnabled ? "enabled" : "disabled")")
            print("📲 Messaging: \(config.isMessagingEnabled ? "enabled" : "disabled")")
            print("⚙️  Remote Config: \(config.isRemoteConfigEnabled ? "enabled" : "disabled")")
            print("⚡️ Performance: \(config.isPerformanceEnabled ? "enabled" : "disabled")")

        } catch {
            print("❌ Firebase configuration failed: \(error.localizedDescription)")
            // App vẫn có thể hoạt động without Firebase
            // Log error nhưng không crash app
        }
    }
}
