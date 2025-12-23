# 🤖 AI Integration Guide

**Phase 6: AI Integration - Complete Implementation Guide**

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Services Architecture](#services-architecture)
3. [OpenAI Integration](#openai-integration)
4. [Claude Integration](#claude-integration)
5. [AI Manager (Unified Interface)](#ai-manager)
6. [Core ML Integration](#core-ml-integration)
7. [Vision Features](#vision-features)
8. [Usage Examples](#usage-examples)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Overview

Phase 6 integrates comprehensive AI capabilities into the iOS Template:

### ✅ What's Included

#### **Cloud AI Services**
- ✅ **OpenAI (GPT)** - GPT-3.5, GPT-4, GPT-4 Turbo
- ✅ **Claude (Anthropic)** - Claude 3 (Opus, Sonnet, Haiku), Claude 3.5 Sonnet
- ✅ **AI Manager** - Unified interface for all providers
- ✅ **Rate Limiting** - Automatic rate limit management
- ✅ **Response Caching** - Cache responses to reduce costs
- ✅ **Prompt Templates** - Reusable prompt templates
- ✅ **Streaming Support** - Real-time streaming responses

#### **On-Device ML**
- ✅ **Core ML Manager** - Model loading and prediction
- ✅ **Vision Service** - Computer vision tasks
  - Text recognition (OCR)
  - Object detection
  - Face detection with landmarks
  - Barcode/QR code scanning
  - Image classification
  - Body pose detection (iOS 14+)
  - Hand pose detection (iOS 14+)
  - Saliency analysis (iOS 13+)

---

## Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      AI Integration Layer                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  AI Manager  │  │  Core ML     │  │    Vision    │     │
│  │  (Unified)   │  │  Manager     │  │   Service    │     │
│  └──────┬───────┘  └──────────────┘  └──────────────┘     │
│         │                                                    │
│    ┌────┴────┐                                              │
│    │         │                                              │
│  ┌─▼──┐   ┌─▼──┐                                           │
│  │OpenAI│  │Claude│                                         │
│  └─────┘   └─────┘                                          │
└─────────────────────────────────────────────────────────────┘
         │              │
         │              │
         ▼              ▼
   OpenAI API    Anthropic API
```

### File Structure

```
Sources/iOSTemplate/Services/
├── AI/
│   ├── OpenAIModels.swift        # OpenAI data models
│   ├── OpenAIService.swift       # OpenAI API client
│   ├── ClaudeModels.swift        # Claude data models
│   ├── ClaudeService.swift       # Claude API client
│   └── AIManager.swift           # Unified AI interface
└── ML/
    ├── CoreMLManager.swift       # Core ML model management
    └── VisionService.swift       # Vision framework integration
```

---

## OpenAI Integration

### 🔧 Setup

#### 1. Configuration

```swift
import iOSTemplate

// Option 1: Load from environment
if let config = OpenAIConfig.loadFromEnvironment() {
    let service = OpenAIService(config: config)
}

// Option 2: Manual configuration
let config = OpenAIConfig(
    apiKey: "sk-...",
    defaultModel: .gpt4Turbo,
    defaultTemperature: 0.7,
    defaultMaxTokens: 1000
)
let service = OpenAIService(config: config)
```

#### 2. Environment Variables

Add to your scheme or `.xcconfig`:
```bash
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-... # Optional
```

### 📊 Models Available

| Model | Context | Cost (per 1K tokens) | Best For |
|-------|---------|----------------------|----------|
| `gpt-3.5-turbo` | 4K | $0.0005/$0.0015 | Fast, cost-effective |
| `gpt-3.5-turbo-16k` | 16K | $0.003/$0.004 | Longer contexts |
| `gpt-4` | 8K | $0.03/$0.06 | Advanced reasoning |
| `gpt-4-turbo` | 128K | $0.01/$0.03 | Long contexts, latest |

### 💬 Usage

#### Basic Chat Completion

```swift
let service = OpenAIService.shared

let messages = [
    OpenAIChatMessage(role: .system, content: "You are a helpful assistant."),
    OpenAIChatMessage(role: .user, content: "What is Swift?")
]

do {
    let response = try await service.chatCompletion(
        messages: messages,
        model: .gpt4Turbo,
        temperature: 0.7,
        maxTokens: 500
    )

    print("Response: \(response.content ?? "")")
    print("Tokens used: \(response.usage.totalTokens)")
    print("Cost: $\(String(format: "%.4f", response.usage.cost(for: .gpt4Turbo)))")
} catch {
    print("Error: \(error)")
}
```

#### Simple Completion

```swift
let answer = try await service.complete(
    prompt: "Explain async/await in Swift",
    model: .gpt35Turbo,
    maxTokens: 200
)
print(answer)
```

#### Streaming Responses

```swift
try await service.chatCompletionStream(
    messages: messages,
    model: .gpt4Turbo,
    temperature: 0.7,
    maxTokens: 1000,
    onChunk: { chunk in
        print(chunk, terminator: "")
    }
)
```

### 🎯 Rate Limiting

Built-in rate limiting (60 requests/min, 90K tokens/min):

```swift
// Automatically managed
let response = try await service.chatCompletion(...)
// If rate limit exceeded, throws OpenAIError.rateLimitExceeded
```

### ⚠️ Error Handling

```swift
do {
    let response = try await service.chatCompletion(...)
} catch OpenAIError.invalidAPIKey {
    print("Invalid API key")
} catch OpenAIError.rateLimitExceeded {
    print("Rate limit exceeded, try again later")
} catch OpenAIError.apiError(let message) {
    print("API error: \(message)")
} catch {
    print("Unknown error: \(error)")
}
```

---

## Claude Integration

### 🔧 Setup

#### 1. Configuration

```swift
// Option 1: Load from environment
if let config = ClaudeConfig.loadFromEnvironment() {
    let service = ClaudeService(config: config)
}

// Option 2: Manual configuration
let config = ClaudeConfig(
    apiKey: "sk-ant-...",
    defaultModel: .claude35Sonnet,
    defaultMaxTokens: 4096,
    defaultTemperature: 1.0
)
let service = ClaudeService(config: config)
```

#### 2. Environment Variables

```bash
ANTHROPIC_API_KEY=sk-ant-...
```

### 📊 Models Available

| Model | Context | Cost (per 1M tokens) | Best For |
|-------|---------|----------------------|----------|
| `claude-3-haiku` | 200K | $0.25/$1.25 | Fast, lightweight |
| `claude-3-sonnet` | 200K | $3/$15 | Balanced |
| `claude-3.5-sonnet` | 200K | $3/$15 | Latest, best performance |
| `claude-3-opus` | 200K | $15/$75 | Most capable, complex tasks |

### 💬 Usage

#### Basic Message

```swift
let service = ClaudeService.shared

let messages = [
    ClaudeMessage(role: .user, content: "Explain SwiftUI")
]

do {
    let response = try await service.sendMessage(
        messages: messages,
        model: .claude35Sonnet,
        system: "You are an iOS expert.",
        maxTokens: 1000,
        temperature: 1.0
    )

    print("Response: \(response.text)")
    print("Tokens: \(response.usage.totalTokens)")
    print("Cost: $\(String(format: "%.6f", response.usage.cost(for: .claude35Sonnet)))")
} catch {
    print("Error: \(error)")
}
```

#### Simple Completion

```swift
let answer = try await service.complete(
    prompt: "What is TCA?",
    model: .claude3Haiku,
    system: "You are a concise assistant.",
    maxTokens: 200
)
print(answer)
```

#### Continue Conversation

```swift
var history: [ClaudeMessage] = [
    ClaudeMessage(role: .user, content: "Hi, I'm learning Swift"),
    ClaudeMessage(role: .assistant, content: "Great! How can I help?")
]

let response = try await service.continueConversation(
    history: history,
    userMessage: "What's the difference between struct and class?",
    system: "You are a patient Swift teacher."
)
print(response)

// Add to history
history.append(ClaudeMessage(role: .user, content: "What's the difference between struct and class?"))
history.append(ClaudeMessage(role: .assistant, content: response))
```

#### Streaming

```swift
try await service.sendMessageStream(
    messages: messages,
    model: .claude35Sonnet,
    system: "You are helpful.",
    maxTokens: 2000,
    temperature: 1.0,
    onChunk: { chunk in
        print(chunk, terminator: "")
    }
)
```

### 🖼️ Vision Support

Claude 3 supports images:

```swift
let imageData = image.pngData()!.base64EncodedString()

let imageContent = ClaudeContent(
    imageSource: ClaudeImageSource(
        mediaType: "image/png",
        data: imageData
    )
)

let textContent = ClaudeContent(text: "What's in this image?")

let message = ClaudeMessage(
    role: .user,
    content: [imageContent, textContent]
)

let response = try await service.sendMessage(
    messages: [message],
    model: .claude35Sonnet,
    system: nil,
    maxTokens: 1000,
    temperature: 1.0
)
```

---

## AI Manager

### 🎯 Unified Interface

AI Manager provides a single interface for all AI providers:

```swift
let manager = AIManager.shared

// Set default provider
manager.defaultProvider = .openai // or .claude
manager.enableCaching = true
```

### 💬 Basic Usage

```swift
// Simple message (uses default provider)
let response = try await manager.sendMessage(
    "Explain dependency injection",
    provider: nil, // Uses default
    temperature: 0.7,
    maxTokens: 500
)

print(response.content)
print("Provider: \(response.provider)")
print("Model: \(response.model)")
print("Cost: $\(String(format: "%.4f", response.usage.cost))")
```

### 🔄 Switch Providers

```swift
// Use OpenAI
let openAIResponse = try await manager.sendMessage(
    "What is Swift?",
    provider: .openai,
    temperature: 0.7,
    maxTokens: 200
)

// Use Claude
let claudeResponse = try await manager.sendMessage(
    "What is Swift?",
    provider: .claude,
    temperature: 1.0,
    maxTokens: 200
)
```

### 💬 Conversation History

```swift
var history: [AIMessage] = [
    AIMessage(role: .system, content: "You are a Swift expert."),
    AIMessage(role: .user, content: "What is a protocol?"),
    AIMessage(role: .assistant, content: "A protocol defines...")
]

let response = try await manager.continueConversation(
    history: history,
    userMessage: "Can you give an example?",
    provider: .openai
)

// Add to history
history.append(AIMessage(role: .user, content: "Can you give an example?"))
history.append(AIMessage(role: .assistant, content: response.content))
```

### 📝 Prompt Templates

#### Predefined Templates

```swift
// Summarization
let response = try await manager.executeTemplate(
    .summarize,
    variables: ["text": longArticle],
    provider: .claude
)

// Translation
let translated = try await manager.executeTemplate(
    .translate,
    variables: [
        "source_lang": "English",
        "target_lang": "Vietnamese",
        "text": "Hello, how are you?"
    ],
    provider: .openai
)

// Code generation
let code = try await manager.executeTemplate(
    .codeGeneration,
    variables: [
        "language": "Swift",
        "task": "Fibonacci sequence",
        "requirements": "Use recursion, include memoization"
    ],
    provider: .claude
)
```

#### Custom Templates

```swift
let customTemplate = PromptTemplate(
    name: "API Documentation",
    systemPrompt: "You are an expert technical writer.",
    userPromptTemplate: """
    Generate API documentation for:

    Function: {{function_name}}
    Parameters: {{parameters}}
    Return type: {{return_type}}
    """,
    variables: ["function_name", "parameters", "return_type"]
)

let docs = try await manager.executeTemplate(
    customTemplate,
    variables: [
        "function_name": "fetchUser",
        "parameters": "userId: String",
        "return_type": "async throws -> User"
    ],
    provider: .openai
)
```

### 💾 Response Caching

```swift
manager.enableCaching = true // Default: true

// First call - makes API request
let response1 = try await manager.sendMessage("What is TCA?")

// Second call with same message - returns cached
let response2 = try await manager.sendMessage("What is TCA?")

// Clear cache
await manager.clearCache()
```

### 📡 Streaming

```swift
var fullResponse = ""

try await manager.sendMessageStream(
    "Write a short story about AI",
    provider: .claude,
    onChunk: { chunk in
        fullResponse += chunk
        print(chunk, terminator: "")
    }
)
```

---

## Core ML Integration

### 🧠 Core ML Manager

Manage on-device ML models:

```swift
let manager = CoreMLManager.shared
```

### 📦 Load Model

```swift
// Load from bundle
let model = try await manager.loadModel(named: "MyModel")

// Check if model exists
if manager.modelExists(named: "MyModel") {
    // Load and use
}

// Get model info
let info = manager.getModelInfo(for: model)
print("Model: \(info.name) v\(info.version)")
```

### 🔮 Make Predictions

```swift
// Simplified example
let result = try await manager.predict(
    model: model,
    input: inputFeatures,
    outputType: OutputFeatures.self
)

print("Processing time: \(result.processingTime)s")
```

### 📥 Download & Update Models

```swift
// Download new model
let modelURL = URL(string: "https://example.com/model.mlmodel")!
let localURL = try await manager.downloadModel(
    from: modelURL,
    named: "NewModel"
)

// Update existing model
try await manager.updateModel(
    named: "MyModel",
    from: modelURL
)
```

### ⚙️ Configuration

```swift
// Configure compute units
let config = manager.configureModel(
    model,
    computeUnits: .all // CPU, GPU, Neural Engine
)

// Get recommended units for device
let recommended = manager.recommendedComputeUnits()
// Returns .cpuOnly on simulator, .all on device
```

### 🔄 Batch Predictions

```swift
let inputs: [MLFeatureProvider] = [input1, input2, input3]

let results = try await manager.batchPredict(
    model: model,
    inputs: inputs
)
```

### 🗑️ Memory Management

```swift
// Unload specific model
manager.unloadModel(named: "MyModel")

// Unload all models
manager.unloadAllModels()
```

---

## Vision Features

### 👁️ Vision Service

Computer vision capabilities:

```swift
let vision = VisionService.shared
```

### 📝 Text Recognition (OCR)

```swift
let results = try await vision.recognizeText(in: image)

for result in results {
    print("Text: \(result.text)")
    print("Confidence: \(result.confidence)")
    print("Bounding box: \(result.boundingBox)")
}
```

### 🎯 Object Detection

```swift
let objects = try await vision.detectObjects(in: image)

for obj in objects {
    print("Object: \(obj.identifier)")
    print("Confidence: \(obj.confidence)")
    print("Location: \(obj.boundingBox)")
}
```

### 😊 Face Detection

```swift
// Basic face detection
let faces = try await vision.detectFaces(
    in: image,
    includeLandmarks: false
)

for face in faces {
    print("Face at: \(face.boundingBox)")
}

// With landmarks
let facesWithLandmarks = try await vision.detectFaces(
    in: image,
    includeLandmarks: true
)

for face in facesWithLandmarks {
    if let landmarks = face.landmarks {
        print("Left eye: \(landmarks.leftEye)")
        print("Right eye: \(landmarks.rightEye)")
        print("Nose: \(landmarks.nose)")
        print("Mouth: \(landmarks.mouth)")
    }

    print("Roll: \(face.roll)")
    print("Yaw: \(face.yaw)")
    print("Pitch: \(face.pitch)")
}
```

### 📷 Barcode/QR Code Scanning

```swift
let barcodes = try await vision.detectBarcodes(in: image)

for barcode in barcodes {
    print("Data: \(barcode.payload)")
    print("Type: \(barcode.symbology)")
    print("Location: \(barcode.boundingBox)")
}
```

### 🖼️ Image Classification

```swift
let classifications = try await vision.classifyImage(image)

for (identifier, confidence) in classifications {
    print("\(identifier): \(Int(confidence * 100))%")
}
```

### 🤸 Advanced Features (iOS 14+)

#### Body Pose Detection

```swift
if #available(iOS 14.0, *) {
    if let pose = try await vision.detectBodyPose(in: image) {
        // Access recognized points
        let recognizedPoints = pose.recognizedPoints
        // Process body joints, skeleton, etc.
    }
}
```

#### Hand Pose Detection

```swift
if #available(iOS 14.0, *) {
    let hands = try await vision.detectHandPose(in: image)

    for hand in hands {
        // Access hand landmarks
        // Process finger positions, gestures, etc.
    }
}
```

#### Saliency Analysis

```swift
if #available(iOS 13.0, *) {
    if let saliency = try await vision.generateSaliency(for: image) {
        // Get salient objects (attention-grabbing regions)
        let salientObjects = saliency.salientObjects
    }
}
```

---

## Usage Examples

### Example 1: Chat Bot with AI Manager

```swift
import SwiftUI
import iOSTemplate

struct ChatBotView: View {
    @State private var messages: [AIMessage] = []
    @State private var input = ""
    @State private var isLoading = false

    let aiManager = AIManager.shared

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.timestamp) { message in
                    MessageRow(message: message)
                }
            }

            HStack {
                TextField("Type a message", text: $input)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    sendMessage()
                }
                .disabled(isLoading || input.isEmpty)
            }
            .padding()
        }
        .onAppear {
            messages.append(AIMessage(
                role: .system,
                content: "You are a helpful iOS development assistant."
            ))
        }
    }

    func sendMessage() {
        let userMessage = input
        input = ""

        messages.append(AIMessage(role: .user, content: userMessage))

        isLoading = true

        Task {
            do {
                let response = try await aiManager.continueConversation(
                    history: messages,
                    userMessage: userMessage,
                    provider: .claude
                )

                messages.append(AIMessage(
                    role: .assistant,
                    content: response.content
                ))
            } catch {
                print("Error: \(error)")
            }

            isLoading = false
        }
    }
}
```

### Example 2: Document Scanner with Vision

```swift
import SwiftUI
import iOSTemplate

