import Foundation
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Vision Result Types

/// Text recognition result
public struct TextRecognitionResult {
    public let text: String
    public let confidence: Float
    public let boundingBox: CGRect

    public init(text: String, confidence: Float, boundingBox: CGRect) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

/// Object detection result
public struct ObjectDetectionResult {
    public let identifier: String
    public let confidence: Float
    public let boundingBox: CGRect

    public init(identifier: String, confidence: Float, boundingBox: CGRect) {
        self.identifier = identifier
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

/// Face detection result
public struct FaceDetectionResult {
    public let boundingBox: CGRect
    public let landmarks: FaceLandmarks?
    public let roll: Float?
    public let yaw: Float?
    public let pitch: Float?

    public init(
        boundingBox: CGRect,
        landmarks: FaceLandmarks? = nil,
        roll: Float? = nil,
        yaw: Float? = nil,
        pitch: Float? = nil
    ) {
        self.boundingBox = boundingBox
        self.landmarks = landmarks
        self.roll = roll
        self.yaw = yaw
        self.pitch = pitch
    }
}

/// Face landmarks
public struct FaceLandmarks {
    public let leftEye: CGPoint?
    public let rightEye: CGPoint?
    public let nose: CGPoint?
    public let mouth: CGPoint?

    public init(leftEye: CGPoint?, rightEye: CGPoint?, nose: CGPoint?, mouth: CGPoint?) {
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.nose = nose
        self.mouth = mouth
    }
}

/// Barcode detection result
public struct BarcodeDetectionResult {
    public let payload: String
    public let symbology: String
    public let boundingBox: CGRect

    public init(payload: String, symbology: String, boundingBox: CGRect) {
        self.payload = payload
        self.symbology = symbology
        self.boundingBox = boundingBox
    }
}

// MARK: - Protocol

/// Vision service protocol
public protocol VisionServiceProtocol {
    /// Recognize text in image
    func recognizeText(in image: CGImage) async throws -> [TextRecognitionResult]

    /// Detect objects in image
    func detectObjects(in image: CGImage) async throws -> [ObjectDetectionResult]

    /// Detect faces in image
    func detectFaces(in image: CGImage, includeLandmarks: Bool) async throws -> [FaceDetectionResult]

    /// Detect barcodes in image
    func detectBarcodes(in image: CGImage) async throws -> [BarcodeDetectionResult]

    /// Classify image
    func classifyImage(_ image: CGImage) async throws -> [(identifier: String, confidence: Float)]
}

// MARK: - Implementation

/// Vision service - Handle Vision framework operations
public final class VisionService: VisionServiceProtocol {

    // MARK: - Singleton

    public static let shared = VisionService()

    // MARK: - Initialization

    public init() {
        logInfo("Vision service initialized")
    }

    // MARK: - Text Recognition

    public func recognizeText(in image: CGImage) async throws -> [TextRecognitionResult] {
        logDebug("Starting text recognition")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.recognitionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.compactMap { observation -> TextRecognitionResult? in
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }

                    return TextRecognitionResult(
                        text: topCandidate.string,
                        confidence: topCandidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }

                logInfo("Recognized \(results.count) text blocks")
                continuation.resume(returning: results)
            }

            // Configure request
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    // MARK: - Object Detection

    public func detectObjects(in image: CGImage) async throws -> [ObjectDetectionResult] {
        logDebug("Starting object detection")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.detectionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.map { observation in
                    ObjectDetectionResult(
                        identifier: "Rectangle",
                        confidence: observation.confidence,
                        boundingBox: observation.boundingBox
                    )
                }

                logInfo("Detected \(results.count) objects")
                continuation.resume(returning: results)
            }

            // Configure request
            request.minimumConfidence = 0.5
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 1.0

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    // MARK: - Face Detection

    public func detectFaces(
        in image: CGImage,
        includeLandmarks: Bool = false
    ) async throws -> [FaceDetectionResult] {
        logDebug("Starting face detection")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.detectionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNFaceObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.map { observation -> FaceDetectionResult in
                    var landmarks: FaceLandmarks?

                    if includeLandmarks, let faceLandmarks = observation.landmarks {
                        landmarks = FaceLandmarks(
                            leftEye: faceLandmarks.leftEye?.normalizedPoints.first,
                            rightEye: faceLandmarks.rightEye?.normalizedPoints.first,
                            nose: faceLandmarks.nose?.normalizedPoints.first,
                            mouth: faceLandmarks.outerLips?.normalizedPoints.first
                        )
                    }

                    return FaceDetectionResult(
                        boundingBox: observation.boundingBox,
                        landmarks: landmarks,
                        roll: observation.roll?.floatValue,
                        yaw: observation.yaw?.floatValue,
                        pitch: observation.pitch?.floatValue
                    )
                }

                logInfo("Detected \(results.count) faces")
                continuation.resume(returning: results)
            }

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    // MARK: - Barcode Detection

    public func detectBarcodes(in image: CGImage) async throws -> [BarcodeDetectionResult] {
        logDebug("Starting barcode detection")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.detectionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNBarcodeObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.compactMap { observation -> BarcodeDetectionResult? in
                    guard let payload = observation.payloadStringValue else {
                        return nil
                    }

                    return BarcodeDetectionResult(
                        payload: payload,
                        symbology: observation.symbology.rawValue,
                        boundingBox: observation.boundingBox
                    )
                }

                logInfo("Detected \(results.count) barcodes")
                continuation.resume(returning: results)
            }

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    // MARK: - Image Classification

    public func classifyImage(_ image: CGImage) async throws -> [(identifier: String, confidence: Float)] {
        logDebug("Starting image classification")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.classificationFailed(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let results = observations.prefix(5).map { observation in
                    (identifier: observation.identifier, confidence: observation.confidence)
                }

                logInfo("Classified image with \(results.count) results")
                continuation.resume(returning: results)
            }

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }
}

// MARK: - UIImage Convenience

#if canImport(UIKit)
extension VisionService {
    /// Recognize text in UIImage
    public func recognizeText(in image: UIImage) async throws -> [TextRecognitionResult] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        return try await recognizeText(in: cgImage)
    }

    /// Detect objects in UIImage
    public func detectObjects(in image: UIImage) async throws -> [ObjectDetectionResult] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        return try await detectObjects(in: cgImage)
    }

