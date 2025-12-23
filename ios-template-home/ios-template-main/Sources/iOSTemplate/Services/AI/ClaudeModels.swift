import Foundation

// MARK: - Claude Models & Types

/// Claude (Anthropic) model types
public enum ClaudeModel: String, Codable {
    case claude3Opus = "claude-3-opus-20240229"
    case claude3Sonnet = "claude-3-sonnet-20240229"
    case claude3Haiku = "claude-3-haiku-20240307"
    case claude35Sonnet = "claude-3-5-sonnet-20241022"

    /// Token limit for the model
    public var maxTokens: Int {
        switch self {
        case .claude3Opus, .claude3Sonnet, .claude3Haiku, .claude35Sonnet:
            return 200000 // 200K context window
        }
    }

    /// Cost per 1M tokens (input/output) in USD
    public var costPer1MTokens: (input: Double, output: Double) {
        switch self {
        case .claude3Opus: return (15.0, 75.0)
        case .claude3Sonnet: return (3.0, 15.0)
        case .claude35Sonnet: return (3.0, 15.0)
        case .claude3Haiku: return (0.25, 1.25)
        }
    }

    /// Model tier
    public var tier: String {
        switch self {
        case .claude3Opus, .claude35Sonnet: return "premium"
        case .claude3Sonnet: return "standard"
        case .claude3Haiku: return "fast"
        }
    }
}

/// Message role in conversation
public enum ClaudeRole: String, Codable {
    case user
    case assistant
}

/// Content block type
public enum ClaudeContentType: String, Codable {
    case text
    case image
}

/// Content block
public struct ClaudeContent: Codable, Equatable {
    public let type: ClaudeContentType
    public let text: String?
    public let source: ClaudeImageSource?

    public init(text: String) {
        self.type = .text
        self.text = text
        self.source = nil
    }

    public init(imageSource: ClaudeImageSource) {
        self.type = .image
        self.text = nil
        self.source = imageSource
    }
}

/// Image source for vision
public struct ClaudeImageSource: Codable, Equatable {
    public let type: String // "base64"
    public let mediaType: String // "image/jpeg", "image/png", etc.
    public let data: String // Base64 encoded image

    public init(mediaType: String, data: String) {
        self.type = "base64"
        self.mediaType = mediaType
        self.data = data
    }
}

/// Chat message
public struct ClaudeMessage: Codable, Equatable {
    public let role: ClaudeRole
    public let content: [ClaudeContent]

    public init(role: ClaudeRole, content: String) {
        self.role = role
        self.content = [ClaudeContent(text: content)]
    }

    public init(role: ClaudeRole, content: [ClaudeContent]) {
        self.role = role
        self.content = content
    }

    /// Get text content
    public var text: String {
        content.compactMap { $0.text }.joined(separator: "\n")
    }
}

// MARK: - Request Models

/// Messages API request
public struct ClaudeMessagesRequest: Codable {
    public let model: ClaudeModel
    public let messages: [ClaudeMessage]
    public let maxTokens: Int
    public let system: String?
    public let temperature: Double?
    public let topP: Double?
    public let topK: Int?
    public let stream: Bool?
    public let stopSequences: [String]?
    public let metadata: ClaudeMetadata?

    enum CodingKeys: String, CodingKey {
        case model, messages, system, temperature, stream, metadata
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case topK = "top_k"
        case stopSequences = "stop_sequences"
    }

    public init(
        model: ClaudeModel,
        messages: [ClaudeMessage],
        maxTokens: Int = 4096,
        system: String? = nil,
        temperature: Double? = 1.0,
        topP: Double? = nil,
        topK: Int? = nil,
        stream: Bool? = false,
        stopSequences: [String]? = nil,
        metadata: ClaudeMetadata? = nil
    ) {
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.system = system
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.stream = stream
        self.stopSequences = stopSequences
        self.metadata = metadata
    }
}

/// Request metadata
public struct ClaudeMetadata: Codable, Equatable {
    public let userId: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }

    public init(userId: String?) {
        self.userId = userId
    }
}

// MARK: - Response Models

/// Token usage
public struct ClaudeUsage: Codable, Equatable {
    public let inputTokens: Int
    public let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }

    /// Total tokens
    public var totalTokens: Int {
        inputTokens + outputTokens
    }

    /// Calculate cost based on model
    public func cost(for model: ClaudeModel) -> Double {
        let (inputCost, outputCost) = model.costPer1MTokens
        let promptCost = Double(inputTokens) / 1_000_000.0 * inputCost
        let completionCost = Double(outputTokens) / 1_000_000.0 * outputCost
        return promptCost + completionCost
    }
}

