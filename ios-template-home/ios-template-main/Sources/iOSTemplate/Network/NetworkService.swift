import Foundation
import Moya

/// Network Service implementation với Moya
public final class NetworkService: NetworkServiceProtocol {

    // MARK: - Properties

    private let provider: MoyaProvider<APITarget>
    private let keychainStorage: SecureStorageProtocol

    // MARK: - Initialization

    public init(
        keychainStorage: SecureStorageProtocol,
        stubClosure: @escaping MoyaProvider<APITarget>.StubClosure = MoyaProvider.neverStub,
        plugins: [PluginType] = []
    ) {
        self.keychainStorage = keychainStorage

        // Configure plugins
        var allPlugins = plugins

        // Add network logger in debug
        #if DEBUG
        allPlugins.append(NetworkLoggerPlugin(configuration: .init(
            logOptions: .verbose
        )))
        #endif

        // Add auth plugin
        // Note: Capture keychainStorage directly (not self) to avoid initialization order issues
        let authPlugin = AccessTokenPlugin { _ in
            guard let token = try? keychainStorage.loadSecure(forKey: SecureStorageKey.accessToken) else {
                return ""
            }
            return token
        }
        allPlugins.append(authPlugin)

        // Create provider
        self.provider = MoyaProvider<APITarget>(
            stubClosure: stubClosure,
            plugins: allPlugins
        )
    }

    // MARK: - NetworkServiceProtocol

    public func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) async throws -> T {
        // Convert to Moya method
        let moyaMethod = method.toMoyaMethod()

        // Create custom target
        let target = APITarget.custom(
            path: endpoint,
            method: moyaMethod,
            parameters: parameters
        )

        // Perform request
        return try await performRequest(target: target)
    }

    public func upload(
        endpoint: String,
        data: Data,
        headers: [String: String]?
    ) async throws -> Data {
        // TODO: Implement upload
        throw ServiceError.notInitialized
    }

    public func download(
        endpoint: String,
        headers: [String: String]?
    ) async throws -> URL {
        // TODO: Implement download
        throw ServiceError.notInitialized
    }

    // MARK: - Public Methods

    /// Perform typed request với APITarget
    public func request<T: Decodable>(_ target: APITarget) async throws -> T {
        try await performRequest(target: target)
    }

    /// Perform request without decoding
    public func requestData(_ target: APITarget) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // Filter successful status codes
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

    // MARK: - Private Methods

    private func performRequest<T: Decodable>(target: APITarget) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // Filter successful status codes
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

    private func mapError(_ error: Error) -> Error {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                // Map HTTP status codes
                switch response.statusCode {
                case 401:
                    return ServiceError.unauthorized
                case 400...499:
                    return NetworkError.serverError(response.statusCode)
                case 500...599:
                    return NetworkError.serverError(response.statusCode)
                default:
                    return NetworkError.unknown
                }

            case .underlying(let underlyingError, _):
                // Check for network connectivity
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

// MARK: - HTTPMethod Extension

extension HTTPMethod {
    func toMoyaMethod() -> Moya.Method {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        }
    }
}

// MARK: - Mock Network Service

/// Mock network service cho testing
public final class MockNetworkService: NetworkServiceProtocol {
    public var shouldFail = false
    public var mockData: Data?
    public var mockError: Error?
    public var requestCallCount = 0

    public init() {}

    public func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) async throws -> T {
        requestCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.unknown
        }

        guard let data = mockData else {
            throw NetworkError.noConnection
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    public func upload(
        endpoint: String,
        data: Data,
        headers: [String: String]?
    ) async throws -> Data {
        requestCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.unknown
        }

        return mockData ?? Data()
    }

    public func download(
        endpoint: String,
        headers: [String: String]?
    ) async throws -> URL {
        requestCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.unknown
        }

        return URL(fileURLWithPath: "/tmp/mock.file")
    }
}
