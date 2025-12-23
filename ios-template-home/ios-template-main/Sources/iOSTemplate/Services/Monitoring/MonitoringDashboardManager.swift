import Foundation
import Combine

// MARK: - Monitoring Dashboard Manager

/// Service quản lý tất cả monitoring dashboards
///
/// **Phase 9 - Task 9.1.1**: Setup Dashboards
///
/// Manager này consolidate tất cả monitoring services:
/// - Crashlytics Dashboard
/// - Analytics Dashboard
/// - Performance Dashboard
/// - Revenue Dashboard
///
/// **Usage Example**:
/// ```swift
/// @Injected var monitoring: MonitoringDashboardManager
///
/// // Get current metrics
/// let metrics = await monitoring.getCurrentMetrics()
///
/// // Start monitoring session
/// monitoring.startMonitoring()
///
/// // Get dashboard summary
/// let summary = monitoring.getDashboardSummary()
/// ```
///
public final class MonitoringDashboardManager: ObservableObject {

    // MARK: - Properties

    /// Shared instance
    public static let shared = MonitoringDashboardManager()

    /// Crashlytics service
    private let crashlytics: CrashlyticsServiceProtocol

    /// Analytics service
    private let analytics: AnalyticsServiceProtocol

    /// Performance service
    private let performance: FirebasePerformanceService

    /// Current metrics
    @Published public private(set) var currentMetrics: MonitoringMetrics

    /// Is monitoring active
    @Published public private(set) var isMonitoringActive: Bool = false

    /// Monitoring session start time
    private var sessionStartTime: Date?

    /// Metrics update timer
    private var metricsTimer: Timer?

    /// Debug mode
    private var isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    // MARK: - Initialization

    public init(
        crashlytics: CrashlyticsServiceProtocol = FirebaseCrashlyticsService.shared,
        analytics: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        performance: FirebasePerformanceService = FirebasePerformanceService.shared
    ) {
        self.crashlytics = crashlytics
        self.analytics = analytics
        self.performance = performance
        self.currentMetrics = MonitoringMetrics()

        setupMonitoring()
    }

    // MARK: - Setup

    /// Setup monitoring
    private func setupMonitoring() {
        logDebug("🎯 Setting up Monitoring Dashboard Manager")

        // Auto-start monitoring in production
        #if !DEBUG
        startMonitoring()
        #endif
    }

    // MARK: - Monitoring Control

