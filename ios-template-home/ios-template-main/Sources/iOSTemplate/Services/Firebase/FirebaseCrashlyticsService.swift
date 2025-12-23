import Foundation
import FirebaseCrashlytics

/// Firebase Crashlytics Service - Implementation của CrashlyticsServiceProtocol
///
/// Service này wrap Firebase Crashlytics SDK và provide methods để:
/// - Record non-fatal errors
/// - Log messages cho crash reports
/// - Set user context (user ID, custom keys)
/// - Test crashes (DEBUG only)
///
/// ## Usage:
/// ```swift
/// @Injected var crashlytics: CrashlyticsServiceProtocol
///
/// // Record non-fatal error
/// crashlytics.recordError(error, userInfo: ["context": "user_action"])
///
/// // Log message
/// crashlytics.log("User completed checkout")
///
/// // Set user ID
/// crashlytics.setUserID("user_123")
///
/// // Set custom key
/// crashlytics.setCustomValue("premium", forKey: "user_tier")
///
/// // Test crash (DEBUG only)
/// #if DEBUG
/// crashlytics.testCrash()
/// #endif
/// ```
///
/// ## Crash Reports Include:
/// - Stack traces
/// - Device info (model, OS version)
/// - App version
/// - Custom logs (via log())
/// - Custom keys (via setCustomValue())
/// - User ID (via setUserID())
/// - Non-fatal errors (via recordError())
///
public final class FirebaseCrashlyticsService: CrashlyticsServiceProtocol {

    // MARK: - Properties

    /// Singleton instance
    public static let shared = FirebaseCrashlyticsService()

    /// Crashlytics instance
    private let crashlytics = Crashlytics.crashlytics()

    /// Debug mode
    private var isDebugMode: Bool = false

    // MARK: - Initialization

    private init() {
        #if DEBUG
        isDebugMode = true
        setupDebugMode()
        #endif
    }

    // MARK: - CrashlyticsServiceProtocol

    /// Record non-fatal error
    ///
    /// Non-fatal errors được track nhưng không crash app.
    /// Useful để track unexpected conditions, API failures, etc.
    ///
    /// - Parameters:
    ///   - error: Error to record
    ///   - userInfo: Additional context (optional)
    ///
    /// **Example**:
    /// ```swift
    /// do {
    ///     try performAction()
    /// } catch {
    ///     crashlytics.recordError(error, userInfo: [
    ///         "action": "checkout",
    ///         "user_tier": "premium"
    ///     ])
    /// }
    /// ```
    public func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        // Record error với Firebase
        crashlytics.record(error: error, userInfo: userInfo)

        if isDebugMode {
            logDebug("💥 Non-fatal error recorded: \(error.localizedDescription)")
            if let info = userInfo, !info.isEmpty {
                logDebug("   UserInfo: \(info)")
            }
        }
    }

    /// Log message to crash reports
    ///
    /// Logs được include trong crash reports, giúp debug crashes.
    /// Logs persist cho đến khi crash xảy ra.
    ///
    /// - Parameter message: Log message (max recommended: 64KB total)
    ///
    /// **Best Practice**:
    /// - Log significant user actions
    /// - Log state changes
    /// - Log API calls
    /// - Don't log sensitive data (passwords, tokens, PII)
    ///
    /// **Example**:
    /// ```swift
    /// crashlytics.log("User tapped checkout button")
    /// crashlytics.log("API call: POST /orders - Success")
    /// crashlytics.log("App state changed to: background")
    /// ```
    public func log(_ message: String) {
        crashlytics.log(message)

        if isDebugMode {
            logDebug("📝 Crashlytics log: \(message)")
        }
    }

    /// Set user identifier
    ///
    /// User ID helps identify which users are experiencing crashes.
    ///
    /// - Parameter userID: User ID (nil to clear)
    ///
    /// **Privacy**:
    /// - Use hashed/anonymized ID
    /// - Don't use email, phone, or other PII
    /// - Clear on logout
    ///
    /// **Example**:
    /// ```swift
    /// // On login
    /// let hashedID = hashUserID(userEmail)
    /// crashlytics.setUserID(hashedID)
    ///
    /// // On logout
    /// crashlytics.setUserID(nil)
    /// ```
    public func setUserID(_ userID: String?) {
        crashlytics.setUserID(userID)

        if isDebugMode {
            if let id = userID {
                logDebug("🆔 Crashlytics user ID set: \(id)")
            } else {
                logDebug("🆔 Crashlytics user ID cleared")
            }
        }
    }

    /// Set custom key-value pair
    ///
    /// Custom keys appear trong crash reports, giúp add context.
    ///
    /// - Parameters:
    ///   - value: Value (String, Int, Bool, Float, Double)
    ///   - key: Key name
    ///
    /// **Common Use Cases**:
    /// - User tier: "premium", "free"
    /// - Feature flags: true/false
    /// - App state: "foreground", "background"
    /// - Last action: "checkout", "profile_view"
    ///
    /// **Example**:
    /// ```swift
    /// crashlytics.setCustomValue("premium", forKey: "user_tier")
    /// crashlytics.setCustomValue(true, forKey: "dark_mode_enabled")
    /// crashlytics.setCustomValue(42, forKey: "items_in_cart")
    /// crashlytics.setCustomValue(1.5, forKey: "app_version")
    /// ```
    public func setCustomValue(_ value: Any, forKey key: String) {
        // Firebase Crashlytics hỗ trợ nhiều types
        if let stringValue = value as? String {
            crashlytics.setCustomValue(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            crashlytics.setCustomValue(intValue, forKey: key)
        } else if let boolValue = value as? Bool {
            crashlytics.setCustomValue(boolValue, forKey: key)
        } else if let floatValue = value as? Float {
            crashlytics.setCustomValue(floatValue, forKey: key)
        } else if let doubleValue = value as? Double {
            crashlytics.setCustomValue(doubleValue, forKey: key)
        } else {
            // Fallback: convert to string
            crashlytics.setCustomValue(String(describing: value), forKey: key)
        }

        if isDebugMode {
            logDebug("🔧 Crashlytics custom key set: \(key) = \(value)")
        }
    }

    /// Force a test crash
    ///
    /// **WARNING**: Chỉ dùng để test Crashlytics setup.
    /// App sẽ crash ngay lập tức.
    ///
    /// **Usage**:
    /// ```swift
    /// #if DEBUG
    /// // Test crash button
    /// Button("Test Crash") {
    ///     crashlytics.testCrash()
    /// }
    /// #endif
    /// ```
    ///
    /// **Validation**:
    /// 1. Call testCrash()
    /// 2. App crashes
    /// 3. Relaunch app (crashes send on next launch)
    /// 4. Wait 5-10 minutes
    /// 5. Check Firebase Console → Crashlytics
    public func testCrash() {
        #if DEBUG
        logDebug("💣 TEST CRASH TRIGGERED - App will crash now!")
        crashlytics.log("TEST CRASH - This is intentional for testing")

        // Force crash
        fatalError("Test crash triggered by FirebaseCrashlyticsService.testCrash()")
        #else
        logDebug("⚠️ testCrash() called in RELEASE build - ignoring for safety")
        #endif
    }

    // MARK: - Debug Helpers

    private func setupDebugMode() {
        logDebug("🐛 Crashlytics Debug Mode: ENABLED")
        logDebug("   Non-fatal errors will be logged to console")
        logDebug("   Test crashes available via testCrash()")
    }

    private func logDebug(_ message: String) {
        if isDebugMode {
            print("[FirebaseCrashlytics] \(message)")
        }
    }
}

