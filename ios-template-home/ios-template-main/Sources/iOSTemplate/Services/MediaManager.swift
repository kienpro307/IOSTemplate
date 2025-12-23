import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Media Manager Protocol

/// Protocol for managing media (camera, photos, videos)
public protocol MediaManagerProtocol {
    /// Capture photo from camera
    func capturePhoto() async throws -> MediaItem

    /// Pick photo from library
    func pickPhotoFromLibrary() async throws -> MediaItem

    /// Pick multiple photos from library
    func pickMultiplePhotos(limit: Int) async throws -> [MediaItem]

    /// Pick video from library
    func pickVideo() async throws -> MediaItem

    /// Save image to photo library
    func saveImageToLibrary(_ image: UIImage) async throws

    /// Save video to photo library
    func saveVideoToLibrary(at url: URL) async throws

    /// Compress image
    func compressImage(_ image: UIImage, quality: CompressionQuality) -> Data?

    /// Generate thumbnail
    func generateThumbnail(from image: UIImage, size: CGSize) -> UIImage?

    /// Generate video thumbnail
    func generateVideoThumbnail(from url: URL) async throws -> UIImage
}

// MARK: - Media Item

/// Represents a media item (photo or video)
public struct MediaItem: Identifiable {
    public let id: UUID
    public let type: MediaType
    public let data: Data?
    public let url: URL?
    public let image: UIImage?
    public let thumbnail: UIImage?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        type: MediaType,
        data: Data? = nil,
        url: URL? = nil,
        image: UIImage? = nil,
        thumbnail: UIImage? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.url = url
        self.image = image
        self.thumbnail = thumbnail
        self.createdAt = createdAt
    }
}

// MARK: - Media Type

/// Type of media
public enum MediaType {
    case photo
    case video
    case livePhoto

    public var icon: String {
        switch self {
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .livePhoto:
            return "livephoto"
        }
    }
}

// MARK: - Compression Quality

/// Image compression quality
public enum CompressionQuality {
    case low // 0.3
    case medium // 0.5
    case high // 0.7
    case original // 1.0

    public var value: CGFloat {
        switch self {
        case .low:
            return 0.3
        case .medium:
            return 0.5
        case .high:
            return 0.7
        case .original:
            return 1.0
        }
    }
}

// MARK: - Media Manager Implementation

/// Default implementation of Media Manager
public final class MediaManager: MediaManagerProtocol {
    // MARK: - Dependencies

    private let permissionManager: PermissionManagerProtocol

    // MARK: - Initialization

    public init(permissionManager: PermissionManagerProtocol) {
        self.permissionManager = permissionManager
    }

    // MARK: - Camera

    public func capturePhoto() async throws -> MediaItem {
        // Check camera permission
        guard try await permissionManager.requestCameraPermission() else {
            throw MediaError.permissionDenied
        }

        // In production, present camera view controller
        // For now, return mock
        throw MediaError.notImplemented
    }

    // MARK: - Photo Library

    public func pickPhotoFromLibrary() async throws -> MediaItem {
        // Check photo library permission
        guard try await permissionManager.requestPhotoLibraryPermission() else {
            throw MediaError.permissionDenied
        }

        // In production, use PHPickerViewController
        throw MediaError.notImplemented
    }

    public func pickMultiplePhotos(limit: Int = 10) async throws -> [MediaItem] {
        // Check photo library permission
        guard try await permissionManager.requestPhotoLibraryPermission() else {
            throw MediaError.permissionDenied
        }

        // In production, use PHPickerViewController with selection limit
        throw MediaError.notImplemented
    }

    public func pickVideo() async throws -> MediaItem {
        // Check photo library permission
        guard try await permissionManager.requestPhotoLibraryPermission() else {
            throw MediaError.permissionDenied
        }

        // In production, use PHPickerViewController with video filter
        throw MediaError.notImplemented
    }

    // MARK: - Save to Library

