// MARK: - Features Module
/// Module chứa các tính năng nghiệp vụ của ứng dụng
/// Thêm các feature reducers, views và logic ở đây

import Foundation
@_exported import ComposableArchitecture

// MARK: - Onboarding
public typealias OnboardingModule = OnboardingReducer

// MARK: - Home
public typealias HomeModule = HomeReducer

// MARK: - Settings
public typealias SettingsModule = SettingsReducer

// MARK: - IAP (In-App Purchase)
public typealias IAPModule = IAPReducer

/// Entry point cho Features module
public struct Features {
    public init() {}
}
