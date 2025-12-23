import Foundation
import FirebasePerformance

// MARK: - Firebase Performance Service

/// Service quản lý Firebase Performance Monitoring
///
/// **Chức năng chính**:
/// - Track app performance metrics
/// - Monitor network requests
/// - Create custom traces
/// - Track specific operations
/// - Automatic performance data collection
///
/// **Usage Example**:
/// ```swift
/// // Track custom operation
/// let trace = FirebasePerformanceService.shared.startTrace(name: "user_login")
/// // ... perform login ...
/// trace.stop()
///
/// // Track network request
/// let metric = FirebasePerformanceService.shared.startHTTPMetric(
///     url: url,
///     method: .post
/// )
/// // ... make request ...
/// metric.markRequestComplete()
/// metric.markResponseStart()
/// // ... receive response ...
/// metric.stop()
/// ```
///
/// **Automatic Tracking**:
/// - App start time
/// - Screen rendering performance
/// - Network requests (via URLSession)
/// - Slow/frozen frames
///
/// **Debug Mode**:
/// - Auto-enabled trong DEBUG builds
/// - Shows detailed logs
/// - Performance data sent to Firebase Console
public final class FirebasePerformanceService {

    // MARK: - Properties

    /// Shared instance
    public static let shared = FirebasePerformanceService()

    /// Performance instance
    private let performance = Performance.sharedInstance()

    /// Active traces
    private var activeTraces: [String: Trace] = [:]

    /// Active HTTP metrics
    private var activeHTTPMetrics: [String: HTTPMetric] = [:]

    /// Debug mode
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Is enabled
    private(set) var isEnabled: Bool = true

    // MARK: - Initialization

    private init() {
        setupPerformance()
    }

    // MARK: - Setup

    /// Setup performance monitoring
    private func setupPerformance() {
        #if DEBUG
        // Performance monitoring enabled in debug
        performance.isDataCollectionEnabled = true
        logDebug("✅ Performance Monitoring enabled (DEBUG)")
        #else
        // Enable based on remote config (optional)
        performance.isDataCollectionEnabled = true
        logDebug("✅ Performance Monitoring enabled (RELEASE)")
        #endif

        isEnabled = performance.isDataCollectionEnabled
    }

    // MARK: - Custom Traces

    /// Start custom trace
    ///
    /// **Use for**:
    /// - Long-running operations
    /// - User flows (login, checkout, etc.)
    /// - Complex computations
    /// - Data synchronization
    ///
    /// **Example**:
    /// ```swift
    /// let trace = service.startTrace(name: "user_login")
    /// trace.setValue(loginMethod, forAttribute: "method")
    /// // ... perform login ...
    /// trace.stop()
    /// ```
    ///
    /// - Parameter name: Trace name (must be unique)
    /// - Returns: Trace instance
    @discardableResult
    public func startTrace(name: String) -> Trace? {
        let trace = performance.trace(name: name)
        trace?.start()
        if let trace = trace {
            activeTraces[name] = trace
            logDebug("▶️ Started trace: \(name)")
        } else {
            logDebug("❌ Failed to create trace: \(name)")
        }
        return trace
    }

    /// Stop trace by name
    ///
    /// - Parameter name: Trace name
    public func stopTrace(name: String) {
        guard let trace = activeTraces[name] else {
            logDebug("⚠️ Trace not found: \(name)")
            return
        }

        trace.stop()
        activeTraces.removeValue(forKey: name)

        logDebug("⏹️ Stopped trace: \(name)")
    }

    /// Execute block with trace
    ///
    /// **Convenience method** that automatically starts and stops trace
    ///
    /// **Example**:
    /// ```swift
    /// service.trace(name: "process_data") {
    ///     // ... process data ...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - name: Trace name
    ///   - block: Code to execute
    public func trace(name: String, _ block: () -> Void) {
        let trace = startTrace(name: name)
        block()
        trace?.stop()
    }

    /// Execute async block with trace
    ///
    /// **Async version** of trace()
    ///
    /// - Parameters:
    ///   - name: Trace name
    ///   - block: Async code to execute
    public func trace(name: String, _ block: () async throws -> Void) async rethrows {
        let trace = startTrace(name: name)
        try await block()
        trace?.stop()
    }

    // MARK: - HTTP Metrics

