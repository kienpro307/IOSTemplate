import XCTest
@testable import iOSTemplate

/// Tests for AlertConfigurationService
///
/// **Phase 9 - Task 9.1.2**: Alert Configuration Tests
///
final class AlertConfigurationTests: XCTestCase {

    var sut: AlertConfigurationService!

    override func setUp() {
        super.setUp()
        sut = AlertConfigurationService.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testServiceInitialization() {
        XCTAssertNotNil(sut, "AlertConfigurationService should initialize")
        XCTAssertNotNil(sut.configurations, "Configurations should be initialized")
    }

    // MARK: - Crash Alert Tests

    func testConfigureCrashAlert() {
        // Given
        let threshold = 0.02 // 2%

        // When
        sut.configureCrashAlert(threshold: threshold, enabled: true)

        // Then
        XCTAssertEqual(sut.configurations.crashRateThreshold, threshold)
        XCTAssertTrue(sut.configurations.crashAlertsEnabled)
    }

    func testShouldTriggerCrashAlert() {
        // Given
        sut.configureCrashAlert(threshold: 0.01, enabled: true)

        // When
        let shouldTrigger = sut.shouldTriggerCrashAlert(crashRate: 0.02)

        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger when crash rate exceeds threshold")
    }

    func testShouldNotTriggerCrashAlert() {
        // Given
        sut.configureCrashAlert(threshold: 0.05, enabled: true)

        // When
        let shouldTrigger = sut.shouldTriggerCrashAlert(crashRate: 0.01)

        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger when crash rate below threshold")
    }

    func testCrashAlertDisabled() {
        // Given
        sut.configureCrashAlert(threshold: 0.01, enabled: false)

        // When
        let shouldTrigger = sut.shouldTriggerCrashAlert(crashRate: 0.02)

        // Then
        XCTAssertFalse(shouldTrigger, "Should not trigger when alerts disabled")
    }

    // MARK: - Performance Alert Tests

    func testConfigurePerformanceAlert() {
        // Given
        let threshold: TimeInterval = 3.0

        // When
        sut.configurePerformanceAlert(
            threshold: threshold,
            metric: .appStartTime,
            enabled: true
        )

        // Then
        XCTAssertEqual(sut.configurations.appStartTimeThreshold, threshold)
        XCTAssertTrue(sut.configurations.performanceAlertsEnabled)
    }

    func testShouldTriggerPerformanceAlert() {
        // Given
        sut.configurePerformanceAlert(threshold: 2.0, metric: .screenLoadTime, enabled: true)

        // When
        let shouldTrigger = sut.shouldTriggerPerformanceAlert(
            value: 3.0,
            metric: .screenLoadTime
        )

        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger when value exceeds threshold")
    }

    // MARK: - Revenue Alert Tests

    func testConfigureRevenueAlert() {
        // Given
        let threshold = 100.0

        // When
        sut.configureRevenueAlert(threshold: threshold, enabled: true)

        // Then
        XCTAssertEqual(sut.configurations.revenueThreshold, threshold)
        XCTAssertTrue(sut.configurations.revenueAlertsEnabled)
    }

    func testShouldTriggerRevenueAlert() {
        // Given
        sut.configureRevenueAlert(threshold: 100.0, enabled: true)

        // When
        let shouldTrigger = sut.shouldTriggerRevenueAlert(revenue: 50.0)

        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger when revenue below threshold")
    }

    // MARK: - User Feedback Alert Tests

    func testConfigureUserFeedbackAlert() {
        // Given
        let threshold = 3.5

        // When
        sut.configureUserFeedbackAlert(threshold: threshold, enabled: true)

        // Then
        XCTAssertEqual(sut.configurations.userFeedbackThreshold, threshold)
        XCTAssertTrue(sut.configurations.feedbackAlertsEnabled)
    }

    func testShouldTriggerUserFeedbackAlert() {
        // Given
        sut.configureUserFeedbackAlert(threshold: 3.5, enabled: true)

        // When
        let shouldTrigger = sut.shouldTriggerUserFeedbackAlert(rating: 3.0)

        // Then
        XCTAssertTrue(shouldTrigger, "Should trigger when rating below threshold")
    }

    // MARK: - Alert Management Tests

    @MainActor
    func testTriggerAlert() async {
        // Given
        let alert = Alert.crashRateExceeded(rate: 0.02)

        // When
        sut.triggerAlert(alert)

        // Then
        let activeAlerts = sut.getActiveAlerts()
        XCTAssertEqual(activeAlerts.count, 1, "Should have one active alert")
        XCTAssertEqual(activeAlerts.first?.type, .crashRateExceeded)
    }

    @MainActor
    func testDismissAlert() async {
        // Given
        let alert = Alert.crashRateExceeded(rate: 0.02)
        sut.triggerAlert(alert)

        // When
        sut.dismissAlert(alert.id)

        // Then
        let activeAlerts = sut.getActiveAlerts()
        XCTAssertEqual(activeAlerts.count, 0, "Should have no active alerts")
    }

    @MainActor
    func testDismissAllAlerts() async {
        // Given
        sut.triggerAlert(Alert.crashRateExceeded(rate: 0.02))
        sut.triggerAlert(Alert.userFeedbackLow(rating: 3.0))

        // When
        sut.dismissAllAlerts()

        // Then
        let activeAlerts = sut.getActiveAlerts()
        XCTAssertEqual(activeAlerts.count, 0, "Should have no active alerts")
    }

    @MainActor
    func testGetActiveAlertsByType() async {
        // Given
        sut.triggerAlert(Alert.crashRateExceeded(rate: 0.02))
        sut.triggerAlert(Alert.userFeedbackLow(rating: 3.0))

        // When
        let crashAlerts = sut.getActiveAlerts(ofType: .crashRateExceeded)

        // Then
        XCTAssertEqual(crashAlerts.count, 1, "Should have one crash alert")
        XCTAssertEqual(crashAlerts.first?.type, .crashRateExceeded)
    }

    @MainActor
    func testGetActiveAlertsBySeverity() async {
        // Given
        sut.triggerAlert(Alert.crashRateExceeded(rate: 0.02)) // critical
        sut.triggerAlert(Alert.userFeedbackLow(rating: 3.0)) // warning

        // When
        let criticalAlerts = sut.getActiveAlerts(bySeverity: .critical)

        // Then
        XCTAssertEqual(criticalAlerts.count, 1, "Should have one critical alert")
        XCTAssertEqual(criticalAlerts.first?.severity, .critical)
    }

    // MARK: - Alert Factory Tests

    func testCreateCrashRateAlert() {
        // When
        let alert = Alert.crashRateExceeded(rate: 0.05)

        // Then
        XCTAssertEqual(alert.type, .crashRateExceeded)
        XCTAssertEqual(alert.severity, .critical)
        XCTAssertTrue(alert.title.contains("Crash Rate"))
    }

    func testCreatePerformanceAlert() {
        // When
        let alert = Alert.performanceDegraded(metric: .appStartTime, value: 5.0)

        // Then
        XCTAssertEqual(alert.type, .performanceDegraded)
        XCTAssertEqual(alert.severity, .warning)
        XCTAssertTrue(alert.title.contains("Performance"))
    }

    func testCreateRevenueAlert() {
        // When
        let alert = Alert.revenueBelowThreshold(current: 50.0, threshold: 100.0)

        // Then
        XCTAssertEqual(alert.type, .revenueBelowThreshold)
        XCTAssertEqual(alert.severity, .warning)
        XCTAssertTrue(alert.title.contains("Revenue"))
    }

    func testCreateUserFeedbackAlert() {
        // When
        let alert = Alert.userFeedbackLow(rating: 3.0)

        // Then
        XCTAssertEqual(alert.type, .userFeedbackLow)
        XCTAssertEqual(alert.severity, .warning)
        XCTAssertTrue(alert.title.contains("Feedback"))
    }

    // MARK: - Alert Severity Tests

    func testAlertSeverityComparison() {
        // Given
        let info = AlertSeverity.info
        let warning = AlertSeverity.warning
        let critical = AlertSeverity.critical

        // Then
        XCTAssertTrue(info < warning, "Info should be less than warning")
        XCTAssertTrue(warning < critical, "Warning should be less than critical")
        XCTAssertTrue(info < critical, "Info should be less than critical")
    }
}
