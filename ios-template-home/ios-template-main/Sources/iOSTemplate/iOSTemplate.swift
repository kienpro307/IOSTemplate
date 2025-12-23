// The Swift Programming Language
// https://docs.swift.org/swift-book

/// iOSTemplate - iOS Template Project with TCA Architecture
///
/// This module provides:
/// - The Composable Architecture (TCA) setup
/// - Theme system (Colors, Typography, Spacing)
/// - Core services (Auth, Storage, Network)
/// - Feature modules (Auth, Onboarding, Settings)
/// - Utilities and helpers

// Re-export ComposableArchitecture for convenience
// Note: Don't use @_exported as it can cause issues with Store type
// Just import it normally in files that need it

// iOSTemplate - Main Module Entry Point
// This file serves as the entry point for the iOSTemplate module

import Foundation
import ComposableArchitecture
import Swinject

// MARK: - Module Version

public enum iOSTemplate {
    public static let version = "0.1.0"
    public static let name = "iOSTemplate"
}

// MARK: - Public API Surface

// Core
@_exported import class ComposableArchitecture.Store
@_exported import struct ComposableArchitecture.Effect

// DI Container is automatically available as it's public
// All service protocols are public and automatically available

// MARK: - Convenience Access

/// Quick access to all services via DI Container
public var Services: DIContainer {
    DIContainer.shared
}

// MARK: - Module Information

public extension iOSTemplate {
    /// Check if module is properly initialized
    static var isInitialized: Bool {
        // Verify DI container has services registered
        let container = DIContainer.shared
        return container.userDefaultsStorage != nil
    }

    /// Initialize module with configuration
    static func initialize() {
        // DI Container is automatically initialized
        _ = DIContainer.shared

        #if DEBUG
        print("ℹ️ [iOSTemplate] Module initialized v\(version)")
        print("ℹ️ [iOSTemplate] Services available: Storage, Network, AI, ML, Vision")
        #endif
    }
}
