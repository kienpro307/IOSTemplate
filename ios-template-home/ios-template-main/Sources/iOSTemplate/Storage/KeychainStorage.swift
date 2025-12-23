import Foundation
import KeychainAccess

/// Keychain wrapper cho secure storage
public final class KeychainStorage: SecureStorageProtocol {

    // MARK: - Properties

    private let keychain: Keychain

    // MARK: - Initialization

    public init(service: String = Bundle.main.bundleIdentifier ?? "com.iostemplate.app") {
        self.keychain = Keychain(service: service)
            .accessibility(.afterFirstUnlock)
    }

    // MARK: - SecureStorageProtocol

    public func saveSecure(_ value: String, forKey key: String) throws {
        do {
            try keychain.set(value, key: key)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    public func loadSecure(forKey key: String) throws -> String? {
        do {
            return try keychain.getString(key)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    public func removeSecure(forKey key: String) throws {
        do {
            try keychain.remove(key)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    public func clearAllSecure() throws {
        do {
            try keychain.removeAll()
        } catch {
            throw StorageError.unknown(error)
        }
    }

    // MARK: - KeychainStorageProtocol

    public func save(_ value: String, forKey key: String) throws {
        try saveSecure(value, forKey: key)
    }

    public func load(forKey key: String) throws -> String? {
        try loadSecure(forKey: key)
    }

    public func remove(forKey key: String) throws {
        try removeSecure(forKey: key)
    }

    public func clearAll() throws {
        try clearAllSecure()
    }

    // MARK: - Additional Methods

    /// Save Codable object securely
    public func saveSecure<T: Codable>(_ value: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            try keychain.set(data, key: key)
        } catch {
            throw StorageError.encodingFailed
        }
    }

    /// Load Codable object securely
    public func loadSecure<T: Codable>(forKey key: String) throws -> T? {
        let decoder = JSONDecoder()
        do {
            guard let data = try keychain.getData(key) else {
                return nil
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }

    /// Check if key exists
    public func existsSecure(forKey key: String) -> Bool {
        do {
            return try keychain.contains(key)
        } catch {
            return false
        }
    }
}

// MARK: - Secure Storage Keys

/// Keys cho secure storage
public enum SecureStorageKey {
    // Authentication
    public static let accessToken = "auth.access_token"
    public static let refreshToken = "auth.refresh_token"
    public static let userID = "auth.user_id"

    // Biometric
    public static let biometricEnabled = "biometric.enabled"

    // API Keys
    public static let apiKey = "api.key"
    public static let apiSecret = "api.secret"

    // User Credentials
    public static let savedEmail = "credentials.email"
    public static let savedPassword = "credentials.password" // Only if explicitly allowed
}

// MARK: - Biometric Authentication Support

#if canImport(LocalAuthentication)
import LocalAuthentication

extension KeychainStorage {
    /// Save with biometric protection
    public func saveBiometric(_ value: String, forKey key: String) throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw StorageError.accessDenied
        }

        // Create keychain with biometric protection
        let protectedKeychain = Keychain(service: keychain.service)
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)

        do {
            try protectedKeychain.set(value, key: key)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    /// Load with biometric authentication
    public func loadBiometric(forKey key: String, prompt: String = "Authenticate to access") throws -> String? {
        let context = LAContext()
        context.localizedReason = prompt

        let protectedKeychain = Keychain(service: keychain.service)
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
            .authenticationPrompt(prompt)

        do {
            return try protectedKeychain.getString(key)
        } catch {
            throw StorageError.accessDenied
        }
    }
}
#endif

// MARK: - Example Usage

/*
 Usage Example:

 let keychain = KeychainStorage()

 // Save token
 try keychain.saveSecure("my-access-token", forKey: SecureStorageKey.accessToken)

 // Load token
 let token = try keychain.loadSecure(forKey: SecureStorageKey.accessToken)

 // Save with biometric
 try keychain.saveBiometric("sensitive-data", forKey: "sensitive.key")

 // Load with biometric
 let data = try keychain.loadBiometric(forKey: "sensitive.key", prompt: "Unlock app")

 // Save Codable object
 struct User: Codable {
     let id: String
     let name: String
 }
 let user = User(id: "123", name: "John")
 try keychain.saveSecure(user, forKey: "user.data")

 // Load Codable object
 let loadedUser: User? = try keychain.loadSecure(forKey: "user.data")
 */
