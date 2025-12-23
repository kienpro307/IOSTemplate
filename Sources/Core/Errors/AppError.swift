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
        }
    }
    
    /// Có thể retry hay không
    public var canRetry: Bool {
        switch self {
        case .network:
            return true
        case .data:
            return true
        case .business:
            return false
        case .system:
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
        }
    }
}

/// Mức độ nghiêm trọng của lỗi
public enum ErrorSeverity: Equatable {
    /// Lỗi nhỏ, không ảnh hưởng nhiều
    case low
    
    /// Lỗi trung bình, ảnh hưởng một phần chức năng
    case medium
    
    /// Lỗi nghiêm trọng, ảnh hưởng lớn đến ứng dụng
    case high
}