struct DocumentScannerView: View {
    @State private var image: UIImage?
    @State private var recognizedText = ""
    @State private var isProcessing = false

    let vision = VisionService.shared

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No image selected")
            }

            Button("Select Image") {
                // Show image picker
            }

            Button("Scan Text") {
                scanText()
            }
            .disabled(image == nil || isProcessing)

            if !recognizedText.isEmpty {
                ScrollView {
                    Text(recognizedText)
                        .padding()
                }
            }
        }
    }

    func scanText() {
        guard let image = image else { return }

        isProcessing = true

        Task {
            do {
                let results = try await vision.recognizeText(in: image)
                recognizedText = results.map { $0.text }.joined(separator: "\n")
            } catch {
                print("Error: \(error)")
            }

            isProcessing = false
        }
    }
}
```

### Example 3: Smart Image Analysis

```swift
Task {
    let vision = VisionService.shared
    let aiManager = AIManager.shared

    // 1. Classify image
    let classifications = try await vision.classifyImage(image)
    let topResult = classifications.first!

    // 2. Detect text
    let textResults = try await vision.recognizeText(in: image)
    let extractedText = textResults.map { $0.text }.joined(separator: " ")

    // 3. Detect faces
    let faces = try await vision.detectFaces(in: image, includeLandmarks: true)

    // 4. Generate AI description
    let prompt = """
    Describe this image based on:
    - Classification: \(topResult.identifier) (\(Int(topResult.confidence * 100))% confidence)
    - Text found: \(extractedText)
    - Number of faces: \(faces.count)
    """

    let description = try await aiManager.sendMessage(
        prompt,
        provider: .claude,
        temperature: 0.7,
        maxTokens: 200
    )

    print("AI Description: \(description.content)")
}
```

---

## Best Practices

### 🔑 API Keys

**DO:**
- ✅ Store API keys in environment variables
- ✅ Use `.gitignore` for keys in config files
- ✅ Use keychain for production apps
- ✅ Rotate keys regularly

**DON'T:**
- ❌ Hardcode keys in source code
- ❌ Commit keys to version control
- ❌ Share keys in logs or error messages

### 💰 Cost Management

**OpenAI:**
```swift
// Use cheaper models for simple tasks
let summary = try await service.complete(
    prompt: text,
    model: .gpt35Turbo, // Cheaper
    maxTokens: 100
)

