import Foundation
import ComposableArchitecture

// Import NetworkError và KeychainError từ Dependencies
// Note: Các types này được định nghĩa trong các file khác của module Core

/// Helper để map các error sang AppError
public struct ErrorMapper {
    /// Map một Error bất kỳ sang AppError
    /// - Parameter error: Error cần map
    /// - Returns: AppError tương ứng
    public static func mapToAppError(_ error: Error) -> AppError {
        // Nếu đã là AppError, trả về luôn
        if let appError = error as? AppError {
            return appError
        }
        
        // Map NetworkError
        if let networkError = error as? NetworkError {
            return .network(networkError)
        }
        
        // Map DataError
        if let dataError = error as? DataError {
            return .data(dataError)
        }
        
        // Map BusinessError
        if let businessError = error as? BusinessError {
            return .business(businessError)
        }
        
        // Map SystemError
        if let systemError = error as? SystemError {
            return .system(systemError)
        }
        
        // Map KeychainError
        if let keychainError = error as? KeychainError {
            return .system(.permissionDenied(keychainError.localizedDescription))
        }
        
        // Map DecodingError
        if let decodingError = error as? DecodingError {
            return .data(.decodingFailed(decodingError.localizedDescription))
        }
        
        // Map EncodingError
        if let encodingError = error as? EncodingError {
            return .data(.encodingFailed(encodingError.localizedDescription))
        }
        
        // Map NSError
        if let nsError = error as NSError? {
            return mapNSError(nsError)
        }
        
        // Fallback: unknown system error
        return .system(.unknown(error.localizedDescription))
    }
    
    // Note: Error recording to Crashlytics/Analytics should be handled
    // at the Features or App layer where Services module is available.
    // Core module should not depend on Services module.
    
    /// Map NSError sang AppError
    private static func mapNSError(_ nsError: NSError) -> AppError {
        // Kiểm tra domain để xác định loại lỗi
        switch nsError.domain {
        case NSURLErrorDomain:
            // URL errors thường là network errors
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .network(.noConnection)
            case NSURLErrorTimedOut:
                return .network(.timeout)
            case NSURLErrorBadServerResponse:
                return .network(.serverError(statusCode: nsError.code))
            default:
                return .network(.unknown)
            }
            
        case NSCocoaErrorDomain:
            // Cocoa errors thường là data errors
            switch nsError.code {
            case NSFileReadNoSuchFileError,
                 NSFileReadNoPermissionError:
                return .data(.notFound)
            default:
                return .data(.databaseError(nsError.localizedDescription))
            }
            
        default:
            return .system(.unknown(nsError.localizedDescription))
        }
    }
}

/// Extension để dễ dàng map error
public extension Error {
    /// Map error này sang AppError
    var asAppError: AppError {
        ErrorMapper.mapToAppError(self)
    }
}

