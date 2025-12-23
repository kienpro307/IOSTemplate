import XCTest
@testable import iOSTemplate

/// Tests for MonitoringDashboardManager
///
/// **Phase 9 - Task 9.1.1**: Monitoring Dashboard Tests
///
final class MonitoringDashboardTests: XCTestCase {

    var sut: MonitoringDashboardManager!

    override func setUp() {
        super.setUp()
        sut = MonitoringDashboardManager.shared
    }

    override func tearDown() {
        sut.stopMonitoring()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testManagerInitialization() {
        XCTAssertNotNil(sut, "MonitoringDashboardManager should initialize")
        XCTAssertNotNil(sut.currentMetrics, "Current metrics should be initialized")
    }

    // MARK: - Monitoring Control Tests

    func testStartMonitoring() {
        // Given
        XCTAssertFalse(sut.isMonitoringActive, "Monitoring should not be active initially")

        // When
        sut.startMonitoring()

        // Then
        XCTAssertTrue(sut.isMonitoringActive, "Monitoring should be active after start")
    }

    func testStopMonitoring() {
        // Given
        sut.startMonitoring()
        XCTAssertTrue(sut.isMonitoringActive)

        // When
        sut.stopMonitoring()

        // Then
        XCTAssertFalse(sut.isMonitoringActive, "Monitoring should not be active after stop")
    }

    func testStartMonitoringMultipleTimes() {
        // Given & When
        sut.startMonitoring()
        sut.startMonitoring()

        // Then
        XCTAssertTrue(sut.isMonitoringActive, "Monitoring should remain active")
    }

    // MARK: - Metrics Tests

    func testGetCurrentMetrics() {
        // When
        let metrics = sut.getCurrentMetrics()

        // Then
        XCTAssertNotNil(metrics, "Should return current metrics")
        XCTAssertNotNil(metrics.crashlytics, "Should have crashlytics metrics")
        XCTAssertNotNil(metrics.analytics, "Should have analytics metrics")
        XCTAssertNotNil(metrics.performance, "Should have performance metrics")
        XCTAssertNotNil(metrics.revenue, "Should have revenue metrics")
    }

    func testGetCrashlyticsDashboard() {
        // When
        let dashboard = sut.getCrashlyticsDashboard()

        // Then
        XCTAssertNotNil(dashboard, "Should return crashlytics dashboard")
        XCTAssertTrue(dashboard.isEnabled, "Crashlytics should be enabled by default")
    }

    func testGetAnalyticsDashboard() {
        // When
        let dashboard = sut.getAnalyticsDashboard()

        // Then
        XCTAssertNotNil(dashboard, "Should return analytics dashboard")
        XCTAssertTrue(dashboard.isEnabled, "Analytics should be enabled by default")
    }

    func testGetPerformanceDashboard() {
        // When
        let dashboard = sut.getPerformanceDashboard()

        // Then
        XCTAssertNotNil(dashboard, "Should return performance dashboard")
        XCTAssertTrue(dashboard.isEnabled, "Performance should be enabled by default")
    }

    func testGetRevenueDashboard() {
        // When
        let dashboard = sut.getRevenueDashboard()

        // Then
        XCTAssertNotNil(dashboard, "Should return revenue dashboard")
    }

    // MARK: - Dashboard Summary Tests

    func testGetDashboardSummary() {
        // When
        let summary = sut.getDashboardSummary()

        // Then
        XCTAssertFalse(summary.isEmpty, "Summary should not be empty")
        XCTAssertTrue(summary.contains("MONITORING DASHBOARD"), "Summary should contain title")
        XCTAssertTrue(summary.contains("CRASHLYTICS"), "Summary should contain Crashlytics section")
        XCTAssertTrue(summary.contains("ANALYTICS"), "Summary should contain Analytics section")
        XCTAssertTrue(summary.contains("PERFORMANCE"), "Summary should contain Performance section")
        XCTAssertTrue(summary.contains("REVENUE"), "Summary should contain Revenue section")
    }

    // MARK: - Dashboard Type Tests

    func testDashboardTypeAllCases() {
        // When
        let allTypes = DashboardType.allCases

        // Then
        XCTAssertEqual(allTypes.count, 5, "Should have 5 dashboard types")
        XCTAssertTrue(allTypes.contains(.crashlytics), "Should include crashlytics")
        XCTAssertTrue(allTypes.contains(.analytics), "Should include analytics")
        XCTAssertTrue(allTypes.contains(.performance), "Should include performance")
        XCTAssertTrue(allTypes.contains(.revenue), "Should include revenue")
        XCTAssertTrue(allTypes.contains(.overview), "Should include overview")
    }

    // MARK: - Event Tracking Tests

    func testTrackDashboardViewed() {
        // Given
        let dashboardType = DashboardType.crashlytics

        // When & Then
        XCTAssertNoThrow(sut.trackDashboardViewed(dashboardType))
    }

    func testTrackMetricThresholdExceeded() {
        // Given
        let metric = "crash_rate"
        let value = 0.05
        let threshold = 0.01

        // When & Then
        XCTAssertNoThrow(sut.trackMetricThresholdExceeded(
            metric: metric,
            value: value,
            threshold: threshold
        ))
    }
}
