import Foundation

// MARK: - Protocol

/// Claude (Anthropic) service protocol
public protocol ClaudeServiceProtocol {
    /// Send messages request
    func sendMessage(
        messages: [ClaudeMessage],
        model: ClaudeModel?,
        system: String?,
        maxTokens: Int?,
        temperature: Double?
    ) async throws -> ClaudeMessagesResponse

    /// Send message with streaming
    func sendMessageStream(
        messages: [ClaudeMessage],
        model: ClaudeModel?,
        system: String?,
        maxTokens: Int?,
        temperature: Double?,
        onChunk: @escaping (String) -> Void
    ) async throws

    /// Simple text completion
    func complete(
        prompt: String,
        model: ClaudeModel?,
        system: String?,
        maxTokens: Int?
    ) async throws -> String

    /// Continue conversation
    func continueConversation(
        history: [ClaudeMessage],
        userMessage: String,
        system: String?
    ) async throws -> String

    /// Get token count estimate
    func estimateTokens(for text: String) -> Int
}

// MARK: - Implementation

/// Claude (Anthropic) service implementation
public final class ClaudeService: ClaudeServiceProtocol {

    // MARK: - Properties

    private let config: ClaudeConfig
    private var rateLimit: ClaudeRateLimit
    private let session: URLSession

    private let baseURL = "https://api.anthropic.com/v1"

    // MARK: - Singleton

    public static let shared = ClaudeService(
        config: ClaudeConfig.loadFromEnvironment() ?? ClaudeConfig(apiKey: "")
    )

    // MARK: - Initialization

    public init(config: ClaudeConfig) {
        self.config = config
        self.rateLimit = ClaudeRateLimit()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        self.session = URLSession(configuration: configuration)

        logInfo("Claude service initialized with model: \(config.defaultModel.rawValue)")
    }

    // MARK: - Public Methods

    public func sendMessage(
        messages: [ClaudeMessage],
        model: ClaudeModel? = nil,
        system: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) async throws -> ClaudeMessagesResponse {
        // Estimate tokens for rate limiting
        let estimatedTokens = messages.reduce(0) { $0 + estimateTokens(for: $1.text) }
        if let sys = system {
            _ = estimatedTokens + estimateTokens(for: sys)
        }

        // Check rate limit
        guard rateLimit.canMakeRequest(estimatedTokens: estimatedTokens) else {
            logWarning("Rate limit exceeded")
            throw ClaudeError.rateLimitExceeded
        }

        let request = ClaudeMessagesRequest(
            model: model ?? config.defaultModel,
            messages: messages,
            maxTokens: maxTokens ?? config.defaultMaxTokens,
            system: system,
            temperature: temperature ?? config.defaultTemperature
        )

        logDebug("Sending message request with \(messages.count) messages")

        let response: ClaudeMessagesResponse = try await performRequest(
            endpoint: "/messages",
            method: "POST",
            body: request
        )

        // Record usage for rate limiting
        rateLimit.recordRequest(tokens: response.usage.totalTokens)

        logInfo("Message received: \(response.usage.totalTokens) tokens, cost: $\(String(format: "%.6f", response.usage.cost(for: model ?? config.defaultModel)))")

        return response
    }

    public func sendMessageStream(
        messages: [ClaudeMessage],
        model: ClaudeModel? = nil,
        system: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        onChunk: @escaping (String) -> Void
    ) async throws {
        let request = ClaudeMessagesRequest(
            model: model ?? config.defaultModel,
            messages: messages,
            maxTokens: maxTokens ?? config.defaultMaxTokens,
            system: system,
            temperature: temperature ?? config.defaultTemperature,
            stream: true
        )

        logDebug("Starting streaming message request")

        try await performStreamingRequest(
            endpoint: "/messages",
            body: request,
            onChunk: onChunk
        )
    }

    public func complete(
        prompt: String,
        model: ClaudeModel? = nil,
        system: String? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        let messages = [ClaudeMessage(role: .user, content: prompt)]
        let response = try await sendMessage(
            messages: messages,
            model: model,
            system: system,
            maxTokens: maxTokens,
            temperature: nil
        )

        return response.text
    }

    public func continueConversation(
        history: [ClaudeMessage],
        userMessage: String,
        system: String? = nil
    ) async throws -> String {
        var updatedHistory = history
        updatedHistory.append(ClaudeMessage(role: .user, content: userMessage))

        let response = try await sendMessage(
            messages: updatedHistory,
            model: nil,
            system: system,
            maxTokens: nil,
            temperature: nil
        )

        return response.text
    }

    public func estimateTokens(for text: String) -> Int {
        // Rough estimation: ~4 characters per token for English
        // Claude uses a similar tokenization to GPT
        return Int(ceil(Double(text.count) / 4.0))
    }

    // MARK: - Private Methods

    private func performRequest<T: Encodable, U: Decodable>(
        endpoint: String,
        method: String,
        body: T
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ClaudeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiVersion, forHTTPHeaderField: "anthropic-version")

        // Encode body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        // Perform request
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        // Handle errors
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) {
                logError("Claude API error: \(errorResponse.error.message)")
                throw ClaudeError.apiError(errorResponse.error.message)
            }
            throw ClaudeError.httpError(httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(U.self, from: data)
        } catch {
            logError("Failed to decode response: \(error)")
            throw ClaudeError.decodingError(error)
        }
    }

    private func performStreamingRequest<T: Encodable>(
        endpoint: String,
        body: T,
        onChunk: @escaping (String) -> Void
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ClaudeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiVersion, forHTTPHeaderField: "anthropic-version")

        // Encode body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        // Perform streaming request
        let (asyncBytes, response) = try await session.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ClaudeError.httpError(httpResponse.statusCode)
        }

        // Process stream
        var buffer = ""
        for try await byte in asyncBytes {
            buffer.append(String(UnicodeScalar(byte)))

            // Process complete lines
            while let newlineRange = buffer.range(of: "\n") {
                let line = String(buffer[..<newlineRange.lowerBound])
                buffer.removeSubrange(..<newlineRange.upperBound)

                // Skip empty lines
                guard !line.isEmpty else { continue }

                // Parse SSE data
                if line.hasPrefix("data: ") {
                    let jsonString = String(line.dropFirst(6))

                    if let data = jsonString.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase

                        if let event = try? decoder.decode(ClaudeStreamEvent.self, from: data) {
                            // Handle content block delta
                            if event.type == .contentBlockDelta,
                               let text = event.delta?.text {
                                onChunk(text)
                            }
                        }
                    }
                }
            }
        }

        logDebug("Streaming completed")
    }
}

// MARK: - Errors

public enum ClaudeError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case rateLimitExceeded
    case apiError(String)
    case httpError(Int)
    case decodingError(Error)
    case streamingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Claude"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .apiError(let message):
            return "Claude API error: \(message)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        }
    }
}

// MARK: - Logging Helpers

private func logDebug(_ message: String) {
    #if DEBUG
    print("🤖 [Claude] \(message)")
    #endif
}

private func logInfo(_ message: String) {
    print("ℹ️ [Claude] \(message)")
}

private func logWarning(_ message: String) {
    print("⚠️ [Claude] \(message)")
}

private func logError(_ message: String) {
    print("❌ [Claude] \(message)")
}