    /// Start monitoring session
    ///
    /// Bắt đầu collect metrics từ tất cả services
    public func startMonitoring() {
        guard !isMonitoringActive else {
            logDebug("⚠️ Monitoring already active")
            return
        }

        isMonitoringActive = true
        sessionStartTime = Date()

        // Start metrics collection timer (every 60 seconds)
        metricsTimer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.updateMetrics()
            }
        }

        logDebug("✅ Monitoring started")

        // Track monitoring start
        analytics.trackEvent(
            AnalyticsEvent(
                name: "monitoring_session_started",
                parameters: ["timestamp": ISO8601DateFormatter().string(from: Date())]
            )
        )
    }

    /// Stop monitoring session
    public func stopMonitoring() {
        guard isMonitoringActive else { return }

        isMonitoringActive = false
        metricsTimer?.invalidate()
        metricsTimer = nil

        // Calculate session duration
        if let startTime = sessionStartTime {
            let duration = Date().timeIntervalSince(startTime)
            logDebug("⏹️ Monitoring stopped. Duration: \(Int(duration))s")

            analytics.trackEvent(
                AnalyticsEvent(
                    name: "monitoring_session_stopped",
                    parameters: [
                        "duration": Int(duration),
                        "timestamp": ISO8601DateFormatter().string(from: Date())
                    ]
                )
            )
        }

        sessionStartTime = nil
    }

    // MARK: - Metrics Collection

    /// Update current metrics
    @MainActor
    private func updateMetrics() async {
        logDebug("📊 Updating metrics...")

        // Update crash metrics
        currentMetrics.crashlytics.activeTraces = performance.getActiveTracesCount()
        currentMetrics.crashlytics.lastUpdateTime = Date()

        // Update performance metrics
        currentMetrics.performance.activeTraces = performance.getActiveTracesCount()
        currentMetrics.performance.activeHTTPMetrics = performance.getActiveHTTPMetricsCount()
        currentMetrics.performance.lastUpdateTime = Date()

        // Update analytics metrics
        currentMetrics.analytics.lastUpdateTime = Date()

        logDebug("✅ Metrics updated")
    }

    /// Get current metrics
    ///
    /// - Returns: Current monitoring metrics
    public func getCurrentMetrics() -> MonitoringMetrics {
        currentMetrics
    }

    /// Get dashboard summary
    ///
    /// Summary của tất cả monitoring data
    ///
    /// - Returns: Dashboard summary string
    public func getDashboardSummary() -> String {
        var summary = "📊 MONITORING DASHBOARD\n"
        summary += "========================\n\n"

        // Crashlytics
        summary += "💥 CRASHLYTICS\n"
        summary += "  Status: \(currentMetrics.crashlytics.isEnabled ? "✅ Active" : "❌ Inactive")\n"
        summary += "  Active Traces: \(currentMetrics.crashlytics.activeTraces)\n"
        summary += "  Last Update: \(formatDate(currentMetrics.crashlytics.lastUpdateTime))\n\n"

        // Analytics
        summary += "📈 ANALYTICS\n"
        summary += "  Status: \(currentMetrics.analytics.isEnabled ? "✅ Active" : "❌ Inactive")\n"
        summary += "  Events Tracked: \(currentMetrics.analytics.eventsTrackedCount)\n"
        summary += "  Last Update: \(formatDate(currentMetrics.analytics.lastUpdateTime))\n\n"

        // Performance
        summary += "⚡ PERFORMANCE\n"
        summary += "  Status: \(currentMetrics.performance.isEnabled ? "✅ Active" : "❌ Inactive")\n"
        summary += "  Active Traces: \(currentMetrics.performance.activeTraces)\n"
        summary += "  HTTP Metrics: \(currentMetrics.performance.activeHTTPMetrics)\n"
        summary += "  Last Update: \(formatDate(currentMetrics.performance.lastUpdateTime))\n\n"

        // Revenue (placeholder)
        summary += "💰 REVENUE\n"
        summary += "  Status: \(currentMetrics.revenue.isEnabled ? "✅ Active" : "❌ Inactive")\n"
        summary += "  Total Revenue: $\(String(format: "%.2f", currentMetrics.revenue.totalRevenue))\n"
        summary += "  Transactions: \(currentMetrics.revenue.transactionCount)\n\n"

        // Session Info
        if let startTime = sessionStartTime {
            let duration = Date().timeIntervalSince(startTime)
            summary += "⏱️ SESSION INFO\n"
            summary += "  Status: \(isMonitoringActive ? "🟢 Active" : "🔴 Stopped")\n"
            summary += "  Duration: \(formatDuration(duration))\n"
        }

        return summary
    }

    // MARK: - Dashboard Accessors

    /// Get Crashlytics dashboard data
    public func getCrashlyticsDashboard() -> CrashlyticsDashboard {
        currentMetrics.crashlytics
    }

    /// Get Analytics dashboard data
    public func getAnalyticsDashboard() -> AnalyticsDashboard {
        currentMetrics.analytics
    }

    /// Get Performance dashboard data
    public func getPerformanceDashboard() -> PerformanceDashboard {
        currentMetrics.performance
    }

    /// Get Revenue dashboard data
    public func getRevenueDashboard() -> RevenueDashboard {
        currentMetrics.revenue
    }

    // MARK: - Event Tracking

    /// Track dashboard viewed event
    ///
    /// - Parameter dashboardType: Type of dashboard viewed
    public func trackDashboardViewed(_ dashboardType: DashboardType) {
        analytics.trackEvent(
            AnalyticsEvent(
                name: "dashboard_viewed",
                parameters: [
                    "dashboard_type": dashboardType.rawValue,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        )

        logDebug("👀 Dashboard viewed: \(dashboardType.rawValue)")
    }

    /// Track metric threshold exceeded
    ///
    /// - Parameters:
    ///   - metric: Metric name
    ///   - value: Current value
    ///   - threshold: Threshold value
    public func trackMetricThresholdExceeded(
        metric: String,
        value: Double,
        threshold: Double
    ) {
        analytics.trackEvent(
            AnalyticsEvent(
                name: "metric_threshold_exceeded",
                parameters: [
                    "metric": metric,
                    "value": value,
                    "threshold": threshold,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        )

        crashlytics.log("⚠️ Metric threshold exceeded: \(metric) = \(value) (threshold: \(threshold))")
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[MonitoringDashboard] \(message)")
    }

    deinit {
        stopMonitoring()
    }
}

// MARK: - Monitoring Metrics

/// Container cho tất cả monitoring metrics
public struct MonitoringMetrics {
    public var crashlytics: CrashlyticsDashboard = CrashlyticsDashboard()
    public var analytics: AnalyticsDashboard = AnalyticsDashboard()
    public var performance: PerformanceDashboard = PerformanceDashboard()
    public var revenue: RevenueDashboard = RevenueDashboard()
}

// MARK: - Dashboard Models

/// Crashlytics Dashboard Data
public struct CrashlyticsDashboard {
    public var isEnabled: Bool = true
    public var crashFreeRate: Double = 0.0
    public var totalCrashes: Int = 0
    public var totalNonFatalErrors: Int = 0
    public var activeTraces: Int = 0
    public var lastUpdateTime: Date?
}

/// Analytics Dashboard Data
public struct AnalyticsDashboard {
    public var isEnabled: Bool = true
    public var activeUsers: Int = 0
    public var eventsTrackedCount: Int = 0
    public var topEvents: [String] = []
    public var sessionCount: Int = 0
    public var averageSessionDuration: TimeInterval = 0
    public var lastUpdateTime: Date?
}

/// Performance Dashboard Data
public struct PerformanceDashboard {
    public var isEnabled: Bool = true
    public var activeTraces: Int = 0
    public var activeHTTPMetrics: Int = 0
    public var averageAppStartTime: TimeInterval = 0
    public var averageScreenLoadTime: TimeInterval = 0
    public var networkSuccessRate: Double = 0.0
    public var lastUpdateTime: Date?
}

/// Revenue Dashboard Data
public struct RevenueDashboard {
    public var isEnabled: Bool = true
    public var totalRevenue: Double = 0.0
    public var transactionCount: Int = 0
    public var averageRevenuePerUser: Double = 0.0
    public var topProducts: [String] = []
    public var lastUpdateTime: Date?
}

// MARK: - Dashboard Types

/// Dashboard type enum
public enum DashboardType: String, CaseIterable {
    case crashlytics = "crashlytics"
    case analytics = "analytics"
    case performance = "performance"
    case revenue = "revenue"
    case overview = "overview"
}