    /// Start HTTP metric
    ///
    /// **Track network requests**:
    /// - Request time
    /// - Response time
    /// - Response size
    /// - Success/failure
    ///
    /// **Example**:
    /// ```swift
    /// let metric = service.startHTTPMetric(
    ///     url: url,
    ///     method: .get
    /// )
    ///
    /// // Make request
    /// metric.markRequestComplete()
    ///
    /// // Receive response
    /// metric.markResponseStart()
    /// metric.responseContentType = "application/json"
    /// metric.responseCode = 200
    ///
    /// // Complete
    /// metric.stop()
    /// ```
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP method
    /// - Returns: HTTPMetric instance
    @discardableResult
    public func startHTTPMetric(url: URL, method: HTTPMethod) -> HTTPMetric? {
        let metric = HTTPMetric(url: url, httpMethod: method.firebaseMethod)
        metric?.start()

        if let metric = metric {
            let key = "\(method.rawValue)_\(url.absoluteString)"
            activeHTTPMetrics[key] = metric
            logDebug("📡 Started HTTP metric: \(method.rawValue) \(url.path)")
        } else {
            logDebug("❌ Failed to create HTTP metric for: \(url)")
        }

        return metric
    }

    /// Stop HTTP metric
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP method
    public func stopHTTPMetric(url: URL, method: HTTPMethod) {
        let key = "\(method.rawValue)_\(url.absoluteString)"

        guard let metric = activeHTTPMetrics[key] else {
            logDebug("⚠️ HTTP metric not found: \(key)")
            return
        }

        metric.stop()
        activeHTTPMetrics.removeValue(forKey: key)

        logDebug("⏹️ Stopped HTTP metric: \(method.rawValue) \(url.path)")
    }

    // MARK: - Predefined Traces

    /// Trace app launch
    ///
    /// **Call in AppDelegate**:
    /// ```swift
    /// func application(...) -> Bool {
    ///     let trace = FirebasePerformanceService.shared.traceAppLaunch()
    ///     // ... app initialization ...
    ///     trace.stop()
    /// }
    /// ```
    @discardableResult
    public func traceAppLaunch() -> Trace? {
        startTrace(name: PerformanceTrace.appLaunch.rawValue)
    }

    /// Trace screen load
    ///
    /// **Track screen loading time**
    ///
    /// - Parameter screenName: Screen name
    /// - Returns: Trace instance
    @discardableResult
    public func traceScreenLoad(_ screenName: String) -> Trace? {
        let trace = startTrace(name: "screen_load_\(screenName)")
        trace?.setValue(screenName, forAttribute: "screen_name")
        return trace
    }

    /// Trace user login
    ///
    /// - Parameter method: Login method (email, social, biometric)
    /// - Returns: Trace instance
    @discardableResult
    public func traceUserLogin(method: String) -> Trace? {
        let trace = startTrace(name: PerformanceTrace.userLogin.rawValue)
        trace?.setValue(method, forAttribute: "method")
        return trace
    }

    /// Trace data sync
    ///
    /// - Parameter syncType: Sync type (full, incremental, etc.)
    /// - Returns: Trace instance
    @discardableResult
    public func traceDataSync(type: String) -> Trace? {
        let trace = startTrace(name: PerformanceTrace.dataSync.rawValue)
        trace?.setValue(type, forAttribute: "sync_type")
        return trace
    }

    /// Trace image load
    ///
    /// - Parameter imageURL: Image URL
    /// - Returns: Trace instance
    @discardableResult
    public func traceImageLoad(url: String) -> Trace? {
        let trace = startTrace(name: PerformanceTrace.imageLoad.rawValue)
        trace?.setValue(url, forAttribute: "image_url")
        return trace
    }

    /// Trace database operation
    ///
    /// - Parameter operation: Operation type (query, insert, update, delete)
    /// - Returns: Trace instance
    @discardableResult
    public func traceDatabaseOperation(_ operation: String) -> Trace? {
        let trace = startTrace(name: PerformanceTrace.databaseOperation.rawValue)
        trace?.setValue(operation, forAttribute: "operation")
        return trace
    }

    // MARK: - Configuration

    /// Enable/disable data collection
    ///
    /// **Note**: Changes take effect on next app launch
    ///
    /// - Parameter enabled: Enable performance monitoring
    public func setDataCollectionEnabled(_ enabled: Bool) {
        performance.isDataCollectionEnabled = enabled
        isEnabled = enabled

        logDebug(enabled ? "✅ Performance monitoring enabled" : "⚠️ Performance monitoring disabled")
    }

    /// Check if performance monitoring is enabled
    ///
    /// - Returns: true if enabled
    public func isPerformanceMonitoringEnabled() -> Bool {
        performance.isDataCollectionEnabled
    }

    // MARK: - Debug

