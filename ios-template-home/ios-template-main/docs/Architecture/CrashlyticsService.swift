import Foundation
import FirebaseCrashlytics

/// High-level Crashlytics service
///
/// Provides convenient methods for error tracking and crash reporting
///
/// ## Usage:
/// ```swift
/// // Record error
/// CrashlyticsService.shared.recordError(error)
///
/// // Record with context
/// CrashlyticsService.shared.recordError(error, userInfo: [
///     "screen": "checkout",
///     "action": "payment"
/// ])
///
/// // Set user ID
/// CrashlyticsService.shared.setUserID("user123")
///
/// // Log breadcrumb
/// CrashlyticsService.shared.log("User tapped checkout button")
/// ```
///
public final class CrashlyticsService {
    
    // MARK: - Singleton
    
    public static let shared = CrashlyticsService()
    
    private let firebaseManager: FirebaseManager
    
    public init(firebaseManager: FirebaseManager = .shared) {
        self.firebaseManager = firebaseManager
    }
    
    // MARK: - Error Logging
    
    /// Record error
    ///
    /// - Parameters:
    ///   - error: Error to record
    ///   - userInfo: Optional additional context
    public func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping error")
            return
        }
        
        // Set custom keys if provided
        if let userInfo = userInfo {
            setCustomKeys(userInfo)
        }
        
        Crashlytics.crashlytics().record(error: error)
        logDebug("[Crashlytics] Error recorded: \(error.localizedDescription)")
    }
    
    /// Record non-fatal error with custom message
    ///
    /// - Parameters:
    ///   - domain: Error domain
    ///   - code: Error code
    ///   - message: Error message
    ///   - userInfo: Optional additional context
    public func recordError(
        domain: String,
        code: Int,
        message: String,
        userInfo: [String: Any]? = nil
    ) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping error")
            return
        }
        
        var errorUserInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
        
        if let additionalInfo = userInfo {
            errorUserInfo.merge(additionalInfo) { _, new in new }
        }
        
        let error = NSError(
            domain: domain,
            code: code,
            userInfo: errorUserInfo
        )
        
        recordError(error, userInfo: userInfo)
    }
    
    /// Record error with context
    ///
    /// - Parameters:
    ///   - error: Error to record
    ///   - screen: Current screen name
    ///   - action: Action that caused the error
    ///   - additionalInfo: Any additional context
    public func recordError(
        _ error: Error,
        screen: String? = nil,
        action: String? = nil,
        additionalInfo: [String: Any]? = nil
    ) {
        var context: [String: Any] = [:]
        
        if let screen = screen {
            context["screen"] = screen
        }
        
        if let action = action {
            context["action"] = action
        }
        
        if let additionalInfo = additionalInfo {
            context.merge(additionalInfo) { _, new in new }
        }
        
        recordError(error, userInfo: context.isEmpty ? nil : context)
    }
    
    // MARK: - User Management
    
    /// Set user ID for crash reports
    ///
    /// - Parameter userID: User identifier (pass empty string to clear)
    public func setUserID(_ userID: String?) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping setUserID")
            return
        }
        
        Crashlytics.crashlytics().setUserID(userID ?? "")
        logDebug("[Crashlytics] User ID set: \(userID ?? "cleared")")
    }
    
    /// Set user email
    ///
    /// - Parameter email: User email
    public func setUserEmail(_ email: String?) {
        guard let email = email else { return }
        setCustomKey("user_email", value: email)
    }
    
    /// Set user name
    ///
    /// - Parameter name: User name
    public func setUserName(_ name: String?) {
        guard let name = name else { return }
        setCustomKey("user_name", value: name)
    }
    
    // MARK: - Custom Keys
    
    /// Set custom key
    ///
    /// - Parameters:
    ///   - key: Key name
    ///   - value: Key value
    public func setCustomKey(_ key: String, value: Any) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping custom key: \(key)")
            return
        }
        
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        logDebug("[Crashlytics] Custom key set: \(key) = \(value)")
    }
    
    /// Set multiple custom keys
    ///
    /// - Parameter keys: Dictionary of keys and values
    public func setCustomKeys(_ keys: [String: Any]) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping custom keys")
            return
        }
        
        Crashlytics.crashlytics().setCustomKeysAndValues(keys)
        logDebug("[Crashlytics] Custom keys set: \(keys.count) keys")
    }
    
    // MARK: - Breadcrumbs
    
    /// Log breadcrumb for debugging
    ///
    /// Breadcrumbs help trace user actions leading up to a crash
    ///
    /// - Parameter message: Breadcrumb message
    public func log(_ message: String) {
        guard firebaseManager.isServiceEnabled(.crashlytics) else {
            logDebug("[Crashlytics] Service not enabled, skipping log")
            return
        }
        
        Crashlytics.crashlytics().log(message)
        logDebug("[Crashlytics] Log: \(message)")
    }
    
    /// Log breadcrumb with timestamp
    ///
    /// - Parameter message: Breadcrumb message
    public func logWithTimestamp(_ message: String) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        log("[\(timestamp)] \(message)")
    }
    
    /// Log breadcrumb with format
    ///
    /// - Parameters:
    ///   - format: Format string
    ///   - args: Arguments for format
    public func logFormat(_ format: String, _ args: CVarArg...) {
        let message = String(format: format, arguments: args)
        log(message)
    }
    
    // MARK: - App State
    
    /// Record app state information
    ///
    /// - Parameters:
    ///   - state: App state (e.g., "active", "background", "inactive")
    ///   - screen: Current screen name
    public func recordAppState(state: String, screen: String? = nil) {
        var keys: [String: Any] = ["app_state": state]
        
        if let screen = screen {
            keys["current_screen"] = screen
        }
        
        setCustomKeys(keys)
        log("App state: \(state)")
    }
    
    // MARK: - Network Errors
    
    /// Record network error
    ///
    /// - Parameters:
    ///   - error: Network error
    ///   - url: Request URL
    ///   - statusCode: HTTP status code
    ///   - method: HTTP method
    public func recordNetworkError(
        _ error: Error,
        url: String,
        statusCode: Int? = nil,
        method: String? = nil
    ) {
        var context: [String: Any] = ["url": url]
        
        if let statusCode = statusCode {
            context["status_code"] = statusCode
        }
        
        if let method = method {
            context["http_method"] = method
        }
        
        recordError(error, userInfo: context)
    }
    
    // MARK: - Testing
    
    #if DEBUG
    /// Force crash for testing (DEBUG only)
    ///
    /// ⚠️ This will crash the app immediately!
    /// Only use for testing Crashlytics integration.
    public func testCrash() {
        log("⚠️ Test crash triggered")
        fatalError("Test crash triggered by CrashlyticsService")
    }
    
    /// Send test error
    ///
    /// Safe test that sends an error without crashing
    public func testError() {
        let error = NSError(
            domain: "TestDomain",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "This is a test error"]
        )
        
        recordError(error, userInfo: [
            "test": true,
            "environment": "debug"
        ])
        
        print("[Crashlytics] ✅ Test error sent")
    }
    #endif
    
    // MARK: - Helpers
    
    private func logDebug(_ message: String) {
        if firebaseManager.config?.isDebugMode == true {
            print(message)
        }
    }
}

