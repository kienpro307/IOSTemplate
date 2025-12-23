import Foundation
import Combine

// MARK: - Feature Iteration Manager

/// Service quản lý feature iterations và continuous improvement
///
/// **Phase 9 - Task 9.2.2**: Feature Iterations
///
/// Manager này handle:
/// - Feedback collection
/// - Feature prioritization
/// - A/B testing setup
/// - Gradual rollout
///
/// **Usage Example**:
/// ```swift
/// @Injected var featureIteration: FeatureIterationManager
///
/// // Collect user feedback
/// featureIteration.collectFeedback(
///     feature: "dark_mode",
///     rating: 5,
///     comment: "Love it!"
/// )
///
/// // Setup A/B test
/// featureIteration.setupABTest(
///     name: "new_checkout_flow",
///     variants: ["control", "variant_a", "variant_b"]
/// )
///
/// // Start gradual rollout
/// featureIteration.startGradualRollout(
///     feature: "premium_feature",
///     initialPercentage: 10
/// )
/// ```
///
public final class FeatureIterationManager: ObservableObject {

    // MARK: - Properties

    /// Shared instance
    public static let shared = FeatureIterationManager()

    /// Feature feedback collection
    @Published public private(set) var feedbackItems: [FeatureFeedback] = []

    /// Active A/B tests
    @Published public private(set) var activeABTests: [ABTest] = []

    /// Feature rollouts
    @Published public private(set) var featureRollouts: [FeatureRollout] = []

    /// Feature priorities
    @Published public private(set) var featurePriorities: [FeaturePriority] = []

    /// Analytics service
    private let analytics: AnalyticsServiceProtocol

    /// Crashlytics service
    private let crashlytics: CrashlyticsServiceProtocol

    /// Remote config service
    private let remoteConfig: RemoteConfigServiceProtocol

