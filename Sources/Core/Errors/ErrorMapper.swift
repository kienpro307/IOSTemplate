import Foundation
import ComposableArchitecture

// MARK: - Error Mapper

/// Helper để map các error sang AppError
public struct ErrorMapper {
    
    // MARK: - Main Mapping
    
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
        
        // Map AuthError
        if let authError = error as? AuthError {
            return .auth(authError)
        }
        
        // Map KeychainError
        if let keychainError = error as? KeychainError {
            return .system(.permissionDenied(keychainError.localizedDescription))
        }
        
        // Map DecodingError
        if let decodingError = error as? DecodingError {
            return .data(.decodingFailed(mapDecodingError(decodingError)))
        }
        
        // Map EncodingError
        if let encodingError = error as? EncodingError {
            return .data(.encodingFailed(mapEncodingError(encodingError)))
        }
        
        // Map NSError
        if let nsError = error as NSError? {
            return mapNSError(nsError)
        }
        
        // Fallback: unknown system error
        return .system(.unknown(error.localizedDescription))
    }
    
    // MARK: - Specific Mappings
    
    /// Map NSError sang AppError
    private static func mapNSError(_ nsError: NSError) -> AppError {
        switch nsError.domain {
        case NSURLErrorDomain:
            return mapURLError(nsError)
        case NSCocoaErrorDomain:
            return mapCocoaError(nsError)
        case "SKErrorDomain":
            return mapStoreKitError(nsError)
        default:
            return .system(.unknown(nsError.localizedDescription))
        }
    }
    
    /// Map URL errors
    private static func mapURLError(_ nsError: NSError) -> AppError {
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost:
            return .network(.noConnection)
        case NSURLErrorTimedOut:
            return .network(.timeout)
        case NSURLErrorCancelled:
            return .network(.cancelled)
        case NSURLErrorBadServerResponse:
            return .network(.serverError(statusCode: nsError.code))
        case NSURLErrorSecureConnectionFailed,
             NSURLErrorServerCertificateHasBadDate,
             NSURLErrorServerCertificateUntrusted:
            return .network(.serverError(statusCode: 495)) // SSL error
        default:
            return .network(.unknown)
        }
    }
    
    /// Map Cocoa errors
    private static func mapCocoaError(_ nsError: NSError) -> AppError {
        switch nsError.code {
        case NSFileReadNoSuchFileError, NSFileReadNoPermissionError:
            return .data(.notFound)
        case NSFileWriteOutOfSpaceError:
            return .system(.memoryError)
        case NSFileWriteNoPermissionError:
            return .system(.permissionDenied("Không có quyền ghi file"))
        default:
            return .data(.databaseError(nsError.localizedDescription))
        }
    }
    
    /// Map StoreKit errors
    private static func mapStoreKitError(_ nsError: NSError) -> AppError {
        switch nsError.code {
        case 0: // SKErrorUnknown
            return .iap(code: "UNKNOWN", message: nsError.localizedDescription)
        case 1: // SKErrorClientInvalid
            return .iap(code: "NOT_ALLOWED", message: "Tài khoản không được phép mua hàng")
        case 2: // SKErrorPaymentCancelled
            return .iap(code: "CANCEL", message: "Giao dịch đã bị hủy")
        case 3: // SKErrorPaymentInvalid
            return .iap(code: "INVALID", message: "Giao dịch không hợp lệ")
        case 4: // SKErrorPaymentNotAllowed
            return .iap(code: "NOT_ALLOWED", message: "Không được phép thực hiện giao dịch")
        case 5: // SKErrorStoreProductNotAvailable
            return .iap(code: "UNAVAILABLE", message: "Sản phẩm không khả dụng")
        default:
            return .iap(code: "PURCHASE_FAILED", message: nsError.localizedDescription)
        }
    }
    
    /// Map DecodingError chi tiết
    private static func mapDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .valueNotFound(let type, let context):
            return "Value not found: \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .keyNotFound(let key, let context):
            return "Key not found: \(key.stringValue) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return error.localizedDescription
        }
    }
    
    /// Map EncodingError chi tiết
    private static func mapEncodingError(_ error: EncodingError) -> String {
        switch error {
        case .invalidValue(let value, let context):
            return "Invalid value \(value) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        @unknown default:
            return error.localizedDescription
        }
    }
}

// MARK: - Error Extension

/// Extension để dễ dàng map error
public extension Error {
    /// Map error này sang AppError
    var asAppError: AppError {
        ErrorMapper.mapToAppError(self)
    }
}

// MARK: - Result Extension

public extension Result where Failure == Error {
    /// Map failure sang AppError
    var mappedError: Result<Success, AppError> {
        mapError { ErrorMapper.mapToAppError($0) }
    }
}
