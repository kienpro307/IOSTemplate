import ComposableArchitecture
import Foundation

/// Trạng thái toàn bộ ứng dụng
@ObservableState
public struct AppState: Equatable {
    // MARK: - Điều hướng
    /// Tab hiện tại đang được chọn
    public var selectedTab: Tab = .home
    
    /// Màn hình đang hiển thị dạng modal/sheet
    public var presentedDestination: Destination?
    
    // MARK: - Mạng
    /// Trạng thái kết nối mạng
    public var isConnected: Bool = true
    
    // MARK: - Thông tin ứng dụng
    /// Phiên bản ứng dụng
    public var appVersion: String = "1.0.0"
    
    public init() {}
    
    // MARK: - Định nghĩa Tab
    /// Enum định nghĩa các tab trong ứng dụng
    public enum Tab: String, CaseIterable, Equatable {
        case home = "home"
        case search = "search"
        case notifications = "notifications"
        case settings = "settings"
        
        public var title: String {
            switch self {
            case .home: return "Home"
            case .search: return "Search"
            case .notifications: return "Notifications"
            case .settings: return "Settings"
            }
        }
        
        public var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .notifications: return "bell"
            case .settings: return "gear"
            }
        }
    }
}
