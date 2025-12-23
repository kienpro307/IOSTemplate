import Foundation
import ComposableArchitecture
import Moya

/// Protocol định nghĩa các chức năng network
public protocol NetworkClientProtocol: Sendable {
    /// Thực hiện request và decode response
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    
    /// Upload data
    func upload(_ data: Data, to endpoint: APIEndpoint) async throws -> URL
}

// MARK: - Định nghĩa API Endpoint
/// Định nghĩa các endpoint API
public enum APIEndpoint {
    case fetchUser(id: String)
    case updateUser(id: String, data: Data)
    case fetchItems(page: Int, limit: Int)
    
    // Sẽ triển khai TargetType sau (Phase 2)
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế với Moya
public struct LiveNetworkClient: NetworkClientProtocol {
    public init() {}
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // TODO: Triển khai với Moya trong Phase 2
        throw NetworkError.notImplemented
    }
    
    public func upload(_ data: Data, to endpoint: APIEndpoint) async throws -> URL {
        // TODO: Triển khai trong Phase 2
        throw NetworkError.notImplemented
    }
}

// MARK: - Triển khai Mock (cho tests & previews)
/// Triển khai giả lập cho testing
public struct MockNetworkClient: NetworkClientProtocol {
    public var mockHandler: @Sendable (APIEndpoint) async throws -> Any
    
    public init() {
        // Mặc định: throw error
        self.mockHandler = { _ in
            throw NetworkError.invalidResponse
        }
    }
    
    /// Khởi tạo với response cụ thể
    public init<T: Sendable & Codable>(mockResponse: T) {
        self.mockHandler = { _ in mockResponse }
    }
    
    /// Khởi tạo với error
    public init(mockError: Error) {
        self.mockHandler = { _ in throw mockError }
    }
    
    /// Khởi tạo với handler tùy chỉnh
    public init(handler: @escaping @Sendable (APIEndpoint) async throws -> Any) {
        self.mockHandler = handler
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let result = try await mockHandler(endpoint)
        
        guard let typedResult = result as? T else {
            throw NetworkError.invalidResponse
        }
        
        return typedResult
    }
    
    public func upload(_ data: Data, to endpoint: APIEndpoint) async throws -> URL {
        _ = try await mockHandler(endpoint)
        return URL(string: "https://example.com/uploaded")!
    }
}

// MARK: - Các lỗi Network
/// Các lỗi có thể xảy ra khi gọi API
public enum NetworkError: Error, Equatable {
    case notImplemented
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var localizedDescription: String {
        switch self {
        case .notImplemented:
            return "Tính năng chưa được triển khai"
        case .noConnection:
            return "Không có kết nối internet"
        case .timeout:
            return "Yêu cầu đã hết thời gian chờ"
        case .serverError(let code):
            return "Lỗi server: \(code)"
        case .invalidResponse:
            return "Phản hồi không hợp lệ"
        case .decodingFailed:
            return "Không thể giải mã phản hồi"
        }
    }
}

// MARK: - Khóa Dependency
private enum NetworkClientKey: DependencyKey {
    static let liveValue: NetworkClientProtocol = LiveNetworkClient()
    static let testValue: NetworkClientProtocol = MockNetworkClient()
    static let previewValue: NetworkClientProtocol = MockNetworkClient()
}

extension DependencyValues {
    public var networkClient: NetworkClientProtocol {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
