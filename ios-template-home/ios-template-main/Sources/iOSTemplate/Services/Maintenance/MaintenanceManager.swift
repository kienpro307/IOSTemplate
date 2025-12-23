import Foundation
import Combine

// MARK: - Maintenance Manager

/// Service quản lý app maintenance và updates
///
/// **Phase 9 - Task 9.2.1**: Regular Updates
///
/// Manager này handle:
/// - Dependency updates
/// - Security patches
/// - OS compatibility
/// - Bug fixes process
///
/// **Usage Example**:
/// ```swift
/// @Injected var maintenance: MaintenanceManager
///
/// // Check for updates
/// await maintenance.checkForUpdates()
///
/// // Get maintenance status
/// let status = maintenance.getMaintenanceStatus()
///
/// // Schedule maintenance window
/// maintenance.scheduleMaintenanceWindow(date: tomorrow)
/// ```
///
public final class MaintenanceManager: ObservableObject {

    // MARK: - Properties

    /// Shared instance
    public static let shared = MaintenanceManager()

    /// Current maintenance status
    @Published public private(set) var status: MaintenanceStatus

    /// Available updates
    @Published public private(set) var availableUpdates: [Update] = []

    /// Maintenance schedule
    @Published public private(set) var scheduledMaintenance: [MaintenanceWindow] = []

    /// Update check timer
    private var updateCheckTimer: Timer?

    /// Analytics service
    private let analytics: AnalyticsServiceProtocol