// Use GPT-4 only when needed
let complexAnalysis = try await service.complete(
    prompt: text,
    model: .gpt4Turbo, // More expensive, more capable
    maxTokens: 500
)
```

**Claude:**
```swift
// Use Haiku for fast, simple tasks
let quickResponse = try await service.complete(
    prompt: prompt,
    model: .claude3Haiku, // Fastest, cheapest
    system: nil,
    maxTokens: 200
)

// Use Opus for complex reasoning
let complexTask = try await service.complete(
    prompt: prompt,
    model: .claude3Opus, // Most capable, expensive
    system: systemPrompt,
    maxTokens: 2000
)
```

### 🚀 Performance

**Enable Caching:**
```swift
let manager = AIManager.shared
manager.enableCaching = true // Reduce duplicate requests
```

**Use Batch Operations:**
```swift
// Instead of multiple single predictions
for input in inputs {
    let result = try await manager.predict(model: model, input: input)
}

// Use batch prediction
let results = try await manager.batchPredict(model: model, inputs: inputs)
```

**Unload Unused Models:**
```swift
// After using ML model
CoreMLManager.shared.unloadModel(named: "MyModel")
```

### 🔒 Privacy

**Data Handling:**
- Never send personal data to AI APIs without user consent
- Anonymize data when possible
- Follow GDPR/privacy regulations

**On-Device First:**
```swift
// Prefer on-device ML for sensitive data
let result = try await VisionService.shared.recognizeText(in: image)

