import Foundation

/// Các lỗi hệ thống
public enum SystemError: Error, Equatable {
    /// Lỗi không xác định
    case unknown(String)
    
    /// Lỗi cấu hình
    case configurationError(String)
    
    /// Lỗi quyền truy cập
    case permissionDenied(String)
    
    /// Lỗi bộ nhớ
    case memoryError
    
    /// Lỗi file system
    case fileSystemError(String)
    
    /// Lỗi không khả dụng
    case unavailable(String)
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var userMessage: String {
        switch self {
        case .unknown(let detail):
            return "Đã xảy ra lỗi không xác định. \(detail.isEmpty ? "Vui lòng thử lại sau." : detail)"
        case .configurationError(let detail):
            return "Lỗi cấu hình ứng dụng. \(detail.isEmpty ? "" : detail)"
        case .permissionDenied(let detail):
            return "Không có quyền truy cập. \(detail.isEmpty ? "Vui lòng cấp quyền trong Cài đặt." : detail)"
        case .memoryError:
            return "Không đủ bộ nhớ. Vui lòng đóng các ứng dụng khác và thử lại."
        case .fileSystemError(let detail):
            return "Lỗi hệ thống file. \(detail.isEmpty ? "" : detail)"
        case .unavailable(let detail):
            return "Tính năng không khả dụng. \(detail.isEmpty ? "" : detail)"
        }
    }
    
    /// Mô tả kỹ thuật cho logging
    public var technicalDescription: String {
        switch self {
        case .unknown(let detail):
            return "Unknown error: \(detail)"
        case .configurationError(let detail):
            return "Configuration error: \(detail)"
        case .permissionDenied(let detail):
            return "Permission denied: \(detail)"
        case .memoryError:
            return "Memory error"
        case .fileSystemError(let detail):
            return "File system error: \(detail)"
        case .unavailable(let detail):
            return "Unavailable: \(detail)"
        }
    }
}

