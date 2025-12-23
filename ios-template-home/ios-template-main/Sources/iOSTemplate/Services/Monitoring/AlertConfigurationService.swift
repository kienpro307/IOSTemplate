import Foundation
import Combine

// MARK: - Alert Configuration Service

/// Service quản lý alert configurations cho monitoring
///
/// **Phase 9 - Task 9.1.2**: Alert Configuration
///
/// Service này handle:
/// - Crash rate alerts
/// - Performance alerts
/// - Revenue alerts
/// - User feedback alerts
///
/// **Usage Example**:
/// ```swift
/// @Injected var alertService: AlertConfigurationService
///
/// // Configure crash alert
/// alertService.configureCrashAlert(threshold: 0.01) // 1% crash rate
///
/// // Check if alert should trigger
/// if alertService.shouldTriggerCrashAlert(crashRate: 0.02) {
///     alertService.triggerAlert(.crashRateExceeded(rate: 0.02))
/// }
///
/// // Get active alerts
/// let alerts = alertService.getActiveAlerts()
/// ```
///
public final class AlertConfigurationService: ObservableObject {

    // MARK: - Properties

    /// Shared instance
    public static let shared = AlertConfigurationService()

    /// Alert configurations
    @Published public private(set) var configurations: AlertConfigurations

    /// Active alerts
    @Published public private(set) var activeAlerts: [Alert] = []

    /// Alert history
    private var alertHistory: [Alert] = []

    /// Analytics service
    private let analytics: AnalyticsServiceProtocol

    /// Crashlytics service
    private let crashlytics: CrashlyticsServiceProtocol

    /// Notification manager
    private let notificationManager: NotificationManager

    /// Debug mode
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Alert check timer
    private var alertCheckTimer: Timer?

    // MARK: - Initialization

    public init(
        analytics: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        crashlytics: CrashlyticsServiceProtocol = FirebaseCrashlyticsService.shared,
        notificationManager: NotificationManager = NotificationManager.shared
    ) {
        self.analytics = analytics
        self.crashlytics = crashlytics
        self.notificationManager = notificationManager
        self.configurations = AlertConfigurations()

        setupAlertService()
    }

    // MARK: - Setup

    private func setupAlertService() {
        logDebug("🚨 Setting up Alert Configuration Service")

        // Load saved configurations
        loadConfigurations()

        // Start periodic alert checks (every 5 minutes)
        startAlertChecks()
    }