// Only use cloud AI for non-sensitive tasks
let summary = try await AIManager.shared.sendMessage(publicData)
```

### ⚠️ Error Handling

**Always handle errors:**
```swift
do {
    let response = try await aiManager.sendMessage(prompt)
} catch OpenAIError.rateLimitExceeded {
    // Wait and retry
    try await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds
    let response = try await aiManager.sendMessage(prompt)
} catch ClaudeError.invalidAPIKey {
    // Prompt user to configure API key
} catch {
    // Generic error handling
    print("Error: \(error.localizedDescription)")
}
```

---

## Troubleshooting

### OpenAI Issues

**Problem: "Invalid API Key"**
```swift
// Solution: Check environment variable
print(ProcessInfo.processInfo.environment["OPENAI_API_KEY"])

// Or configure manually
let config = OpenAIConfig(apiKey: "sk-...")
```

**Problem: "Rate limit exceeded"**
```swift
// Solution: Implement exponential backoff
var retries = 0
while retries < 3 {
    do {
        let response = try await service.chatCompletion(...)
        break
    } catch OpenAIError.rateLimitExceeded {
        retries += 1
        let delay = UInt64(pow(2.0, Double(retries))) * 1_000_000_000
        try await Task.sleep(nanoseconds: delay)
    }
}
```

### Claude Issues

**Problem: "Context too long"**
```swift
// Solution: Reduce maxTokens or shorten input
let response = try await service.sendMessage(
    messages: messages,
    model: .claude3Haiku, // Smaller model
    system: nil,
    maxTokens: 2000, // Reduce from 4096
    temperature: 1.0
)
```

### Vision Issues

**Problem: "Text recognition not working"**
```swift
// Ensure image has good quality
// Check image orientation
// Try different recognition levels
let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate // or .fast
```

**Problem: "Face detection not finding faces"**
```swift
// Ensure faces are visible and not too small
// Try different image scales
// Check image quality and lighting
```

---

## Next Steps

1. **Test Integration**: Run test scenarios (see `TASK_6_TEST_SCENARIOS.md`)
2. **Configure API Keys**: Set up environment variables
3. **Customize Templates**: Create app-specific prompt templates
4. **Add ML Models**: Include custom Core ML models
5. **Monitor Costs**: Track API usage and costs
6. **Optimize Performance**: Profile and optimize for your use case

---

**Phase 6 Status**: ✅ **COMPLETE**

All AI integration features implemented and ready for production use!
