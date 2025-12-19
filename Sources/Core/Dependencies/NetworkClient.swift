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

// MARK: - API Endpoint Definition
/// Định nghĩa các endpoint API
public enum APIEndpoint {
    case fetchUser(id: String)
    case updateUser(id: String, data: Data)
    case fetchItems(page: Int, limit: Int)
    
    // Sẽ implement TargetType sau (Phase 2)
}

// MARK: - Live Implementation
/// Implementation thực tế với Moya
public struct LiveNetworkClient: NetworkClientProtocol {
    public init() {}
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // TODO: Implement với Moya trong Phase 2
        throw NetworkError.notImplemented
    }
    
    public func upload(_ data: Data, to endpoint: APIEndpoint) async throws -> URL {
        // TODO: Implement trong Phase 2
        throw NetworkError.notImplemented
    }
}

// MARK: - Mock Implementation (for tests & previews)
/// Implementation giả cho testing
public struct MockNetworkClient: NetworkClientProtocol {
    public var mockHandler: @Sendable (APIEndpoint) async throws -> Any
    
    public init() {
        // Default: throw error
        self.mockHandler = { _ in
            throw NetworkError.invalidResponse
        }
    }
    
    // Initializer với response cụ thể
    public init<T: Sendable & Codable>(mockResponse: T) {
        self.mockHandler = { _ in mockResponse }
    }
    
    // Initializer với error
    public init(mockError: Error) {
        self.mockHandler = { _ in throw mockError }
    }
    
    // Initializer với custom handler
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

// MARK: - Network Errors
public enum NetworkError: Error, Equatable {
    case notImplemented
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed
    
    public var localizedDescription: String {
        switch self {
        case .notImplemented:
            return "Feature not implemented yet"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timeout"
        case .serverError(let code):
            return "Server error: \(code)"
        case .invalidResponse:
            return "Invalid response"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}

// MARK: - Dependency Key
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
