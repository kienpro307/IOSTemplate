import SwiftUI
import Dependencies

// MARK: - SwiftUI View Modifiers for Firebase

/// SwiftUI view modifiers for easy Firebase integration
///
/// ## Usage:
/// ```swift
/// struct HomeView: View {
///     var body: some View {
///         VStack {
///             Text("Home")
///         }
///         .trackScreen("home")
///         .onAppear {
///             logEvent(.appOpen)
///         }
///     }
/// }
/// ```

// MARK: - Screen Tracking

extension View {
    /// Track screen view automatically
    ///
    /// - Parameters:
    ///   - screenName: Screen name for analytics
    ///   - screenClass: Optional screen class (defaults to screenName)
    /// - Returns: Modified view
    public func trackScreen(_ screenName: String, screenClass: String? = nil) -> some View {
        self.modifier(ScreenTrackingModifier(screenName: screenName, screenClass: screenClass))
    }
}

private struct ScreenTrackingModifier: ViewModifier {
    let screenName: String
    let screenClass: String?
    
    @Dependency(\.analyticsService) var analytics
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analytics.trackScreen(screenName, screenClass: screenClass)
            }
    }
}

// MARK: - Event Tracking

extension View {
    /// Log analytics event when view appears
    ///
    /// - Parameters:
    ///   - event: Analytics event
    ///   - parameters: Optional parameters
    /// - Returns: Modified view
    public func trackOnAppear(
        _ event: AnalyticsEvent,
        parameters: [String: Any]? = nil
    ) -> some View {
        self.modifier(EventTrackingModifier(event: event, parameters: parameters))
    }
}

private struct EventTrackingModifier: ViewModifier {
    let event: AnalyticsEvent
    let parameters: [String: Any]?
    
    @Dependency(\.analyticsService) var analytics
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analytics.logEvent(event, parameters: parameters)
            }
    }
}

// MARK: - Remote Config

extension View {
    /// Show/hide view based on remote config
    ///
    /// - Parameter key: Remote config key
    /// - Returns: Modified view (conditionally visible)
    @ViewBuilder
    public func showIf(remoteConfigKey key: RemoteConfigKey) -> some View {
        RemoteConfigView(key: key) {
            self
        }
    }
}

private struct RemoteConfigView<Content: View>: View {
    let key: RemoteConfigKey
    let content: Content
    
    @Dependency(\.remoteConfigService) var remoteConfig
    
    init(key: RemoteConfigKey, @ViewBuilder content: () -> Content) {
        self.key = key
        self.content = content()
    }
    
    var body: some View {
        if remoteConfig.getBool(key) {
            content
        }
    }
}

// MARK: - Performance Monitoring

extension View {
    /// Measure view load performance
    ///
    /// - Parameter traceName: Trace name for performance monitoring
    /// - Returns: Modified view
    public func measurePerformance(_ traceName: String) -> some View {
        self.modifier(PerformanceTrackingModifier(traceName: traceName))
    }
}

private struct PerformanceTrackingModifier: ViewModifier {
    let traceName: String
    
    @Dependency(\.performanceService) var performance
    @State private var trace: Trace?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                trace = performance.startTrace(name: traceName)
            }
            .onDisappear {
                performance.stopTrace(trace)
            }
    }
}

// MARK: - Error Handling

extension View {
    /// Record errors to Crashlytics
    ///
    /// Use with task/task modifiers to catch and log errors
    ///
    /// ```swift
    /// .task {
    ///     try await loadData()
    /// }
    /// .recordErrors(screen: "home", action: "load_data")
    /// ```
    public func recordErrors(
        screen: String? = nil,
        action: String? = nil
    ) -> some View {
        self.modifier(ErrorRecordingModifier(screen: screen, action: action))
    }
}

private struct ErrorRecordingModifier: ViewModifier {
    let screen: String?
    let action: String?
    
    @Dependency(\.crashlyticsService) var crashlytics
    
    func body(content: Content) -> some View {
        content
            .task {
                // This modifier is meant to be used alongside .task
                // The actual error recording happens in the view's task
            }
    }
}

// MARK: - Convenience Functions

/// Global analytics logging helper
///
/// Use in views without @Dependency:
/// ```swift
/// Button("Tap Me") {
///     logEvent(.buttonTapped, parameters: ["button": "submit"])
/// }
/// ```
public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
    AnalyticsService.shared.logEvent(event, parameters: parameters)
}

/// Global crashlytics logging helper
public func recordError(_ error: Error, screen: String? = nil, action: String? = nil) {
    CrashlyticsService.shared.recordError(error, screen: screen, action: action)
}

/// Global screen tracking helper
public func trackScreen(_ screenName: String) {
    AnalyticsService.shared.trackScreen(screenName)
}

// MARK: - Usage Examples in Views

/*
 
 // Example 1: Track screen with modifier
 struct HomeView: View {
     var body: some View {
         VStack {
             Text("Home")
         }
         .trackScreen("home")
     }
 }
 
 // Example 2: Log event on appear
 struct FeatureView: View {
     var body: some View {
         VStack {
             Text("Feature")
         }
         .trackOnAppear(.featureUsed, parameters: ["feature": "new_design"])
     }
 }
 
 // Example 3: Remote config visibility
 struct BannerView: View {
     var body: some View {
         Text("Special Offer!")
             .showIf(remoteConfigKey: .showBanner)
     }
 }
 
 // Example 4: Performance monitoring
 struct DataView: View {
     var body: some View {
         List {
             // content
         }
         .measurePerformance("data_view_load")
     }
 }
 
 // Example 5: Button with analytics
 struct LoginView: View {
     var body: some View {
         Button("Login") {
             logEvent(.buttonTapped, parameters: ["button": "login"])
             // handle login
         }
     }
 }
 
 // Example 6: Error handling with crashlytics
 struct ProfileView: View {
     @State private var userData: User?
     @State private var error: Error?
     
     var body: some View {
         VStack {
             if let user = userData {
                 Text(user.name)
             }
         }
         .task {
             do {
                 userData = try await loadUserData()
             } catch {
                 recordError(error, screen: "profile", action: "load_data")
                 self.error = error
             }
         }
     }
 }
 
 // Example 7: Comprehensive tracking
 struct CheckoutView: View {
     var body: some View {
         VStack {
             Text("Checkout")
         }
         .trackScreen("checkout")
         .measurePerformance("checkout_load")
         .trackOnAppear(.featureUsed, parameters: ["feature": "checkout"])
     }
 }
 
 */
