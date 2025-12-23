import ComposableArchitecture
import Foundation

/// Trạng thái của Onboarding feature
@ObservableState
public struct OnboardingState: Equatable {
    /// Trang hiện tại đang hiển thị (0-based index)
    public var currentPage: Int = 0
    
    /// Đã hoàn thành onboarding chưa
    public var hasCompleted: Bool = false
    
    /// Configuration cho onboarding
    public var config: OnboardingConfig
    
    public init(config: OnboardingConfig = .default) {
        self.config = config
    }
}

