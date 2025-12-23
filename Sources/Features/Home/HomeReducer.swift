import ComposableArchitecture
import Core

/// Reducer xử lý logic của Home feature
@Reducer
public struct HomeReducer {
    public init() {}
    
    public typealias State = HomeState
    public typealias Action = HomeAction
    
    // MARK: - Dependencies
    /// Analytics service để track events
    @Dependency(\.analytics) var analytics
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Track screen vào Analytics
                return .run { _ in
                    await analytics.trackScreen("Home")
                }
                
            case .notificationTapped:
                // Track event và navigate (sẽ được handle ở AppReducer)
                return .run { _ in
                    await analytics.trackEvent("home_notification_tapped", parameters: nil)
                }
                
            case .getStartedTapped:
                // Track event
                return .run { _ in
                    await analytics.trackEvent("home_get_started_tapped", parameters: nil)
                }
                
            case .quickActionTapped(let action):
                // Track event
                return .run { _ in
                    await analytics.trackEvent("home_quick_action_tapped", parameters: [
                        "action_title": action.title,
                        "action_icon": action.icon
                    ])
                }
                
            case .activityTapped(let activity):
                // Track event
                return .run { _ in
                    await analytics.trackEvent("home_activity_tapped", parameters: [
                        "activity_title": activity.title
                    ])
                }
                
            case .seeAllTapped:
                // Track event
                return .run { _ in
                    await analytics.trackEvent("home_see_all_tapped", parameters: nil)
                }
                
            case .refresh:
                // Refresh dữ liệu (có thể fetch từ API sau này)
                state.isLoading = true
                return .run { send in
                    // Simulate refresh delay
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    await send(.refreshCompleted)
                }
                
            case .refreshCompleted:
                // Refresh hoàn thành
                state.isLoading = false
                return .none
            }
        }
    }
}

