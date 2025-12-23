import Foundation
import ComposableArchitecture
import FirebaseAnalytics

/// Analytics service protocol
/// Theo cấu trúc trong ios-template-docs/02-MO-DUN/03-DICH-VU/README.md
public protocol AnalyticsServiceProtocol: Sendable {
    /// Track event
    func trackEvent(_ name: String, parameters: [String: Any]?) async
    
    /// Track screen view
    func trackScreen(_ name: String) async
}

// MARK: - Live Implementation với Firebase Analytics
/// Live implementation sử dụng Firebase Analytics SDK
public actor LiveAnalyticsService: AnalyticsServiceProtocol {
    private let isDebugMode: Bool
    
    public init(isDebugMode: Bool = false) {
        #if DEBUG
        self.isDebugMode = true
        #else
        self.isDebugMode = isDebugMode
        #endif
    }
    
    public func trackEvent(_ name: String, parameters: [String: Any]?) async {
        Analytics.logEvent(name, parameters: parameters)
        
        if isDebugMode {
            print("[Analytics] 📊 Event: \(name)")
            if let params = parameters {
                print("[Analytics]    Parameters: \(params)")
            }
        }
    }
    
    public func trackScreen(_ name: String) async {
        var params: [String: Any] = [:]
        params[AnalyticsParameterScreenName] = name
        params[AnalyticsParameterScreenClass] = name
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
        
        if isDebugMode {
            print("[Analytics] 📱 Screen: \(name)")
        }
    }
}

// MARK: - Mock Implementation
public actor MockAnalyticsService: AnalyticsServiceProtocol {
    public init() {}
    
    public func trackEvent(_ name: String, parameters: [String: Any]?) async {
        // Mock: không làm gì
    }
    
    public func trackScreen(_ name: String) async {
        // Mock: không làm gì
    }
}

// MARK: - Dependency Key
private enum AnalyticsServiceKey: DependencyKey {
    static let liveValue: AnalyticsServiceProtocol = LiveAnalyticsService()
    static let testValue: AnalyticsServiceProtocol = MockAnalyticsService()
    static let previewValue: AnalyticsServiceProtocol = MockAnalyticsService()
}

extension DependencyValues {
    public var analytics: AnalyticsServiceProtocol {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}

