import Foundation
import Dependencies

// MARK: - TCA Dependencies Integration

/// Firebase services integration with TCA Dependencies
///
/// ## Usage with TCA:
/// ```swift
/// @Reducer
/// struct MyFeature {
///     @Dependency(\.analyticsService) var analytics
///     @Dependency(\.crashlyticsService) var crashlytics
///     @Dependency(\.remoteConfigService) var remoteConfig
///
///     func reduce(into state: inout State, action: Action) -> Effect<Action> {
///         switch action {
///         case .buttonTapped:
///             analytics.logEvent(.featureUsed)
///             return .none
///         }
///     }
/// }
/// ```
///

extension DependencyValues {
    
    // MARK: - Analytics Service
    
    /// Analytics service for tracking events and user properties
    public var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
    
    // MARK: - Crashlytics Service
    
    /// Crashlytics service for error tracking
    public var crashlyticsService: CrashlyticsService {
        get { self[CrashlyticsServiceKey.self] }
        set { self[CrashlyticsServiceKey.self] = newValue }
    }
    
    // MARK: - Remote Config Service
    
    /// Remote Config service for feature flags and configuration
    public var remoteConfigService: RemoteConfigService {
        get { self[RemoteConfigServiceKey.self] }
        set { self[RemoteConfigServiceKey.self] = newValue }
    }
    
    // MARK: - Messaging Service
    
    /// Messaging service for push notifications
    public var messagingService: MessagingService {
        get { self[MessagingServiceKey.self] }
        set { self[MessagingServiceKey.self] = newValue }
    }
    
    // MARK: - Performance Service
    
    /// Performance monitoring service
    public var performanceService: PerformanceService {
        get { self[PerformanceServiceKey.self] }
        set { self[PerformanceServiceKey.self] = newValue }
    }
    
    // MARK: - Firebase Manager
    
    /// Firebase manager for configuration
    public var firebaseManager: FirebaseManager {
        get { self[FirebaseManagerKey.self] }
        set { self[FirebaseManagerKey.self] = newValue }
    }
}

// MARK: - Dependency Keys

private enum AnalyticsServiceKey: DependencyKey {
    static let liveValue = AnalyticsService.shared
    static let testValue = AnalyticsService.shared // Will be mocked in tests
    static let previewValue = AnalyticsService.shared // For SwiftUI previews
}

private enum CrashlyticsServiceKey: DependencyKey {
    static let liveValue = CrashlyticsService.shared
    static let testValue = CrashlyticsService.shared
    static let previewValue = CrashlyticsService.shared
}

private enum RemoteConfigServiceKey: DependencyKey {
    static let liveValue = RemoteConfigService.shared
    static let testValue = RemoteConfigService.shared
    static let previewValue = RemoteConfigService.shared
}

private enum MessagingServiceKey: DependencyKey {
    static let liveValue = MessagingService.shared
    static let testValue = MessagingService.shared
    static let previewValue = MessagingService.shared
}

private enum PerformanceServiceKey: DependencyKey {
    static let liveValue = PerformanceService.shared
    static let testValue = PerformanceService.shared
    static let previewValue = PerformanceService.shared
}

private enum FirebaseManagerKey: DependencyKey {
    static let liveValue = FirebaseManager.shared
    static let testValue = FirebaseManager.shared
    static let previewValue = FirebaseManager.shared
}

// MARK: - Mock Services for Testing

#if DEBUG

/// Mock Analytics Service for testing
public final class MockAnalyticsService: AnalyticsService {
    public var loggedEvents: [(name: String, parameters: [String: Any]?)] = []
    public var trackedScreens: [String] = []
    public var userID: String?
    public var userProperties: [String: String?] = [:]
    
    public override func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        loggedEvents.append((name: name, parameters: parameters))
    }
    
    public override func trackScreen(_ screenName: String, screenClass: String? = nil) {
        trackedScreens.append(screenName)
    }
    
    public override func setUserID(_ userID: String?) {
        self.userID = userID
    }
    
    public override func setUserProperty(_ value: String?, forName name: String) {
        userProperties[name] = value
    }
}

/// Mock Crashlytics Service for testing
public final class MockCrashlyticsService: CrashlyticsService {
    public var recordedErrors: [(error: Error, userInfo: [String: Any]?)] = []
    public var userID: String?
    public var customKeys: [String: Any] = [:]
    public var logs: [String] = []
    
    public override func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        recordedErrors.append((error: error, userInfo: userInfo))
    }
    
    public override func setUserID(_ userID: String?) {
        self.userID = userID
    }
    
    public override func setCustomKey(_ key: String, value: Any) {
        customKeys[key] = value
    }
    
    public override func log(_ message: String) {
        logs.append(message)
    }
}

/// Mock Remote Config Service for testing
public final class MockRemoteConfigService: RemoteConfigService {
    public var mockValues: [String: Any] = [:]
    public var fetchCalled = false
    public var activateCalled = false
    
    public override func getString(_ key: String) -> String {
        return mockValues[key] as? String ?? ""
    }
    
    public override func getBool(_ key: String) -> Bool {
        return mockValues[key] as? Bool ?? false
    }
    
    public override func getInt(_ key: String) -> Int {
        return mockValues[key] as? Int ?? 0
    }
    
    public override func getDouble(_ key: String) -> Double {
        return mockValues[key] as? Double ?? 0.0
    }
    
    public override func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus {
        fetchCalled = true
        activateCalled = true
        return .successUsingPreFetchedData
    }
}

// MARK: - Test Helpers

extension DependencyValues {
    /// Use mock analytics in tests
    public mutating func useMockAnalytics(_ mock: MockAnalyticsService = MockAnalyticsService()) {
        self.analyticsService = mock
    }
    
    /// Use mock crashlytics in tests
    public mutating func useMockCrashlytics(_ mock: MockCrashlyticsService = MockCrashlyticsService()) {
        self.crashlyticsService = mock
    }
    
    /// Use mock remote config in tests
    public mutating func useMockRemoteConfig(_ mock: MockRemoteConfigService = MockRemoteConfigService()) {
        self.remoteConfigService = mock
    }
}

#endif
