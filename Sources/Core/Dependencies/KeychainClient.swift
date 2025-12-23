import Foundation
import ComposableArchitecture
import KeychainAccess

/// Protocol cho các thao tác Keychain (dữ liệu bảo mật)
public protocol KeychainClientProtocol: Sendable {
    /// Lưu chuỗi vào Keychain
    func save(_ value: String, forKey key: String) async throws
    
    /// Lấy chuỗi từ Keychain theo key
    func load(forKey key: String) async throws -> String?
    
    /// Xóa giá trị theo key
    func remove(forKey key: String) async throws
    
    /// Xóa tất cả dữ liệu trong Keychain
    func removeAll() async throws
}

// MARK: - Các khóa Keychain
/// Định nghĩa các key thường dùng để lưu trữ trong Keychain
public enum KeychainKey: String {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case apiKey = "api_key"
    case userPassword = "user_password"
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế với thư viện KeychainAccess
public actor LiveKeychainClient: KeychainClientProtocol {
    private let keychain: Keychain
    
    public init(service: String = Bundle.main.bundleIdentifier ?? "group.com.flabs.iOSTemplate") {
        self.keychain = Keychain(service: service)
            .accessibility(.afterFirstUnlock)
    }
    
    public func save(_ value: String, forKey key: String) async throws {
        try keychain.set(value, key: key)
    }
    
    public func load(forKey key: String) async throws -> String? {
        try keychain.get(key)
    }
    
    public func remove(forKey key: String) async throws {
        try keychain.remove(key)
    }
    
    public func removeAll() async throws {
        try keychain.removeAll()
    }
}

// MARK: - Triển khai Mock
/// Triển khai giả lập Keychain cho testing
public actor MockKeychainClient: KeychainClientProtocol {
    private var storage: [String: String] = [:]
    
    public init() {}
    
    public func save(_ value: String, forKey key: String) async throws {
        storage[key] = value
    }
    
    public func load(forKey key: String) async throws -> String? {
        storage[key]
    }
    
    public func remove(forKey key: String) async throws {
        storage.removeValue(forKey: key)
    }
    
    public func removeAll() async throws {
        storage.removeAll()
    }
}

// MARK: - Khóa Dependency
private enum KeychainClientKey: DependencyKey {
    static let liveValue: KeychainClientProtocol = LiveKeychainClient()
    static let testValue: KeychainClientProtocol = MockKeychainClient()
    static let previewValue: KeychainClientProtocol = MockKeychainClient()
}

extension DependencyValues {
    public var keychainClient: KeychainClientProtocol {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}
