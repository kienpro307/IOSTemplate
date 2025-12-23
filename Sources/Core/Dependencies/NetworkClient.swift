import Foundation
import ComposableArchitecture
import Moya

/// Protocol định nghĩa các chức năng network
public protocol NetworkClientProtocol: Sendable {
    /// Thực hiện request và decode response
    func request<T: Decodable>(_ target: APITarget) async throws -> T
    
    /// Thực hiện request và trả về Data
    func requestData(_ target: APITarget) async throws -> Data
    
    /// Upload data
    func upload(_ data: Data, to target: APITarget) async throws -> URL
}

// MARK: - Token Provider
/// Provider để cache và cung cấp token cho AccessTokenPlugin
private final class TokenProvider: @unchecked Sendable {
    private var cachedToken: String?
    private let keychainClient: KeychainClientProtocol
    
    init(keychainClient: KeychainClientProtocol) {
        self.keychainClient = keychainClient
    }
    
    /// Lấy token (synchronous, từ cache)
    func getToken() -> String {
        return cachedToken ?? ""
    }
    
    /// Refresh token từ Keychain (async)
    func refreshToken() async {
        cachedToken = try? await keychainClient.load(forKey: KeychainKey.accessToken.rawValue)
    }
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế với Moya
public actor LiveNetworkClient: NetworkClientProtocol {
    private let provider: MoyaProvider<APITarget>
    private let keychainClient: KeychainClientProtocol
    private let tokenProvider: TokenProvider
    
    public init(
        keychainClient: KeychainClientProtocol,
        stubClosure: @escaping MoyaProvider<APITarget>.StubClosure = MoyaProvider.neverStub,
        plugins: [PluginType] = []
    ) {
        self.keychainClient = keychainClient
        self.tokenProvider = TokenProvider(keychainClient: keychainClient)
        
        // Cấu hình plugins
        var allPlugins = plugins
        
        // Thêm network logger trong debug
        #if DEBUG
        allPlugins.append(NetworkLoggerPlugin(configuration: .init(
            logOptions: .verbose
        )))
        #endif
        
        // Thêm auth plugin để tự động inject token
        let authPlugin = AccessTokenPlugin { [tokenProvider] _ in
            tokenProvider.getToken()
        }
        allPlugins.append(authPlugin)
        
        // Tạo provider
        self.provider = MoyaProvider<APITarget>(
            stubClosure: stubClosure,
            plugins: allPlugins
        )
    }
    
    public func request<T: Decodable>(_ target: APITarget) async throws -> T {
        try await performRequest(target: target)
    }
    
    public func requestData(_ target: APITarget) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // Lọc các status code thành công
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        continuation.resume(returning: filteredResponse.data)
                    } catch {
                        continuation.resume(throwing: self.mapError(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error))
                }
            }
        }
    }
    
    public func upload(_ data: Data, to target: APITarget) async throws -> URL {
        // TODO: Implement upload với multipart
        throw NetworkError.notImplemented
    }
    
    // MARK: - Private Methods
    
    /// Thực hiện request và decode response
    private func performRequest<T: Decodable>(target: APITarget) async throws -> T {
        // Refresh token trước khi request (nếu cần)
        await tokenProvider.refreshToken()
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // Lọc các status code thành công
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        
                        // Decode response
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decodedObject = try decoder.decode(T.self, from: filteredResponse.data)
                        
                        continuation.resume(returning: decodedObject)
                    } catch {
                        continuation.resume(throwing: self.mapError(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error))
                }
            }
        }
    }
    
    /// Map Moya error sang NetworkError
    private func mapError(_ error: Error) -> Error {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                // Map HTTP status codes
                switch response.statusCode {
                case 401:
                    return NetworkError.unauthorized
                case 400...499:
                    return NetworkError.serverError(statusCode: response.statusCode)
                case 500...599:
                    return NetworkError.serverError(statusCode: response.statusCode)
                default:
                    return NetworkError.unknown
                }
                
            case .underlying(let underlyingError, _):
                // Kiểm tra kết nối mạng
                let nsError = underlyingError as NSError
                if nsError.domain == NSURLErrorDomain {
                    if nsError.code == NSURLErrorNotConnectedToInternet ||
                       nsError.code == NSURLErrorNetworkConnectionLost {
                        return NetworkError.noConnection
                    }
                    if nsError.code == NSURLErrorTimedOut {
                        return NetworkError.timeout
                    }
                }
                return NetworkError.unknown
                
            default:
                return NetworkError.unknown
            }
        }
        
        return error
    }
}

// MARK: - Triển khai Mock (cho tests & previews)
/// Triển khai giả lập cho testing
public actor MockNetworkClient: NetworkClientProtocol {
    public var mockHandler: @Sendable (APITarget) async throws -> Any
    public var shouldFail = false
    public var mockData: Data?
    public var mockError: Error?
    public var requestCallCount = 0
    
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
        self.mockError = mockError
        self.shouldFail = true
        self.mockHandler = { _ in throw mockError }
    }
    
    /// Khởi tạo với handler tùy chỉnh
    public init(handler: @escaping @Sendable (APITarget) async throws -> Any) {
        self.mockHandler = handler
    }
    
    public func request<T: Decodable>(_ target: APITarget) async throws -> T {
        requestCallCount += 1
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        let result = try await mockHandler(target)
        
        guard let typedResult = result as? T else {
            // Nếu không có typed result, thử decode từ mockData
            if let data = mockData {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            }
            throw NetworkError.invalidResponse
        }
        
        return typedResult
    }
    
    public func requestData(_ target: APITarget) async throws -> Data {
        requestCallCount += 1
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        return mockData ?? Data()
    }
    
    public func upload(_ data: Data, to target: APITarget) async throws -> URL {
        requestCallCount += 1
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        return URL(string: "https://example.com/uploaded")!
    }
}

// MARK: - Các lỗi Network
/// Các lỗi có thể xảy ra khi gọi API
public enum NetworkError: Error, Equatable {
    case notImplemented
    case noConnection
    case timeout
    case unauthorized
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed
    case unknown
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var localizedDescription: String {
        switch self {
        case .notImplemented:
            return "Tính năng chưa được triển khai"
        case .noConnection:
            return "Không có kết nối internet"
        case .timeout:
            return "Yêu cầu đã hết thời gian chờ"
        case .unauthorized:
            return "Không có quyền truy cập"
        case .serverError(let code):
            return "Lỗi server: \(code)"
        case .invalidResponse:
            return "Phản hồi không hợp lệ"
        case .decodingFailed:
            return "Không thể giải mã phản hồi"
        case .unknown:
            return "Lỗi không xác định"
        }
    }
}

// MARK: - Khóa Dependency
private enum NetworkClientKey: DependencyKey {
    static let liveValue: NetworkClientProtocol = LiveNetworkClient(
        keychainClient: LiveKeychainClient()
    )
    static let testValue: NetworkClientProtocol = MockNetworkClient()
    static let previewValue: NetworkClientProtocol = MockNetworkClient()
}

extension DependencyValues {
    public var networkClient: NetworkClientProtocol {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
