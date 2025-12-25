import Foundation

/// Các lỗi liên quan đến xác thực
public enum AuthError: Error, Equatable {
    /// Sai email hoặc mật khẩu
    case invalidCredentials
    
    /// Email đã tồn tại
    case emailAlreadyExists
    
    /// Email không hợp lệ
    case invalidEmail
    
    /// Mật khẩu không hợp lệ (quá ngắn, không đủ phức tạp...)
    case invalidPassword(String)
    
    /// Token hết hạn
    case tokenExpired
    
    /// Refresh token không hợp lệ
    case invalidRefreshToken
    
    /// Tài khoản bị khóa
    case accountLocked
    
    /// Tài khoản chưa được xác thực
    case accountNotVerified
    
    /// Yêu cầu xác thực 2 yếu tố
    case twoFactorRequired
    
    /// Mã xác thực không hợp lệ
    case invalidVerificationCode
    
    /// Biometric authentication thất bại
    case biometricFailed(String)
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var userMessage: String {
        switch self {
        case .invalidCredentials:
            return "Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại."
        case .emailAlreadyExists:
            return "Email này đã được sử dụng. Vui lòng sử dụng email khác."
        case .invalidEmail:
            return "Email không hợp lệ. Vui lòng nhập email đúng định dạng."
        case .invalidPassword(let reason):
            return reason.isEmpty ? "Mật khẩu không hợp lệ." : reason
        case .tokenExpired:
            return "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
        case .invalidRefreshToken:
            return "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại."
        case .accountLocked:
            return "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ."
        case .accountNotVerified:
            return "Tài khoản chưa được xác thực. Vui lòng kiểm tra email để xác thực."
        case .twoFactorRequired:
            return "Vui lòng nhập mã xác thực 2 yếu tố."
        case .invalidVerificationCode:
            return "Mã xác thực không đúng. Vui lòng thử lại."
        case .biometricFailed(let reason):
            return reason.isEmpty ? "Xác thực sinh trắc học thất bại." : reason
        }
    }
    
    /// Mô tả kỹ thuật cho logging
    public var technicalDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials"
        case .emailAlreadyExists:
            return "Email already exists"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPassword(let reason):
            return "Invalid password: \(reason)"
        case .tokenExpired:
            return "Token expired"
        case .invalidRefreshToken:
            return "Invalid refresh token"
        case .accountLocked:
            return "Account locked"
        case .accountNotVerified:
            return "Account not verified"
        case .twoFactorRequired:
            return "2FA required"
        case .invalidVerificationCode:
            return "Invalid verification code"
        case .biometricFailed(let reason):
            return "Biometric authentication failed: \(reason)"
        }
    }
    
    /// Có nên đăng xuất người dùng không
    public var shouldLogout: Bool {
        switch self {
        case .tokenExpired, .invalidRefreshToken, .accountLocked:
            return true
        default:
            return false
        }
    }
}