    /// Crashlytics service
    private let crashlytics: CrashlyticsServiceProtocol

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
        crashlytics: CrashlyticsServiceProtocol = FirebaseCrashlyticsService.shared
    ) {
        self.analytics = analytics
        self.crashlytics = crashlytics
        self.status = MaintenanceStatus()

        setupMaintenanceManager()
    }

    // MARK: - Setup

    private func setupMaintenanceManager() {
        logDebug("🔧 Setting up Maintenance Manager")

        // Load saved status
        loadMaintenanceStatus()

        // Start periodic update checks (daily)
        startUpdateChecks()

        // Check OS compatibility
        checkOSCompatibility()
    }

    /// Start periodic update checks
    private func startUpdateChecks() {
        // Check once on launch
        Task {
            await checkForUpdates()
        }

        // Schedule daily checks
        updateCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 86400.0, // 24 hours
            repeats: true
        ) { [weak self] _ in
            Task {
                await self?.checkForUpdates()
            }
        }
    }

    // MARK: - Update Management

    /// Check for available updates
    @MainActor
    public func checkForUpdates() async {
        logDebug("🔍 Checking for updates...")

        status.lastUpdateCheckTime = Date()

        // Check dependency updates
        await checkDependencyUpdates()

        // Check security patches
        await checkSecurityPatches()

        // Check for bug fixes
        await checkBugFixes()

        logDebug("✅ Update check completed. Found \(availableUpdates.count) updates")

        // Track analytics
        analytics.trackEvent(
            AnalyticsEvent(
                name: "maintenance_update_check",
                parameters: [
                    "updates_found": availableUpdates.count,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        )

        saveMaintenanceStatus()
    }

    /// Check dependency updates
    private func checkDependencyUpdates() async {
        logDebug("📦 Checking dependency updates...")

        // This would integrate with actual package managers
        // For now, it's a placeholder structure

        // Example: Check Swift Package Manager dependencies
        let dependencies = getCurrentDependencies()

        for dependency in dependencies {
            if let latestVersion = await getLatestVersion(for: dependency) {
                if dependency.needsUpdate(to: latestVersion) {
                    let update = Update(
                        id: UUID(),
                        type: .dependency,
                        name: dependency.name,
                        currentVersion: dependency.version,
                        newVersion: latestVersion,
                        priority: .medium,
                        description: "Update \(dependency.name) to \(latestVersion)"
                    )
                    availableUpdates.append(update)
                }
            }
        }
    }

    /// Check security patches
    private func checkSecurityPatches() async {
        logDebug("🔒 Checking security patches...")

        // This would integrate with security advisories
        // For now, it's a placeholder structure

        // Track security check
        analytics.trackEvent(
            AnalyticsEvent(
                name: "security_check_performed",
                parameters: ["timestamp": ISO8601DateFormatter().string(from: Date())]
            )
        )
    }

    /// Check bug fixes
    private func checkBugFixes() async {
        logDebug("🐛 Checking bug fixes...")

        // This would integrate with issue tracking systems
        // For now, it's a placeholder structure
    }

    // MARK: - OS Compatibility

    /// Check OS compatibility
    public func checkOSCompatibility() {
        let currentOS = ProcessInfo.processInfo.operatingSystemVersion
        let minimumSupported = getMinimumSupportedOSVersion()

        status.isOSCompatible = isVersionSupported(current: currentOS, minimum: minimumSupported)
        status.currentOSVersion = formatOSVersion(currentOS)
        status.minimumOSVersion = formatOSVersion(minimumSupported)

        if !status.isOSCompatible {
            logDebug("⚠️ OS version not compatible")

            // Create alert
            let alert = Update(
                id: UUID(),
                type: .osCompatibility,
                name: "OS Update Required",
                currentVersion: status.currentOSVersion,
                newVersion: status.minimumOSVersion,
                priority: .critical,
                description: "Your iOS version is below the minimum supported version"
            )
            availableUpdates.append(alert)

            crashlytics.log("⚠️ OS Compatibility: Current \(status.currentOSVersion), Minimum \(status.minimumOSVersion)")
        } else {
            logDebug("✅ OS version compatible: \(status.currentOSVersion)")
        }
    }

    /// Get minimum supported OS version
    private func getMinimumSupportedOSVersion() -> OperatingSystemVersion {
        // This should be configured based on your app's deployment target
        return OperatingSystemVersion(majorVersion: 15, minorVersion: 0, patchVersion: 0)
    }

    /// Check if OS version is supported
    private func isVersionSupported(
        current: OperatingSystemVersion,
        minimum: OperatingSystemVersion
    ) -> Bool {
        if current.majorVersion > minimum.majorVersion {
            return true
        } else if current.majorVersion == minimum.majorVersion {
            if current.minorVersion > minimum.minorVersion {
                return true
            } else if current.minorVersion == minimum.minorVersion {
                return current.patchVersion >= minimum.patchVersion
            }
        }
        return false
    }

    /// Format OS version
    private func formatOSVersion(_ version: OperatingSystemVersion) -> String {
        "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    // MARK: - Maintenance Windows

    /// Schedule maintenance window
    ///
    /// - Parameters:
    ///   - date: Maintenance window start date
    ///   - duration: Duration in seconds
    ///   - description: Maintenance description
    public func scheduleMaintenanceWindow(
        date: Date,
        duration: TimeInterval = 3600, // 1 hour default
        description: String
    ) {
        let window = MaintenanceWindow(
            id: UUID(),
            startDate: date,
            duration: duration,
            description: description
        )

        scheduledMaintenance.append(window)
        scheduledMaintenance.sort { $0.startDate < $1.startDate }

        logDebug("📅 Maintenance scheduled: \(description) at \(date)")

        analytics.trackEvent(
            AnalyticsEvent(
                name: "maintenance_scheduled",
                parameters: [
                    "description": description,
                    "date": ISO8601DateFormatter().string(from: date)
                ]
            )
        )

        saveMaintenanceStatus()
    }

    /// Cancel maintenance window
    ///
    /// - Parameter id: Maintenance window ID
    public func cancelMaintenanceWindow(_ id: UUID) {
        scheduledMaintenance.removeAll { $0.id == id }
        logDebug("❌ Maintenance cancelled: \(id)")
        saveMaintenanceStatus()
    }

    /// Get upcoming maintenance windows
    ///
    /// - Returns: Array of upcoming maintenance windows
    public func getUpcomingMaintenanceWindows() -> [MaintenanceWindow] {
        let now = Date()
        return scheduledMaintenance.filter { $0.startDate > now }
    }

    /// Check if in maintenance mode
    ///
    /// - Returns: true if currently in maintenance window
    public func isInMaintenanceMode() -> Bool {
        let now = Date()
        return scheduledMaintenance.contains { window in
            let endDate = window.startDate.addingTimeInterval(window.duration)
            return now >= window.startDate && now <= endDate
        }
    }

    // MARK: - Update Application

    /// Apply update
    ///
    /// - Parameter update: Update to apply
    @MainActor
    public func applyUpdate(_ update: Update) async throws {
        logDebug("🔄 Applying update: \(update.name)")

        status.isUpdating = true

        do {
            // Track update start
            analytics.trackEvent(
                AnalyticsEvent(
                    name: "update_started",
                    parameters: [
                        "update_type": update.type.rawValue,
                        "update_name": update.name
                    ]
                )
            )

            // Simulate update process
            try await performUpdate(update)

            // Remove from available updates
            availableUpdates.removeAll { $0.id == update.id }

            // Track success
            status.lastUpdateTime = Date()
            status.isUpdating = false

            analytics.trackEvent(
                AnalyticsEvent(
                    name: "update_completed",
                    parameters: [
                        "update_type": update.type.rawValue,
                        "update_name": update.name
                    ]
                )
            )

            logDebug("✅ Update completed: \(update.name)")

        } catch {
            status.isUpdating = false

            crashlytics.recordError(error, userInfo: [
                "update_type": update.type.rawValue,
                "update_name": update.name
            ])

            logDebug("❌ Update failed: \(error.localizedDescription)")

            throw error
        }

        saveMaintenanceStatus()
    }

    /// Perform update (placeholder for actual update logic)
    private func performUpdate(_ update: Update) async throws {
        // This would contain actual update logic based on update type
        // For now, simulate with delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }

    // MARK: - Status & Reporting

    /// Get maintenance status
    ///
    /// - Returns: Current maintenance status
    public func getMaintenanceStatus() -> MaintenanceStatus {
        status
    }

    /// Get maintenance report
    ///
    /// - Returns: Formatted maintenance report
    public func getMaintenanceReport() -> String {
        var report = "🔧 MAINTENANCE REPORT\n"
        report += "====================\n\n"

        // Status
        report += "📊 Status\n"
        report += "  OS Compatible: \(status.isOSCompatible ? "✅" : "❌")\n"
        report += "  Current OS: \(status.currentOSVersion)\n"
        report += "  Minimum OS: \(status.minimumOSVersion)\n"
        report += "  Updating: \(status.isUpdating ? "🔄 Yes" : "❌ No")\n"
        report += "  Last Check: \(formatDate(status.lastUpdateCheckTime))\n"
        report += "  Last Update: \(formatDate(status.lastUpdateTime))\n\n"

        // Available Updates
        report += "📦 Available Updates (\(availableUpdates.count))\n"
        for update in availableUpdates {
            let priorityEmoji = update.priority == .critical ? "🔴" : update.priority == .high ? "🟠" : "🟢"
            report += "  \(priorityEmoji) \(update.name): \(update.currentVersion) → \(update.newVersion)\n"
        }

        // Scheduled Maintenance
        report += "\n📅 Scheduled Maintenance (\(scheduledMaintenance.count))\n"
        for window in scheduledMaintenance {
            report += "  • \(window.description) - \(formatDate(window.startDate))\n"
        }

        return report
    }

    // MARK: - Dependencies Helper

    private func getCurrentDependencies() -> [Dependency] {
        // This would parse Package.swift or similar
        // For now, return placeholder
        return [
            Dependency(name: "FirebaseAnalytics", version: "10.0.0"),
            Dependency(name: "FirebaseCrashlytics", version: "10.0.0"),
            Dependency(name: "FirebasePerformance", version: "10.0.0")
        ]
    }

    private func getLatestVersion(for dependency: Dependency) async -> String? {
        // This would query package registry
        // For now, return placeholder
        return nil
    }

    // MARK: - Persistence

    private func saveMaintenanceStatus() {
        if let encoded = try? JSONEncoder().encode(status) {
            UserDefaults.standard.set(encoded, forKey: "MaintenanceStatus")
        }
    }

    private func loadMaintenanceStatus() {
        if let data = UserDefaults.standard.data(forKey: "MaintenanceStatus"),
           let decoded = try? JSONDecoder().decode(MaintenanceStatus.self, from: data) {
            self.status = decoded
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func logDebug(_ message: String) {
        guard isDebugMode else { return }
        print("[Maintenance] \(message)")
    }

    deinit {
        updateCheckTimer?.invalidate()
    }
}

// MARK: - Maintenance Status

/// Maintenance status model
public struct MaintenanceStatus: Codable {
    public var isOSCompatible: Bool = true
    public var currentOSVersion: String = ""
    public var minimumOSVersion: String = ""
    public var isUpdating: Bool = false
    public var lastUpdateCheckTime: Date?
    public var lastUpdateTime: Date?
}

// MARK: - Update Model

/// Update model
public struct Update: Identifiable, Codable {
    public let id: UUID
    public let type: UpdateType
    public let name: String
    public let currentVersion: String
    public let newVersion: String
    public let priority: UpdatePriority
    public let description: String
    public var releaseNotes: String?
    public var isApplied: Bool = false

    public init(
        id: UUID = UUID(),
        type: UpdateType,
        name: String,
        currentVersion: String,
        newVersion: String,
        priority: UpdatePriority,
        description: String,
        releaseNotes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.currentVersion = currentVersion
        self.newVersion = newVersion
        self.priority = priority
        self.description = description
        self.releaseNotes = releaseNotes
    }
}

/// Update type
public enum UpdateType: String, Codable {
    case dependency = "dependency"
    case securityPatch = "security_patch"
    case bugFix = "bug_fix"
    case osCompatibility = "os_compatibility"
    case feature = "feature"
}

/// Update priority
public enum UpdatePriority: String, Codable, Comparable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"

    public static func < (lhs: UpdatePriority, rhs: UpdatePriority) -> Bool {
        let order: [UpdatePriority] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Maintenance Window

/// Scheduled maintenance window
public struct MaintenanceWindow: Identifiable, Codable {
    public let id: UUID
    public let startDate: Date
    public let duration: TimeInterval
    public let description: String

    public var endDate: Date {
        startDate.addingTimeInterval(duration)
    }
}

// MARK: - Dependency Model

/// Dependency model
struct Dependency {
    let name: String
    let version: String

    func needsUpdate(to newVersion: String) -> Bool {
        // Simple version comparison
        return version.compare(newVersion, options: .numeric) == .orderedAscending
    }
}