// MARK: - Convenience Extensions

public extension CrashlyticsService {
    /// Record Swift Error with context
    ///
    /// - Parameters:
    ///   - error: Swift error
    ///   - file: Source file (auto-captured)
    ///   - function: Function name (auto-captured)
    ///   - line: Line number (auto-captured)
    func recordSwiftError(
        _ error: Error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        
        recordError(error, userInfo: [
            "file": fileName,
            "function": function,
            "line": line
        ])
    }
}

// MARK: - Error Context Builder

/// Helper for building error context
public struct CrashContext {
    var screen: String?
    var action: String?
    var userInfo: [String: Any] = [:]
    
    public init() {}
    
    public mutating func setScreen(_ screen: String) {
        self.screen = screen
    }
    
    public mutating func setAction(_ action: String) {
        self.action = action
    }
    
    public mutating func addInfo(key: String, value: Any) {
        userInfo[key] = value
    }
    
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = userInfo
        
        if let screen = screen {
            dict["screen"] = screen
        }
        
        if let action = action {
            dict["action"] = action
        }
        
        return dict
    }
}

public extension CrashlyticsService {
    /// Record error with context builder
    ///
    /// ```swift
    /// var context = CrashContext()
    /// context.setScreen("checkout")
    /// context.setAction("process_payment")
    /// context.addInfo(key: "amount", value: 99.99)
    ///
    /// crashlytics.recordError(error, context: context)
    /// ```
    func recordError(_ error: Error, context: CrashContext) {
        let userInfo = context.toDictionary()
        recordError(error, userInfo: userInfo.isEmpty ? nil : userInfo)
    }
}
