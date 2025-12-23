import Foundation
import UserNotifications
import AVFoundation
import Photos
import CoreLocation
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

// MARK: - Permission Manager Protocol

/// Protocol for managing app permissions
public protocol PermissionManagerProtocol {
    /// Request notification permission
    func requestNotificationPermission() async throws -> Bool

    /// Request camera permission
    func requestCameraPermission() async throws -> Bool

    /// Request photo library permission
    func requestPhotoLibraryPermission() async throws -> Bool

    /// Request location permission
    func requestLocationPermission() async throws -> Bool

    /// Request tracking permission (iOS 14+)
    func requestTrackingPermission() async throws -> Bool

    /// Check notification permission status
    func notificationPermissionStatus() async -> PermissionStatus

    /// Check camera permission status
    func cameraPermissionStatus() -> PermissionStatus

    /// Check photo library permission status
    func photoLibraryPermissionStatus() -> PermissionStatus

    /// Check location permission status
    func locationPermissionStatus() -> PermissionStatus
}

// MARK: - Permission Status

/// Permission status enum
public enum PermissionStatus {
    case notDetermined
    case denied
    case authorized
    case restricted
    case limited // For photo library limited access

    public var isAuthorized: Bool {
        self == .authorized || self == .limited
    }

    public var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .restricted:
            return "Restricted"
        case .limited:
            return "Limited Access"
        }
    }
}

// MARK: - Permission Type

/// Types of permissions
public enum PermissionType: String, CaseIterable {
    case notifications
    case camera
    case photoLibrary
    case location
    case tracking

    public var title: String {
        switch self {
        case .notifications:
            return "Notifications"
        case .camera:
            return "Camera"
        case .photoLibrary:
            return "Photos"
        case .location:
            return "Location"
        case .tracking:
            return "Tracking"
        }
    }

    public var description: String {
        switch self {
        case .notifications:
            return "Get notified about important updates and messages"
        case .camera:
            return "Take photos and videos within the app"
        case .photoLibrary:
            return "Choose photos and videos from your library"
        case .location:
            return "Provide location-based features and services"
        case .tracking:
            return "Provide personalized experience and ads"
        }
    }

    public var icon: String {
        switch self {
        case .notifications:
            return "bell.fill"
        case .camera:
            return "camera.fill"
        case .photoLibrary:
            return "photo.fill"
        case .location:
            return "location.fill"
        case .tracking:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Permission Manager Implementation

/// Default implementation of Permission Manager
public final class PermissionManager: NSObject, PermissionManagerProtocol {
    // MARK: - Dependencies

    private let notificationCenter = UNUserNotificationCenter.current()
    private var locationManager: CLLocationManager?

    // MARK: - Initialization

    public override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
    }

    // MARK: - Notification Permission

    public func requestNotificationPermission() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            return granted
        } catch {
            throw PermissionError.requestFailed(error)
        }
    }

    public func notificationPermissionStatus() async -> PermissionStatus {
        let settings = await notificationCenter.notificationSettings()
        return mapNotificationStatus(settings.authorizationStatus)
    }

    private func mapNotificationStatus(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    // MARK: - Camera Permission

    public func requestCameraPermission() async throws -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true

        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)

        case .denied, .restricted:
            throw PermissionError.denied

        @unknown default:
            throw PermissionError.unknown
        }
    }

    public func cameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return mapAVAuthorizationStatus(status)
    }

    private func mapAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    // MARK: - Photo Library Permission

    public func requestPhotoLibraryPermission() async throws -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            return true

        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited

        case .denied, .restricted:
            throw PermissionError.denied

        @unknown default:
            throw PermissionError.unknown
        }
    }

    public func photoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return mapPhotoLibraryStatus(status)
    }

    private func mapPhotoLibraryStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        @unknown default:
            return .notDetermined
        }
    }

    // MARK: - Location Permission

    public func requestLocationPermission() async throws -> Bool {
        guard let locationManager = locationManager else {
            throw PermissionError.notAvailable
        }

        let status = locationManager.authorizationStatus

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return true

        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization()
            // Wait for delegate callback
            // In production, use Continuation
            return false

        case .denied, .restricted:
            throw PermissionError.denied

        @unknown default:
            throw PermissionError.unknown
        }
    }

    public func locationPermissionStatus() -> PermissionStatus {
        guard let locationManager = locationManager else {
            return .notDetermined
        }

        let status = locationManager.authorizationStatus
        return mapLocationStatus(status)
    }

    private func mapLocationStatus(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    // MARK: - Tracking Permission (iOS 14+)

    public func requestTrackingPermission() async throws -> Bool {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            // Import at file scope for iOS 14+
            // Note: AppTrackingTransparency must be imported at the top
            // Returning true for now as placeholder
            // In production, implement proper ATTrackingManager.requestTrackingAuthorization()
            return true
        } else {
            return true
        }
        #else
        return true
        #endif
    }
}

// MARK: - CLLocationManagerDelegate

extension PermissionManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization changes
        let status = manager.authorizationStatus
        print("Location authorization changed: \(status.rawValue)")
    }
}

// MARK: - Permission Errors

public enum PermissionError: Error, LocalizedError {
    case denied
    case restricted
    case notAvailable
    case requestFailed(Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .denied:
            return "Permission denied. Please enable it in Settings"
        case .restricted:
            return "Permission restricted by system or parental controls"
        case .notAvailable:
            return "Permission not available on this device"
        case .requestFailed(let error):
            return "Permission request failed: \(error.localizedDescription)"
        case .unknown:
            return "Unknown permission error"
        }
    }
}

// MARK: - Mock Permission Manager

/// Mock implementation for testing
public final class MockPermissionManager: PermissionManagerProtocol {
    public var shouldGrantPermission = true

    public init() {}

    public func requestNotificationPermission() async throws -> Bool {
        return shouldGrantPermission
    }

    public func requestCameraPermission() async throws -> Bool {
        return shouldGrantPermission
    }

    public func requestPhotoLibraryPermission() async throws -> Bool {
        return shouldGrantPermission
    }

    public func requestLocationPermission() async throws -> Bool {
        return shouldGrantPermission
    }

    public func requestTrackingPermission() async throws -> Bool {
        return shouldGrantPermission
    }

    public func notificationPermissionStatus() async -> PermissionStatus {
        return shouldGrantPermission ? .authorized : .denied
    }

    public func cameraPermissionStatus() -> PermissionStatus {
        return shouldGrantPermission ? .authorized : .denied
    }

    public func photoLibraryPermissionStatus() -> PermissionStatus {
        return shouldGrantPermission ? .authorized : .denied
    }

    public func locationPermissionStatus() -> PermissionStatus {
        return shouldGrantPermission ? .authorized : .denied
    }
}
