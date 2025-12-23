import Foundation
import Swinject

/// Dependency Injection Container using Swinject
/// Central place để register và resolve dependencies
public final class DIContainer {
    
    // MARK: - Singleton
    
    /// Shared instance
    public static let shared = DIContainer()
    
    // MARK: - Properties
    
    /// Swinject container
    private let container: Container
    
    /// Assembler for modular registration
    private let assembler: Assembler
    
    // MARK: - Initialization
    
    private init() {
        self.container = Container()
        
        // Explicitly type the assemblies array
        let assemblies: [Swinject.Assembly] = [
            StorageAssembly(),
            ServiceAssembly(),
            RepositoryAssembly(),
            MonetizationAssembly(),
            AIAssembly()
        ]
        
        self.assembler = Assembler(
            assemblies,
            container: container
        )
    }
    
    // MARK: - Public Methods
    
    /// Resolve dependency
    public func resolve<T>(_ type: T.Type) -> T? {
        container.resolve(T.self)
    }
    
    /// Resolve dependency with argument
    public func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T? {
        container.resolve(T.self, argument: argument)
    }
    
    /// Register dependency (for testing)
    public func register<T>(_ type: T.Type, factory: @escaping (Resolver) -> T) {
        container.register(T.self) { resolver in
            factory(resolver)
        }
    }
    
    /// Remove all registrations (for testing)
    public func removeAll() {
        container.removeAll()
    }
}

// MARK: - Convenience Methods

public extension DIContainer {
    // Storage Services
    var userDefaultsStorage: StorageServiceProtocol {
        resolve(StorageServiceProtocol.self)!
    }
    
    var keychainStorage: SecureStorageProtocol {
        resolve(SecureStorageProtocol.self)!
    }
    
    var fileStorage: FileStorageProtocol {
        resolve(FileStorageProtocol.self)!
    }
    
    // Business Services
    var networkService: NetworkServiceProtocol? {
        resolve(NetworkServiceProtocol.self)
    }
    
    var authService: AuthServiceProtocol? {
        resolve(AuthServiceProtocol.self)
    }
    
    var analyticsService: AnalyticsServiceProtocol? {
        resolve(AnalyticsServiceProtocol.self)
    }
    
    var crashlyticsService: CrashlyticsServiceProtocol? {
        resolve(CrashlyticsServiceProtocol.self)
    }
    
    var loggingService: LoggingServiceProtocol? {
        resolve(LoggingServiceProtocol.self)
    }
    
    var remoteConfigService: RemoteConfigServiceProtocol? {
        resolve(RemoteConfigServiceProtocol.self)
    }
    
    var pushNotificationService: PushNotificationServiceProtocol? {
        resolve(PushNotificationServiceProtocol.self)
    }
    
    // Monetization Services
    var iapService: IAPServiceProtocol? {
        resolve(IAPServiceProtocol.self)
    }
    
    var adMobManager: AdMobManager? {
        resolve(AdMobManager.self)
    }
    
    var appsFlyerManager: AppsFlyerManager? {
        resolve(AppsFlyerManager.self)
    }
    
    var revenueTracker: RevenueTracker? {
        resolve(RevenueTracker.self)
    }
}

// MARK: - Storage Assembly

/// Assembly cho storage dependencies
final class StorageAssembly: Swinject.Assembly {
    func assemble(container: Container) {
        // UserDefaults Storage
        container.register(StorageServiceProtocol.self) { _ in
            UserDefaultsStorage()
        }
        .inObjectScope(.container) // Singleton
        
        // Keychain Storage
        container.register(SecureStorageProtocol.self) { _ in
            KeychainStorage()
        }
        .inObjectScope(.container) // Singleton
        
        // File Storage - Documents
        container.register(FileStorageProtocol.self, name: "documents") { _ in
            FileStorage.documents
        }
        .inObjectScope(.container)
        
        // File Storage - Cache
        container.register(FileStorageProtocol.self, name: "cache") { _ in
            FileStorage.cache
        }
        .inObjectScope(.container)
        
        // File Storage - Temporary
        container.register(FileStorageProtocol.self, name: "temporary") { _ in
            FileStorage.temporary
        }
        .inObjectScope(.container)
        
        // Default File Storage (Documents)
        container.register(FileStorageProtocol.self) { resolver in
            resolver.resolve(FileStorageProtocol.self, name: "documents")!
        }
    }
}

// MARK: - Service Assembly

