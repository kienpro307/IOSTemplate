import Foundation
import ComposableArchitecture
import Moya

// MARK: - Network Configuration

/// Cấu hình cho Network Client
public struct NetworkConfiguration: Sendable {
    /// Timeout cho request (giây)
    public let timeout: TimeInterval
    /// Số lần retry tối đa
    public let maxRetryCount: Int
    /// Delay giữa các lần retry (giây)
    public let retryDelay: TimeInterval
    /// Có log request/response không
    public let enableLogging: Bool
    
    public init(
        timeout: TimeInterval = 30,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        enableLogging: Bool = true
    ) {
        self.timeout = timeout
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        self.enableLogging = enableLogging
    }
    
    /// Configuration mặc định
    public static let `default` = NetworkConfiguration()
    
    /// Configuration cho testing (không retry, không log)
    public static let testing = NetworkConfiguration(
        timeout: 5,
        maxRetryCount: 0,
        retryDelay: 0,
        enableLogging: false
    )
}

// MARK: - Protocol

/// Protocol định nghĩa các chức năng network
public protocol NetworkClientProtocol: Sendable {
    /// Thực hiện request và decode response
    func request<T: Decodable>(_ target: APITarget) async throws -> T
    
    /// Thực hiện request và trả về Data
    func requestData(_ target: APITarget) async throws -> Data
    
    /// Upload data lên server
    func upload(_ data: Data, to target: APITarget, progressHandler: ((Double) -> Void)?) async throws -> Data
    
    /// Download file từ server
    func download(from url: URL, progressHandler: ((Double) -> Void)?) async throws -> URL
}

// MARK: - Token Provider

/// Provider để cache và cung cấp token cho AccessTokenPlugin
/// Swift 6: Sử dụng actor + sync cache cho AccessTokenPlugin compatibility
private actor TokenProviderActor {
    private var cachedToken: String?
    private let keychainClient: KeychainClientProtocol

    init(keychainClient: KeychainClientProtocol) {
        self.keychainClient = keychainClient
    }

    /// Refresh token từ Keychain (async)
    func refreshToken() async -> String? {
        let token = try? await keychainClient.load(forKey: KeychainKey.accessToken.rawValue)
        cachedToken = token
        return token
    }

    /// Clear cached token
    func clearToken() {
        cachedToken = nil
    }

    /// Get current token
    func getToken() -> String? {
        cachedToken
    }
}

/// Sync wrapper cho AccessTokenPlugin (cần sync closure)
private final class TokenProvider: @unchecked Sendable {
    private let actor: TokenProviderActor
    private var syncCachedToken: String = ""

    init(keychainClient: KeychainClientProtocol) {
        self.actor = TokenProviderActor(keychainClient: keychainClient)
    }

    /// Lấy token (synchronous, cho AccessTokenPlugin)
    func getToken() -> String {
        syncCachedToken
    }

    /// Refresh token từ Keychain (async)
    func refreshToken() async {
        if let token = await actor.refreshToken() {
            syncCachedToken = token
        }
    }

    /// Clear cached token (synchronous)
    /// Note: Actor clearing happens async, but sync cache is cleared immediately
    func clearToken() {
        syncCachedToken = ""
        // Actor will be cleared on next refresh
    }
}

// MARK: - Live Implementation

