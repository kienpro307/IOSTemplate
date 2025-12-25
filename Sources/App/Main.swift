import SwiftUI
import ComposableArchitecture
import Core
import Services
import UserNotifications
#if os(iOS)
import UIKit
#endif

/// Entry point của ứng dụng iOS
@main
struct iOSTemplateApp: App {
    /// Store chính của ứng dụng - quản lý toàn bộ state
    let store = Store(initialState: AppState()) {
        AppReducer()
    }
    
    #if os(iOS)
    /// Notification delegate để handle push notifications
    @StateObject private var notificationDelegate = NotificationDelegate()
    #endif
    
    init() {
        // Initialize Firebase khi app khởi động
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .onAppear {
                    // Setup notification delegate
                    setupNotifications()
                }
        }
    }
    
    // MARK: - Firebase Setup
    
    /// Setup Firebase với config tự động detect environment
    private func setupFirebase() {
        do {
            let config = FirebaseConfig.auto
            try FirebaseManager.shared.configure(with: config)
        } catch {
            print("❌ Firebase setup failed: \(error.localizedDescription)")
            // App vẫn có thể chạy nếu Firebase setup fail
        }
    }
    
    // MARK: - Push Notifications Setup
    
    /// Setup push notifications delegate
    private func setupNotifications() {
        #if os(iOS)
        // Notification delegate đã được setup trong init
        // Chỉ cần register for remote notifications nếu permission đã được grant
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        #endif
    }
}
