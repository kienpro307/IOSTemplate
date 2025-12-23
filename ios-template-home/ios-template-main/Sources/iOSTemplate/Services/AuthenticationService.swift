import Foundation
import Combine

// MARK: - Authentication Errors

/// Errors có thể xảy ra trong authentication
public enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case networkError
    case invalidToken
    case tokenExpired
    case biometricNotAvailable
    case biometricFailed
    case userCancelled
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "Email already registered"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network error occurred"
        case .invalidToken:
            return "Invalid authentication token"
        case .tokenExpired:
            return "Session expired. Please login again"
        case .biometricNotAvailable:
            return "Biometric authentication is not available"
        case .biometricFailed:
            return "Biometric authentication failed"
        case .userCancelled:
            return "Authentication cancelled by user"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Service Protocol

/// Protocol cho authentication service
public protocol AuthServiceProtocol {
    /// Login with email and password
    func login(email: String, password: String) async throws -> UserProfile

    /// Register new user
    func register(name: String, email: String, password: String) async throws -> UserProfile

    /// Request password reset
    func forgotPassword(email: String) async throws

    /// Login with social provider (Google, Apple, Facebook)
    func socialLogin(provider: SocialLoginProvider) async throws -> UserProfile

    /// Authenticate with biometric (Face ID / Touch ID)
    func biometricAuth() async throws -> Bool

    /// Logout current user
    func logout() async throws

    /// Refresh access token
    func refreshToken() async throws -> String

    /// Verify email with code
    func verifyEmail(code: String) async throws
}

// MARK: - Authentication Service Implementation

/// Default implementation của AuthenticationService
public final class AuthenticationService: AuthServiceProtocol {
    // MARK: - Dependencies

    private let networkService: NetworkServiceProtocol
    private let keychainStorage: SecureStorageProtocol
    private let userDefaultsStorage: StorageServiceProtocol

    // MARK: - Properties

    private var currentUser: UserProfile?
    private var accessToken: String?
    private var refreshTokenValue: String?

    // MARK: - Initialization

    public init(
        networkService: NetworkServiceProtocol,
        keychainStorage: SecureStorageProtocol,
        userDefaultsStorage: StorageServiceProtocol
    ) {
        self.networkService = networkService
        self.keychainStorage = keychainStorage
        self.userDefaultsStorage = userDefaultsStorage

        // Load saved tokens
        loadSavedTokens()
    }

    // MARK: - Public Methods

    public func login(email: String, password: String) async throws -> UserProfile {
        // Validate inputs
        guard isValidEmail(email) else {
            throw AuthenticationError.invalidCredentials
        }

        guard !password.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }

        // TODO: Make actual API call
        // For now, mock implementation
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Mock response
        let profile = UserProfile(
            id: UUID().uuidString,
            email: email,
            name: extractNameFromEmail(email)
        )

        // Mock tokens
        let token = "mock_access_token_\(UUID().uuidString)"
        let refresh = "mock_refresh_token_\(UUID().uuidString)"

        // Save tokens
        try saveTokens(accessToken: token, refreshToken: refresh)

        // Save profile
        currentUser = profile