// MARK: - Convenience Extensions

public extension CrashlyticsServiceProtocol {
    /// Record error without userInfo
    func recordError(_ error: Error) {
        recordError(error, userInfo: nil)
    }

    /// Log formatted message
    func log(format: String, _ args: CVarArg...) {
        let message = String(format: format, arguments: args)
        log(message)
    }

    /// Set multiple custom values
    func setCustomValues(_ values: [String: Any]) {
        for (key, value) in values {
            setCustomValue(value, forKey: key)
        }
    }
}

// MARK: - Common Error Types

/// Common error types để track trong Crashlytics
public enum AppCrashError: Error, LocalizedError {
    case networkFailure(statusCode: Int, endpoint: String)
    case dataCorruption(description: String)
    case invalidState(description: String)
    case unauthorized
    case timeout
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .networkFailure(let code, let endpoint):
            return "Network failure: \(code) at \(endpoint)"
        case .dataCorruption(let desc):
            return "Data corruption: \(desc)"
        case .invalidState(let desc):
            return "Invalid state: \(desc)"
        case .unauthorized:
            return "Unauthorized access"
        case .timeout:
            return "Operation timed out"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Usage Examples in Comments

/*
 ## Basic Usage Examples:

 ### 1. Record API Errors
 ```swift
 func fetchData() async {
     do {
         let data = try await apiClient.get("/users")
     } catch {
         crashlytics.recordError(error, userInfo: [
             "endpoint": "/users",
             "user_tier": "premium"
         ])
     }
 }
 ```

 ### 2. Log User Journey
 ```swift
 // Track user flow leading to crash
 crashlytics.log("User opened checkout")
 crashlytics.log("User entered payment info")
 crashlytics.log("User tapped 'Pay Now'")
 // If crash happens, all logs appear in crash report
 ```

 ### 3. Set Context
 ```swift
 // On app launch
 crashlytics.setCustomValue(AppVersion.current, forKey: "app_version")
 crashlytics.setCustomValue(UIDevice.current.model, forKey: "device_model")

 // On user login
 crashlytics.setUserID(hashedUserID)
 crashlytics.setCustomValue(user.tier, forKey: "user_tier")
 crashlytics.setCustomValue(user.isFirstTime, forKey: "is_first_time_user")
 ```

 ### 4. Track Non-Fatal Errors
 ```swift
 // Record errors that don't crash app but indicate problems
 if responseCode != 200 {
     let error = AppCrashError.networkFailure(
         statusCode: responseCode,
         endpoint: "/api/checkout"
     )
     crashlytics.recordError(error, userInfo: [
         "user_action": "checkout",
         "cart_items": cartItemCount
     ])
 }
 ```

 ### 5. Test Setup (DEBUG only)
 ```swift
 struct DebugSettingsView: View {
     @Injected var crashlytics: CrashlyticsServiceProtocol

     var body: some View {
         VStack {
             #if DEBUG
             Button("Test Crash") {
                 crashlytics.testCrash()
             }
             .foregroundColor(.red)
             #endif
         }
     }
 }
 ```
 */
