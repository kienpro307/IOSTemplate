import Foundation

// MARK: - AI Provider

/// AI provider types
public enum AIProvider: String, Codable {
    case openai = "OpenAI"
    case claude = "Claude"

    /// Display name
    public var displayName: String {
        rawValue
    }

    /// Default model for provider
    public var defaultModel: String {
        switch self {
        case .openai: return OpenAIModel.gpt35Turbo.rawValue
        case .claude: return ClaudeModel.claude35Sonnet.rawValue
        }
    }
}

// MARK: - AI Message (Unified)

/// Unified AI message format
public struct AIMessage: Codable, Equatable {
    public let role: AIRole
    public let content: String
    public let timestamp: Date

    public init(role: AIRole, content: String, timestamp: Date = Date()) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

/// Unified message role
public enum AIRole: String, Codable {
    case system
    case user
    case assistant

    /// Convert to OpenAI role
    var openAIRole: OpenAIRole {
        switch self {
        case .system: return .system
        case .user: return .user
        case .assistant: return .assistant
        }
    }

    /// Convert to Claude role
    var claudeRole: ClaudeRole {
        switch self {
        case .system, .user: return .user
        case .assistant: return .assistant
        }
    }
}

// MARK: - AI Response

/// Unified AI response
public struct AIResponse: Codable {
    public let id: String
    public let provider: AIProvider
    public let model: String
    public let content: String
    public let usage: AIUsage
    public let timestamp: Date

    public init(
        id: String,
        provider: AIProvider,
        model: String,
        content: String,
        usage: AIUsage,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.provider = provider
        self.model = model
        self.content = content
        self.usage = usage
        self.timestamp = timestamp
    }
}

/// Unified usage info
public struct AIUsage: Codable {
    public let inputTokens: Int
    public let outputTokens: Int
    public let totalTokens: Int
    public let cost: Double

    public init(inputTokens: Int, outputTokens: Int, totalTokens: Int, cost: Double) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.totalTokens = totalTokens
        self.cost = cost
    }
}

// MARK: - Prompt Template

/// Prompt template for common tasks
public struct PromptTemplate {
    public let name: String
    public let systemPrompt: String?
    public let userPromptTemplate: String
    public let variables: [String]

    public init(
        name: String,
        systemPrompt: String? = nil,
        userPromptTemplate: String,
        variables: [String] = []
    ) {
        self.name = name
        self.systemPrompt = systemPrompt
        self.userPromptTemplate = userPromptTemplate
        self.variables = variables
    }

    /// Fill template with variables
    public func fill(with values: [String: String]) -> String {
        var result = userPromptTemplate
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}

// MARK: - Predefined Templates

public extension PromptTemplate {
    /// Summarization template
    static let summarize = PromptTemplate(
        name: "Summarize",
        systemPrompt: "You are a helpful assistant that summarizes text concisely.",
        userPromptTemplate: "Please summarize the following text:\n\n{{text}}",
        variables: ["text"]
    )

    /// Translation template
    static let translate = PromptTemplate(
        name: "Translate",
        systemPrompt: "You are a professional translator.",
        userPromptTemplate: "Translate the following text from {{source_lang}} to {{target_lang}}:\n\n{{text}}",
        variables: ["source_lang", "target_lang", "text"]
    )

    /// Code generation
    static let codeGeneration = PromptTemplate(
        name: "Code Generation",
        systemPrompt: "You are an expert programmer. Provide clean, well-documented code.",
        userPromptTemplate: "Write {{language}} code for: {{task}}\n\nRequirements:\n{{requirements}}",
        variables: ["language", "task", "requirements"]
    )

    /// Question answering
    static let questionAnswer = PromptTemplate(
        name: "Question Answering",
        systemPrompt: "You are a knowledgeable assistant that provides accurate, helpful answers.",
        userPromptTemplate: "Question: {{question}}\n\nContext: {{context}}",
        variables: ["question", "context"]
    )

