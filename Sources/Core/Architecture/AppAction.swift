import Foundation
import ComposableArchitecture

/// Các hành động có thể xảy ra trong ứng dụng
@CasePathable
public enum AppAction: Equatable {
    // MARK: - Vòng đời ứng dụng
    /// Gọi khi view xuất hiện
    case onAppear
    
    // MARK: - Điều hướng
    /// Thay đổi tab hiện tại
    case tabChanged(AppState.Tab)
    /// Hiển thị màn hình dạng modal
    case present(Destination)
    /// Đóng màn hình modal hiện tại
    case dismiss
    /// Xử lý deep link từ URL
    case handleDeepLink(DeepLink)
    
    // MARK: - Mạng
    /// Trạng thái kết nối mạng thay đổi
    case networkStatusChanged(Bool)
}
