import Foundation
import FirebasePerformance

/// High-level Performance Monitoring service
///
/// Provides convenient methods for tracking performance metrics
///
/// ## Usage:
/// ```swift
/// // Start custom trace
/// let trace = PerformanceService.shared.startTrace(name: "image_load")
/// // ... do work ...
/// PerformanceService.shared.stopTrace(trace)
///
/// // Measure async operation
/// let result = await PerformanceService.shared.measure(name: "fetch_data") {
///     return try await fetchData()
/// }
///
/// // Measure with attributes
/// let result = await PerformanceService.shared.measure(
///     name: "api_call",
///     attributes: ["endpoint": "/users", "method": "GET"]
/// ) {
///     return try await apiCall()
/// }
/// ```
///
public final class PerformanceService {
    
    // MARK: - Singleton
    
    public static let shared = PerformanceService()
    
    private let firebaseManager: FirebaseManager
    
    public init(firebaseManager: FirebaseManager = .shared) {
        self.firebaseManager = firebaseManager
    }
    
    // MARK: - Custom Traces
    
    /// Start custom trace
    ///
    /// - Parameter name: Trace name (e.g., "image_load", "data_processing")
    /// - Returns: Trace object or nil if service not enabled
    public func startTrace(name: String) -> Trace? {
        guard firebaseManager.isServiceEnabled(.performance) else {
            logDebug("[Performance] Service not enabled, skipping trace: \(name)")
            return nil
        }
        
        let trace = Performance.startTrace(name: name)
        trace.start()
        
        logDebug("[Performance] ✅ Trace started: \(name)")
        return trace
    }
    
    /// Stop trace
    ///
    /// - Parameter trace: Trace object from startTrace
    public func stopTrace(_ trace: Trace?) {
        guard let trace = trace else { return }
        trace.stop()
        logDebug("[Performance] ✅ Trace stopped")
    }
    
    /// Add metric to trace
    ///
    /// - Parameters:
    ///   - trace: Trace object
    ///   - name: Metric name
    ///   - value: Metric value
    public func incrementMetric(_ trace: Trace?, name: String, by value: Int64 = 1) {
        guard let trace = trace else { return }
        trace.incrementMetric(name, by: value)
        logDebug("[Performance] Metric incremented: \(name) by \(value)")
    }
    
    /// Set attribute on trace
    ///
    /// - Parameters:
    ///   - trace: Trace object
    ///   - key: Attribute key
    ///   - value: Attribute value
    public func setAttribute(_ trace: Trace?, key: String, value: String) {
        guard let trace = trace else { return }
        trace.setValue(value, forAttribute: key)
        logDebug("[Performance] Attribute set: \(key) = \(value)")
    }
    
    // MARK: - Measure Operations (Async)
    
    /// Measure async operation
    ///
    /// Automatically starts trace, executes operation, and stops trace
    ///
    /// - Parameters:
    ///   - name: Trace name
    ///   - attributes: Optional attributes
    ///   - operation: Async operation to measure
    /// - Returns: Operation result
    @discardableResult
    public func measure<T>(
        name: String,
        attributes: [String: String]? = nil,
        operation: () async throws -> T
    ) async rethrows -> T {
        let trace = startTrace(name: name)
        
        // Set attributes
        attributes?.forEach { key, value in
            setAttribute(trace, key: key, value: value)
        }
        
        defer {
            stopTrace(trace)
        }
        
        return try await operation()
    }
    
    /// Measure async operation with metrics
    ///
    /// - Parameters:
    ///   - name: Trace name
    ///   - attributes: Optional attributes
    ///   - metrics: Metrics to track
    ///   - operation: Async operation to measure
    /// - Returns: Operation result
    @discardableResult
    public func measure<T>(
        name: String,
        attributes: [String: String]? = nil,
        metrics: [String: Int64] = [:],
        operation: () async throws -> T
    ) async rethrows -> T {
        let trace = startTrace(name: name)
        
        // Set attributes
        attributes?.forEach { key, value in
            setAttribute(trace, key: key, value: value)
        }
        
        // Set initial metrics
        metrics.forEach { key, value in
            incrementMetric(trace, name: key, by: value)
        }
        
        defer {
            stopTrace(trace)
        }
        
        return try await operation()
    }
    
    // MARK: - Measure Operations (Sync)
    
    /// Measure synchronous operation
    ///
    /// - Parameters:
    ///   - name: Trace name
    ///   - attributes: Optional attributes
    ///   - operation: Sync operation to measure
    /// - Returns: Operation result
    @discardableResult
    public func measure<T>(
        name: String,
        attributes: [String: String]? = nil,
        operation: () throws -> T
    ) rethrows -> T {
        let trace = startTrace(name: name)
        
        // Set attributes
        attributes?.forEach { key, value in
            setAttribute(trace, key: key, value: value)
        }
        
        defer {
            stopTrace(trace)
        }
        
        return try operation()
    }
    
    // MARK: - Network Traces
    