    /// Creative writing
    static let creativeWriting = PromptTemplate(
        name: "Creative Writing",
        systemPrompt: "You are a creative writer with a vivid imagination.",
        userPromptTemplate: "Write a {{genre}} story about: {{topic}}\n\nLength: {{length}} words",
        variables: ["genre", "topic", "length"]
    )
}

// MARK: - Response Cache

/// Simple response cache
actor ResponseCache {
    private var cache: [String: (response: AIResponse, expiry: Date)] = [:]
    private let cacheDuration: TimeInterval

    init(cacheDuration: TimeInterval = 3600) { // 1 hour default
        self.cacheDuration = cacheDuration
    }

    func get(for key: String) -> AIResponse? {
        cleanExpired()
        guard let cached = cache[key], cached.expiry > Date() else {
            return nil
        }
        return cached.response
    }

    func set(_ response: AIResponse, for key: String) {
        let expiry = Date().addingTimeInterval(cacheDuration)
        cache[key] = (response, expiry)
    }

    func clear() {
        cache.removeAll()
    }

    private func cleanExpired() {
        let now = Date()
        cache = cache.filter { $0.value.expiry > now }
    }
}

// MARK: - AI Manager Protocol

/// AI Manager protocol
public protocol AIManagerProtocol {
    /// Send message with automatic provider selection
    func sendMessage(
        _ message: String,
        provider: AIProvider?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AIResponse

    /// Send message with streaming
    func sendMessageStream(
        _ message: String,
        provider: AIProvider?,
        onChunk: @escaping (String) -> Void
    ) async throws

    /// Continue conversation
    func continueConversation(
        history: [AIMessage],
        userMessage: String,
        provider: AIProvider?
    ) async throws -> AIResponse

    /// Use prompt template
    func executeTemplate(
        _ template: PromptTemplate,
        variables: [String: String],
        provider: AIProvider?
    ) async throws -> AIResponse
}

// MARK: - AI Manager Implementation

/// AI Manager - Unified interface for all AI providers
public final class AIManager: AIManagerProtocol {

    // MARK: - Properties

    private let openAI: OpenAIServiceProtocol
    private let claude: ClaudeServiceProtocol
    private let cache: ResponseCache

    public var defaultProvider: AIProvider = .openai
    public var enableCaching: Bool = true

    // MARK: - Singleton

    public static let shared = AIManager()

    // MARK: - Initialization

    public init(
        openAI: OpenAIServiceProtocol = OpenAIService.shared,
        claude: ClaudeServiceProtocol = ClaudeService.shared,
        cacheDuration: TimeInterval = 3600
    ) {
        self.openAI = openAI
        self.claude = claude
        self.cache = ResponseCache(cacheDuration: cacheDuration)

        logInfo("AI Manager initialized")
    }

    // MARK: - Public Methods

