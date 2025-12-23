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
    
    /// Kiểm tra key có tồn tại không
    func exists(forKey key: String) async -> Bool
}

// MARK: - Các khóa Keychain
/// Định nghĩa các key thường dùng để lưu trữ trong Keychain
public enum KeychainKey: String {
    // Authentication
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    public static let userID = "auth.user_id"

    // Biometric
    public static let biometricEnabled = "biometric.enabled"

    // API Keys
    case apiKey = "api_key"
    public static let apiSecret = "api.secret"

    // User Credentials
    public static let savedEmail = "credentials.email"
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
    
    public func exists(forKey key: String) async -> Bool {
        do {
            return try keychain.contains(key)
        } catch {
            return false
        }
    }
    
    // MARK: - Triển khai hỗ trợ Codable
    
    /// Lưu Data trực tiếp vào Keychain bằng KeychainAccess
    public func saveData(_ data: Data, forKey key: String) async throws {
        try keychain.set(data, key: key)
    }
    
    /// Lấy Data trực tiếp từ Keychain bằng KeychainAccess
    public func loadData(forKey key: String) async throws -> Data? {
        try keychain.getData(key)
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
    
    public func exists(forKey key: String) async -> Bool {
        storage[key] != nil
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

// MARK: - Hỗ trợ Codable

public extension KeychainClientProtocol {
    /// Lưu object Codable vào Keychain một cách bảo mật
    /// - Parameters:
    ///   - value: Object cần lưu (phải conform Codable)
    ///   - key: Key để lưu
    /// - Throws: Error nếu encoding thất bại hoặc lưu thất bại
    func saveCodable<T: Codable>(_ value: T, forKey key: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        // KeychainAccess hỗ trợ Data trực tiếp
        try await saveData(data, forKey: key)
    }
    
    /// Lấy object Codable từ Keychain một cách bảo mật
    /// - Parameters:
    ///   - type: Type của object cần load
    ///   - key: Key để load
    /// - Returns: Object đã decode hoặc nil nếu không tồn tại
    /// - Throws: Error nếu decoding thất bại
    func loadCodable<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = try await loadData(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    /// Lưu Data trực tiếp (helper nội bộ)
    func saveData(_ data: Data, forKey key: String) async throws {
        // Implementation mặc định: chuyển đổi sang base64 string
        // Các subclass có thể override để dùng Data trực tiếp nếu KeychainAccess hỗ trợ
        let base64String = data.base64EncodedString()
        try await save(base64String, forKey: key)
    }
    
    /// Lấy Data trực tiếp (helper nội bộ)
    func loadData(forKey key: String) async throws -> Data? {
        // Implementation mặc định: load base64 string và chuyển đổi về Data
        guard let base64String = try await load(forKey: key),
              let data = Data(base64Encoded: base64String) else {
            return nil
        }
        return data
    }
}

// MARK: - Biometric Authentication Support

#if canImport(LocalAuthentication)
import LocalAuthentication

public extension KeychainClientProtocol {
    /// Save với biometric protection
    /// - Parameters:
    ///   - value: Giá trị cần lưu
    ///   - key: Key để lưu
    /// - Throws: Error nếu biometric không available hoặc save failed
    func saveBiometric(_ value: String, forKey key: String) async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw KeychainError.accessDenied
        }

        // Sử dụng keychain với biometric protection
        // Lưu ý: Thư viện KeychainAccess hỗ trợ authenticationPolicy
        let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.iostemplate.app")
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)

        do {
            try keychain.set(value, key: key)
        } catch {
            throw KeychainError.unknown(error)
        }
    }

    /// Lấy giá trị với biometric authentication
    /// - Parameters:
    ///   - key: Key cần load
    ///   - prompt: Thông báo hiển thị khi authenticate
    /// - Returns: Giá trị đã lưu hoặc nil
    /// - Throws: Error nếu authentication thất bại
    func loadBiometric(forKey key: String, prompt: String = "Xác thực để truy cập") async throws -> String? {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.iostemplate.app")
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
            .authenticationPrompt(prompt)

        do {
            return try keychain.getString(key)
        } catch {
            throw KeychainError.accessDenied
        }
    }
}

// MARK: - Lỗi Keychain

/// Các lỗi cụ thể của Keychain
public enum KeychainError: Error, LocalizedError {
    case accessDenied
    case itemNotFound
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Truy cập bị từ chối vào keychain item"
        case .itemNotFound:
            return "Không tìm thấy keychain item"
        case .unknown(let error):
            return "Lỗi Keychain: \(error.localizedDescription)"
        }
    }
}
#endif