    /// Create HTTP metric
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - httpMethod: HTTP method
    /// - Returns: HTTPMetric or nil if service not enabled
    public func createHTTPMetric(url: URL, httpMethod: HTTPMethod) -> HTTPMetric? {
        guard firebaseManager.isServiceEnabled(.performance) else {
            logDebug("[Performance] Service not enabled, skipping HTTP metric")
            return nil
        }
        
        let metric = HTTPMetric(url: url, httpMethod: httpMethod)
        logDebug("[Performance] HTTP metric created: \(httpMethod.rawValue) \(url)")
        return metric
    }
    
    /// Track network request
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP method
    ///   - statusCode: Response status code
    ///   - requestSize: Request payload size in bytes
    ///   - responseSize: Response payload size in bytes
    public func trackNetworkRequest(
        url: URL,
        method: HTTPMethod,
        statusCode: Int? = nil,
        requestSize: Int64? = nil,
        responseSize: Int64? = nil
    ) {
        guard let metric = createHTTPMetric(url: url, httpMethod: method) else { return }
        
        metric.start()
        
        if let statusCode = statusCode {
            metric.responseCode = statusCode
        }
        
        if let requestSize = requestSize {
            metric.requestPayloadSize = requestSize
        }
        
        if let responseSize = responseSize {
            metric.responsePayloadSize = responseSize
        }
        
        metric.stop()
        logDebug("[Performance] ✅ Network request tracked")
    }
    
    // MARK: - Screen Traces
    
    /// Track screen rendering
    ///
    /// Use this to measure screen load time
    ///
    /// - Parameter screenName: Screen identifier
    /// - Returns: Trace object
    public func startScreenTrace(_ screenName: String) -> Trace? {
        return startTrace(name: "screen_\(screenName)")
    }
    
    // MARK: - Helpers
    
    private func logDebug(_ message: String) {
        if firebaseManager.config?.isDebugMode == true {
            print(message)
        }
    }
}

// MARK: - Convenience Extensions

public extension PerformanceService {
    /// Measure view loading
    ///
    /// ```swift
    /// await performanceService.measureViewLoad("HomeView") {
    ///     await loadData()
    /// }
    /// ```
    func measureViewLoad<T>(
        _ viewName: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        return try await measure(
            name: "view_load",
            attributes: ["view": viewName],
            operation: operation
        )
    }
    
    /// Measure API call
    ///
    /// ```swift
    /// let users = await performanceService.measureAPICall(
    ///     endpoint: "/users",
    ///     method: "GET"
    /// ) {
    ///     try await fetchUsers()
    /// }
    /// ```
    func measureAPICall<T>(
        endpoint: String,
        method: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        return try await measure(
            name: "api_call",
            attributes: [
                "endpoint": endpoint,
                "method": method
            ],
            operation: operation
        )
    }
    
    /// Measure database operation
    func measureDBOperation<T>(
        operation: String,
        table: String? = nil,
        closure: () async throws -> T
    ) async rethrows -> T {
        var attributes = ["operation": operation]
        if let table = table {
            attributes["table"] = table
        }
        
        return try await measure(
            name: "db_operation",
            attributes: attributes,
            operation: closure
        )
    }
    
    /// Measure image loading
    func measureImageLoad<T>(
        source: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        return try await measure(
            name: "image_load",
            attributes: ["source": source],
            operation: operation
        )
    }
}

// MARK: - Performance Monitor Helper

/// Helper for tracking multiple metrics in a single trace
public final class PerformanceMonitor {
    private let trace: Trace?
    private let name: String
    
    public init(name: String, service: PerformanceService = .shared) {
        self.name = name
        self.trace = service.startTrace(name: name)
    }
    
    /// Add metric
    public func incrementMetric(_ name: String, by value: Int64 = 1) {
        trace?.incrementMetric(name, by: value)
    }
    
    /// Set attribute
    public func setAttribute(key: String, value: String) {
        trace?.setValue(value, forAttribute: key)
    }
    
    /// Set multiple attributes
    public func setAttributes(_ attributes: [String: String]) {
        attributes.forEach { key, value in
            setAttribute(key: key, value: value)
        }
    }
    
    /// Stop monitoring
    public func stop() {
        trace?.stop()
    }
    
    deinit {
        trace?.stop()
    }
}

// MARK: - Usage Examples

/*
 
 // Example 1: Simple trace
 let trace = PerformanceService.shared.startTrace(name: "data_processing")
 processData()
 PerformanceService.shared.stopTrace(trace)
 
 // Example 2: Measure async operation
 let data = await PerformanceService.shared.measure(name: "fetch_data") {
     return try await fetchData()
 }
 
 // Example 3: Measure with attributes
 let result = await PerformanceService.shared.measure(
     name: "api_call",
     attributes: [
         "endpoint": "/users",
         "method": "GET"
     ]
 ) {
     return try await apiCall()
 }
 
 // Example 4: Complex monitoring
 let monitor = PerformanceMonitor(name: "checkout_flow")
 monitor.setAttribute(key: "user_type", value: "premium")
 monitor.incrementMetric("items_count", by: 3)
 // ... do checkout ...
 monitor.stop()
 
 // Example 5: Convenience methods
 let users = await PerformanceService.shared.measureAPICall(
     endpoint: "/users",
     method: "GET"
 ) {
     try await fetchUsers()
 }
 
 */
