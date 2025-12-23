import XCTest
@testable import iOSTemplate

/// Tests for FeatureIterationManager
///
/// **Phase 9 - Task 9.2.2**: Feature Iteration Tests
///
final class FeatureIterationTests: XCTestCase {

    var sut: FeatureIterationManager!

    override func setUp() {
        super.setUp()
        sut = FeatureIterationManager.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testManagerInitialization() {
        XCTAssertNotNil(sut, "FeatureIterationManager should initialize")
    }

    // MARK: - Feedback Collection Tests

    @MainActor
    func testCollectFeedback() async {
        // Given
        let feature = "dark_mode"
        let rating = 5

        // When
        sut.collectFeedback(feature: feature, rating: rating, comment: "Great!")

        // Then
        let avgRating = sut.getAverageRating(for: feature)
        XCTAssertEqual(avgRating, 5.0, "Average rating should be 5.0")
    }

    @MainActor
    func testGetAverageRating() async {
        // Given
        let feature = "test_feature"
        sut.collectFeedback(feature: feature, rating: 5)
        sut.collectFeedback(feature: feature, rating: 3)

        // When
        let avgRating = sut.getAverageRating(for: feature)

        // Then
        XCTAssertEqual(avgRating, 4.0, "Average should be (5+3)/2 = 4.0")
    }

    func testGetAverageRatingNoFeedback() {
        // When
        let avgRating = sut.getAverageRating(for: "nonexistent_feature")

        // Then
        XCTAssertNil(avgRating, "Should return nil for feature with no feedback")
    }

    @MainActor
    func testGetFeedbackSummary() async {
        // Given
        let feature = "test_feature"
        sut.collectFeedback(feature: feature, rating: 5)
        sut.collectFeedback(feature: feature, rating: 4)
        sut.collectFeedback(feature: feature, rating: 5)

        // When
        let summary = sut.getFeedbackSummary(for: feature)

        // Then
        XCTAssertEqual(summary.feature, feature)
        XCTAssertEqual(summary.totalFeedbackCount, 3)
        XCTAssertEqual(summary.averageRating, 4.666, accuracy: 0.01)
        XCTAssertEqual(summary.ratingDistribution[5], 2)
        XCTAssertEqual(summary.ratingDistribution[4], 1)
    }

    // MARK: - Feature Prioritization Tests

    @MainActor
    func testSetFeaturePriority() async {
        // Given
        let feature = "new_feature"
        let priority = Priority.high

        // When
        sut.setFeaturePriority(
            feature: feature,
            priority: priority,
            justification: "Important for users"
        )

        // Then
        let priorities = sut.getPrioritizedFeatures()
        XCTAssertTrue(priorities.contains(where: { $0.feature == feature }))
    }

    @MainActor
    func testGetPrioritizedFeatures() async {
        // Given
        sut.setFeaturePriority(feature: "low_priority", priority: .low, justification: "Test")
        sut.setFeaturePriority(feature: "high_priority", priority: .high, justification: "Test")
        sut.setFeaturePriority(feature: "critical_priority", priority: .critical, justification: "Test")

        // When
        let priorities = sut.getPrioritizedFeatures()

        // Then
        XCTAssertEqual(priorities.count, 3)
        XCTAssertEqual(priorities.first?.feature, "critical_priority", "Critical should be first")
        XCTAssertEqual(priorities.last?.feature, "low_priority", "Low should be last")
    }

    // MARK: - A/B Testing Tests

    @MainActor
    func testSetupABTest() async {
        // Given
        let testName = "checkout_flow_test"
        let variants = ["control", "variant_a", "variant_b"]

        // When
        sut.setupABTest(
            name: testName,
            variants: variants,
            targetPercentage: 1.0,
            description: "Test new checkout flow"
        )

        // Then
        let activeTests = sut.activeABTests
        XCTAssertTrue(activeTests.contains(where: { $0.name == testName }))
    }

    @MainActor
    func testGetVariantForUser() async {
        // Given
        let testName = "test_ab"
        sut.setupABTest(
            name: testName,
            variants: ["control", "variant_a"],
            targetPercentage: 1.0,
            description: "Test"
        )

        // When
        let variant = sut.getVariant(for: testName, userID: "user123")

        // Then
        XCTAssertNotNil(variant, "Should return a variant")
        XCTAssertTrue(["control", "variant_a"].contains(variant!))
    }

    @MainActor
    func testGetVariantConsistency() async {
        // Given
        let testName = "test_consistency"
        sut.setupABTest(
            name: testName,
            variants: ["control", "variant_a"],
            targetPercentage: 1.0,
            description: "Test"
        )

        // When
        let variant1 = sut.getVariant(for: testName, userID: "user456")
        let variant2 = sut.getVariant(for: testName, userID: "user456")

        // Then
        XCTAssertEqual(variant1, variant2, "Same user should get same variant")
    }

    @MainActor
    func testStopABTest() async {
        // Given
        let testName = "test_stop"
        sut.setupABTest(
            name: testName,
            variants: ["control", "variant_a"],
            targetPercentage: 1.0,
            description: "Test"
        )

        // When
        sut.stopABTest(testName)

        // Then
        let activeTests = sut.activeABTests
        let test = activeTests.first(where: { $0.name == testName })
        XCTAssertEqual(test?.status, .completed)
    }

    func testTrackConversion() async {
        // Given
        let testName = "conversion_test"
        await MainActor.run {
            sut.setupABTest(
                name: testName,
                variants: ["control", "variant_a"],
                targetPercentage: 1.0,
                description: "Test"
            )
        }

        // When & Then
        XCTAssertNoThrow(sut.trackConversion(for: testName, variant: "control", value: 9.99))
    }

    // MARK: - Gradual Rollout Tests

    @MainActor
    func testStartGradualRollout() async {
        // Given
        let feature = "premium_feature"
        let initialPercentage = 0.1

        // When
        sut.startGradualRollout(
            feature: feature,
            initialPercentage: initialPercentage,
            description: "Premium feature rollout"
        )

        // Then
        let rollouts = sut.featureRollouts
        let rollout = rollouts.first(where: { $0.feature == feature })
        XCTAssertNotNil(rollout)
        XCTAssertEqual(rollout?.currentPercentage, initialPercentage)
        XCTAssertEqual(rollout?.status, .inProgress)
    }

    @MainActor
    func testIncreaseRolloutPercentage() async {
        // Given
        let feature = "test_rollout"
        sut.startGradualRollout(
            feature: feature,
            initialPercentage: 0.1,
            description: "Test"
        )

        // When
        sut.increaseRolloutPercentage(feature: feature, newPercentage: 0.5)

        // Then
        let rollouts = sut.featureRollouts
        let rollout = rollouts.first(where: { $0.feature == feature })
        XCTAssertEqual(rollout?.currentPercentage, 0.5)
    }

    @MainActor
    func testCompleteRollout() async {
        // Given
        let feature = "complete_rollout"
        sut.startGradualRollout(
            feature: feature,
            initialPercentage: 0.5,
            description: "Test"
        )

        // When
        sut.increaseRolloutPercentage(feature: feature, newPercentage: 1.0)

        // Then
        let rollouts = sut.featureRollouts
        let rollout = rollouts.first(where: { $0.feature == feature })
        XCTAssertEqual(rollout?.status, .completed)
    }

    @MainActor
    func testRollbackFeature() async {
        // Given
        let feature = "rollback_test"
        sut.startGradualRollout(
            feature: feature,
            initialPercentage: 0.5,
            description: "Test"
        )

        // When
        sut.rollbackFeature(feature)

        // Then
        let rollouts = sut.featureRollouts
        let rollout = rollouts.first(where: { $0.feature == feature })
        XCTAssertEqual(rollout?.status, .rolledBack)
    }

    // MARK: - Reporting Tests

    func testGetFeatureIterationReport() {
        // When
        let report = sut.getFeatureIterationReport()

        // Then
        XCTAssertFalse(report.isEmpty)
        XCTAssertTrue(report.contains("FEATURE ITERATION REPORT"))
        XCTAssertTrue(report.contains("FEEDBACK SUMMARY"))
        XCTAssertTrue(report.contains("FEATURE PRIORITIES"))
        XCTAssertTrue(report.contains("ACTIVE A/B TESTS"))
        XCTAssertTrue(report.contains("FEATURE ROLLOUTS"))
    }

    // MARK: - Priority Comparison Tests

    func testPriorityComparison() {
        // Given
        let low = Priority.low
        let medium = Priority.medium
        let high = Priority.high
        let critical = Priority.critical

        // Then
        XCTAssertTrue(low < medium)
        XCTAssertTrue(medium < high)
        XCTAssertTrue(high < critical)
        XCTAssertTrue(low < critical)
    }
}
