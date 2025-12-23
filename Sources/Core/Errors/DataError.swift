import Foundation

/// Các lỗi liên quan đến dữ liệu
public enum DataError: Error, Equatable {
    /// Lỗi decode dữ liệu không thành công
    case decodingFailed(String)
    
    /// Lỗi encode dữ liệu không thành công
    case encodingFailed(String)
    
    /// Lỗi database
    case databaseError(String)
    
    /// Không tìm thấy dữ liệu
    case notFound
    
    /// Dữ liệu không hợp lệ
    case invalidData(String)
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var userMessage: String {
        switch self {
        case .decodingFailed(let detail):
            return "Không thể đọc dữ liệu. \(detail.isEmpty ? "" : detail)"
        case .encodingFailed(let detail):
            return "Không thể lưu dữ liệu. \(detail.isEmpty ? "" : detail)"
        case .databaseError(let detail):
            return "Lỗi cơ sở dữ liệu. \(detail.isEmpty ? "" : detail)"
        case .notFound:
            return "Không tìm thấy dữ liệu."
        case .invalidData(let detail):
            return "Dữ liệu không hợp lệ. \(detail.isEmpty ? "" : detail)"
        }
    }
    
    /// Mô tả kỹ thuật cho logging
    public var technicalDescription: String {
        switch self {
        case .decodingFailed(let detail):
            return "Decoding failed: \(detail)"
        case .encodingFailed(let detail):
            return "Encoding failed: \(detail)"
        case .databaseError(let detail):
            return "Database error: \(detail)"
        case .notFound:
            return "Data not found"
        case .invalidData(let detail):
            return "Invalid data: \(detail)"
        }
    }
}