/// Stop reason
public enum ClaudeStopReason: String, Codable {
    case endTurn = "end_turn"
    case maxTokens = "max_tokens"
    case stopSequence = "stop_sequence"
}

/// Messages API response
public struct ClaudeMessagesResponse: Codable, Equatable {
    public let id: String
    public let type: String
    public let role: ClaudeRole
    public let content: [ClaudeContent]
    public let model: String
    public let stopReason: ClaudeStopReason?
    public let stopSequence: String?
    public let usage: ClaudeUsage

    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model, usage
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }

    /// Get text content
    public var text: String {
        content.compactMap { $0.text }.joined(separator: "\n")
    }
}

/// Error response from Claude
public struct ClaudeErrorResponse: Codable, Error {
    public let type: String
    public let error: ClaudeErrorDetail
}

public struct ClaudeErrorDetail: Codable {
    public let type: String
    public let message: String
}

// MARK: - Streaming Models

/// Stream event type
public enum ClaudeStreamEventType: String, Codable {
    case messageStart = "message_start"
    case contentBlockStart = "content_block_start"
    case contentBlockDelta = "content_block_delta"
    case contentBlockStop = "content_block_stop"
    case messageDelta = "message_delta"
    case messageStop = "message_stop"
    case ping
    case error
}

/// Stream event
public struct ClaudeStreamEvent: Codable {
    public let type: ClaudeStreamEventType
    public let message: ClaudeMessagesResponse?
    public let index: Int?
    public let contentBlock: ClaudeContent?
    public let delta: ClaudeDelta?

    enum CodingKeys: String, CodingKey {
        case type, message, index, delta
        case contentBlock = "content_block"
    }
}

/// Delta for streaming
public struct ClaudeDelta: Codable {
    public let type: String?
    public let text: String?
    public let stopReason: ClaudeStopReason?
    public let stopSequence: String?
    public let usage: ClaudeUsage?

    enum CodingKeys: String, CodingKey {
        case type, text, usage
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }
}

// MARK: - Configuration

/// Claude configuration
public struct ClaudeConfig {
    public let apiKey: String
    public let defaultModel: ClaudeModel
    public let defaultMaxTokens: Int
    public let defaultTemperature: Double
    public let timeoutInterval: TimeInterval
    public let apiVersion: String

    public init(
        apiKey: String,
        defaultModel: ClaudeModel = .claude35Sonnet,
        defaultMaxTokens: Int = 4096,
        defaultTemperature: Double = 1.0,
        timeoutInterval: TimeInterval = 60,
        apiVersion: String = "2023-06-01"
    ) {
        self.apiKey = apiKey
        self.defaultModel = defaultModel
        self.defaultMaxTokens = defaultMaxTokens
        self.defaultTemperature = defaultTemperature
        self.timeoutInterval = timeoutInterval
        self.apiVersion = apiVersion
    }

    /// Load from environment
    public static func loadFromEnvironment() -> ClaudeConfig? {
        guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] else {
            return nil
        }

        return ClaudeConfig(apiKey: apiKey)
    }
}

// MARK: - Rate Limiting

/// Rate limit for Claude
public struct ClaudeRateLimit {
    public let requestsPerMinute: Int
    public let tokensPerMinute: Int
    public var currentRequests: Int
    public var currentTokens: Int
    public var windowStart: Date

    public init(
        requestsPerMinute: Int = 50,
        tokensPerMinute: Int = 100000
    ) {
        self.requestsPerMinute = requestsPerMinute
        self.tokensPerMinute = tokensPerMinute
        self.currentRequests = 0
        self.currentTokens = 0
        self.windowStart = Date()
    }

    /// Check if can make request
    public mutating func canMakeRequest(estimatedTokens: Int) -> Bool {
        resetIfNeeded()

        let canRequest = currentRequests < requestsPerMinute
        let canUseTokens = currentTokens + estimatedTokens <= tokensPerMinute

        return canRequest && canUseTokens
    }

    /// Record request
    public mutating func recordRequest(tokens: Int) {
        resetIfNeeded()
        currentRequests += 1
        currentTokens += tokens
    }

    /// Reset window if needed
    private mutating func resetIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(windowStart) >= 60 {
            currentRequests = 0
            currentTokens = 0
            windowStart = now
        }
    }
}
