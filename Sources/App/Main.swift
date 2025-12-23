import SwiftUI
import ComposableArchitecture
import Core

/// Entry point của ứng dụng iOS
@main
struct iOSTemplateApp: App {
    /// Store chính của ứng dụng - quản lý toàn bộ state
    let store = Store(initialState: AppState()) {
        AppReducer()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