/// Triển khai thực tế với Moya
public actor LiveNetworkClient: NetworkClientProtocol {
    private let provider: MoyaProvider<APITarget>
    private let keychainClient: KeychainClientProtocol
    private let tokenProvider: TokenProvider
    private let configuration: NetworkConfiguration
    
    public init(
        keychainClient: KeychainClientProtocol,
        configuration: NetworkConfiguration = .default,
        stubClosure: @escaping MoyaProvider<APITarget>.StubClosure = MoyaProvider.neverStub,
        plugins: [PluginType] = []
    ) {
        self.keychainClient = keychainClient
        self.configuration = configuration
        self.tokenProvider = TokenProvider(keychainClient: keychainClient)
        
        // Cấu hình plugins
        var allPlugins = plugins
        
        // Thêm network logger trong debug
        #if DEBUG
        if configuration.enableLogging {
            allPlugins.append(NetworkLoggerPlugin(configuration: .init(
                logOptions: .verbose
            )))
        }
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
    
    // MARK: - Public Methods
    
    public func request<T: Decodable>(_ target: APITarget) async throws -> T {
        try await performRequestWithRetry(target: target)
    }
    
    public func requestData(_ target: APITarget) async throws -> Data {
        try await performDataRequestWithRetry(target: target)
    }
    
    public func upload(_ data: Data, to target: APITarget, progressHandler: ((Double) -> Void)?) async throws -> Data {
        try await performUpload(data: data, target: target, progressHandler: progressHandler)
    }
    
    public func download(from url: URL, progressHandler: ((Double) -> Void)?) async throws -> URL {
        try await performDownload(url: url, progressHandler: progressHandler)
    }
    
    // MARK: - Private Methods with Retry
    
    /// Thực hiện request với retry logic
    private func performRequestWithRetry<T: Decodable>(target: APITarget, attempt: Int = 0) async throws -> T {
        do {
            return try await performRequest(target: target)
        } catch {
            // Check if should retry
            if shouldRetry(error: error, attempt: attempt) {
                // Wait before retry using async delay
                let delay = configuration.retryDelay * Double(attempt + 1)
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        continuation.resume()
                    }
                }
                return try await performRequestWithRetry(target: target, attempt: attempt + 1)
            }
            throw error
        }
    }
    
    /// Thực hiện data request với retry logic
    private func performDataRequestWithRetry(target: APITarget, attempt: Int = 0) async throws -> Data {
        do {
            return try await performDataRequest(target: target)
        } catch {
            if shouldRetry(error: error, attempt: attempt) {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    DispatchQueue.global().asyncAfter(deadline: .now() + configuration.retryDelay * Double(attempt + 1)) {
                        continuation.resume()
                    }
                }
                return try await performDataRequestWithRetry(target: target, attempt: attempt + 1)
            }
            throw error
        }
    }
    
    /// Kiểm tra có nên retry không
    private func shouldRetry(error: Error, attempt: Int) -> Bool {
        guard attempt < configuration.maxRetryCount else { return false }
        
        // Chỉ retry với các lỗi có thể recover
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noConnection, .timeout:
                return true
            case .serverError(let code):
                return code >= 500
            default:
                return false
            }
        }
        
        return false
    }
    
    /// Thực hiện request và decode response
    private func performRequest<T: Decodable>(target: APITarget) async throws -> T {
        // Refresh token trước khi request
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
                        decoder.dateDecodingStrategy = .iso8601
                        let decodedObject = try decoder.decode(T.self, from: filteredResponse.data)
                        
                        continuation.resume(returning: decodedObject)
                    } catch {
                        continuation.resume(throwing: self.mapError(error, response: response))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, response: nil))
                }
            }
        }
    }
    
    /// Thực hiện request và trả về raw data
    private func performDataRequest(target: APITarget) async throws -> Data {
        await tokenProvider.refreshToken()
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        continuation.resume(returning: filteredResponse.data)
                    } catch {
                        continuation.resume(throwing: self.mapError(error, response: response))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, response: nil))
                }
            }
        }
    }
    
    /// Thực hiện upload
    private func performUpload(data: Data, target: APITarget, progressHandler: ((Double) -> Void)?) async throws -> Data {
        await tokenProvider.refreshToken()
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target, callbackQueue: .main, progress: { progress in
                progressHandler?(progress.progress)
            }) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        continuation.resume(returning: filteredResponse.data)
                    } catch {
                        continuation.resume(throwing: self.mapError(error, response: response))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, response: nil))
                }
            }
        }
    }
    
    /// Thực hiện download
    private func performDownload(url: URL, progressHandler: ((Double) -> Void)?) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
                if let error = error {
                    continuation.resume(throwing: self.mapError(error, response: nil))
                    return
                }
                
                guard let localURL = localURL else {
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                
                // Move file to permanent location
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                
                do {
                    // Remove existing file if exists
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: NetworkError.downloadFailed(error.localizedDescription))
                }
            }
            
            // Setup progress observation
            if let progressHandler = progressHandler {
                let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                    DispatchQueue.main.async {
                        progressHandler(progress.fractionCompleted)
                    }
                }
                // Store observation to prevent deallocation
                objc_setAssociatedObject(task, "progressObservation", observation, .OBJC_ASSOCIATION_RETAIN)
            }
            
            task.resume()
        }
    }
    
    /// Map Moya error sang NetworkError
    nonisolated private func mapError(_ error: Error, response: Response?) -> NetworkError {
        // Thử parse error message từ response
        var serverMessage: String?
        if let response = response,
           let json = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
           let message = json["message"] as? String ?? json["error"] as? String {
            serverMessage = message
        }
        
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                switch response.statusCode {
                case 400:
                    return .badRequest(serverMessage ?? "Yêu cầu không hợp lệ")
                case 401:
                    tokenProvider.clearToken() // Clear cached token
                    return .unauthorized
                case 403:
                    return .forbidden
                case 404:
                    return .notFound
                case 422:
                    return .validationError(serverMessage ?? "Dữ liệu không hợp lệ")
                case 429:
                    return .tooManyRequests
                case 400...499:
                    return .clientError(statusCode: response.statusCode, message: serverMessage)
                case 500...599:
                    return .serverError(statusCode: response.statusCode)
                default:
                    return .unknown
                }
                
            case .underlying(let underlyingError, _):
                let nsError = underlyingError as NSError
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                        return .noConnection
                    case NSURLErrorTimedOut:
                        return .timeout
                    case NSURLErrorCancelled:
                        return .cancelled
                    default:
                        return .unknown
                    }
                }
                return .unknown
                
            case .objectMapping:
                return .decodingFailed
                
            default:
                return .unknown
            }
        }
        
        if error is DecodingError {
            return .decodingFailed
        }
        
        return .unknown
    }
}