    /// Start periodic alert checks
    private func startAlertChecks() {
        alertCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 300.0, // 5 minutes
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.performAlertChecks()
            }
        }
    }

    // MARK: - Configuration Methods

    /// Configure crash rate alert
    ///
    /// - Parameters:
    ///   - threshold: Crash rate threshold (0.0 - 1.0)
    ///   - enabled: Enable/disable alert
    public func configureCrashAlert(threshold: Double, enabled: Bool = true) {
        configurations.crashRateThreshold = threshold
        configurations.crashAlertsEnabled = enabled

        saveConfigurations()

        logDebug("⚙️ Crash alert configured: threshold=\(threshold * 100)%, enabled=\(enabled)")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "alert_configured",
                parameters: [
                    "alert_type": "crash_rate",
                    "threshold": threshold,
                    "enabled": enabled
                ]
            )
        )
    }

    /// Configure performance alert
    ///
    /// - Parameters:
    ///   - threshold: Performance threshold (ms)
    ///   - metric: Performance metric type
    ///   - enabled: Enable/disable alert
    public func configurePerformanceAlert(
        threshold: TimeInterval,
        metric: PerformanceMetric,
        enabled: Bool = true
    ) {
        switch metric {
        case .appStartTime:
            configurations.appStartTimeThreshold = threshold
        case .screenLoadTime:
            configurations.screenLoadTimeThreshold = threshold
        case .apiResponseTime:
            configurations.apiResponseTimeThreshold = threshold
        }

        configurations.performanceAlertsEnabled = enabled
        saveConfigurations()

        logDebug("⚙️ Performance alert configured: \(metric.rawValue) threshold=\(threshold)ms")
    }

    /// Configure revenue alert
    ///
    /// - Parameters:
    ///   - threshold: Minimum revenue threshold
    ///   - enabled: Enable/disable alert
    public func configureRevenueAlert(threshold: Double, enabled: Bool = true) {
        configurations.revenueThreshold = threshold
        configurations.revenueAlertsEnabled = enabled

        saveConfigurations()

        logDebug("⚙️ Revenue alert configured: threshold=$\(threshold)")
    }

    /// Configure user feedback alert
    ///
    /// - Parameters:
    ///   - threshold: Minimum rating threshold (1.0 - 5.0)
    ///   - enabled: Enable/disable alert
    public func configureUserFeedbackAlert(threshold: Double, enabled: Bool = true) {
        configurations.userFeedbackThreshold = threshold
        configurations.feedbackAlertsEnabled = enabled

        saveConfigurations()

        logDebug("⚙️ User feedback alert configured: threshold=\(threshold) stars")
    }

    // MARK: - Alert Checking

    /// Perform all alert checks
    @MainActor
    private func performAlertChecks() async {
        logDebug("🔍 Performing alert checks...")

        // This would integrate with real monitoring data
        // For now, it's a placeholder for the structure
    }

    /// Check if crash alert should trigger
    ///
    /// - Parameter crashRate: Current crash rate (0.0 - 1.0)
    /// - Returns: true if alert should trigger
    public func shouldTriggerCrashAlert(crashRate: Double) -> Bool {
        guard configurations.crashAlertsEnabled else { return false }
        return crashRate > configurations.crashRateThreshold
    }

    /// Check if performance alert should trigger
    ///
    /// - Parameters:
    ///   - value: Performance metric value
    ///   - metric: Performance metric type
    /// - Returns: true if alert should trigger
    public func shouldTriggerPerformanceAlert(
        value: TimeInterval,
        metric: PerformanceMetric
    ) -> Bool {
        guard configurations.performanceAlertsEnabled else { return false }

        switch metric {
        case .appStartTime:
            return value > configurations.appStartTimeThreshold
        case .screenLoadTime:
            return value > configurations.screenLoadTimeThreshold
        case .apiResponseTime:
            return value > configurations.apiResponseTimeThreshold
        }
    }

    /// Check if revenue alert should trigger
    ///
    /// - Parameter revenue: Current revenue
    /// - Returns: true if alert should trigger
    public func shouldTriggerRevenueAlert(revenue: Double) -> Bool {
        guard configurations.revenueAlertsEnabled else { return false }
        return revenue < configurations.revenueThreshold
    }

    /// Check if user feedback alert should trigger
    ///
    /// - Parameter rating: Average user rating
    /// - Returns: true if alert should trigger
    public func shouldTriggerUserFeedbackAlert(rating: Double) -> Bool {
        guard configurations.feedbackAlertsEnabled else { return false }
        return rating < configurations.userFeedbackThreshold
    }

    // MARK: - Alert Triggering

    /// Trigger an alert
    ///
    /// - Parameter alert: Alert to trigger
    @MainActor
    public func triggerAlert(_ alert: Alert) {
        logDebug("🚨 Alert triggered: \(alert.title)")

        // Add to active alerts
        activeAlerts.append(alert)

        // Add to history
        alertHistory.append(alert)

        // Track analytics
        analytics.trackEvent(
            AnalyticsEvent(
                name: "alert_triggered",
                parameters: [
                    "alert_type": alert.type.rawValue,
                    "severity": alert.severity.rawValue,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        )

        // Record in crashlytics
        crashlytics.log("🚨 Alert: \(alert.title) - \(alert.message)")

        // Send local notification (if critical)
        if alert.severity == .critical {
            sendNotification(for: alert)
        }
    }

    /// Dismiss an alert
    ///
    /// - Parameter alertId: Alert ID
    @MainActor
    public func dismissAlert(_ alertId: UUID) {
        activeAlerts.removeAll { $0.id == alertId }
        logDebug("✅ Alert dismissed: \(alertId)")
    }

    /// Dismiss all alerts
    @MainActor
    public func dismissAllAlerts() {
        let count = activeAlerts.count
        activeAlerts.removeAll()
        logDebug("✅ Dismissed \(count) alerts")
    }

    // MARK: - Alert Queries

    /// Get active alerts
    ///
    /// - Returns: Array of active alerts
    public func getActiveAlerts() -> [Alert] {
        activeAlerts
    }

    /// Get active alerts by type
    ///
    /// - Parameter type: Alert type
    /// - Returns: Array of active alerts of specified type
    public func getActiveAlerts(ofType type: AlertType) -> [Alert] {
        activeAlerts.filter { $0.type == type }
    }

    /// Get active alerts by severity
    ///
    /// - Parameter severity: Alert severity
    /// - Returns: Array of active alerts of specified severity
    public func getActiveAlerts(bySeverity severity: AlertSeverity) -> [Alert] {
        activeAlerts.filter { $0.severity == severity }
    }

    /// Get alert history
    ///
    /// - Parameter limit: Maximum number of alerts to return
    /// - Returns: Array of historical alerts
    public func getAlertHistory(limit: Int = 100) -> [Alert] {
        Array(alertHistory.suffix(limit))
    }

    // MARK: - Notification

    private func sendNotification(for alert: Alert) {
        Task {
            do {
                try await notificationManager.scheduleLocalNotification(
                    identifier: alert.id.uuidString,
                    title: alert.title,
                    body: alert.message,
                    timeInterval: 0.1 // Send immediately
                )
            } catch {
                logDebug("❌ Failed to send notification: \(error)")
            }
        }
    }

    // MARK: - Persistence

    private func saveConfigurations() {
        if let encoded = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(encoded, forKey: "AlertConfigurations")
            logDebug("💾 Alert configurations saved")
        }
    }

    private func loadConfigurations() {
        if let data = UserDefaults.standard.data(forKey: "AlertConfigurations"),
           let decoded = try? JSONDecoder().decode(AlertConfigurations.self, from: data) {
            self.configurations = decoded
            logDebug("📂 Alert configurations loaded")
        } else {
            logDebug("ℹ️ Using default alert configurations")
        }
    }

    // MARK: - Helpers

    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[AlertConfiguration] \(message)")
    }

    deinit {
        alertCheckTimer?.invalidate()
    }
}