    /// Detect faces in UIImage
    public func detectFaces(
        in image: UIImage,
        includeLandmarks: Bool = false
    ) async throws -> [FaceDetectionResult] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        return try await detectFaces(in: cgImage, includeLandmarks: includeLandmarks)
    }

    /// Detect barcodes in UIImage
    public func detectBarcodes(in image: UIImage) async throws -> [BarcodeDetectionResult] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        return try await detectBarcodes(in: cgImage)
    }

    /// Classify UIImage
    public func classifyImage(_ image: UIImage) async throws -> [(identifier: String, confidence: Float)] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        return try await classifyImage(cgImage)
    }
}
#endif

// MARK: - Advanced Features

extension VisionService {
    /// Detect human body pose
    @available(iOS 14.0, *)
    public func detectBodyPose(in image: CGImage) async throws -> VNHumanBodyPoseObservation? {
        logDebug("Starting body pose detection")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.detectionFailed(error))
                    return
                }

                guard let observation = request.results?.first as? VNHumanBodyPoseObservation else {
                    continuation.resume(returning: nil)
                    return
                }

                logInfo("Body pose detected")
                continuation.resume(returning: observation)
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    /// Detect hand pose
    @available(iOS 14.0, *)
    public func detectHandPose(in image: CGImage) async throws -> [VNHumanHandPoseObservation] {
        logDebug("Starting hand pose detection")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanHandPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.detectionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNHumanHandPoseObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                logInfo("Detected \(observations.count) hands")
                continuation.resume(returning: observations)
            }

            request.maximumHandCount = 2

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }

    /// Generate attention-based saliency
    @available(iOS 13.0, *)
    public func generateSaliency(for image: CGImage) async throws -> VNSaliencyImageObservation? {
        logDebug("Generating saliency map")

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: VisionError.requestFailed(error))
                    return
                }

                guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                    continuation.resume(returning: nil)
                    return
                }

                logInfo("Saliency map generated")
                continuation.resume(returning: observation)
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionError.requestFailed(error))
            }
        }
    }
}

// MARK: - Errors

public enum VisionError: Error, LocalizedError {
    case invalidImage
    case recognitionFailed(Error)
    case detectionFailed(Error)
    case classificationFailed(Error)
    case requestFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .recognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        case .detectionFailed(let error):
            return "Detection failed: \(error.localizedDescription)"
        case .classificationFailed(let error):
            return "Classification failed: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Vision request failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Logging Helpers

private func logDebug(_ message: String) {
    #if DEBUG
    print("👁️ [Vision] \(message)")
    #endif
}

private func logInfo(_ message: String) {
    print("ℹ️ [Vision] \(message)")
}

private func logError(_ message: String) {
    print("❌ [Vision] \(message)")
}