    public func saveImageToLibrary(_ image: UIImage) async throws {
        // Check photo library permission
        guard try await permissionManager.requestPhotoLibraryPermission() else {
            throw MediaError.permissionDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            continuation.resume()
        }
    }

    public func saveVideoToLibrary(at url: URL) async throws {
        // Check photo library permission
        guard try await permissionManager.requestPhotoLibraryPermission() else {
            throw MediaError.permissionDenied
        }

        // Use PHPhotoLibrary to save video
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }

    // MARK: - Image Processing

    public func compressImage(_ image: UIImage, quality: CompressionQuality = .medium) -> Data? {
        return image.jpegData(compressionQuality: quality.value)
    }

    public func generateThumbnail(from image: UIImage, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Video Processing

    public func generateVideoThumbnail(from url: URL) async throws -> UIImage {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Media Errors

public enum MediaError: Error, LocalizedError {
    case permissionDenied
    case cameraNotAvailable
    case captureSessionFailed
    case saveFailed
    case invalidMedia
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied. Please allow access in Settings"
        case .cameraNotAvailable:
            return "Camera is not available on this device"
        case .captureSessionFailed:
            return "Failed to start camera session"
        case .saveFailed:
            return "Failed to save media to library"
        case .invalidMedia:
            return "Invalid media format"
        case .notImplemented:
            return "Feature not implemented yet"
        }
    }
}

// MARK: - Image Picker (SwiftUI)

/// SwiftUI wrapper for PHPickerViewController
public struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let selectionLimit: Int

    @SwiftUI.Environment(\.dismiss) private var dismiss: DismissAction

    public init(selectedImages: Binding<[UIImage]>, selectionLimit: Int = 1) {
        _selectedImages = selectedImages
        self.selectionLimit = selectionLimit
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            var images: [UIImage] = []

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            images.append(image)
                        }
                    }
                }
            }

            // Wait a bit for async loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.parent.selectedImages = images
            }
        }
    }
}

// MARK: - Camera View (SwiftUI)

/// SwiftUI wrapper for camera
public struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?

    @SwiftUI.Environment(\.dismiss) private var dismiss: DismissAction

    public init(capturedImage: Binding<UIImage?>) {
        _capturedImage = capturedImage
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Mock Media Manager

/// Mock implementation for testing
public final class MockMediaManager: MediaManagerProtocol {
    public var shouldSucceed = true

    public init() {}

    public func capturePhoto() async throws -> MediaItem {
        if shouldSucceed {
            return MediaItem(type: .photo, image: UIImage())
        } else {
            throw MediaError.cameraNotAvailable
        }
    }

    public func pickPhotoFromLibrary() async throws -> MediaItem {
        if shouldSucceed {
            return MediaItem(type: .photo, image: UIImage())
        } else {
            throw MediaError.permissionDenied
        }
    }

    public func pickMultiplePhotos(limit: Int) async throws -> [MediaItem] {
        if shouldSucceed {
            return [MediaItem(type: .photo, image: UIImage())]
        } else {
            throw MediaError.permissionDenied
        }
    }

    public func pickVideo() async throws -> MediaItem {
        if shouldSucceed {
            return MediaItem(type: .video)
        } else {
            throw MediaError.permissionDenied
        }
    }

    public func saveImageToLibrary(_ image: UIImage) async throws {
        if !shouldSucceed {
            throw MediaError.saveFailed
        }
    }

    public func saveVideoToLibrary(at url: URL) async throws {
        if !shouldSucceed {
            throw MediaError.saveFailed
        }
    }

    public func compressImage(_ image: UIImage, quality: CompressionQuality) -> Data? {
        return shouldSucceed ? Data() : nil
    }

    public func generateThumbnail(from image: UIImage, size: CGSize) -> UIImage? {
        return shouldSucceed ? UIImage() : nil
    }

    public func generateVideoThumbnail(from url: URL) async throws -> UIImage {
        if shouldSucceed {
            return UIImage()
        } else {
            throw MediaError.invalidMedia
        }
    }
}
