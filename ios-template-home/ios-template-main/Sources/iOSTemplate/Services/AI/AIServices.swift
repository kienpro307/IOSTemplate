import Foundation

// MARK: - AI Services Aggregator
// This file aggregates all AI service protocols and types for easy import

/// Re-export all AI service protocols
public protocol AIServices {
    var openAI: OpenAIServiceProtocol { get }
    var claude: ClaudeServiceProtocol { get }
    var aiManager: AIManagerProtocol { get }
}

/// Default implementation using singletons
public struct DefaultAIServices: AIServices {
    public var openAI: OpenAIServiceProtocol { OpenAIService.shared }
    public var claude: ClaudeServiceProtocol { ClaudeService.shared }
    public var aiManager: AIManagerProtocol { AIManager.shared }

    public init() {}
}

/// Convenience access
public extension AIServices {
    static var `default`: AIServices {
        DefaultAIServices()
    }
}
