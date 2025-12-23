import Foundation

// MARK: - Storage Service Protocols

/// Protocol cho UserDefaults storage
public protocol StorageServiceProtocol {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func delete(forKey key: String)
    func exists(forKey key: String) -> Bool
    func clear()
}

/// Alias for backward compatibility
public typealias UserDefaultsStorageProtocol = StorageServiceProtocol

/// Protocol cho Keychain (secure storage)
public protocol SecureStorageProtocol {
    func saveSecure(_ value: String, forKey key: String) throws
    func loadSecure(forKey key: String) throws -> String?
    func removeSecure(forKey key: String) throws
    func clearAllSecure() throws
}

/// Alias for backward compatibility
public typealias KeychainStorageProtocol = SecureStorageProtocol

/// Protocol cho File storage
public protocol FileStorageProtocol {
    func save(_ data: Data, fileName: String) throws
    func load(fileName: String) throws -> Data?
    func delete(fileName: String) throws
    func exists(fileName: String) -> Bool
    func fileURL(for fileName: String) -> URL
}

// MARK: - Network Service Protocol

/// Protocol cho network service
public protocol NetworkServiceProtocol {
    /// Perform network request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) async throws -> T

    /// Upload data
    func upload(
        endpoint: String,
        data: Data,
        headers: [String: String]?
    ) async throws -> Data

    /// Download file
    func download(
        endpoint: String,
        headers: [String: String]?
    ) async throws -> URL
}

/// HTTP Methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Analytics Service Protocol

/// Protocol cho analytics service
public protocol AnalyticsServiceProtocol {
    /// Track event
    func trackEvent(_ event: AnalyticsEvent)

    /// Track screen view
    func trackScreen(_ screenName: String, parameters: [String: Any]?)

    /// Set user property
    func setUserProperty(_ value: String, forName name: String)

    /// Set user ID
    func setUserID(_ userID: String?)
}

/// Analytics event
public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: Any]?

    public init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}

// MARK: - Logging Service Protocol

/// Protocol cho logging service
public protocol LoggingServiceProtocol {
    /// Log verbose message
    func verbose(_ message: String, file: String, function: String, line: Int)

    /// Log debug message
    func debug(_ message: String, file: String, function: String, line: Int)

    /// Log info message
    func info(_ message: String, file: String, function: String, line: Int)

    /// Log warning message
    func warning(_ message: String, file: String, function: String, line: Int)

    /// Log error message
    func error(_ message: String, error: Error?, file: String, function: String, line: Int)
}

// MARK: - Remote Config Service Protocol

/// Protocol cho remote config service
public protocol RemoteConfigServiceProtocol {
    /// Fetch remote config
    func fetch() async throws

    /// Get string value
    func getString(forKey key: String, defaultValue: String) -> String

    /// Get bool value
    func getBool(forKey key: String, defaultValue: Bool) -> Bool

    /// Get int value
    func getInt(forKey key: String, defaultValue: Int) -> Int

    /// Get double value
    func getDouble(forKey key: String, defaultValue: Double) -> Double
}

// MARK: - Image Cache Service Protocol

/// Protocol cho image cache service
public protocol ImageCacheServiceProtocol {
    /// Cache image
    func cacheImage(_ data: Data, forKey key: String)

    /// Get cached image
    func getCachedImage(forKey key: String) -> Data?

    /// Remove cached image
    func removeCachedImage(forKey key: String)

    /// Clear all cached images
    func clearCache()

    /// Get cache size
    func cacheSize() -> Int64
}

// MARK: - Crashlytics Service Protocol

/// Protocol cho crashlytics service
public protocol CrashlyticsServiceProtocol {
    /// Record non-fatal error
    /// - Parameters:
    ///   - error: Error to record
    ///   - userInfo: Additional context
    func recordError(_ error: Error, userInfo: [String: Any]?)

    /// Log message to crash reports
    /// Messages logged sẽ appear trong crash reports
    /// - Parameter message: Log message
    func log(_ message: String)

    /// Set user identifier
    /// - Parameter userID: User ID (nil to clear)
    func setUserID(_ userID: String?)

    /// Set custom key-value pair
    /// Custom keys appear trong crash reports
    /// - Parameters:
    ///   - value: Value (String, Int, Bool, etc.)
    ///   - key: Key name
    func setCustomValue(_ value: Any, forKey key: String)

    /// Force a test crash (DEBUG only)
    /// **WARNING**: Chỉ call trong DEBUG builds để test
    func testCrash()
}

// MARK: - Push Notification Service Protocol

/// Protocol cho push notification service
public protocol PushNotificationServiceProtocol {
    /// Request permission
    func requestPermission() async throws -> Bool

    /// Register for remote notifications
    func registerForRemoteNotifications()

    /// Handle device token
    func handleDeviceToken(_ token: Data)

    /// Handle notification
    func handleNotification(_ userInfo: [AnyHashable: Any])

    /// Subscribe to topic
    func subscribe(toTopic topic: String)

    /// Unsubscribe from topic
    func unsubscribe(fromTopic topic: String)
}

// MARK: - Location Service Protocol

/// Protocol cho location service
public protocol LocationServiceProtocol {
    /// Request permission
    func requestPermission() async throws -> Bool

    /// Get current location
    func getCurrentLocation() async throws -> Location

    /// Start monitoring location
    func startMonitoring()

    /// Stop monitoring location
    func stopMonitoring()
}

/// Location model
public struct Location: Codable {
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let timestamp: Date

    public init(latitude: Double, longitude: Double, accuracy: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = timestamp
    }
}

// MARK: - Storage Errors

/// Storage-specific errors
public enum StorageError: Error, LocalizedError {
    case notFound
    case encodingFailed
    case decodingFailed
    case writeFailed
    case readFailed
    case deleteFailed
    case invalidData
    case accessDenied
    case diskFull
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found in storage"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .writeFailed:
            return "Failed to write to storage"
        case .readFailed:
            return "Failed to read from storage"
        case .deleteFailed:
            return "Failed to delete from storage"
        case .invalidData:
            return "Invalid data format"
        case .accessDenied:
            return "Access denied to storage location"
        case .diskFull:
            return "Disk is full, cannot write to storage"
        case .unknown(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Service Errors

/// Common service errors
public enum ServiceError: Error, LocalizedError {
    case notInitialized
    case invalidConfiguration
    case unauthorized
    case networkError(Error)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Service not initialized"
        case .invalidConfiguration:
            return "Invalid service configuration"
        case .unauthorized:
            return "Unauthorized access"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

/// Network-specific errors
public enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case unauthorized
    case invalidResponse
    case decodingError(Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .unauthorized:
            return "Unauthorized - invalid credentials"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown:
            return "Unknown network error"
        }
    }
}
