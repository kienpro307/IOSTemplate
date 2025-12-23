import Foundation

// MARK: - ML Services Aggregator
// This file aggregates all ML service protocols and types for easy import

/// Re-export all ML service protocols
public protocol MLServices {
    var coreML: CoreMLManagerProtocol { get }
    var vision: VisionServiceProtocol { get }
}

/// Default implementation using singletons
public struct DefaultMLServices: MLServices {
    public var coreML: CoreMLManagerProtocol { CoreMLManager.shared }
    public var vision: VisionServiceProtocol { VisionService.shared }

    public init() {}
}

/// Convenience access
public extension MLServices {
    static var `default`: MLServices {
        DefaultMLServices()
    }
}