// MARK: - Mock Implementation

/// Triển khai giả lập cho testing
public actor MockNetworkClient: NetworkClientProtocol {
    public var mockHandler: @Sendable (APITarget) async throws -> Any
    public var shouldFail = false
    public var mockData: Data?
    public var mockError: Error?
    public var requestCallCount = 0
    public var lastRequestedTarget: APITarget?
    
    public init() {
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
        lastRequestedTarget = target
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        let result = try await mockHandler(target)
        
        guard let typedResult = result as? T else {
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
        lastRequestedTarget = target
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        return mockData ?? Data()
    }
    
    public func upload(_ data: Data, to target: APITarget, progressHandler: ((Double) -> Void)?) async throws -> Data {
        requestCallCount += 1
        lastRequestedTarget = target
        
        // Simulate progress (without blocking)
        if let progressHandler = progressHandler {
            for i in 1...10 {
                progressHandler(Double(i) / 10.0)
            }
        }
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        return mockData ?? Data()
    }
    
    public func download(from url: URL, progressHandler: ((Double) -> Void)?) async throws -> URL {
        requestCallCount += 1
        
        // Simulate progress (without blocking)
        if let progressHandler = progressHandler {
            for i in 1...10 {
                progressHandler(Double(i) / 10.0)
            }
        }
        
        if shouldFail {
            throw mockError ?? NetworkError.invalidResponse
        }
        
        return URL(fileURLWithPath: "/tmp/mock_download.file")
    }
    
    /// Reset mock state
    public func reset() {
        shouldFail = false
        mockData = nil
        mockError = nil
        requestCallCount = 0
        lastRequestedTarget = nil
    }
}

// MARK: - NetworkError

/// Các lỗi có thể xảy ra khi gọi API
public enum NetworkError: Error, Equatable {
    // Connection errors
    case noConnection
    case timeout
    case cancelled
    
    // HTTP errors
    case badRequest(String)
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case tooManyRequests
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int)
    
    // Response errors
    case invalidResponse
    case decodingFailed
    case downloadFailed(String)
    case uploadFailed(String)
    
    // Other
    case notImplemented
    case unknown
    
    /// Mô tả lỗi dễ hiểu cho người dùng
    public var localizedDescription: String {
        switch self {
        case .noConnection:
            return "Không có kết nối internet. Vui lòng kiểm tra kết nối mạng."
        case .timeout:
            return "Yêu cầu đã hết thời gian chờ. Vui lòng thử lại."
        case .cancelled:
            return "Yêu cầu đã bị hủy."
        case .badRequest(let message):
            return message.isEmpty ? "Yêu cầu không hợp lệ." : message
        case .unauthorized:
            return "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
        case .forbidden:
            return "Bạn không có quyền truy cập tài nguyên này."
        case .notFound:
            return "Không tìm thấy dữ liệu yêu cầu."
        case .validationError(let message):
            return message.isEmpty ? "Dữ liệu không hợp lệ." : message
        case .tooManyRequests:
            return "Quá nhiều yêu cầu. Vui lòng thử lại sau."
        case .clientError(_, let message):
            return message ?? "Đã xảy ra lỗi. Vui lòng thử lại."
        case .serverError(let code):
            return "Lỗi máy chủ (\(code)). Vui lòng thử lại sau."
        case .invalidResponse:
            return "Phản hồi từ máy chủ không hợp lệ."
        case .decodingFailed:
            return "Không thể xử lý dữ liệu từ máy chủ."
        case .downloadFailed(let message):
            return "Tải xuống thất bại. \(message)"
        case .uploadFailed(let message):
            return "Tải lên thất bại. \(message)"
        case .notImplemented:
            return "Tính năng chưa được triển khai."
        case .unknown:
            return "Đã xảy ra lỗi không xác định. Vui lòng thử lại."
        }
    }
    
    /// Có thể retry không
    public var canRetry: Bool {
        switch self {
        case .noConnection, .timeout, .serverError, .tooManyRequests:
            return true
        default:
            return false
        }
    }
    
    /// HTTP status code (nếu có)
    public var statusCode: Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .validationError: return 422
        case .tooManyRequests: return 429
        case .clientError(let code, _): return code
        case .serverError(let code): return code
        default: return nil
        }
    }
}

// MARK: - Dependency Key

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