    public func sendMessage(
        _ message: String,
        provider: AIProvider? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> AIResponse {
        let selectedProvider = provider ?? defaultProvider

        // Check cache
        if enableCaching {
            let cacheKey = "\(selectedProvider.rawValue):\(message)"
            if let cached = await cache.get(for: cacheKey) {
                logDebug("Cache hit for message")
                return cached
            }
        }

        logDebug("Sending message to \(selectedProvider.displayName)")

        let response: AIResponse

        switch selectedProvider {
        case .openai:
            response = try await sendToOpenAI(
                message: message,
                temperature: temperature,
                maxTokens: maxTokens
            )

        case .claude:
            response = try await sendToClaude(
                message: message,
                temperature: temperature,
                maxTokens: maxTokens
            )
        }

        // Cache response
        if enableCaching {
            let cacheKey = "\(selectedProvider.rawValue):\(message)"
            await cache.set(response, for: cacheKey)
        }

        return response
    }

    public func sendMessageStream(
        _ message: String,
        provider: AIProvider? = nil,
        onChunk: @escaping (String) -> Void
    ) async throws {
        let selectedProvider = provider ?? defaultProvider

        logDebug("Starting streaming to \(selectedProvider.displayName)")

        switch selectedProvider {
        case .openai:
            let messages = [OpenAIChatMessage(role: .user, content: message)]
            try await openAI.chatCompletionStream(
                messages: messages,
                model: nil,
                temperature: nil,
                maxTokens: nil,
                onChunk: onChunk
            )

        case .claude:
            let messages = [ClaudeMessage(role: .user, content: message)]
            try await claude.sendMessageStream(
                messages: messages,
                model: nil,
                system: nil,
                maxTokens: nil,
                temperature: nil,
                onChunk: onChunk
            )
        }
    }

    public func continueConversation(
        history: [AIMessage],
        userMessage: String,
        provider: AIProvider? = nil
    ) async throws -> AIResponse {
        let selectedProvider = provider ?? defaultProvider

        logDebug("Continuing conversation with \(selectedProvider.displayName)")

        switch selectedProvider {
        case .openai:
            let messages = history.map {
                OpenAIChatMessage(role: $0.role.openAIRole, content: $0.content)
            }
            var updatedMessages = messages
            updatedMessages.append(OpenAIChatMessage(role: .user, content: userMessage))

            let response = try await openAI.chatCompletion(
                messages: updatedMessages,
                model: nil,
                temperature: nil,
                maxTokens: nil
            )

            return AIResponse(
                id: response.id,
                provider: .openai,
                model: response.model,
                content: response.content ?? "",
                usage: AIUsage(
                    inputTokens: response.usage.promptTokens,
                    outputTokens: response.usage.completionTokens,
                    totalTokens: response.usage.totalTokens,
                    cost: response.usage.cost(for: .gpt35Turbo)
                )
            )

        case .claude:
            // Claude doesn't support system messages in conversation
            // Extract system message if first message is system
            var systemMessage: String?
            var conversationHistory = history

            if let firstMessage = history.first, firstMessage.role == .system {
                systemMessage = firstMessage.content
                conversationHistory = Array(history.dropFirst())
            }

            let messages = conversationHistory.map {
                ClaudeMessage(role: $0.role.claudeRole, content: $0.content)
            }

            let result = try await claude.continueConversation(
                history: messages,
                userMessage: userMessage,
                system: systemMessage
            )

            // Get last response to extract metadata
            var updatedMessages = messages
            updatedMessages.append(ClaudeMessage(role: .user, content: userMessage))

            let response = try await claude.sendMessage(
                messages: updatedMessages,
                model: nil,
                system: systemMessage,
                maxTokens: nil,
                temperature: nil
            )

            return AIResponse(
                id: response.id,
                provider: .claude,
                model: response.model,
                content: result,
                usage: AIUsage(
                    inputTokens: response.usage.inputTokens,
                    outputTokens: response.usage.outputTokens,
                    totalTokens: response.usage.totalTokens,
                    cost: response.usage.cost(for: .claude35Sonnet)
                )
            )
        }
    }

    public func executeTemplate(
        _ template: PromptTemplate,
        variables: [String: String],
        provider: AIProvider? = nil
    ) async throws -> AIResponse {
        let userPrompt = template.fill(with: variables)
        let selectedProvider = provider ?? defaultProvider

        logDebug("Executing template '\(template.name)' with \(selectedProvider.displayName)")

        switch selectedProvider {
        case .openai:
            var messages: [OpenAIChatMessage] = []

            if let system = template.systemPrompt {
                messages.append(OpenAIChatMessage(role: .system, content: system))
            }

            messages.append(OpenAIChatMessage(role: .user, content: userPrompt))

            let response = try await openAI.chatCompletion(
                messages: messages,
                model: nil,
                temperature: nil,
                maxTokens: nil
            )

            return AIResponse(
                id: response.id,
                provider: .openai,
                model: response.model,
                content: response.content ?? "",
                usage: AIUsage(
                    inputTokens: response.usage.promptTokens,
                    outputTokens: response.usage.completionTokens,
                    totalTokens: response.usage.totalTokens,
                    cost: response.usage.cost(for: .gpt35Turbo)
                )
            )

        case .claude:
            let messages = [ClaudeMessage(role: .user, content: userPrompt)]

            let response = try await claude.sendMessage(
                messages: messages,
                model: nil,
                system: template.systemPrompt,
                maxTokens: nil,
                temperature: nil
            )

            return AIResponse(
                id: response.id,
                provider: .claude,
                model: response.model,
                content: response.text,
                usage: AIUsage(
                    inputTokens: response.usage.inputTokens,
                    outputTokens: response.usage.outputTokens,
                    totalTokens: response.usage.totalTokens,
                    cost: response.usage.cost(for: .claude35Sonnet)
                )
            )
        }
    }

    /// Clear response cache
    public func clearCache() async {
        await cache.clear()
        logInfo("Response cache cleared")
    }

    // MARK: - Private Methods

    private func sendToOpenAI(
        message: String,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AIResponse {
        let messages = [OpenAIChatMessage(role: .user, content: message)]

        let response = try await openAI.chatCompletion(
            messages: messages,
            model: nil,
            temperature: temperature,
            maxTokens: maxTokens
        )

        return AIResponse(
            id: response.id,
            provider: .openai,
            model: response.model,
            content: response.content ?? "",
            usage: AIUsage(
                inputTokens: response.usage.promptTokens,
                outputTokens: response.usage.completionTokens,
                totalTokens: response.usage.totalTokens,
                cost: response.usage.cost(for: .gpt35Turbo)
            )
        )
    }

    private func sendToClaude(
        message: String,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AIResponse {
        let messages = [ClaudeMessage(role: .user, content: message)]

        let response = try await claude.sendMessage(
            messages: messages,
            model: nil,
            system: nil,
            maxTokens: maxTokens,
            temperature: temperature
        )

        return AIResponse(
            id: response.id,
            provider: .claude,
            model: response.model,
            content: response.text,
            usage: AIUsage(
                inputTokens: response.usage.inputTokens,
                outputTokens: response.usage.outputTokens,
                totalTokens: response.usage.totalTokens,
                cost: response.usage.cost(for: .claude35Sonnet)
            )
        )
    }
}

// MARK: - Logging Helpers

private func logDebug(_ message: String) {
    #if DEBUG
    print("🤖 [AIManager] \(message)")
    #endif
}

private func logInfo(_ message: String) {
    print("ℹ️ [AIManager] \(message)")
}

private func logError(_ message: String) {
    print("❌ [AIManager] \(message)")
}
