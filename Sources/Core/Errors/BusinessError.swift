import Foundation

/// Các lỗi nghiệp vụ (business logic errors)
public enum BusinessError: Error, Equatable {
    /// Số dư không đủ
    case insufficientBalance
    
    /// Vượt quá giới hạn
    case limitExceeded(String)
    
    /// Dữ liệu đầu vào không hợp lệ
    case invalidInput(String)
    
    /// Hành động không được phép
    case unauthorizedAction(String)
    
    /// Tài nguyên không khả dụng
    case resourceUnavailable(String)
    
    /// Xác thực thất bại
    case validationFailed(String)
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var userMessage: String {
        switch self {
        case .insufficientBalance:
            return "Số dư không đủ để thực hiện giao dịch."
        case .limitExceeded(let detail):
            return "Đã vượt quá giới hạn. \(detail.isEmpty ? "" : detail)"
        case .invalidInput(let detail):
            return "Thông tin không hợp lệ. \(detail.isEmpty ? "" : detail)"
        case .unauthorizedAction(let detail):
            return "Bạn không có quyền thực hiện hành động này. \(detail.isEmpty ? "" : detail)"
        case .resourceUnavailable(let detail):
            return "Tài nguyên không khả dụng. \(detail.isEmpty ? "" : detail)"
        case .validationFailed(let detail):
            return "Xác thực thất bại. \(detail.isEmpty ? "" : detail)"
        }
    }
    
    /// Mô tả kỹ thuật cho logging
    public var technicalDescription: String {
        switch self {
        case .insufficientBalance:
            return "Insufficient balance"
        case .limitExceeded(let detail):
            return "Limit exceeded: \(detail)"
        case .invalidInput(let detail):
            return "Invalid input: \(detail)"
        case .unauthorizedAction(let detail):
            return "Unauthorized action: \(detail)"
        case .resourceUnavailable(let detail):
            return "Resource unavailable: \(detail)"
        case .validationFailed(let detail):
            return "Validation failed: \(detail)"
        }
    }
}

