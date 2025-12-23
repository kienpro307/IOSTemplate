import Foundation
import ComposableArchitecture
import FirebaseCrashlytics

/// Crashlytics service protocol
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol CrashlyticsServiceProtocol: Sendable {
    /// Record error
    func recordError(_ error: Error) async
    
    /// Set user identifier
    func setUserIdentifier(_ identifier: String) async
    
    /// Set custom key
    func setCustomKey(_ key: String, value: String) async
}

// MARK: - Live Implementation với Firebase Crashlytics
/// Live implementation sử dụng Firebase Crashlytics SDK
public actor LiveCrashlyticsService: CrashlyticsServiceProtocol {
    private let crashlytics: Crashlytics
    private let isDebugMode: Bool
    
    public init(isDebugMode: Bool = false) {
        self.crashlytics = Crashlytics.crashlytics()
        #if DEBUG
        self.isDebugMode = true
        #else
        self.isDebugMode = isDebugMode
        #endif
    }
    
    public func recordError(_ error: Error) async {
        crashlytics.record(error: error)
        
        if isDebugMode {
            print("[Crashlytics] 💥 Error recorded: \(error.localizedDescription)")
        }
    }
    
    public func setUserIdentifier(_ identifier: String) async {
        crashlytics.setUserID(identifier)
        
        if isDebugMode {
            print("[Crashlytics] 🆔 User ID set: \(identifier)")
        }
    }
    
    public func setCustomKey(_ key: String, value: String) async {
        crashlytics.setCustomValue(value, forKey: key)
        
        if isDebugMode {
            print("[Crashlytics] 🔧 Custom key set: \(key) = \(value)")
        }
    }
}

// MARK: - Mock Implementation
public actor MockCrashlyticsService: CrashlyticsServiceProtocol {
    public init() {}
    
    public func recordError(_ error: Error) async {
        // Mock: không làm gì
    }
    
    public func setUserIdentifier(_ identifier: String) async {
        // Mock: không làm gì
    }
    
    public func setCustomKey(_ key: String, value: String) async {
        // Mock: không làm gì
    }
}

// MARK: - Dependency Key
private enum CrashlyticsServiceKey: DependencyKey {
    static let liveValue: CrashlyticsServiceProtocol = LiveCrashlyticsService()
    static let testValue: CrashlyticsServiceProtocol = MockCrashlyticsService()
    static let previewValue: CrashlyticsServiceProtocol = MockCrashlyticsService()
}

extension DependencyValues {
    public var crashlytics: CrashlyticsServiceProtocol {
        get { self[CrashlyticsServiceKey.self] }
        set { self[CrashlyticsServiceKey.self] = newValue }
    }
}