    /// Feature flag manager
    private let featureFlags: FeatureFlagManager

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
        analytics: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        crashlytics: CrashlyticsServiceProtocol = FirebaseCrashlyticsService.shared,
        remoteConfig: RemoteConfigServiceProtocol = FirebaseRemoteConfigService.shared,
        featureFlags: FeatureFlagManager = FeatureFlagManager.shared
    ) {
        self.analytics = analytics
        self.crashlytics = crashlytics
        self.remoteConfig = remoteConfig
        self.featureFlags = featureFlags

        setupFeatureIterationManager()
    }

    // MARK: - Setup

    private func setupFeatureIterationManager() {
        logDebug("🔄 Setting up Feature Iteration Manager")

        // Load saved data
        loadFeedback()
        loadABTests()
        loadRollouts()
        loadPriorities()
    }

    // MARK: - Feedback Collection

    /// Collect user feedback for a feature
    ///
    /// - Parameters:
    ///   - feature: Feature name
    ///   - rating: User rating (1-5)
    ///   - comment: Optional comment
    ///   - metadata: Additional metadata
    @MainActor
    public func collectFeedback(
        feature: String,
        rating: Int,
        comment: String? = nil,
        metadata: [String: String]? = nil
    ) {
        let feedback = FeatureFeedback(
            id: UUID(),
            feature: feature,
            rating: rating,
            comment: comment,
            timestamp: Date(),
            metadata: metadata
        )

        feedbackItems.append(feedback)

        // Track in analytics
        analytics.trackEvent(
            AnalyticsEvent(
                name: "feature_feedback_collected",
                parameters: [
                    "feature": feature,
                    "rating": rating,
                    "has_comment": comment != nil
                ]
            )
        )

        logDebug("📝 Feedback collected for \(feature): \(rating) stars")

        // Log to Crashlytics for monitoring
        crashlytics.log("Feedback: \(feature) - \(rating) stars")

        saveFeedback()

        // Auto-update feature priorities based on feedback
        updateFeaturePriorities()
    }

    /// Get average rating for a feature
    ///
    /// - Parameter feature: Feature name
    /// - Returns: Average rating or nil if no feedback
    public func getAverageRating(for feature: String) -> Double? {
        let featureFeedback = feedbackItems.filter { $0.feature == feature }
        guard !featureFeedback.isEmpty else { return nil }

        let sum = featureFeedback.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(featureFeedback.count)
    }

    /// Get feedback summary for a feature
    ///
    /// - Parameter feature: Feature name
    /// - Returns: Feedback summary
    public func getFeedbackSummary(for feature: String) -> FeedbackSummary {
        let featureFeedback = feedbackItems.filter { $0.feature == feature }

        let totalCount = featureFeedback.count
        let averageRating = getAverageRating(for: feature) ?? 0.0

        let ratingDistribution = Dictionary(grouping: featureFeedback) { $0.rating }
            .mapValues { $0.count }

        return FeedbackSummary(
            feature: feature,
            totalFeedbackCount: totalCount,
            averageRating: averageRating,
            ratingDistribution: ratingDistribution,
            recentFeedback: Array(featureFeedback.suffix(10))
        )
    }

    // MARK: - Feature Prioritization

    /// Add or update feature priority
    ///
    /// - Parameters:
    ///   - feature: Feature name
    ///   - priority: Priority level
    ///   - justification: Reason for priority
    @MainActor
    public func setFeaturePriority(
        feature: String,
        priority: Priority,
        justification: String
    ) {
        // Remove existing if present
        featurePriorities.removeAll { $0.feature == feature }

        let featurePriority = FeaturePriority(
            id: UUID(),
            feature: feature,
            priority: priority,
            justification: justification,
            lastUpdated: Date()
        )

        featurePriorities.append(featurePriority)
        featurePriorities.sort { $0.priority > $1.priority }

        logDebug("🎯 Feature priority set: \(feature) - \(priority.rawValue)")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "feature_priority_set",
                parameters: [
                    "feature": feature,
                    "priority": priority.rawValue
                ]
            )
        )

        savePriorities()
    }

    /// Update feature priorities based on feedback
    @MainActor
    private func updateFeaturePriorities() {
        // Auto-prioritize features with low ratings
        let featureRatings = Dictionary(grouping: feedbackItems) { $0.feature }
            .mapValues { items -> Double in
                let sum = items.reduce(0) { $0 + $1.rating }
                return Double(sum) / Double(items.count)
            }

        for (feature, avgRating) in featureRatings where avgRating < 3.0 {
            // Low rating = high priority for improvement
            if !featurePriorities.contains(where: { $0.feature == feature && $0.priority == .critical }) {
                setFeaturePriority(
                    feature: feature,
                    priority: .high,
                    justification: "Low user rating: \(String(format: "%.1f", avgRating)) stars"
                )
            }
        }
    }

    /// Get prioritized features list
    ///
    /// - Returns: Array of features sorted by priority
    public func getPrioritizedFeatures() -> [FeaturePriority] {
        featurePriorities.sorted { $0.priority > $1.priority }
    }

    // MARK: - A/B Testing

    /// Setup A/B test
    ///
    /// - Parameters:
    ///   - name: Test name
    ///   - variants: Array of variant names
    ///   - targetPercentage: Percentage of users to include (0.0 - 1.0)
    ///   - description: Test description
    @MainActor
    public func setupABTest(
        name: String,
        variants: [String],
        targetPercentage: Double = 1.0,
        description: String
    ) {
        guard variants.count >= 2 else {
            logDebug("⚠️ A/B test requires at least 2 variants")
            return
        }

        let test = ABTest(
            id: UUID(),
            name: name,
            variants: variants,
            targetPercentage: targetPercentage,
            description: description,
            startDate: Date(),
            status: .active
        )

        activeABTests.append(test)

        logDebug("🧪 A/B test setup: \(name) with \(variants.count) variants")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "ab_test_setup",
                parameters: [
                    "test_name": name,
                    "variants_count": variants.count,
                    "target_percentage": targetPercentage
                ]
            )
        )

        saveABTests()
    }

    /// Get variant for user in A/B test
    ///
    /// Assigns user to consistent variant using hash
    ///
    /// - Parameters:
    ///   - testName: Test name
    ///   - userID: User ID
    /// - Returns: Assigned variant or nil if test not found
    public func getVariant(for testName: String, userID: String) -> String? {
        guard let test = activeABTests.first(where: { $0.name == testName && $0.status == .active }) else {
            return nil
        }

        // Use hash to assign consistent variant
        let hash = abs(userID.hashValue) % 100
        let threshold = Int(test.targetPercentage * 100)

        guard hash < threshold else {
            return nil // User not in test
        }

        // Assign to variant based on hash
        let variantIndex = hash % test.variants.count
        let variant = test.variants[variantIndex]

        // Track assignment
        analytics.trackEvent(
            AnalyticsEvent(
                name: "ab_test_variant_assigned",
                parameters: [
                    "test_name": testName,
                    "variant": variant
                ]
            )
        )

        return variant
    }

    /// Track A/B test conversion
    ///
    /// - Parameters:
    ///   - testName: Test name
    ///   - variant: Variant that converted
    ///   - value: Optional conversion value
    public func trackConversion(
        for testName: String,
        variant: String,
        value: Double? = nil
    ) {
        var parameters: [String: Any] = [
            "test_name": testName,
            "variant": variant
        ]

        if let value = value {
            parameters["value"] = value
        }

        analytics.trackEvent(
            AnalyticsEvent(
                name: "ab_test_conversion",
                parameters: parameters
            )
        )

        logDebug("✅ A/B test conversion tracked: \(testName) - \(variant)")
    }

    /// Stop A/B test
    ///
    /// - Parameter testName: Test name
    @MainActor
    public func stopABTest(_ testName: String) {
        if let index = activeABTests.firstIndex(where: { $0.name == testName }) {
            activeABTests[index].status = .completed
            activeABTests[index].endDate = Date()

            logDebug("⏹️ A/B test stopped: \(testName)")

            analytics.trackEvent(
                AnalyticsEvent(
                    name: "ab_test_stopped",
                    parameters: ["test_name": testName]
                )
            )

            saveABTests()
        }
    }

    // MARK: - Gradual Rollout

    /// Start gradual rollout for a feature
    ///
    /// - Parameters:
    ///   - feature: Feature name
    ///   - initialPercentage: Initial rollout percentage (0.0 - 1.0)
    ///   - description: Rollout description
    @MainActor
    public func startGradualRollout(
        feature: String,
        initialPercentage: Double,
        description: String
    ) {
        let rollout = FeatureRollout(
            id: UUID(),
            feature: feature,
            currentPercentage: initialPercentage,
            targetPercentage: 1.0,
            startDate: Date(),
            status: .inProgress,
            description: description
        )

        featureRollouts.append(rollout)

        // Enable feature flag with percentage
        featureFlags.setFeatureEnabled(feature, percentage: initialPercentage)

        logDebug("🚀 Gradual rollout started: \(feature) at \(Int(initialPercentage * 100))%")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "gradual_rollout_started",
                parameters: [
                    "feature": feature,
                    "initial_percentage": initialPercentage
                ]
            )
        )

        saveRollouts()
    }

    /// Increase rollout percentage
    ///
    /// - Parameters:
    ///   - feature: Feature name
    ///   - newPercentage: New rollout percentage
    @MainActor
    public func increaseRolloutPercentage(
        feature: String,
        newPercentage: Double
    ) {
        guard let index = featureRollouts.firstIndex(where: { $0.feature == feature }) else {
            logDebug("⚠️ Rollout not found for feature: \(feature)")
            return
        }

        let oldPercentage = featureRollouts[index].currentPercentage
        featureRollouts[index].currentPercentage = min(newPercentage, 1.0)
        featureRollouts[index].lastUpdated = Date()

        // Update feature flag
        featureFlags.setFeatureEnabled(feature, percentage: newPercentage)

        logDebug("📈 Rollout increased: \(feature) from \(Int(oldPercentage * 100))% to \(Int(newPercentage * 100))%")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "rollout_percentage_increased",
                parameters: [
                    "feature": feature,
                    "old_percentage": oldPercentage,
                    "new_percentage": newPercentage
                ]
            )
        )

        // Complete rollout if at 100%
        if newPercentage >= 1.0 {
            featureRollouts[index].status = .completed
            logDebug("✅ Rollout completed: \(feature)")
        }

        saveRollouts()
    }

    /// Rollback feature rollout
    ///
    /// - Parameter feature: Feature name
    @MainActor
    public func rollbackFeature(_ feature: String) {
        guard let index = featureRollouts.firstIndex(where: { $0.feature == feature }) else {
            return
        }

        featureRollouts[index].status = .rolledBack
        featureRollouts[index].lastUpdated = Date()

        // Disable feature flag
        featureFlags.setFeatureEnabled(feature, percentage: 0.0)

        logDebug("⏪ Feature rolled back: \(feature)")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "feature_rolled_back",
                parameters: ["feature": feature]
            )
        )

        crashlytics.log("⚠️ Feature rolled back: \(feature)")

        saveRollouts()
    }

    // MARK: - Reporting

    /// Get feature iteration report
    ///
    /// - Returns: Formatted report
    public func getFeatureIterationReport() -> String {
        var report = "🔄 FEATURE ITERATION REPORT\n"
        report += "===========================\n\n"

        // Feedback Summary
        report += "📝 FEEDBACK SUMMARY\n"
        report += "  Total Feedback: \(feedbackItems.count)\n"
        let avgOverallRating = feedbackItems.isEmpty ? 0.0 :
            Double(feedbackItems.reduce(0) { $0 + $1.rating }) / Double(feedbackItems.count)
        report += "  Average Rating: \(String(format: "%.1f", avgOverallRating)) stars\n\n"

        // Feature Priorities
        report += "🎯 FEATURE PRIORITIES (\(featurePriorities.count))\n"
        for priority in getPrioritizedFeatures().prefix(5) {
            let emoji = priority.priority == .critical ? "🔴" :
                       priority.priority == .high ? "🟠" : "🟢"
            report += "  \(emoji) \(priority.feature) - \(priority.justification)\n"
        }
        report += "\n"

        // Active A/B Tests
        report += "🧪 ACTIVE A/B TESTS (\(activeABTests.filter { $0.status == .active }.count))\n"
        for test in activeABTests where test.status == .active {
            report += "  • \(test.name) - \(test.variants.count) variants\n"
        }
        report += "\n"

        // Feature Rollouts
        report += "🚀 FEATURE ROLLOUTS (\(featureRollouts.filter { $0.status == .inProgress }.count))\n"
        for rollout in featureRollouts where rollout.status == .inProgress {
            report += "  • \(rollout.feature) - \(Int(rollout.currentPercentage * 100))%\n"
        }

        return report
    }

    // MARK: - Persistence

    private func saveFeedback() {
        if let encoded = try? JSONEncoder().encode(feedbackItems) {
            UserDefaults.standard.set(encoded, forKey: "FeatureFeedback")
        }
    }

    private func loadFeedback() {
        if let data = UserDefaults.standard.data(forKey: "FeatureFeedback"),
           let decoded = try? JSONDecoder().decode([FeatureFeedback].self, from: data) {
            self.feedbackItems = decoded
        }
    }

    private func saveABTests() {
        if let encoded = try? JSONEncoder().encode(activeABTests) {
            UserDefaults.standard.set(encoded, forKey: "ABTests")
        }
    }

    private func loadABTests() {
        if let data = UserDefaults.standard.data(forKey: "ABTests"),
           let decoded = try? JSONDecoder().decode([ABTest].self, from: data) {
            self.activeABTests = decoded
        }
    }

    private func saveRollouts() {
        if let encoded = try? JSONEncoder().encode(featureRollouts) {
            UserDefaults.standard.set(encoded, forKey: "FeatureRollouts")
        }
    }

    private func loadRollouts() {
        if let data = UserDefaults.standard.data(forKey: "FeatureRollouts"),
           let decoded = try? JSONDecoder().decode([FeatureRollout].self, from: data) {
            self.featureRollouts = decoded
        }
    }

    private func savePriorities() {
        if let encoded = try? JSONEncoder().encode(featurePriorities) {
            UserDefaults.standard.set(encoded, forKey: "FeaturePriorities")
        }
    }

    private func loadPriorities() {
        if let data = UserDefaults.standard.data(forKey: "FeaturePriorities"),
           let decoded = try? JSONDecoder().decode([FeaturePriority].self, from: data) {
            self.featurePriorities = decoded
        }
    }

    // MARK: - Helpers

    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[FeatureIteration] \(message)")
    }
}

