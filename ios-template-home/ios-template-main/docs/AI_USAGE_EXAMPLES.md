# 🚀 AI Services - Quick Start Examples

## Setup Checklist

Before using AI services, ensure:

- [ ] API keys are configured (see below)
- [ ] Services are registered in DI Container ✅ (already done)
- [ ] App has internet connection (for cloud AI)
- [ ] Privacy permissions granted (for Vision features)

---

## 🔑 API Key Configuration

### Option 1: Environment Variables (Recommended)

**Xcode Scheme:**
1. Edit Scheme → Run → Arguments
2. Add Environment Variables:
   - `OPENAI_API_KEY` = `sk-...`
   - `ANTHROPIC_API_KEY` = `sk-ant-...`

### Option 2: Manual Configuration

```swift
// In your app initialization
let openAIConfig = OpenAIConfig(
    apiKey: "sk-...",
    defaultModel: .gpt35Turbo
)
let openAIService = OpenAIService(config: openAIConfig)

let claudeConfig = ClaudeConfig(
    apiKey: "sk-ant-...",
    defaultModel: .claude35Sonnet
)
let claudeService = ClaudeService(config: claudeConfig)
```

### Option 3: Secure Storage (Production)

```swift
// Store in Keychain
let keychain = DIContainer.shared.keychainStorage
try keychain.saveSecure("sk-...", forKey: "openai.api_key")
try keychain.saveSecure("sk-ant-...", forKey: "anthropic.api_key")

// Load from Keychain
if let openAIKey = try? keychain.getSecure("openai.api_key"),
   let claudeKey = try? keychain.getSecure("anthropic.api_key") {
    // Configure services
}
```

---

## 📱 SwiftUI Examples

### Example 1: Simple Chat Bot

```swift
import SwiftUI
import iOSTemplate

struct SimpleChatView: View {
    @State private var userInput = ""
    @State private var response = ""
    @State private var isLoading = false

    let aiManager = AIManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("AI Chat Bot")
                .font(.theme.headlineLarge)

            ScrollView {
                Text(response)
                    .font(.theme.bodyMedium)
                    .padding()
            }
            .frame(maxHeight: 300)

            HStack {
                TextField("Ask me anything...", text: $userInput)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    sendMessage()
                }
                .primaryButton()
                .disabled(isLoading || userInput.isEmpty)
            }
            .padding()
        }
        .padding()
    }

    func sendMessage() {
        isLoading = true
        let message = userInput
        userInput = ""

        Task {
            do {
                let result = try await aiManager.sendMessage(
                    message,
                    provider: .openai, // or .claude
                    temperature: 0.7,
                    maxTokens: 200
                )

                response = result.content

            } catch {
                response = "Error: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }
}
```

---

### Example 2: Document Scanner with OCR

```swift
import SwiftUI
import PhotosUI
import iOSTemplate

struct DocumentScannerView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var extractedText = ""
    @State private var isProcessing = false

    let vision = VisionService.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Document Scanner")
                .font(.theme.headlineLarge)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            }

            PhotosPicker(
                selection: $selectedImage,
                matching: .images
            ) {
                Text("Select Image")
                    .primaryButton()
            }
            .onChange(of: selectedImage) { newValue in
                loadImage(from: newValue)
            }

            Button("Scan Text") {
                scanText()
            }
            .secondaryButton()
            .disabled(image == nil || isProcessing)

            if !extractedText.isEmpty {
                ScrollView {
                    Text(extractedText)
                        .font(.theme.bodyMedium)
                        .padding()
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.card)
                }
            }
        }
        .padding()
    }

    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                image = uiImage
            }
        }
    }

    func scanText() {
        guard let image = image else { return }

        isProcessing = true

        Task {
            do {
                let results = try await vision.recognizeText(in: image)
                extractedText = results.map { $0.text }.joined(separator: "\n")
            } catch {
                extractedText = "Error: \(error.localizedDescription)"
            }

            isProcessing = false
        }
    }
}
```

---

### Example 3: QR Code Scanner

