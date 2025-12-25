import Foundation

/// Root error type - Loại lỗi gốc cho toàn bộ ứng dụng
public enum AppError: Error, Equatable {
    /// Lỗi mạng
    case network(NetworkError)
    
    /// Lỗi dữ liệu
    case data(DataError)
    
    /// Lỗi nghiệp vụ
    case business(BusinessError)
    
    /// Lỗi hệ thống
    case system(SystemError)
    
    /// Lỗi xác thực
    case auth(AuthError)
    
    /// Lỗi dịch vụ bên ngoài (IAP, Payment, etc.)
    /// - Parameters:
    ///   - domain: Domain của lỗi (ví dụ: "iap", "payment", "ads")
    ///   - code: Mã lỗi
    ///   - message: Thông báo lỗi cho người dùng
    case external(domain: String, code: String, message: String)
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var userMessage: String {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .data(let error):
            return error.userMessage
        case .business(let error):
            return error.userMessage
        case .system(let error):
            return error.userMessage
        case .auth(let error):
            return error.userMessage
        case .external(_, _, let message):
            return message
        }
    }
    
    /// Mô tả kỹ thuật cho logging
    public var technicalDescription: String {
        switch self {
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .data(let error):
            return "Data error: \(error.technicalDescription)"
        case .business(let error):
            return "Business error: \(error.technicalDescription)"
        case .system(let error):
            return "System error: \(error.technicalDescription)"
        case .auth(let error):
            return "Auth error: \(error.technicalDescription)"
        case .external(let domain, let code, let message):
            return "External error [\(domain):\(code)]: \(message)"
        }
    }
    
    /// Có thể retry hay không
    public var canRetry: Bool {
        switch self {
        case .network(let error):
            return error.canRetry
        case .data:
            return true
        case .business:
            return false
        case .system:
            return false
        case .auth:
            return false
        case .external(_, let code, _):
            // Network errors in external services can be retried
            return code.contains("NET") || code.contains("TIMEOUT")
        }
    }
    
    /// Có nên hiển thị cho người dùng không
    public var shouldShowToUser: Bool {
        switch self {
        case .auth(let error):
            // Không show nếu token hết hạn, sẽ redirect đến login
            return !error.shouldLogout
        case .external(_, let code, _):
            // User cancelled không cần show
            return !code.contains("CANCEL")
        default:
            return true
        }
    }
    
    /// Có nên đăng xuất người dùng không
    public var shouldLogout: Bool {
        switch self {
        case .auth(let error):
            return error.shouldLogout
        case .network(.unauthorized):
            return true
        default:
            return false
        }
    }
    
    /// Mức độ nghiêm trọng của lỗi
    public var severity: ErrorSeverity {
        switch self {
        case .network:
            return .medium
        case .data:
            return .low
        case .business:
            return .medium
        case .system(let error):
            switch error {
            case .memoryError, .configurationError:
                return .high
            default:
                return .medium
            }
        case .auth(let error):
            switch error {
            case .accountLocked:
                return .high
            default:
                return .medium
            }
        case .external:
            return .medium
        }
    }
    
    /// Loại lỗi (dùng cho analytics)
    public var errorType: String {
        switch self {
        case .network: return "network"
        case .data: return "data"
        case .business: return "business"
        case .system: return "system"
        case .auth: return "auth"
        case .external(let domain, _, _): return domain
        }
    }
    
    /// Error code (dùng cho analytics và logging)
    public var errorCode: String {
        switch self {
        case .network(let error):
            if let statusCode = error.statusCode {
                return "NET_\(statusCode)"
            }
            return "NET_UNKNOWN"
        case .data(let error):
            switch error {
            case .decodingFailed: return "DATA_DECODE"
            case .encodingFailed: return "DATA_ENCODE"
            case .databaseError: return "DATA_DB"
            case .notFound: return "DATA_404"
            case .invalidData: return "DATA_INVALID"
            }
        case .business(let error):
            switch error {
            case .insufficientBalance: return "BIZ_BALANCE"
            case .limitExceeded: return "BIZ_LIMIT"
            case .invalidInput: return "BIZ_INPUT"
            case .unauthorizedAction: return "BIZ_AUTH"
            case .resourceUnavailable: return "BIZ_UNAVAIL"
            case .validationFailed: return "BIZ_VALID"
            }
        case .system(let error):
            switch error {
            case .unknown: return "SYS_UNKNOWN"
            case .configurationError: return "SYS_CONFIG"
            case .permissionDenied: return "SYS_PERM"
            case .memoryError: return "SYS_MEM"
            case .fileSystemError: return "SYS_FILE"
            case .unavailable: return "SYS_UNAVAIL"
            }
        case .auth(let error):
            switch error {
            case .invalidCredentials: return "AUTH_CRED"
            case .emailAlreadyExists: return "AUTH_EMAILEXIST"
            case .invalidEmail: return "AUTH_EMAIL"
            case .invalidPassword: return "AUTH_PASS"
            case .tokenExpired: return "AUTH_TOKENEXP"
            case .invalidRefreshToken: return "AUTH_REFRESH"
            case .accountLocked: return "AUTH_LOCKED"
            case .accountNotVerified: return "AUTH_UNVERIFIED"
            case .twoFactorRequired: return "AUTH_2FA"
            case .invalidVerificationCode: return "AUTH_VERCODE"
            case .biometricFailed: return "AUTH_BIO"
            }
        case .external(let domain, let code, _):
            return "\(domain.uppercased())_\(code)"
        }
    }
}

/// Mức độ nghiêm trọng của lỗi
public enum ErrorSeverity: String, Equatable {
    /// Lỗi nhỏ, không ảnh hưởng nhiều
    case low
    
    /// Lỗi trung bình, ảnh hưởng một phần chức năng
    case medium
    
    /// Lỗi nghiêm trọng, ảnh hưởng lớn đến ứng dụng
    case high
}

// MARK: - Error Extensions

extension AppError: LocalizedError {
    public var errorDescription: String? {
        return userMessage
    }
    
    public var failureReason: String? {
        return technicalDescription
    }
}

// MARK: - External Error Helpers

extension AppError {
    /// Tạo IAP error
    public static func iap(code: String, message: String) -> AppError {
        .external(domain: "iap", code: code, message: message)
    }
    
    /// Tạo Payment error
    public static func payment(code: String, message: String) -> AppError {
        .external(domain: "payment", code: code, message: message)
    }
    
    /// Tạo Ads error
    public static func ads(code: String, message: String) -> AppError {
        .external(domain: "ads", code: code, message: message)
    }
}
