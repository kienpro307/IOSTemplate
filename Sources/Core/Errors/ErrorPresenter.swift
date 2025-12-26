import Foundation
import SwiftUI

// MARK: - Error Presentation Model

/// Model chứa thông tin để hiển thị lỗi
public struct ErrorPresentation: Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let message: String
    public let icon: String
    public let iconColor: Color
    public let canRetry: Bool
    public let retryAction: (() -> Void)?
    public let dismissAction: (() -> Void)?
    
    public init(
        id: UUID = UUID(),
        title: String,
        message: String,
        icon: String = "exclamationmark.triangle.fill",
        iconColor: Color = .orange,
        canRetry: Bool = false,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
        self.canRetry = canRetry
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }
    
    // Equatable chỉ so sánh các properties có thể so sánh
    public static func == (lhs: ErrorPresentation, rhs: ErrorPresentation) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.icon == rhs.icon &&
        lhs.canRetry == rhs.canRetry
    }
}

// MARK: - Error Presenter

/// Helper để tạo ErrorPresentation từ AppError
public struct ErrorPresenter {
    
    // MARK: - Factory Methods
    
    /// Tạo ErrorPresentation từ AppError
    public static func present(
        _ error: AppError,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) -> ErrorPresentation {
        let (title, icon, iconColor) = getTitleAndIcon(for: error)
        
        return ErrorPresentation(
            title: title,
            message: error.userMessage,
            icon: icon,
            iconColor: iconColor,
            canRetry: error.canRetry && retryAction != nil,
            retryAction: retryAction,
            dismissAction: dismissAction
        )
    }
    
    /// Tạo ErrorPresentation từ Error bất kỳ
    public static func present(
        _ error: Error,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) -> ErrorPresentation {
        let appError = ErrorMapper.mapToAppError(error)
        return present(appError, retryAction: retryAction, dismissAction: dismissAction)
    }
    
    /// Tạo ErrorPresentation cho network error
    public static func presentNetworkError(
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) -> ErrorPresentation {
        ErrorPresentation(
            title: "Lỗi kết nối",
            message: "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.",
            icon: "wifi.slash",
            iconColor: .red,
            canRetry: retryAction != nil,
            retryAction: retryAction,
            dismissAction: dismissAction
        )
    }
    
    /// Tạo ErrorPresentation cho generic error
    public static func presentGenericError(
        message: String? = nil,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) -> ErrorPresentation {
        ErrorPresentation(
            title: "Đã xảy ra lỗi",
            message: message ?? "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.",
            icon: "exclamationmark.triangle.fill",
            iconColor: .orange,
            canRetry: retryAction != nil,
            retryAction: retryAction,
            dismissAction: dismissAction
        )
    }
    
    // MARK: - Private Helpers
    
    private static func getTitleAndIcon(for error: AppError) -> (title: String, icon: String, color: Color) {
        switch error {
        case .network(let networkError):
            return getNetworkErrorInfo(networkError)
        case .data:
            return ("Lỗi dữ liệu", "doc.badge.ellipsis", .orange)
        case .business:
            return ("Không thể thực hiện", "exclamationmark.circle.fill", .orange)
        case .system(let systemError):
            return getSystemErrorInfo(systemError)
        case .auth(let authError):
            return getAuthErrorInfo(authError)
        case .external(let domain, _, _):
            return getExternalErrorInfo(domain: domain)
        }
    }
    
    private static func getAuthErrorInfo(_ error: AuthError) -> (String, String, Color) {
        switch error {
        case .invalidCredentials:
            return ("Đăng nhập thất bại", "person.badge.key.fill", .red)
        case .emailAlreadyExists:
            return ("Email đã tồn tại", "envelope.badge.fill", .orange)
        case .invalidEmail:
            return ("Email không hợp lệ", "envelope.badge.fill", .orange)
        case .invalidPassword:
            return ("Mật khẩu không hợp lệ", "key.fill", .orange)
        case .tokenExpired, .invalidRefreshToken:
            return ("Phiên hết hạn", "clock.badge.exclamationmark", .red)
        case .accountLocked:
            return ("Tài khoản bị khóa", "lock.fill", .red)
        case .accountNotVerified:
            return ("Chưa xác thực", "checkmark.circle", .orange)
        case .twoFactorRequired:
            return ("Xác thực 2 yếu tố", "shield.fill", .blue)
        case .invalidVerificationCode:
            return ("Mã không hợp lệ", "number.circle.fill", .orange)
        case .biometricFailed:
            return ("Xác thực thất bại", "faceid", .red)
        }
    }
    