```swift
import SwiftUI
import iOSTemplate

struct QRScannerView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var qrData = ""
    @State private var isProcessing = false

    let vision = VisionService.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("QR Code Scanner")
                .font(.theme.headlineLarge)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            }

            PhotosPicker(
                selection: $selectedImage,
                matching: .images
            ) {
                Text("Select Image")
                    .primaryButton()
            }
            .onChange(of: selectedImage) { newValue in
                loadImage(from: newValue)
            }

            Button("Scan QR Code") {
                scanQRCode()
            }
            .secondaryButton()
            .disabled(image == nil || isProcessing)

            if !qrData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("QR Code Data:")
                        .font(.theme.labelMedium)
                        .foregroundColor(.theme.textSecondary)

                    Text(qrData)
                        .font(.theme.bodyMedium)
                        .padding()
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.card)
                }
            }
        }
        .padding()
    }

    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                image = uiImage
            }
        }
    }

    func scanQRCode() {
        guard let image = image else { return }

        isProcessing = true

        Task {
            do {
                let barcodes = try await vision.detectBarcodes(in: image)
                if let first = barcodes.first {
                    qrData = "Type: \(first.symbology)\nData: \(first.payload)"
                } else {
                    qrData = "No QR code found"
                }
            } catch {
                qrData = "Error: \(error.localizedDescription)"
            }

            isProcessing = false
        }
    }
}
```

---

### Example 4: AI-Powered Image Analysis

```swift
import SwiftUI
import iOSTemplate

struct ImageAnalysisView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var analysis = ""
    @State private var isProcessing = false

    let vision = VisionService.shared
    let aiManager = AIManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("AI Image Analysis")
                .font(.theme.headlineLarge)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            }

            PhotosPicker(
                selection: $selectedImage,
                matching: .images
            ) {
                Text("Select Image")
                    .primaryButton()
            }
            .onChange(of: selectedImage) { newValue in
                loadImage(from: newValue)
            }

            Button("Analyze Image") {
                analyzeImage()
            }
            .secondaryButton()
            .disabled(image == nil || isProcessing)

            if !analysis.isEmpty {
                ScrollView {
                    Text(analysis)
                        .font(.theme.bodyMedium)
                        .padding()
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.card)
                }
            }
        }
        .padding()
    }

    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                image = uiImage
            }
        }
    }

    func analyzeImage() {
        guard let image = image else { return }

        isProcessing = true

        Task {
            do {
                // Step 1: Classify image
                let classifications = try await vision.classifyImage(image)
                let topClass = classifications.first!

                // Step 2: Detect text
                let textResults = try await vision.recognizeText(in: image)
                let extractedText = textResults.map { $0.text }.joined(separator: " ")

                // Step 3: Detect faces
                let faces = try await vision.detectFaces(in: image, includeLandmarks: false)

                // Step 4: Get AI analysis
                let prompt = """
                Analyze this image based on:
                - Classification: \(topClass.identifier) (\(Int(topClass.confidence * 100))% confidence)
                - Text found: \(extractedText.isEmpty ? "None" : extractedText)
                - Number of faces detected: \(faces.count)

                Provide a detailed description of what you think this image contains.
                """

                let response = try await aiManager.sendMessage(
                    prompt,
                    provider: .claude,
                    temperature: 0.7,
                    maxTokens: 300
                )

                analysis = """
                ## Vision Analysis
                - Type: \(topClass.identifier)
                - Confidence: \(Int(topClass.confidence * 100))%
                - Text: \(extractedText.isEmpty ? "None" : extractedText)
                - Faces: \(faces.count)

                ## AI Description
                \(response.content)
                """

            } catch {
                analysis = "Error: \(error.localizedDescription)"
            }

            isProcessing = false
        }
    }
}
```

---

### Example 5: Text Summarizer

