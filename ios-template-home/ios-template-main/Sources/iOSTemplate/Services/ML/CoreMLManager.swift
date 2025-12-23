import Foundation
import CoreML

// MARK: - Core ML Model Info

/// Core ML model metadata
public struct MLModelInfo {
    public let name: String
    public let version: String
    public let author: String?
    public let description: String?
    public let license: String?

    public init(
        name: String,
        version: String,
        author: String? = nil,
        description: String? = nil,
        license: String? = nil
    ) {
        self.name = name
        self.version = version
        self.author = author
        self.description = description
        self.license = license
    }
}

// MARK: - ML Model Type

/// Types of ML models supported
public enum MLModelType: String {
    case imageClassification = "Image Classification"
    case objectDetection = "Object Detection"
    case textClassification = "Text Classification"
    case sentimentAnalysis = "Sentiment Analysis"
    case custom = "Custom Model"

    /// File extension
    public var fileExtension: String {
        ".mlmodel" // Uncompiled
    }

    /// Compiled extension
    public var compiledExtension: String {
        ".mlmodelc" // Compiled
    }
}

// MARK: - Prediction Result

/// Generic prediction result
public struct MLPredictionResult<T> {
    public let output: T
    public let confidence: Double?
    public let processingTime: TimeInterval
    public let modelName: String

    public init(
        output: T,
        confidence: Double? = nil,
        processingTime: TimeInterval,
        modelName: String
    ) {
        self.output = output
        self.confidence = confidence
        self.processingTime = processingTime
        self.modelName = modelName
    }
}

// MARK: - Protocol

/// Core ML Manager protocol
public protocol CoreMLManagerProtocol {
    /// Load model from bundle
    func loadModel(named name: String) async throws -> MLModel

    /// Compile model
    func compileModel(at url: URL) async throws -> URL

    /// Check if model exists
    func modelExists(named name: String) -> Bool

    /// Get model info
    func getModelInfo(for model: MLModel) -> MLModelInfo

    /// Perform prediction
    func predict<Input, Output>(
        model: MLModel,
        input: Input,
        outputType: Output.Type
    ) async throws -> MLPredictionResult<Output> where Input: MLFeatureProvider
}

// MARK: - Implementation

/// Core ML Manager - Handle ML model loading and predictions
public final class CoreMLManager: CoreMLManagerProtocol {

    // MARK: - Properties

    private var loadedModels: [String: MLModel] = [:]
    private let modelCache: NSCache<NSString, MLModel>

    // MARK: - Singleton

    public static let shared = CoreMLManager()

    // MARK: - Initialization

    public init() {
        self.modelCache = NSCache<NSString, MLModel>()
        self.modelCache.countLimit = 5 // Cache up to 5 models
        logInfo("Core ML Manager initialized")
    }

    // MARK: - Public Methods

    public func loadModel(named name: String) async throws -> MLModel {
        // Check cache first
        if let cached = modelCache.object(forKey: name as NSString) {
            logDebug("Model '\(name)' loaded from cache")
            return cached
        }

        // Check if already loaded
        if let loaded = loadedModels[name] {
            logDebug("Model '\(name)' already loaded")
            return loaded
        }

        logInfo("Loading model '\(name)'")

        // Find compiled model in bundle
        guard let compiledModelURL = Bundle.main.url(
            forResource: name,
            withExtension: "mlmodelc"
        ) else {
            // Try to find and compile uncompiled model
            if let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodel") {
                logDebug("Compiling model '\(name)'")
                let compiledURL = try await compileModel(at: modelURL)
                return try await loadCompiledModel(at: compiledURL, name: name)
            }

            throw CoreMLError.modelNotFound(name)
        }

        return try await loadCompiledModel(at: compiledModelURL, name: name)
    }

    public func compileModel(at url: URL) async throws -> URL {
        do {
            let compiledURL = try await MLModel.compileModel(at: url)
            logInfo("Model compiled successfully at: \(compiledURL.path)")
            return compiledURL
        } catch {
            logError("Failed to compile model: \(error)")
            throw CoreMLError.compilationFailed(error)
        }
    }

    public func modelExists(named name: String) -> Bool {
        // Check if already loaded
        if loadedModels[name] != nil {
            return true
        }

        // Check bundle for compiled model
        if Bundle.main.url(forResource: name, withExtension: "mlmodelc") != nil {
            return true
        }

        // Check bundle for uncompiled model
        if Bundle.main.url(forResource: name, withExtension: "mlmodel") != nil {
            return true
        }

        return false
    }

    public func getModelInfo(for model: MLModel) -> MLModelInfo {
        let description = model.modelDescription

        return MLModelInfo(
            name: "CoreMLModel",
            version: "1.0",
            author: description.metadata[.author] as? String,
            description: description.metadata[.description] as? String,
            license: description.metadata[.license] as? String
        )
    }

    public func predict<Input, Output>(
        model: MLModel,
        input: Input,
        outputType: Output.Type
    ) async throws -> MLPredictionResult<Output> where Input: MLFeatureProvider {
        let startTime = Date()

        do {
            let prediction = try model.prediction(from: input)

            let processingTime = Date().timeIntervalSince(startTime)

            // Extract output (simplified - in production, properly parse MLFeatureProvider)
            guard let output = prediction as? Output else {
                throw CoreMLError.invalidOutput
            }

            logDebug("Prediction completed in \(String(format: "%.3f", processingTime))s")

            return MLPredictionResult(
                output: output,
                confidence: nil,
                processingTime: processingTime,
                modelName: "model"
            )
        } catch {
            logError("Prediction failed: \(error)")
            throw CoreMLError.predictionFailed(error)
        }
    }

    /// Unload model from memory
    public func unloadModel(named name: String) {
        loadedModels.removeValue(forKey: name)
        modelCache.removeObject(forKey: name as NSString)
        logDebug("Model '\(name)' unloaded")
    }

    /// Unload all models
    public func unloadAllModels() {
        loadedModels.removeAll()
        modelCache.removeAllObjects()
        logInfo("All models unloaded")
    }

    // MARK: - Private Methods

    private func loadCompiledModel(at url: URL, name: String) async throws -> MLModel {
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all // Use CPU, GPU, and Neural Engine

            let model = try MLModel(contentsOf: url, configuration: configuration)

            // Cache model
            loadedModels[name] = model
            modelCache.setObject(model, forKey: name as NSString)

            logInfo("Model '\(name)' loaded successfully")

            return model
        } catch {
            logError("Failed to load model '\(name)': \(error)")
            throw CoreMLError.loadingFailed(error)
        }
    }
}

