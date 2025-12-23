import Foundation
import ComposableArchitecture
import FirebaseRemoteConfig

/// Remote Config service protocol
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol RemoteConfigServiceProtocol: Sendable {
    /// Get boolean value
    func getBool(_ key: String) async -> Bool
    
    /// Get string value
    func getString(_ key: String) async -> String?
    
    /// Get integer value
    func getInt(_ key: String) async -> Int
    
    /// Fetch and activate
    func fetchAndActivate() async throws
}

// MARK: - Live Implementation với Firebase Remote Config
/// Live implementation sử dụng Firebase Remote Config SDK
public actor LiveRemoteConfigService: RemoteConfigServiceProtocol {
    private let remoteConfig: RemoteConfig
    private let isDebugMode: Bool
    
    public init(isDebugMode: Bool = false) {
        self.remoteConfig = RemoteConfig.remoteConfig()
        #if DEBUG
        self.isDebugMode = true
        // Debug mode: fetch immediately
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        self.remoteConfig.configSettings = settings
        #else
        self.isDebugMode = isDebugMode
        #endif
    }
    
    public func getBool(_ key: String) async -> Bool {
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    public func getString(_ key: String) async -> String? {
        let value = remoteConfig.configValue(forKey: key).stringValue
        return value.isEmpty ? nil : value
    }
    
    public func getInt(_ key: String) async -> Int {
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }
    
    public func fetchAndActivate() async throws {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            
            if isDebugMode {
                switch status {
                case .successFetchedFromRemote:
                    print("[RemoteConfig] ✅ Fetched and activated from remote")
                case .successUsingPreFetchedData:
                    print("[RemoteConfig] ✅ Using pre-fetched data")
                case .error:
                    print("[RemoteConfig] ⚠️ Error fetching")
                @unknown default:
                    print("[RemoteConfig] ⚠️ Unknown status")
                }
            }
        } catch {
            if isDebugMode {
                print("[RemoteConfig] ❌ Fetch failed: \(error.localizedDescription)")
            }
            throw error
        }
    }
}

// MARK: - Mock Implementation
public actor MockRemoteConfigService: RemoteConfigServiceProtocol {
    public init() {}
    
    public func getBool(_ key: String) async -> Bool {
        return false
    }
    
    public func getString(_ key: String) async -> String? {
        return nil
    }
    
    public func getInt(_ key: String) async -> Int {
        return 0
    }
    
    public func fetchAndActivate() async throws {
        // Mock: không làm gì
    }
}

// MARK: - Dependency Key
private enum RemoteConfigServiceKey: DependencyKey {
    static let liveValue: RemoteConfigServiceProtocol = LiveRemoteConfigService()
    static let testValue: RemoteConfigServiceProtocol = MockRemoteConfigService()
    static let previewValue: RemoteConfigServiceProtocol = MockRemoteConfigService()
}

extension DependencyValues {
    public var remoteConfig: RemoteConfigServiceProtocol {
        get { self[RemoteConfigServiceKey.self] }
        set { self[RemoteConfigServiceKey.self] = newValue }
    }
}