// MARK: - Alert Configurations

/// Alert configuration thresholds
public struct AlertConfigurations: Codable {
    // Crash Alerts
    public var crashAlertsEnabled: Bool = true
    public var crashRateThreshold: Double = 0.01 // 1%

    // Performance Alerts
    public var performanceAlertsEnabled: Bool = true
    public var appStartTimeThreshold: TimeInterval = 3.0 // 3 seconds
    public var screenLoadTimeThreshold: TimeInterval = 2.0 // 2 seconds
    public var apiResponseTimeThreshold: TimeInterval = 5.0 // 5 seconds

    // Revenue Alerts
    public var revenueAlertsEnabled: Bool = true
    public var revenueThreshold: Double = 100.0 // $100 minimum daily

    // User Feedback Alerts
    public var feedbackAlertsEnabled: Bool = true
    public var userFeedbackThreshold: Double = 3.5 // 3.5 stars minimum
}

// MARK: - Alert Model

/// Alert model
public struct Alert: Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: AlertType
    public let severity: AlertSeverity
    public let title: String
    public let message: String
    public let timestamp: Date
    public var metadata: [String: String]?

    public init(
        id: UUID = UUID(),
        type: AlertType,
        severity: AlertSeverity,
        title: String,
        message: String,
        timestamp: Date = Date(),
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Alert Types

/// Alert type
public enum AlertType: String, Codable, CaseIterable {
    case crashRateExceeded = "crash_rate_exceeded"
    case performanceDegraded = "performance_degraded"
    case revenueBelowThreshold = "revenue_below_threshold"
    case userFeedbackLow = "user_feedback_low"
    case apiFailure = "api_failure"
    case dataCorruption = "data_corruption"
    case securityThreat = "security_threat"
    case customAlert = "custom_alert"
}

/// Alert severity
public enum AlertSeverity: String, Codable, Comparable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"

    public static func < (lhs: AlertSeverity, rhs: AlertSeverity) -> Bool {
        let order: [AlertSeverity] = [.info, .warning, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// Performance metric types
public enum PerformanceMetric: String, Codable {
    case appStartTime = "app_start_time"
    case screenLoadTime = "screen_load_time"
    case apiResponseTime = "api_response_time"
}

// MARK: - Convenience Alert Factory

public extension Alert {
    /// Create crash rate exceeded alert
    static func crashRateExceeded(rate: Double) -> Alert {
        Alert(
            type: .crashRateExceeded,
            severity: .critical,
            title: "Crash Rate Exceeded",
            message: "App crash rate (\(String(format: "%.2f", rate * 100))%) exceeded threshold",
            metadata: ["crash_rate": String(format: "%.4f", rate)]
        )
    }

    /// Create performance degraded alert
    static func performanceDegraded(metric: PerformanceMetric, value: TimeInterval) -> Alert {
        Alert(
            type: .performanceDegraded,
            severity: .warning,
            title: "Performance Degraded",
            message: "\(metric.rawValue) exceeded threshold: \(String(format: "%.2f", value))s",
            metadata: [
                "metric": metric.rawValue,
                "value": String(format: "%.2f", value)
            ]
        )
    }

    /// Create revenue below threshold alert
    static func revenueBelowThreshold(current: Double, threshold: Double) -> Alert {
        Alert(
            type: .revenueBelowThreshold,
            severity: .warning,
            title: "Revenue Below Threshold",
            message: "Current revenue ($\(String(format: "%.2f", current))) below threshold ($\(String(format: "%.2f", threshold)))",
            metadata: [
                "current": String(format: "%.2f", current),
                "threshold": String(format: "%.2f", threshold)
            ]
        )
    }

    /// Create user feedback low alert
    static func userFeedbackLow(rating: Double) -> Alert {
        Alert(
            type: .userFeedbackLow,
            severity: .warning,
            title: "User Feedback Low",
            message: "Average user rating (\(String(format: "%.1f", rating)) stars) below threshold",
            metadata: ["rating": String(format: "%.1f", rating)]
        )
    }
}
