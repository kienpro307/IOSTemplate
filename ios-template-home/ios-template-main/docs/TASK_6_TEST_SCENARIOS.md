# 🧪 Phase 6: AI Integration - Test Scenarios

**Complete Test Coverage for AI Integration**

---

## 📋 Table of Contents

1. [OpenAI Integration Tests](#openai-integration-tests)
2. [Claude Integration Tests](#claude-integration-tests)
3. [AI Manager Tests](#ai-manager-tests)
4. [Core ML Tests](#core-ml-tests)
5. [Vision Service Tests](#vision-service-tests)
6. [Integration Tests](#integration-tests)
7. [Performance Tests](#performance-tests)
8. [Edge Cases & Error Handling](#edge-cases--error-handling)

---

## OpenAI Integration Tests

### Test 6.1.1.1: OpenAI Configuration
**Objective**: Verify OpenAI service configuration

**Steps:**
1. Create OpenAIConfig with valid API key
2. Initialize OpenAIService with config
3. Verify default model is set correctly
4. Verify default temperature is set

**Expected:**
- ✅ Service initializes without error
- ✅ Default model is `.gpt35Turbo`
- ✅ Default temperature is 0.7
- ✅ Rate limit initialized

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Passed | ❌ Failed

---

### Test 6.1.1.2: Basic Chat Completion
**Objective**: Test simple chat completion request

**Steps:**
```swift
let messages = [OpenAIChatMessage(role: .user, content: "Say hello")]
let response = try await service.chatCompletion(
    messages: messages,
    model: .gpt35Turbo,
    temperature: 0.7,
    maxTokens: 50
)
```

**Expected:**
- ✅ Response received
- ✅ Response contains content
- ✅ Usage info populated (tokens, cost)
- ✅ Response time < 5 seconds

**Status**: ⬜

---

### Test 6.1.1.3: Multi-turn Conversation
**Objective**: Test conversation with context

**Steps:**
1. Send message: "My name is John"
2. Send message: "What's my name?"
3. Verify AI remembers context

**Expected:**
- ✅ Second response mentions "John"
- ✅ Context maintained across messages

**Status**: ⬜

---

### Test 6.1.1.4: Streaming Response
**Objective**: Test streaming chat completion

**Steps:**
```swift
var chunks: [String] = []
try await service.chatCompletionStream(
    messages: messages,
    model: .gpt35Turbo,
    onChunk: { chunk in
        chunks.append(chunk)
    }
)
```

**Expected:**
- ✅ Multiple chunks received
- ✅ Chunks received in order
- ✅ Final text makes sense

**Status**: ⬜

---

### Test 6.1.1.5: Rate Limiting
**Objective**: Verify rate limit enforcement

**Steps:**
1. Set low rate limit (e.g., 1 request/min)
2. Make 2 requests in quick succession
3. Verify second request is blocked

**Expected:**
- ✅ First request succeeds
- ✅ Second request throws `rateLimitExceeded`
- ✅ After 60s, request succeeds

**Status**: ⬜

---

### Test 6.1.1.6: Token Estimation
**Objective**: Test token counting accuracy

**Steps:**
```swift
let text = "Hello, world!"
let estimate = service.estimateTokens(for: text)
```

**Expected:**
- ✅ Estimate is reasonable (~3-4 tokens)
- ✅ Estimate is > 0

**Status**: ⬜

---

### Test 6.1.1.7: Different Models
**Objective**: Test all supported models

**Steps:**
1. Test GPT-3.5-Turbo
2. Test GPT-3.5-Turbo-16K
3. Test GPT-4
4. Test GPT-4-Turbo

**Expected:**
- ✅ All models respond correctly
- ✅ Token limits respected
- ✅ Costs calculated correctly

**Status**: ⬜

---

### Test 6.1.1.8: Error Handling - Invalid API Key
**Objective**: Test error when API key is invalid

**Steps:**
1. Create config with invalid key
2. Make request
3. Catch error

**Expected:**
- ✅ Throws `OpenAIError.invalidAPIKey` or `apiError`
- ✅ Error message is descriptive

**Status**: ⬜

---

### Test 6.1.1.9: Error Handling - Network Failure
**Objective**: Test network error handling

**Steps:**
1. Disable network
2. Make request
3. Catch error

**Expected:**
- ✅ Throws appropriate network error
- ✅ No crash

**Status**: ⬜

---

### Test 6.1.1.10: Temperature Variation
**Objective**: Test different temperature settings

**Steps:**
1. Request with temperature 0.0 (deterministic)
2. Request with temperature 1.0 (creative)
3. Request with temperature 2.0 (very random)

**Expected:**
- ✅ Lower temperature = more consistent
- ✅ Higher temperature = more varied

**Status**: ⬜

---

## Claude Integration Tests

### Test 6.1.2.1: Claude Configuration
**Objective**: Verify Claude service configuration

**Steps:**
1. Create ClaudeConfig with valid API key
2. Initialize ClaudeService
3. Verify defaults

**Expected:**
- ✅ Service initializes
- ✅ Default model is `.claude35Sonnet`
- ✅ Default max tokens is 4096

**Status**: ⬜

---

### Test 6.1.2.2: Basic Message
**Objective**: Test simple message request

**Steps:**
```swift
let messages = [ClaudeMessage(role: .user, content: "Say hello")]
let response = try await service.sendMessage(
    messages: messages,
    model: .claude35Sonnet,
    system: nil,
    maxTokens: 100,
    temperature: 1.0
)
```

**Expected:**
- ✅ Response received
- ✅ Text content present
- ✅ Usage info populated

**Status**: ⬜

---

### Test 6.1.2.3: System Prompt
**Objective**: Test system prompt usage

**Steps:**
```swift
let response = try await service.sendMessage(
    messages: [ClaudeMessage(role: .user, content: "Introduce yourself")],
    system: "You are a friendly robot named Claude.",
    maxTokens: 100
)
```

**Expected:**
- ✅ Response mentions being Claude
- ✅ Response reflects robot persona

**Status**: ⬜

---

### Test 6.1.2.4: Continue Conversation
**Objective**: Test conversation continuation

**Steps:**
```swift
let history = [
    ClaudeMessage(role: .user, content: "I like pizza"),
    ClaudeMessage(role: .assistant, content: "That's great!")
]
let response = try await service.continueConversation(
    history: history,
    userMessage: "What did I say I like?",
    system: nil
)
```

**Expected:**
- ✅ Response mentions "pizza"
- ✅ Context maintained

**Status**: ⬜

---

### Test 6.1.2.5: Streaming Response
**Objective**: Test streaming messages

**Steps:**
```swift
var fullText = ""
try await service.sendMessageStream(
    messages: messages,
    onChunk: { chunk in
        fullText += chunk
    }
)
```

**Expected:**
- ✅ Multiple chunks received
- ✅ Full text is coherent

**Status**: ⬜

---

### Test 6.1.2.6: Vision - Image Analysis
**Objective**: Test image input (Claude 3)

**Steps:**
1. Create image content with base64 image
2. Send to Claude
3. Request image description

**Expected:**
- ✅ Response describes image content
- ✅ No errors

**Status**: ⬜

---

### Test 6.1.2.7: Long Context
**Objective**: Test large context (200K tokens)

**Steps:**
1. Create messages with ~50K tokens
2. Send to Claude 3.5 Sonnet
3. Request summary

**Expected:**
- ✅ Request succeeds
- ✅ Response relevant to full context

**Status**: ⬜

---

### Test 6.1.2.8: Different Models
**Objective**: Test all Claude models

**Steps:**
1. Test Haiku (fast)
2. Test Sonnet (balanced)
3. Test Opus (powerful)
4. Test 3.5 Sonnet (latest)

**Expected:**
- ✅ All models respond
- ✅ Quality matches tier (Opus > Sonnet > Haiku)
- ✅ Speed matches tier (Haiku > Sonnet > Opus)

**Status**: ⬜

---

### Test 6.1.2.9: Error Handling - Invalid Key
**Objective**: Test error with bad API key

**Steps:**
1. Use invalid API key
2. Make request

**Expected:**
- ✅ Throws `ClaudeError.invalidAPIKey` or `apiError`

**Status**: ⬜

---

### Test 6.1.2.10: Rate Limiting
**Objective**: Test Claude rate limits

**Steps:**
1. Make rapid requests
2. Verify rate limit enforcement

**Expected:**
- ✅ Rate limit kicks in
- ✅ Error thrown when exceeded

**Status**: ⬜

---

## AI Manager Tests

### Test 6.1.3.1: Initialization
**Objective**: Verify AI Manager setup

**Steps:**
1. Initialize AIManager.shared
2. Verify default provider
3. Verify caching enabled

**Expected:**
- ✅ Manager initializes
- ✅ Default provider is `.openai`
- ✅ Caching enabled by default

**Status**: ⬜

---

### Test 6.1.3.2: Send Message - Default Provider
**Objective**: Test message with default provider

**Steps:**
```swift
let response = try await manager.sendMessage(
    "What is Swift?",
    provider: nil, // Uses default
    temperature: 0.7,
    maxTokens: 100
)
```

**Expected:**
- ✅ Response received
- ✅ Provider matches default
- ✅ Unified AIResponse format

**Status**: ⬜

---

### Test 6.1.3.3: Switch Providers
**Objective**: Test switching between providers

**Steps:**
1. Send message with provider: .openai
2. Send message with provider: .claude
3. Compare responses

**Expected:**
- ✅ Both requests succeed
- ✅ Different providers used
- ✅ Response formats unified

**Status**: ⬜

---

### Test 6.1.3.4: Conversation History
**Objective**: Test conversation management

**Steps:**
```swift
var history: [AIMessage] = []
let response1 = try await manager.continueConversation(
    history: history,
    userMessage: "My name is Alice",
    provider: .openai
)
history.append(AIMessage(role: .user, content: "My name is Alice"))
history.append(AIMessage(role: .assistant, content: response1.content))

let response2 = try await manager.continueConversation(
    history: history,
    userMessage: "What's my name?",
    provider: .openai
)
```

**Expected:**
- ✅ Second response mentions "Alice"
- ✅ Context maintained

**Status**: ⬜

---

### Test 6.1.3.5: Prompt Template - Summarize
**Objective**: Test summarization template

**Steps:**
```swift
let summary = try await manager.executeTemplate(
    .summarize,
    variables: ["text": longText],
    provider: .claude
)
```

**Expected:**
- ✅ Summary received
- ✅ Summary is shorter than original
- ✅ Key points captured

**Status**: ⬜

---

### Test 6.1.3.6: Prompt Template - Translate
**Objective**: Test translation template

**Steps:**
```swift
let translation = try await manager.executeTemplate(
    .translate,
    variables: [
        "source_lang": "English",
        "target_lang": "Spanish",
        "text": "Hello, how are you?"
    ],
    provider: .openai
)
```

**Expected:**
- ✅ Translation received
- ✅ Text is in Spanish
- ✅ Meaning preserved

**Status**: ⬜

---

### Test 6.1.3.7: Response Caching
**Objective**: Test caching functionality

**Steps:**
1. Enable caching
2. Send message
3. Send same message again
4. Measure response time

**Expected:**
- ✅ First request makes API call
- ✅ Second request returns cached (faster)
- ✅ Same content returned

**Status**: ⬜

---

### Test 6.1.3.8: Clear Cache
**Objective**: Test cache clearing

**Steps:**
1. Send message (cached)
2. Clear cache
3. Send same message

**Expected:**
- ✅ Third request makes API call
- ✅ Cache properly cleared

**Status**: ⬜

---

### Test 6.1.3.9: Streaming
**Objective**: Test unified streaming

**Steps:**
```swift
try await manager.sendMessageStream(
    "Tell a story",
    provider: .claude,
    onChunk: { chunk in
        print(chunk, terminator: "")
    }
)
```

**Expected:**
- ✅ Chunks stream in real-time
- ✅ Works for both providers

**Status**: ⬜

---

### Test 6.1.3.10: Custom Template
**Objective**: Test custom prompt template

**Steps:**
1. Create custom PromptTemplate
2. Execute with variables
3. Verify output

**Expected:**
- ✅ Variables substituted correctly
- ✅ System prompt applied
- ✅ Response follows template

**Status**: ⬜

---

## Core ML Tests

### Test 6.2.1.1: Load Model from Bundle
**Objective**: Test model loading

**Steps:**
```swift
let model = try await manager.loadModel(named: "TestModel")
```

**Expected:**
- ✅ Model loads successfully
- ✅ Model cached
- ✅ Info retrievable

**Status**: ⬜

---

### Test 6.2.1.2: Model Exists Check
**Objective**: Test model existence check

**Steps:**
```swift
let exists = manager.modelExists(named: "TestModel")
```

**Expected:**
- ✅ Returns true for existing model
- ✅ Returns false for non-existent model

**Status**: ⬜

---

### Test 6.2.1.3: Model Caching
**Objective**: Verify model caching works

**Steps:**
1. Load model (first time)
2. Load same model (second time)
3. Measure load time

**Expected:**
- ✅ Second load is faster
- ✅ Same model instance

**Status**: ⬜

---

### Test 6.2.1.4: Batch Predictions
**Objective**: Test batch prediction

**Steps:**
```swift
let results = try await manager.batchPredict(
    model: model,
    inputs: [input1, input2, input3]
)
```

**Expected:**
- ✅ All predictions complete
- ✅ Results in correct order
- ✅ Faster than individual predictions

**Status**: ⬜

---

### Test 6.2.1.5: Unload Model
**Objective**: Test model unloading

**Steps:**
1. Load model
2. Unload model
3. Verify memory freed

**Expected:**
- ✅ Model unloaded
- ✅ Not in cache
- ✅ Memory reduced

**Status**: ⬜

---

## Vision Service Tests

### Test 6.2.2.1: Text Recognition
**Objective**: Test OCR functionality

**Steps:**
```swift
let results = try await vision.recognizeText(in: testImage)
```

**Expected:**
- ✅ Text detected
- ✅ Confidence scores present
- ✅ Bounding boxes correct

**Status**: ⬜

---

### Test 6.2.2.2: Object Detection
**Objective**: Test object detection

**Steps:**
```swift
let objects = try await vision.detectObjects(in: image)
```

**Expected:**
- ✅ Objects detected
- ✅ Classifications present
- ✅ Bounding boxes accurate

**Status**: ⬜

---

### Test 6.2.2.3: Face Detection - Basic
**Objective**: Test basic face detection

**Steps:**
```swift
let faces = try await vision.detectFaces(
    in: image,
    includeLandmarks: false
)
```

**Expected:**
- ✅ Faces detected
- ✅ Bounding boxes present
- ✅ Count is accurate

**Status**: ⬜

---

### Test 6.2.2.4: Face Detection - Landmarks
**Objective**: Test face landmarks detection

**Steps:**
```swift
let faces = try await vision.detectFaces(
    in: image,
    includeLandmarks: true
)
```

**Expected:**
- ✅ Landmarks detected (eyes, nose, mouth)
- ✅ Roll/yaw/pitch present
- ✅ Landmarks positioned correctly

**Status**: ⬜

---

### Test 6.2.2.5: Barcode Scanning
**Objective**: Test barcode/QR detection

**Steps:**
```swift
let barcodes = try await vision.detectBarcodes(in: image)
```

**Expected:**
- ✅ Barcodes detected
- ✅ Payload extracted correctly
- ✅ Symbology identified

**Status**: ⬜

---

### Test 6.2.2.6: Image Classification
**Objective**: Test image classification

**Steps:**
```swift
let classifications = try await vision.classifyImage(image)
```

**Expected:**
- ✅ Classifications returned
- ✅ Confidence scores present
- ✅ Top 5 results

**Status**: ⬜

---

### Test 6.2.2.7: Body Pose Detection (iOS 14+)
**Objective**: Test body pose recognition

**Steps:**
```swift
if #available(iOS 14.0, *) {
    let pose = try await vision.detectBodyPose(in: image)
}
```

**Expected:**
- ✅ Pose detected
- ✅ Joint points identified
- ✅ Skeleton structure present

**Status**: ⬜

---

### Test 6.2.2.8: Hand Pose Detection (iOS 14+)
**Objective**: Test hand pose detection

**Steps:**
```swift
if #available(iOS 14.0, *) {
    let hands = try await vision.detectHandPose(in: image)
}
```

**Expected:**
- ✅ Hands detected
- ✅ Finger landmarks present
- ✅ Multiple hands supported

**Status**: ⬜

---

### Test 6.2.2.9: Error - Invalid Image
**Objective**: Test error handling for bad image

**Steps:**
```swift
let badImage = UIImage()
try await vision.recognizeText(in: badImage)
```

**Expected:**
- ✅ Throws `VisionError.invalidImage`

**Status**: ⬜

---

### Test 6.2.2.10: UIImage Convenience
**Objective**: Test UIImage extensions

**Steps:**
```swift
let uiImage = UIImage(named: "test")!
let results = try await vision.recognizeText(in: uiImage)
```

**Expected:**
- ✅ Works with UIImage
- ✅ Results same as CGImage

**Status**: ⬜

---

## Integration Tests

### Test 6.3.1: AI + Vision Pipeline
**Objective**: Test AI analyzing Vision results

**Steps:**
1. Use Vision to extract text from image
2. Send text to AI for analysis
3. Get AI response

**Expected:**
- ✅ Pipeline works end-to-end
- ✅ Results are coherent

**Status**: ⬜

---

### Test 6.3.2: DI Container Resolution
**Objective**: Test all AI services resolve from DI

**Steps:**
```swift
let openAI = DIContainer.shared.openAIService
let claude = DIContainer.shared.claudeService
let aiManager = DIContainer.shared.aiManager
let coreML = DIContainer.shared.coreMLManager
let vision = DIContainer.shared.visionService
```

**Expected:**
- ✅ All services resolve correctly
- ✅ Singletons maintained

**Status**: ⬜

---

### Test 6.3.3: Multi-Provider Conversation
**Objective**: Test switching providers mid-conversation

**Steps:**
1. Start conversation with OpenAI
2. Continue with Claude
3. Continue with OpenAI

**Expected:**
- ✅ Context maintained across providers
- ✅ No errors

**Status**: ⬜

---

## Performance Tests

### Test 6.4.1: Response Time - OpenAI
**Objective**: Measure OpenAI response time

**Steps:**
1. Send simple prompt
2. Measure time to response

**Expected:**
- ✅ Response < 2 seconds (simple prompt)
- ✅ Response < 5 seconds (complex prompt)

**Status**: ⬜

---

### Test 6.4.2: Response Time - Claude
**Objective**: Measure Claude response time

**Expected:**
- ✅ Haiku < 1 second
- ✅ Sonnet < 3 seconds
- ✅ Opus < 5 seconds

**Status**: ⬜

---

### Test 6.4.3: Vision Processing Speed
**Objective**: Measure Vision operations

**Expected:**
- ✅ Text recognition < 1 second
- ✅ Face detection < 500ms
- ✅ Barcode scan < 200ms

**Status**: ⬜

---

### Test 6.4.4: Memory Usage
**Objective**: Test memory consumption

**Steps:**
1. Load 5 ML models
2. Measure memory
3. Unload all
4. Measure memory

**Expected:**
- ✅ Memory increases with models
- ✅ Memory decreases after unload
- ✅ No memory leaks

**Status**: ⬜

---

## Edge Cases & Error Handling

### Test 6.5.1: Empty Input
**Objective**: Test empty message handling

**Steps:**
```swift
let response = try await manager.sendMessage("")
```

**Expected:**
- ✅ Either handles gracefully or throws clear error

**Status**: ⬜

---

### Test 6.5.2: Very Long Input
**Objective**: Test max token limits

**Steps:**
1. Create text with 100K+ tokens
2. Send to AI

**Expected:**
- ✅ Throws token limit error or truncates

**Status**: ⬜

---

### Test 6.5.3: Concurrent Requests
**Objective**: Test thread safety

**Steps:**
```swift
await withTaskGroup(of: AIResponse.self) { group in
    for i in 1...10 {
        group.addTask {
            try await manager.sendMessage("Request \(i)")
        }
    }
}
```

**Expected:**
- ✅ All requests complete
- ✅ No race conditions
- ✅ No crashes

**Status**: ⬜

---

### Test 6.5.4: Network Interruption
**Objective**: Test network failure handling

**Steps:**
1. Start streaming request
2. Disable network mid-stream
3. Re-enable network

**Expected:**
- ✅ Error thrown
- ✅ Graceful handling
- ✅ Can retry

**Status**: ⬜

---

### Test 6.5.5: Invalid Model Name
**Objective**: Test non-existent model

**Steps:**
```swift
let model = try await coreMLManager.loadModel(named: "NonExistent")
```

**Expected:**
- ✅ Throws `CoreMLError.modelNotFound`

**Status**: ⬜

---

## Test Summary

| Category | Total Tests | Passed | Failed | Not Started |
|----------|-------------|--------|--------|-------------|
| OpenAI | 10 | - | - | - |
| Claude | 10 | - | - | - |
| AI Manager | 10 | - | - | - |
| Core ML | 5 | - | - | - |
| Vision | 10 | - | - | - |
| Integration | 3 | - | - | - |
| Performance | 4 | - | - | - |
| Edge Cases | 5 | - | - | - |
| **TOTAL** | **57** | **0** | **0** | **57** |

---

## Running Tests

### Manual Testing

```swift
// 1. Configure API keys
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...

// 2. Run app in debug mode
// 3. Navigate to test screens
// 4. Verify each scenario
// 5. Mark results in this document
```

### Unit Testing

```swift
// Future: Automated test suite
class AIIntegrationTests: XCTestCase {
    func testOpenAIChatCompletion() async throws {
        // Test implementation
    }
}
```

---

**Phase 6 Test Status**: ⬜ **NOT STARTED**

Test execution to be performed after deployment.