    private static func getExternalErrorInfo(domain: String) -> (String, String, Color) {
        switch domain {
        case "iap", "payment":
            return ("Lỗi giao dịch", "creditcard.fill", .orange)
        case "ads":
            return ("Lỗi quảng cáo", "rectangle.badge.xmark", .orange)
        default:
            return ("Lỗi dịch vụ", "exclamationmark.triangle.fill", .orange)
        }
    }
    
    private static func getNetworkErrorInfo(_ error: NetworkError) -> (String, String, Color) {
        switch error {
        case .noConnection:
            return ("Không có kết nối", "wifi.slash", .red)
        case .timeout:
            return ("Hết thời gian chờ", "clock.badge.exclamationmark", .orange)
        case .unauthorized:
            return ("Phiên hết hạn", "person.badge.key.fill", .red)
        case .forbidden:
            return ("Không có quyền", "lock.fill", .red)
        case .notFound:
            return ("Không tìm thấy", "magnifyingglass.circle", .orange)
        case .serverError:
            return ("Lỗi máy chủ", "server.rack", .red)
        default:
            return ("Lỗi kết nối", "exclamationmark.triangle.fill", .orange)
        }
    }
    
    private static func getSystemErrorInfo(_ error: SystemError) -> (String, String, Color) {
        switch error {
        case .memoryError:
            return ("Không đủ bộ nhớ", "memorychip.fill", .red)
        case .permissionDenied:
            return ("Không có quyền", "lock.fill", .red)
        case .configurationError:
            return ("Lỗi cấu hình", "gearshape.fill", .red)
        default:
            return ("Lỗi hệ thống", "exclamationmark.triangle.fill", .orange)
        }
    }
    
    }

// MARK: - Alert Presentation

/// Extension để dễ dàng tạo SwiftUI Alert từ ErrorPresentation
public extension ErrorPresentation {
    /// Tạo Alert actions
    func makeAlertActions() -> [AlertAction] {
        var actions: [AlertAction] = []
        
        if canRetry, let retry = retryAction {
            actions.append(AlertAction(title: "Thử lại", role: nil, action: retry))
        }
        
        actions.append(AlertAction(title: "Đóng", role: .cancel, action: dismissAction ?? {}))
        
        return actions
    }
}

/// Action cho Alert
public struct AlertAction: Identifiable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole?
    public let action: () -> Void
    
    public init(title: String, role: ButtonRole?, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
}

/// Button role cho Alert
public enum ButtonRole {
    case cancel
    case destructive
    case none
}

// MARK: - Toast/Banner Presentation

/// Model cho Toast/Banner notification
public struct ErrorToast: Equatable, Identifiable {
    public let id: UUID
    public let message: String
    public let icon: String
    public let iconColor: Color
    public let duration: TimeInterval
    
    public init(
        id: UUID = UUID(),
        message: String,
        icon: String = "exclamationmark.circle.fill",
        iconColor: Color = .orange,
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
        self.duration = duration
    }
    
    /// Tạo Toast từ AppError
    public static func from(_ error: AppError) -> ErrorToast {
        let iconInfo = ErrorPresenter.getToastIconInfo(for: error)
        return ErrorToast(
            message: error.userMessage,
            icon: iconInfo.icon,
            iconColor: iconInfo.color
        )
    }
}

// MARK: - Public Helpers for ErrorToast

extension ErrorPresenter {
    /// Get icon info for toast (public access)
    public static func getToastIconInfo(for error: AppError) -> (icon: String, color: Color) {
        let (_, icon, color) = getTitleAndIcon(for: error)
        return (icon, color)
    }
}

