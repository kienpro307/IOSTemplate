import Foundation
import ComposableArchitecture

/// Các hành động có thể xảy ra trong app
@CasePathable
public enum AppAction: Equatable {
    // MARK: - Lifecycle
    case onAppear
    
    // MARK: - Navigation
    case tabChanged(AppState.Tab)
    case present(Destination)
    case dismiss
    case handleDeepLink(DeepLink)
    
    // MARK: - Network
    case networkStatusChanged(Bool)
}