```swift
import SwiftUI
import iOSTemplate

struct TextSummarizerView: View {
    @State private var inputText = ""
    @State private var summary = ""
    @State private var isProcessing = false
    @State private var selectedProvider: AIProvider = .claude

    let aiManager = AIManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Text Summarizer")
                .font(.theme.headlineLarge)

            Picker("AI Provider", selection: $selectedProvider) {
                Text("Claude").tag(AIProvider.claude)
                Text("OpenAI").tag(AIProvider.openai)
            }
            .pickerStyle(.segmented)

            TextEditor(text: $inputText)
                .frame(minHeight: 150)
                .padding(Spacing.sm)
                .background(Color.theme.backgroundSecondary)
                .cornerRadius(CornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.theme.border, lineWidth: BorderWidth.standard)
                )

            Button("Summarize") {
                summarizeText()
            }
            .primaryButton()
            .disabled(inputText.isEmpty || isProcessing)

            if !summary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary:")
                        .font(.theme.labelMedium)
                        .foregroundColor(.theme.textSecondary)

                    Text(summary)
                        .font(.theme.bodyMedium)
                        .padding()
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.card)
                }
            }
        }
        .padding()
    }

    func summarizeText() {
        isProcessing = true

        Task {
            do {
                let response = try await aiManager.executeTemplate(
                    .summarize,
                    variables: ["text": inputText],
                    provider: selectedProvider
                )

                summary = response.content

            } catch {
                summary = "Error: \(error.localizedDescription)"
            }

            isProcessing = false
        }
    }
}
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. "Invalid API Key" Error

**Symptom:** API calls fail with authentication error

**Solutions:**
```swift
// Check if API key is set
print("OpenAI Key:", ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "Not set")
print("Claude Key:", ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "Not set")

// Test key validity
let service = OpenAIService.shared
do {
    let response = try await service.complete(prompt: "Say hello", model: .gpt35Turbo, maxTokens: 10)
    print("Success: \(response)")
} catch {
    print("Error: \(error)")
}
```

#### 2. "Rate Limit Exceeded"

**Symptom:** API calls fail after multiple requests

**Solutions:**
```swift
// Option 1: Wait before retry
do {
    let response = try await aiManager.sendMessage("Hello")
} catch OpenAIError.rateLimitExceeded {
    try await Task.sleep(nanoseconds: 60_000_000_000) // Wait 60s
    let response = try await aiManager.sendMessage("Hello")
}

// Option 2: Clear cache and retry
await aiManager.clearCache()
```

#### 3. Vision Features Not Working

**Symptom:** Vision API returns empty results

**Solutions:**
```swift
// Check image quality
if let cgImage = image.cgImage {
    print("Image size: \(cgImage.width)x\(cgImage.height)")
    // Ensure image is not too small (min 50x50)
}

// Try with different recognition level
// In VisionService, modify request.recognitionLevel
```

#### 4. Services Not Resolved from DI

**Symptom:** `DIContainer.shared.aiManager` returns nil

**Solutions:**
```swift
// Verify DI registration
let container = DIContainer.shared
print("OpenAI:", container.openAIService != nil)
print("Claude:", container.claudeService != nil)
print("AI Manager:", container.aiManager != nil)
print("Vision:", container.visionService != nil)

// If nil, check AIAssembly is included in assemblies array
```

---

## 📊 Performance Tips

### 1. Use Caching

```swift
// Enable caching (default: enabled)
AIManager.shared.enableCaching = true

// Same request will use cache
let response1 = try await aiManager.sendMessage("What is Swift?")
let response2 = try await aiManager.sendMessage("What is Swift?") // From cache
```

### 2. Choose Right Model

```swift
// For simple tasks: Use cheaper/faster models
let simple = try await aiManager.sendMessage(
    "Say hello",
    provider: .claude,
    // Claude Haiku is fastest/cheapest
    temperature: 0.7,
    maxTokens: 50
)

// For complex tasks: Use powerful models
let complex = try await aiManager.sendMessage(
    "Explain quantum computing",
    provider: .openai,
    // GPT-4 for complex reasoning
    temperature: 0.7,
    maxTokens: 500
)
```

### 3. Batch Vision Operations

```swift
// Instead of sequential
for image in images {
    let result = try await vision.recognizeText(in: image)
}

// Use Core ML batch (if using custom models)
let results = try await coreMLManager.batchPredict(model: model, inputs: inputs)
```

---

## 🎯 Next Steps

1. **Test Examples**: Run the examples above in your app
2. **Configure API Keys**: Set up environment variables
3. **Read Full Guide**: See `AI_INTEGRATION_GUIDE.md`
4. **Run Tests**: Execute scenarios in `TASK_6_TEST_SCENARIOS.md`
5. **Customize**: Modify for your specific use case

---

**Happy Coding! 🚀**
