import SwiftUI
import ComposableArchitecture
import Core

@main
struct iOSTemplateApp: App {
    // Tạo Store với initial state
    let store = Store(initialState: AppState()) {
        AppReducer()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