// MARK: - Models

/// Feature feedback model
public struct FeatureFeedback: Identifiable, Codable {
    public let id: UUID
    public let feature: String
    public let rating: Int // 1-5
    public let comment: String?
    public let timestamp: Date
    public let metadata: [String: String]?
}

/// Feedback summary
public struct FeedbackSummary {
    public let feature: String
    public let totalFeedbackCount: Int
    public let averageRating: Double
    public let ratingDistribution: [Int: Int]
    public let recentFeedback: [FeatureFeedback]
}

/// Feature priority
public struct FeaturePriority: Identifiable, Codable {
    public let id: UUID
    public let feature: String
    public let priority: Priority
    public let justification: String
    public let lastUpdated: Date
}

/// Priority level
public enum Priority: String, Codable, Comparable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        let order: [Priority] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// A/B Test model
public struct ABTest: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let variants: [String]
    public let targetPercentage: Double
    public let description: String
    public let startDate: Date
    public var endDate: Date?
    public var status: ABTestStatus
}

/// A/B test status
public enum ABTestStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

/// Feature rollout model
public struct FeatureRollout: Identifiable, Codable {
    public let id: UUID
    public let feature: String
    public var currentPercentage: Double
    public let targetPercentage: Double
    public let startDate: Date
    public var lastUpdated: Date = Date()
    public var status: RolloutStatus
    public let description: String
}

/// Rollout status
public enum RolloutStatus: String, Codable {
    case inProgress = "in_progress"
    case completed = "completed"
    case rolledBack = "rolled_back"
    case paused = "paused"
}
