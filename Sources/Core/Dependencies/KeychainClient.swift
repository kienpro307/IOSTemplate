import Foundation
import ComposableArchitecture
import KeychainAccess

/// Protocol cho Keychain operations (dữ liệu bảo mật)
public protocol KeychainClientProtocol: Sendable {
    /// Lưu string vào keychain
    func save(_ value: String, forKey key: String) async throws
    
    /// Lấy string từ keychain
    func load(forKey key: String) async throws -> String?
    
    /// Xóa value theo key
    func remove(forKey key: String) async throws
    
    /// Xóa tất cả
    func removeAll() async throws
}

// MARK: - Keychain Keys
public enum KeychainKey: String {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case apiKey = "api_key"
    case userPassword = "user_password"
}

// MARK: - Live Implementation
/// Implementation với KeychainAccess
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

// MARK: - Mock Implementation
/// Mock keychain cho testing
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

// MARK: - Dependency Key
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
