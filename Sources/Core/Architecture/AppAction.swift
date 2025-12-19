import Foundation
import CasePaths

/// Các hành động có thể xảy ra trong app
@CasePathable
public enum AppAction: Equatable {
    // MARK: - Lifecycle
    /// Khi app xuất hiện
    case onAppear
    
    // MARK: - Navigation
    /// Khi tab thay đổi
    case tabChanged(AppState.Tab)
    
    // MARK: - Network
    /// Khi trạng thái kết nối mạng thay đổi
    case networkStatusChanged(Bool)
    
    // MARK: - Feature Actions (sẽ thêm sau)
    // case home(HomeAction)
    // case settings(SettingsAction)
}