/// Assembly cho business services
final class ServiceAssembly: Swinject.Assembly {
    func assemble(container: Container) {
        // Network Service
        // TODO: Register NetworkService implementation
        // container.register(NetworkServiceProtocol.self) { _ in
        //     NetworkService()
        // }
        // .inObjectScope(.container)
        
        // Auth Service
        // TODO: Register AuthService implementation
        // container.register(AuthServiceProtocol.self) { resolver in
        //     AuthService(
        //         networkService: resolver.resolve(NetworkServiceProtocol.self)!,
        //         keychainStorage: resolver.resolve(SecureStorageProtocol.self)!
        //     )
        // }
        // .inObjectScope(.container)
        
        // Analytics Service
        container.register(AnalyticsServiceProtocol.self) { _ in
            FirebaseAnalyticsService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Crashlytics Service
        container.register(CrashlyticsServiceProtocol.self) { _ in
            FirebaseCrashlyticsService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Push Notification Service
        container.register(PushNotificationServiceProtocol.self) { _ in
            FirebaseMessagingService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Remote Config Service
        container.register(RemoteConfigServiceProtocol.self) { _ in
            FirebaseRemoteConfigService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Logging Service
        // TODO: Register LoggingService implementation
        // container.register(LoggingServiceProtocol.self) { _ in
        //     LoggingService()
        // }
        // .inObjectScope(.container)
    }
}

// MARK: - Repository Assembly

/// Assembly cho repositories
final class RepositoryAssembly: Swinject.Assembly {
    func assemble(container: Container) {
        // User Repository
        // TODO: Register UserRepository
        // container.register(UserRepositoryProtocol.self) { resolver in
        //     UserRepository(
        //         networkService: resolver.resolve(NetworkServiceProtocol.self)!,
        //         storage: resolver.resolve(StorageServiceProtocol.self)!
        //     )
        // }
        // .inObjectScope(.container)
    }
}

// MARK: - Monetization Assembly

/// Assembly cho monetization services
final class MonetizationAssembly: Swinject.Assembly {
    func assemble(container: Container) {
        // StoreKit Manager
        container.register(StoreKitManager.self) { _ in
            StoreKitManager()
        }
        .inObjectScope(.container) // Singleton
        
        // IAP Service
        container.register(IAPServiceProtocol.self) { resolver in
            // Get FirebaseAnalyticsService as MonetizationAnalyticsProtocol
            let firebaseService = resolver.resolve(AnalyticsServiceProtocol.self) as? FirebaseAnalyticsService
            let monetizationAnalytics = firebaseService as MonetizationAnalyticsProtocol?
            
            return IAPService(
                storeKitManager: resolver.resolve(StoreKitManager.self)!,
                analyticsService: monetizationAnalytics
            )
        }
        .inObjectScope(.container) // Singleton
        
        // AdMob Manager
        container.register(AdMobManager.self) { _ in
            AdMobManager()
        }
        .inObjectScope(.container) // Singleton
        
        // AppsFlyer Manager
        container.register(AppsFlyerManager.self) { _ in
            AppsFlyerManager()
        }
        .inObjectScope(.container) // Singleton
        
        // Revenue Tracker
        container.register(RevenueTracker.self) { resolver in
            // Get FirebaseAnalyticsService as FirebaseAnalyticsServiceProtocol
            let firebaseService = resolver.resolve(AnalyticsServiceProtocol.self) as? FirebaseAnalyticsService
            let firebaseAnalytics = firebaseService as FirebaseAnalyticsServiceProtocol?
            
            return RevenueTracker(
                appsFlyerManager: resolver.resolve(AppsFlyerManager.self)!,
                analyticsService: firebaseAnalytics
            )
        }
        .inObjectScope(.container) // Singleton
    }
}

// MARK: - AI Assembly

/// Assembly cho AI và ML services
final class AIAssembly: Swinject.Assembly {
    func assemble(container: Container) {
        // OpenAI Service
        container.register(OpenAIServiceProtocol.self) { _ in
            OpenAIService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Claude Service
        container.register(ClaudeServiceProtocol.self) { _ in
            ClaudeService.shared
        }
        .inObjectScope(.container) // Singleton
        
        // AI Manager (Unified Interface)
        container.register(AIManagerProtocol.self) { resolver in
            AIManager(
                openAI: resolver.resolve(OpenAIServiceProtocol.self)!,
                claude: resolver.resolve(ClaudeServiceProtocol.self)!
            )
        }
        .inObjectScope(.container) // Singleton
        
        // Core ML Manager
        container.register(CoreMLManagerProtocol.self) { _ in
            CoreMLManager.shared
        }
        .inObjectScope(.container) // Singleton
        
        // Vision Service
        container.register(VisionServiceProtocol.self) { _ in
            VisionService.shared
        }
        .inObjectScope(.container) // Singleton
    }
}

// MARK: - Dependency Property Wrapper

/// Property wrapper để inject dependencies
@propertyWrapper
public struct Injected<T> {
    private let type: T.Type
    
    public init(_ type: T.Type) {
        self.type = type
    }
    
    public var wrappedValue: T {
        guard let resolved = DIContainer.shared.resolve(type) else {
            fatalError("Could not resolve type \(type)")
        }
        return resolved
    }
}

// MARK: - Example Usage

/*
 Usage Example:
 
 // 1. Register dependencies (done in assemblies)
 
 // 2. Resolve in code:
 let storage = DIContainer.shared.userDefaultsStorage
 let keychain = DIContainer.shared.keychainStorage
 
 // 3. Use @Injected property wrapper:
 class MyViewModel {
 @Injected(StorageServiceProtocol.self)
 var storage: StorageServiceProtocol
 
 @Injected(SecureStorageProtocol.self)
 var keychain: SecureStorageProtocol
 
 func saveData() {
 try? storage.save("value", forKey: "key")
 try? keychain.saveSecure("token", forKey: "auth.token")
 }
 }
 
 // 4. For testing, register mocks:
 class MockStorage: StorageServiceProtocol {
 // Mock implementation
 }
 
 func setupTest() {
 DIContainer.shared.register(StorageServiceProtocol.self) { _ in
 MockStorage()
 }
 }
 */