    /// Get active traces count
    ///
    /// **Debug helper**
    ///
    /// - Returns: Number of active traces
    public func getActiveTracesCount() -> Int {
        activeTraces.count
    }

    /// Get active HTTP metrics count
    ///
    /// **Debug helper**
    ///
    /// - Returns: Number of active HTTP metrics
    public func getActiveHTTPMetricsCount() -> Int {
        activeHTTPMetrics.count
    }

    /// Get active traces info
    ///
    /// **Debug helper**
    ///
    /// - Returns: Array of active trace names
    public func getActiveTracesInfo() -> [String] {
        Array(activeTraces.keys)
    }

    // MARK: - Private Methods

    /// Debug logging
    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[Performance] \(message)")
    }
}

// MARK: - HTTP Method Extension

extension HTTPMethod {
    /// Convert to Firebase Performance HTTPMethod
    var firebaseMethod: FirebasePerformance.HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        }
    }
}

// MARK: - Performance Traces

/// Predefined performance trace names
public enum PerformanceTrace: String {
    case appLaunch = "app_launch"
    case appBecomeActive = "app_become_active"
    case userLogin = "user_login"
    case dataSync = "data_sync"
    case imageLoad = "image_load"
    case databaseOperation = "database_operation"
    case apiCall = "api_call"
    case fileUpload = "file_upload"
    case fileDownload = "file_download"
}

// MARK: - Trace Extensions

extension Trace {
    /// Add attribute with String value
    ///
    /// **Attributes**:
    /// - Max 5 custom attributes per trace
    /// - Attribute name max 40 characters
    /// - Attribute value max 100 characters
    ///
    /// - Parameters:
    ///   - value: Attribute value
    ///   - attribute: Attribute name
    public func setValue(_ value: String, forAttribute attribute: String) {
        self.setValue(value, forAttribute: attribute)
    }

    /// Increment metric
    ///
    /// **Metrics**:
    /// - Max 32 custom metrics per trace
    /// - Track counts, sizes, durations, etc.
    ///
    /// - Parameters:
    ///   - metricName: Metric name
    ///   - incrementBy: Increment value (default: 1)
    public func incrementMetric(_ metricName: String, by value: Int64 = 1) {
        self.incrementMetric(metricName, by: value)
    }
}

// MARK: - URLSession Extension

/// URLSession extension for automatic performance tracking
extension URLSession {

    /// Data task with automatic performance tracking
    ///
    /// **Automatically tracks**:
    /// - Request time
    /// - Response time
    /// - Response size
    /// - Status code
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - completionHandler: Completion handler
    /// - Returns: URLSessionDataTask
    public func trackedDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let metric = FirebasePerformanceService.shared.startHTTPMetric(
            url: url,
            method: .get
        )

        return self.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, let metric = metric {
                // Set response properties
                metric.responseCode = httpResponse.statusCode

                if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
                    metric.responseContentType = contentType
                }

                if let data = data {
                    metric.responsePayloadSize = Int(data.count)
                }

                // Stop metric
                metric.stop()
            }

            // Call original completion handler
            completionHandler(data, response, error)
        }
    }

    /// Data task with URLRequest and automatic tracking
    ///
    /// - Parameters:
    ///   - request: URLRequest
    ///   - completionHandler: Completion handler
    /// - Returns: URLSessionDataTask
    public func trackedDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        guard let url = request.url else {
            return self.dataTask(with: request, completionHandler: completionHandler)
        }

        let method = HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .get
        let metric = FirebasePerformanceService.shared.startHTTPMetric(
            url: url,
            method: method
        )

        return self.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, let metric = metric {
                metric.responseCode = httpResponse.statusCode

                if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
                    metric.responseContentType = contentType
                }

                if let data = data {
                    metric.responsePayloadSize = Int(data.count)
                }

                metric.stop()
            }

            completionHandler(data, response, error)
        }
    }
}

// MARK: - Performance Errors

/// Performance monitoring errors
public enum PerformanceError: Error, LocalizedError {
    case traceNotFound(String)
    case metricNotFound(String)
    case invalidTraceName
    case tooManyAttributes
    case tooManyMetrics

    public var errorDescription: String? {
        switch self {
        case .traceNotFound(let name):
            return "Trace not found: \(name)"
        case .metricNotFound(let name):
            return "Metric not found: \(name)"
        case .invalidTraceName:
            return "Invalid trace name"
        case .tooManyAttributes:
            return "Too many attributes (max 5 per trace)"
        case .tooManyMetrics:
            return "Too many metrics (max 32 per trace)"
        }
    }
}
