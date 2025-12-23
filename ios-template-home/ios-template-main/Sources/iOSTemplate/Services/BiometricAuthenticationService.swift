import Foundation
import LocalAuthentication

// MARK: - Biometric Authentication Service Protocol

/// Protocol cho biometric authentication (Face ID / Touch ID)
public protocol BiometricAuthenticationServiceProtocol {
    /// Check if biometric authentication is available
    var isBiometricAvailable: Bool { get }

    /// Get biometric type (FaceID or TouchID)
    var biometricType: BiometricType { get }

    /// Authenticate user với biometric
    /// - Parameter reason: Lý do request authentication
    /// - Returns: True nếu authentication thành công
    func authenticate(reason: String) async throws -> Bool

    /// Enable biometric authentication
    func enableBiometric() async throws

    /// Disable biometric authentication
    func disableBiometric() async throws

    /// Check if biometric is enabled for this app
    var isBiometricEnabled: Bool { get }
}

// MARK: - Biometric Types

/// Loại biometric authentication
public enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID // For Apple Vision Pro

    public var displayName: String {
        switch self {
        case .none:
            return "Not Available"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        }
    }

    public var icon: String {
        switch self {
        case .none:
            return "xmark.circle"
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .opticID:
            return "eye"
        }
    }
}

// MARK: - Biometric Authentication Errors

public enum BiometricAuthenticationError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case lockout
    case passcodeNotSet
    case failed
    case cancelled
    case fallback
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "No biometric authentication is enrolled. Please set up Face ID or Touch ID in Settings"
        case .lockout:
            return "Biometric authentication is locked out. Please use your passcode"
        case .passcodeNotSet:
            return "Please set up a passcode to use biometric authentication"
        case .failed:
            return "Biometric authentication failed"
        case .cancelled:
            return "Authentication cancelled"
        case .fallback:
            return "User chose to use fallback"
        case .unknown(let error):
            return "Authentication error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Biometric Authentication Service Implementation

public final class BiometricAuthenticationService: BiometricAuthenticationServiceProtocol {
    // MARK: - Dependencies

    private let context: LAContext
    private let userDefaultsStorage: StorageServiceProtocol

    // MARK: - Properties

    private let biometricEnabledKey = "biometric_authentication_enabled"

    // MARK: - Initialization

    public init(
        context: LAContext = LAContext(),
        userDefaultsStorage: StorageServiceProtocol
    ) {
        self.context = context
        self.userDefaultsStorage = userDefaultsStorage
    }

    // MARK: - Public Properties

    public var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometricType: BiometricType {
        guard isBiometricAvailable else {
            return .none
        }

        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }

    public var isBiometricEnabled: Bool {
        get {
            (try? userDefaultsStorage.load(Bool.self, forKey: biometricEnabledKey)) ?? false
        }
    }

    // MARK: - Public Methods

    public func authenticate(reason: String) async throws -> Bool {
        // Check if biometric is available
        guard isBiometricAvailable else {
            throw BiometricAuthenticationError.notAvailable
        }

        // Check if biometric is enabled
        guard isBiometricEnabled else {
            throw BiometricAuthenticationError.notEnrolled
        }

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw mapLAError(error)
            }
            throw BiometricAuthenticationError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch let error as LAError {
            throw mapLAError(error)
        } catch {
            throw BiometricAuthenticationError.unknown(error)
        }
    }

    public func enableBiometric() async throws {
        // Verify biometric is available
        guard isBiometricAvailable else {
            throw BiometricAuthenticationError.notAvailable
        }

        // Authenticate user first
        let success = try await authenticate(
            reason: "Authenticate to enable \(biometricType.displayName)"
        )

        guard success else {
            throw BiometricAuthenticationError.failed
        }

        // Save enabled state
        try userDefaultsStorage.save(true, forKey: biometricEnabledKey)
    }

    public func disableBiometric() async throws {
        // Save disabled state
        try userDefaultsStorage.save(false, forKey: biometricEnabledKey)
    }

    // MARK: - Private Methods

    private func mapLAError(_ error: Error) -> BiometricAuthenticationError {
        guard let laError = error as? LAError else {
            return .unknown(error)
        }

        switch laError.code {
        case .authenticationFailed:
            return .failed
        case .userCancel:
            return .cancelled
        case .userFallback:
            return .fallback
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Mock Biometric Authentication Service

/// Mock implementation for testing
public final class MockBiometricAuthenticationService: BiometricAuthenticationServiceProtocol {
    public var shouldSucceed = true
    public var mockBiometricType: BiometricType = .faceID
    public var mockIsAvailable = true
    public var mockIsEnabled = false

    public init() {}

    public var isBiometricAvailable: Bool {
        mockIsAvailable
    }

    public var biometricType: BiometricType {
        mockBiometricType
    }

    public var isBiometricEnabled: Bool {
        mockIsEnabled
    }

    public func authenticate(reason: String) async throws -> Bool {
        if shouldSucceed {
            return true
        } else {
            throw BiometricAuthenticationError.failed
        }
    }

    public func enableBiometric() async throws {
        if shouldSucceed {
            mockIsEnabled = true
        } else {
            throw BiometricAuthenticationError.notAvailable
        }
    }

    public func disableBiometric() async throws {
        mockIsEnabled = false
    }
}
