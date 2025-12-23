import Foundation

/// Các hành động của Onboarding feature
@CasePathable
public enum OnboardingAction: Equatable {
    /// Chuyển sang trang tiếp theo
    case nextPage
    
    /// Chuyển về trang trước
    case previousPage
    
    /// Chuyển đến trang cụ thể
    case goToPage(Int)
    
    /// Skip onboarding (hoàn thành ngay)
    case skip
    
    /// Hoàn thành onboarding
    case complete
}

