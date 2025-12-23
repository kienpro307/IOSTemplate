import Foundation

// MARK: - Feature Flag Manager + Gradual Rollout

/// Extension for FeatureFlagManager to support gradual rollout
///
/// **Phase 9 - Task 9.2.2**: Feature Iterations - Gradual Rollout Support
///
/// This extension adds percentage-based feature rollout functionality
/// to the existing FeatureFlagManager, enabling gradual feature releases.
///
/// **Usage Example**:
/// ```swift
/// // Start rollout at 10%
/// FeatureFlagManager.shared.setFeatureEnabled("new_feature", percentage: 0.1)
///
/// // Increase to 50%
/// FeatureFlagManager.shared.setFeatureEnabled("new_feature", percentage: 0.5)
///
/// // Full rollout
/// FeatureFlagManager.shared.setFeatureEnabled("new_feature", percentage: 1.0)
/// ```
///
extension FeatureFlagManager {

    // MARK: - Rollout Support

    /// Set feature enabled for a percentage of users
    ///
    /// Uses consistent hashing to ensure same user always gets same result
    ///
    /// - Parameters:
    ///   - feature: Feature name (String)
    ///   - percentage: Percentage of users (0.0 - 1.0)
    public func setFeatureEnabled(_ feature: String, percentage: Double) {
        // Clamp percentage to valid range
        let validPercentage = max(0.0, min(1.0, percentage))

        // Store in UserDefaults for persistence
        let key = "rollout_percentage_\(feature)"
        UserDefaults.standard.set(validPercentage, forKey: key)

        #if DEBUG
        print("[FeatureFlags] 🎲 Rollout set for '\(feature)': \(Int(validPercentage * 100))%")
        #endif
    }

    /// Check if feature is enabled for current user based on rollout percentage
    ///
    /// Uses device UUID for consistent hashing
    ///
    /// - Parameter feature: Feature name
    /// - Returns: true if feature is enabled for this user
    public func isEnabledWithRollout(_ feature: String) -> Bool {
        // Get rollout percentage
        let key = "rollout_percentage_\(feature)"
        let percentage = UserDefaults.standard.double(forKey: key)

        // If no rollout configured, return false
        guard percentage > 0 else { return false }

        // If 100% rollout, always return true
        if percentage >= 1.0 { return true }

        // Use device UUID for consistent hashing
        let deviceID = getDeviceID()
        let hash = calculateHash(for: feature, userID: deviceID)

        // Check if hash falls within percentage
        let threshold = Int(percentage * 100)
        let userBucket = hash % 100

        return userBucket < threshold
    }

    /// Get rollout percentage for a feature
    ///
    /// - Parameter feature: Feature name
    /// - Returns: Current rollout percentage (0.0 - 1.0)
    public func getRolloutPercentage(for feature: String) -> Double {
        let key = "rollout_percentage_\(feature)"
        return UserDefaults.standard.double(forKey: key)
    }

    /// Clear rollout configuration for a feature
    ///
    /// - Parameter feature: Feature name
    public func clearRollout(for feature: String) {
        let key = "rollout_percentage_\(feature)"
        UserDefaults.standard.removeObject(forKey: key)
        #if DEBUG
        print("[FeatureFlags] 🧹 Rollout cleared for '\(feature)'")
        #endif
    }

    // MARK: - User Bucketing

    /// Calculate consistent hash for user and feature
    ///
    /// Same user + same feature = same bucket (deterministic)
    ///
    /// - Parameters:
    ///   - feature: Feature name
    ///   - userID: User identifier
    /// - Returns: Hash value (0-99)
    private func calculateHash(for feature: String, userID: String) -> Int {
        let combined = "\(feature)_\(userID)"
        var hash = 0

        for char in combined.utf8 {
            hash = ((hash << 5) &- hash) &+ Int(char)
        }

        return abs(hash) % 100
    }

    /// Get persistent device ID
    ///
    /// Creates and stores a UUID if not exists
    ///
    /// - Returns: Device identifier
    private func getDeviceID() -> String {
        let key = "device_rollout_id"

        if let existingID = UserDefaults.standard.string(forKey: key) {
            return existingID
        }

        // Create new ID
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }

    // MARK: - Rollout Statistics

    /// Get all active rollouts
    ///
    /// - Returns: Dictionary of feature names and their rollout percentages
    public func getAllRollouts() -> [String: Double] {
        var rollouts: [String: Double] = [:]

        // Scan UserDefaults for rollout keys
        if let defaults = UserDefaults.standard.dictionaryRepresentation() as? [String: Any] {
            for (key, value) in defaults {
                if key.hasPrefix("rollout_percentage_"),
                   let percentage = value as? Double,
                   percentage > 0 {
                    let feature = key.replacingOccurrences(of: "rollout_percentage_", with: "")
                    rollouts[feature] = percentage
                }
            }
        }

        return rollouts
    }

    /// Get rollout status report
    ///
    /// - Returns: Formatted report string
    public func getRolloutReport() -> String {
        let rollouts = getAllRollouts()

        var report = "🎲 FEATURE ROLLOUT STATUS\n"
        report += "========================\n\n"

        if rollouts.isEmpty {
            report += "No active rollouts\n"
        } else {
            report += "Active Rollouts (\(rollouts.count)):\n"
            for (feature, percentage) in rollouts.sorted(by: { $0.key < $1.key }) {
                let percentDisplay = Int(percentage * 100)
                let bar = progressBar(percentage: percentage, width: 20)
                report += "  • \(feature): \(bar) \(percentDisplay)%\n"
            }
        }

        return report
    }

    /// Create visual progress bar
    ///
    /// - Parameters:
    ///   - percentage: Percentage (0.0 - 1.0)
    ///   - width: Bar width in characters
    /// - Returns: Progress bar string
    private func progressBar(percentage: Double, width: Int) -> String {
        let filled = Int(percentage * Double(width))
        let empty = width - filled

        let filledBar = String(repeating: "█", count: filled)
        let emptyBar = String(repeating: "░", count: empty)

        return "[\(filledBar)\(emptyBar)]"
    }
}

// MARK: - Dynamic Feature Flag with Rollout

/// Dynamic feature flag that supports rollout percentages
public struct DynamicFeatureFlag {
    public let name: String
    private let manager: FeatureFlagManager

    public init(name: String, manager: FeatureFlagManager = .shared) {
        self.name = name
        self.manager = manager
    }

    /// Check if enabled for current user
    public var isEnabled: Bool {
        manager.isEnabledWithRollout(name)
    }

    /// Get rollout percentage
    public var rolloutPercentage: Double {
        manager.getRolloutPercentage(for: name)
    }

    /// Set rollout percentage
    public func setRollout(percentage: Double) {
        manager.setFeatureEnabled(name, percentage: percentage)
    }

    /// Clear rollout
    public func clearRollout() {
        manager.clearRollout(for: name)
    }
}