// MARK: - Errors

public enum CoreMLError: Error, LocalizedError {
    case modelNotFound(String)
    case compilationFailed(Error)
    case loadingFailed(Error)
    case predictionFailed(Error)
    case invalidInput
    case invalidOutput
    case modelUpdateFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Model '\(name)' not found in bundle"
        case .compilationFailed(let error):
            return "Model compilation failed: \(error.localizedDescription)"
        case .loadingFailed(let error):
            return "Model loading failed: \(error.localizedDescription)"
        case .predictionFailed(let error):
            return "Prediction failed: \(error.localizedDescription)"
        case .invalidInput:
            return "Invalid input for model"
        case .invalidOutput:
            return "Invalid output from model"
        case .modelUpdateFailed(let error):
            return "Model update failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Model Download & Update

extension CoreMLManager {
    /// Download model from URL
    public func downloadModel(from url: URL, named name: String) async throws -> URL {
        logInfo("Downloading model '\(name)' from \(url)")

        let (localURL, response) = try await URLSession.shared.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CoreMLError.loadingFailed(URLError(.badServerResponse))
        }

        // Move to documents directory
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let destinationURL = documentsPath.appendingPathComponent("\(name).mlmodel")

        // Remove existing file if present
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.moveItem(at: localURL, to: destinationURL)

        logInfo("Model downloaded to: \(destinationURL.path)")

        return destinationURL
    }

    /// Update model
    public func updateModel(named name: String, from url: URL) async throws {
        logInfo("Updating model '\(name)'")

        // Download new model
        let downloadedURL = try await downloadModel(from: url, named: name)

        // Compile new model
        let compiledURL = try await compileModel(at: downloadedURL)

        // Unload old model
        unloadModel(named: name)

        // Load new model
        _ = try await loadCompiledModel(at: compiledURL, name: name)

        logInfo("Model '\(name)' updated successfully")
    }
}

// MARK: - Model Configuration

extension CoreMLManager {
    /// Configure model computation units
    public func configureModel(
        _ model: MLModel,
        computeUnits: MLComputeUnits
    ) -> MLModelConfiguration {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        return configuration
    }

    /// Get recommended compute units based on device
    public func recommendedComputeUnits() -> MLComputeUnits {
        #if targetEnvironment(simulator)
        return .cpuOnly
        #else
        // On device, use all available units (CPU, GPU, Neural Engine)
        return .all
        #endif
    }
}

// MARK: - Batch Predictions

extension CoreMLManager {
    /// Perform batch predictions
    public func batchPredict<Input>(
        model: MLModel,
        inputs: [Input]
    ) async throws -> [MLFeatureProvider] where Input: MLFeatureProvider {
        logInfo("Performing batch prediction with \(inputs.count) inputs")

        let startTime = Date()

        do {
            let batchProvider = MLArrayBatchProvider(array: inputs)
            let results = try model.predictions(from: batchProvider, options: MLPredictionOptions())

            let processingTime = Date().timeIntervalSince(startTime)
            logInfo("Batch prediction completed in \(String(format: "%.3f", processingTime))s")

            var predictions: [MLFeatureProvider] = []
            for i in 0..<results.count {
                predictions.append(results.features(at: i))
            }

            return predictions
        } catch {
            logError("Batch prediction failed: \(error)")
            throw CoreMLError.predictionFailed(error)
        }
    }
}

// MARK: - Logging Helpers

private func logDebug(_ message: String) {
    #if DEBUG
    print("🧠 [CoreML] \(message)")
    #endif
}

private func logInfo(_ message: String) {
    print("ℹ️ [CoreML] \(message)")
}

private func logError(_ message: String) {
    print("❌ [CoreML] \(message)")
}
