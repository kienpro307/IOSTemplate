import ComposableArchitecture
import Foundation

/// Trạng thái toàn bộ ứng dụng
@ObservableState
public struct AppState: Equatable {
    // MARK: - Navigation
    /// Tab hiện tại
    public var selectedTab: Tab = .home
    
    /// Presented destination (modal/sheet)
    public var presentedDestination: Destination?
    
    // MARK: - Network
    /// Có kết nối mạng không
    public var isConnected: Bool = true
    
    // MARK: - App Info
    /// Phiên bản app
    public var appVersion: String = "1.0.0"
    
    public init() {}
    
    // MARK: - Tab Definition
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
