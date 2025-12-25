import Foundation
import ComposableArchitecture

/// Các hành động của Home feature
@CasePathable
public enum HomeAction: Equatable {
    /// View xuất hiện
    case onAppear
    
    /// Tap vào notification button
    case notificationTapped
    
    /// Tap vào Get Started button
    case getStartedTapped
    
    /// Tap vào quick action
    case quickActionTapped(QuickAction)
    
    /// Tap vào activity
    case activityTapped(Activity)
    
    /// Tap vào See All button
    case seeAllTapped
    
    /// Refresh dữ liệu
    case refresh
    
    /// Refresh completed
    case refreshCompleted
}

