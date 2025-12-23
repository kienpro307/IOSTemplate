import Foundation

// MARK: - Protocol

/// OpenAI service protocol
public protocol OpenAIServiceProtocol {
    /// Send chat completion request
    func chatCompletion(
        messages: [OpenAIChatMessage],
        model: OpenAIModel?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> OpenAIChatCompletionResponse

    /// Send chat completion with streaming
    func chatCompletionStream(
        messages: [OpenAIChatMessage],
        model: OpenAIModel?,
        temperature: Double?,
        maxTokens: Int?,
        onChunk: @escaping (String) -> Void
    ) async throws

    /// Simple text completion
    func complete(
        prompt: String,
        model: OpenAIModel?,
        maxTokens: Int?
    ) async throws -> String

    /// Get token count estimate
    func estimateTokens(for text: String) -> Int
}

// MARK: - Implementation

/// OpenAI service implementation
public final class OpenAIService: OpenAIServiceProtocol {

    // MARK: - Properties

    private let config: OpenAIConfig
    private var rateLimit: OpenAIRateLimit
    private let session: URLSession

    private let baseURL = "https://api.openai.com/v1"

    // MARK: - Singleton

    public static let shared = OpenAIService(
        config: OpenAIConfig.loadFromEnvironment() ?? OpenAIConfig(apiKey: "")
    )

    // MARK: - Initialization

    public init(config: OpenAIConfig) {
        self.config = config
        self.rateLimit = OpenAIRateLimit()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        self.session = URLSession(configuration: configuration)

        logInfo("OpenAI service initialized with model: \(config.defaultModel.rawValue)")
    }

    // MARK: - Public Methods

    public func chatCompletion(
        messages: [OpenAIChatMessage],
        model: OpenAIModel? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> OpenAIChatCompletionResponse {
        // Estimate tokens for rate limiting
        let estimatedTokens = messages.reduce(0) { $0 + estimateTokens(for: $1.content) }

        // Check rate limit
        guard rateLimit.canMakeRequest(estimatedTokens: estimatedTokens) else {
            logWarning("Rate limit exceeded")
            throw OpenAIError.rateLimitExceeded
        }

        let request = OpenAIChatCompletionRequest(
            model: model ?? config.defaultModel,
            messages: messages,
            temperature: temperature ?? config.defaultTemperature,
            maxTokens: maxTokens ?? config.defaultMaxTokens
        )

        logDebug("Sending chat completion request with \(messages.count) messages")

        let response: OpenAIChatCompletionResponse = try await performRequest(
            endpoint: "/chat/completions",
            method: "POST",
            body: request
        )

        // Record usage for rate limiting
        rateLimit.recordRequest(tokens: response.usage.totalTokens)

        logInfo("Chat completion received: \(response.usage.totalTokens) tokens, cost: $\(String(format: "%.4f", response.usage.cost(for: model ?? config.defaultModel)))")

        return response
    }

    public func chatCompletionStream(
        messages: [OpenAIChatMessage],
        model: OpenAIModel? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        onChunk: @escaping (String) -> Void
    ) async throws {
        let request = OpenAIChatCompletionRequest(
            model: model ?? config.defaultModel,
            messages: messages,
            temperature: temperature ?? config.defaultTemperature,
            stream: true,
            maxTokens: maxTokens ?? config.defaultMaxTokens
        )

        logDebug("Starting streaming chat completion")

        try await performStreamingRequest(
            endpoint: "/chat/completions",
            body: request,
            onChunk: onChunk
        )
    }

    public func complete(
        prompt: String,
        model: OpenAIModel? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        let messages = [OpenAIChatMessage(role: .user, content: prompt)]
        let response = try await chatCompletion(
            messages: messages,
            model: model,
            temperature: nil,
            maxTokens: maxTokens
        )

        return response.content ?? ""
    }

    public func estimateTokens(for text: String) -> Int {
        // Rough estimation: ~4 characters per token for English
        // This is a simplified version. For production, use tiktoken library
        return Int(ceil(Double(text.count) / 4.0))
    }

    // MARK: - Private Methods

    private func performRequest<T: Encodable, U: Decodable>(
        endpoint: String,
        method: String,
        body: T
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let orgId = config.organizationId {
            request.setValue(orgId, forHTTPHeaderField: "OpenAI-Organization")
        }

        // Encode body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        // Perform request
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        // Handle errors
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                logError("OpenAI API error: \(errorResponse.error.message)")
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(U.self, from: data)
        } catch {
            logError("Failed to decode response: \(error)")
            throw OpenAIError.decodingError(error)
        }
    }

    private func performStreamingRequest<T: Encodable>(
        endpoint: String,
        body: T,
        onChunk: @escaping (String) -> Void
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let orgId = config.organizationId {
            request.setValue(orgId, forHTTPHeaderField: "OpenAI-Organization")
        }

        // Encode body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        // Perform streaming request
        let (asyncBytes, response) = try await session.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIError.httpError(httpResponse.statusCode)
        }

        // Process stream
        var buffer = ""
        for try await byte in asyncBytes {
            buffer.append(String(UnicodeScalar(byte)))

            // Process complete lines
            while let newlineRange = buffer.range(of: "\n") {
                let line = String(buffer[..<newlineRange.lowerBound])
                buffer.removeSubrange(..<newlineRange.upperBound)

                // Skip empty lines and "data: [DONE]"
                guard !line.isEmpty, line != "data: [DONE]" else { continue }

                // Parse SSE data
                if line.hasPrefix("data: ") {
                    let jsonString = String(line.dropFirst(6))

                    if let data = jsonString.data(using: .utf8),
                       let chunk = try? JSONDecoder().decode(OpenAIStreamResponse.self, from: data),
                       let content = chunk.choices.first?.delta.content {
                        onChunk(content)
                    }
                }
            }
        }

        logDebug("Streaming completed")
    }
}

// MARK: - Errors

public enum OpenAIError: Error, LocalizedError {
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
            return "Invalid response from OpenAI"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .apiError(let message):
            return "OpenAI API error: \(message)"
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
    print("🤖 [OpenAI] \(message)")
    #endif
}

private func logInfo(_ message: String) {
    print("ℹ️ [OpenAI] \(message)")
}

private func logWarning(_ message: String) {
    print("⚠️ [OpenAI] \(message)")
}

private func logError(_ message: String) {
    print("❌ [OpenAI] \(message)")
}