        return profile
    }

    public func register(name: String, email: String, password: String) async throws -> UserProfile {
        // Validate inputs
        guard !name.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }

        guard isValidEmail(email) else {
            throw AuthenticationError.invalidCredentials
        }

        guard isValidPassword(password) else {
            throw AuthenticationError.weakPassword
        }

        // TODO: Make actual API call
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Mock response
        let profile = UserProfile(
            id: UUID().uuidString,
            email: email,
            name: name
        )

        // Mock tokens
        let token = "mock_access_token_\(UUID().uuidString)"
        let refresh = "mock_refresh_token_\(UUID().uuidString)"

        // Save tokens
        try saveTokens(accessToken: token, refreshToken: refresh)

        // Save profile
        currentUser = profile

        return profile
    }

    public func forgotPassword(email: String) async throws {
        guard isValidEmail(email) else {
            throw AuthenticationError.invalidCredentials
        }

        // TODO: Make actual API call
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock: Always succeeds
    }

    public func socialLogin(provider: SocialLoginProvider) async throws -> UserProfile {
        // TODO: Implement OAuth flow for each provider
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Mock response
        let profile = UserProfile(
            id: UUID().uuidString,
            email: "\(provider.rawValue)@example.com",
            name: "\(provider.rawValue.capitalized) User"
        )

        // Mock tokens
        let token = "mock_access_token_\(UUID().uuidString)"
        let refresh = "mock_refresh_token_\(UUID().uuidString)"

        // Save tokens
        try saveTokens(accessToken: token, refreshToken: refresh)

        // Save profile
        currentUser = profile

        return profile
    }

    public func biometricAuth() async throws -> Bool {
        // Implementation in BiometricService
        // This is just a placeholder
        return true
    }

    public func logout() async throws {
        // Clear tokens
        try keychainStorage.removeSecure(forKey: "access_token")
        try keychainStorage.removeSecure(forKey: "refresh_token")

        // Clear user data
        currentUser = nil
        accessToken = nil
        refreshTokenValue = nil

        // TODO: Revoke tokens on server
    }

    public func refreshToken() async throws -> String {
        guard let refresh = refreshTokenValue else {
            throw AuthenticationError.invalidToken
        }

        // TODO: Make actual API call to refresh token
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock new token
        let newToken = "mock_access_token_\(UUID().uuidString)"

        // Save new token
        try keychainStorage.saveSecure(newToken, forKey: "access_token")
        accessToken = newToken

        return newToken
    }

    public func verifyEmail(code: String) async throws {
        // TODO: Implement email verification
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    // MARK: - Private Methods

    private func loadSavedTokens() {
        accessToken = try? keychainStorage.loadSecure(forKey: "access_token")
        refreshTokenValue = try? keychainStorage.loadSecure(forKey: "refresh_token")
    }

    private func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychainStorage.saveSecure(accessToken, forKey: "access_token")
        try keychainStorage.saveSecure(refreshToken, forKey: "refresh_token")

        self.accessToken = accessToken
        self.refreshTokenValue = refreshToken
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        password.count >= 8 &&
        password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
        password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        guard let firstPart = components.first else {
            return "User"
        }
        return firstPart.capitalized
    }
}

// MARK: - Mock Authentication Service (for testing)

/// Mock implementation cho testing
public final class MockAuthenticationService: AuthServiceProtocol {
    public var shouldSucceed = true
    public var mockUser: UserProfile?

    public init() {}

    public func login(email: String, password: String) async throws -> UserProfile {
        if shouldSucceed {
            let profile = mockUser ?? UserProfile(
                id: "mock_id",
                email: email,
                name: "Mock User"
            )
            return profile
        } else {
            throw AuthenticationError.invalidCredentials
        }
    }

    public func register(name: String, email: String, password: String) async throws -> UserProfile {
        if shouldSucceed {
            let profile = mockUser ?? UserProfile(
                id: "mock_id",
                email: email,
                name: name
            )
            return profile
        } else {
            throw AuthenticationError.emailAlreadyExists
        }
    }

    public func forgotPassword(email: String) async throws {
        if !shouldSucceed {
            throw AuthenticationError.userNotFound
        }
    }

    public func socialLogin(provider: SocialLoginProvider) async throws -> UserProfile {
        if shouldSucceed {
            return mockUser ?? UserProfile(
                id: "mock_id",
                email: "\(provider)@example.com",
                name: "Social User"
            )
        } else {
            throw AuthenticationError.userCancelled
        }
    }

    public func biometricAuth() async throws -> Bool {
        return shouldSucceed
    }

    public func logout() async throws {
        // Do nothing in mock
    }

    public func refreshToken() async throws -> String {
        if shouldSucceed {
            return "mock_token"
        } else {
            throw AuthenticationError.tokenExpired
        }
    }

    public func verifyEmail(code: String) async throws {
        if !shouldSucceed {
            throw AuthenticationError.invalidToken
        }
    }
}
