import Foundation

// MARK: - OpenAI Models & Types

/// OpenAI GPT model types
public enum OpenAIModel: String, Codable {
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo-preview"
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt35Turbo16k = "gpt-3.5-turbo-16k"

    /// Token limit for the model
    public var maxTokens: Int {
        switch self {
        case .gpt4: return 8192
        case .gpt4Turbo: return 128000
        case .gpt35Turbo: return 4096
        case .gpt35Turbo16k: return 16384
        }
    }

    /// Cost per 1K tokens (input/output) in USD
    public var costPer1KTokens: (input: Double, output: Double) {
        switch self {
        case .gpt4: return (0.03, 0.06)
        case .gpt4Turbo: return (0.01, 0.03)
        case .gpt35Turbo: return (0.0005, 0.0015)
        case .gpt35Turbo16k: return (0.003, 0.004)
        }
    }
}

/// Message role in conversation
public enum OpenAIRole: String, Codable {
    case system
    case user
    case assistant
    case function
}

/// Chat message
public struct OpenAIChatMessage: Codable, Equatable {
    public let role: OpenAIRole
    public let content: String
    public let name: String?

    public init(role: OpenAIRole, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }
}

/// Function definition for function calling
public struct OpenAIFunction: Codable {
    public let name: String
    public let description: String
    public let parameters: [String: Any]

    enum CodingKeys: String, CodingKey {
        case name, description, parameters
    }

    public init(name: String, description: String, parameters: [String: Any]) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        // Simplified - in production, properly decode Any
        parameters = [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        // Simplified - in production, properly encode Any
    }
}

extension OpenAIFunction: Equatable {
    public static func == (lhs: OpenAIFunction, rhs: OpenAIFunction) -> Bool {
        // Compare name and description only since [String: Any] cannot be compared
        return lhs.name == rhs.name && lhs.description == rhs.description
    }
}

// MARK: - Request Models

/// Chat completion request
public struct OpenAIChatCompletionRequest: Codable {
    public let model: OpenAIModel
    public let messages: [OpenAIChatMessage]
    public let temperature: Double?
    public let topP: Double?
    public let n: Int?
    public let stream: Bool?
    public let stop: [String]?
    public let maxTokens: Int?
    public let presencePenalty: Double?
    public let frequencyPenalty: Double?
    public let user: String?
    public let functions: [OpenAIFunction]?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, n, stream, stop, user, functions
        case topP = "top_p"
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
    }

    public init(
        model: OpenAIModel,
        messages: [OpenAIChatMessage],
        temperature: Double? = 0.7,
        topP: Double? = nil,
        n: Int? = 1,
        stream: Bool? = false,
        stop: [String]? = nil,
        maxTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        user: String? = nil,
        functions: [OpenAIFunction]? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.stream = stream
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.user = user
        self.functions = functions
    }
}

// MARK: - Response Models

/// Token usage information
public struct OpenAIUsage: Codable, Equatable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }

    /// Calculate cost based on model
    public func cost(for model: OpenAIModel) -> Double {
        let (inputCost, outputCost) = model.costPer1KTokens
        let promptCost = Double(promptTokens) / 1000.0 * inputCost
        let completionCost = Double(completionTokens) / 1000.0 * outputCost
        return promptCost + completionCost
    }
}

/// Finish reason
public enum OpenAIFinishReason: String, Codable {
    case stop
    case length
    case functionCall = "function_call"
    case contentFilter = "content_filter"
    case null
}

/// Chat completion choice
public struct OpenAIChatChoice: Codable, Equatable {
    public let index: Int
    public let message: OpenAIChatMessage
    public let finishReason: OpenAIFinishReason?

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// Chat completion response
public struct OpenAIChatCompletionResponse: Codable, Equatable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [OpenAIChatChoice]
    public let usage: OpenAIUsage

    /// Get first choice message content
    public var content: String? {
        choices.first?.message.content
    }
}

/// Error response from OpenAI
public struct OpenAIErrorResponse: Codable, Error {
    public let error: OpenAIErrorDetail
}

public struct OpenAIErrorDetail: Codable {
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?
}

// MARK: - Streaming Models

/// Stream chunk delta
public struct OpenAIStreamDelta: Codable {
    public let role: OpenAIRole?
    public let content: String?
}

/// Stream choice
public struct OpenAIStreamChoice: Codable {
    public let index: Int
    public let delta: OpenAIStreamDelta
    public let finishReason: OpenAIFinishReason?

    enum CodingKeys: String, CodingKey {
        case index, delta
        case finishReason = "finish_reason"
    }
}

/// Stream chunk response
public struct OpenAIStreamResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [OpenAIStreamChoice]
}

// MARK: - Configuration

/// OpenAI configuration
public struct OpenAIConfig {
    public let apiKey: String
    public let organizationId: String?
    public let defaultModel: OpenAIModel
    public let defaultTemperature: Double
    public let defaultMaxTokens: Int?
    public let timeoutInterval: TimeInterval

    public init(
        apiKey: String,
        organizationId: String? = nil,
        defaultModel: OpenAIModel = .gpt35Turbo,
        defaultTemperature: Double = 0.7,
        defaultMaxTokens: Int? = nil,
        timeoutInterval: TimeInterval = 60
    ) {
        self.apiKey = apiKey
        self.organizationId = organizationId
        self.defaultModel = defaultModel
        self.defaultTemperature = defaultTemperature
        self.defaultMaxTokens = defaultMaxTokens
        self.timeoutInterval = timeoutInterval
    }

    /// Load from environment or config file
    public static func loadFromEnvironment() -> OpenAIConfig? {
        // In production, load from secure storage or environment
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return nil
        }

        return OpenAIConfig(
            apiKey: apiKey,
            organizationId: ProcessInfo.processInfo.environment["OPENAI_ORG_ID"]
        )
    }
}

// MARK: - Rate Limiting

/// Rate limit information
public struct OpenAIRateLimit {
    public let requestsPerMinute: Int
    public let tokensPerMinute: Int
    public var currentRequests: Int
    public var currentTokens: Int
    public var windowStart: Date

    public init(
        requestsPerMinute: Int = 60,
        tokensPerMinute: Int = 90000
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
