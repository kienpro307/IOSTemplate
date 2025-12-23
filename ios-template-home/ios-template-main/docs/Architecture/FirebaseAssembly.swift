import Foundation
import Swinject

// MARK: - Firebase Assembly for Swinject

/// Swinject Assembly for Firebase services
///
/// Register all Firebase services với Swinject DI container
///
/// ## Usage:
/// ```swift
/// // In DIContainer
/// let assemblies: [Assembly] = [
///     FirebaseAssembly(),
///     // ... other assemblies
/// ]
///
/// // Resolve service
/// let analytics = DIContainer.shared.resolve(AnalyticsService.self)
/// analytics?.logEvent(.appOpen)
/// ```
///
public final class FirebaseAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        
        // MARK: - Firebase Manager
        
        container.register(FirebaseManager.self) { _ in
            return FirebaseManager.shared
        }
        .inObjectScope(.container) // Singleton
        
        // MARK: - Analytics Service
        
        container.register(AnalyticsService.self) { _ in
            return AnalyticsService.shared
        }
        .inObjectScope(.container)
        
        // MARK: - Crashlytics Service
        
        container.register(CrashlyticsService.self) { _ in
            return CrashlyticsService.shared
        }
        .inObjectScope(.container)
        
        // MARK: - Remote Config Service
        
        container.register(RemoteConfigService.self) { _ in
            return RemoteConfigService.shared
        }
        .inObjectScope(.container)
        
        // MARK: - Messaging Service
        
        container.register(MessagingService.self) { _ in
            return MessagingService.shared
        }
        .inObjectScope(.container)
        
        // MARK: - Performance Service
        
        container.register(PerformanceService.self) { _ in
            return PerformanceService.shared
        }
        .inObjectScope(.container)
    }
}

// MARK: - DIContainer Extension

public extension DIContainer {
    
    // MARK: - Convenience Getters
    
    /// Get Analytics Service
    var analyticsService: AnalyticsService? {
        resolve(AnalyticsService.self)
    }
    
    /// Get Crashlytics Service
    var crashlyticsService: CrashlyticsService? {
        resolve(CrashlyticsService.self)
    }
    
    /// Get Remote Config Service
    var remoteConfigService: RemoteConfigService? {
        resolve(RemoteConfigService.self)
    }
    
    /// Get Messaging Service
    var messagingService: MessagingService? {
        resolve(MessagingService.self)
    }
    
    /// Get Performance Service
    var performanceService: PerformanceService? {
        resolve(PerformanceService.self)
    }
    
    /// Get Firebase Manager
    var firebaseManager: FirebaseManager? {
        resolve(FirebaseManager.self)
    }
}

// MARK: - Usage Examples

/*
 
 // Example 1: Register Firebase Assembly
 // In DIContainer.swift, add FirebaseAssembly to assemblies array:
 
 private init() {
     self.container = Container()
     
     let assemblies: [Assembly] = [
         FirebaseAssembly(),          // ← Add this
         StorageAssembly(),
         ServiceAssembly(),
         RepositoryAssembly(),
         MonetizationAssembly(),
         AIAssembly()
     ]
     
     self.assembler = Assembler(assemblies, container: container)
 }
 
 // Example 2: Resolve and use services
 class MyViewModel {
     private let analytics: AnalyticsService?
     private let remoteConfig: RemoteConfigService?
     
     init() {
         self.analytics = DIContainer.shared.analyticsService
         self.remoteConfig = DIContainer.shared.remoteConfigService
     }
     
     func trackEvent() {
         analytics?.logEvent(.featureUsed)
     }
     
     func loadConfig() async {
         try? await remoteConfig?.fetchAndActivate()
     }
 }
 
 // Example 3: Direct resolve
 if let analytics = DIContainer.shared.resolve(AnalyticsService.self) {
     analytics.logEvent(.appOpen)
 }
 
 */
