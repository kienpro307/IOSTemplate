import Foundation

/// Service Locator pattern as alternative to DI
/// Dùng cho cases không thể inject dependencies
public final class ServiceLocator {

    // MARK: - Singleton

    public static let shared = ServiceLocator()

    // MARK: - Properties

    private var services: [String: Any] = [:]
    private let lock = NSLock()

    // MARK: - Initialization

    private init() {
        // Setup default services
        setupDefaultServices()
    }

    // MARK: - Public Methods

    /// Register service
    public func register<T>(_ service: T, forType type: T.Type) {
        lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        services[key] = service
    }

    /// Resolve service
    public func resolve<T>(_ type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        return services[key] as? T
    }

    /// Remove service
    public func remove<T>(_ type: T.Type) {
        lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        services.removeValue(forKey: key)
    }

    /// Clear all services
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }

        services.removeAll()
        setupDefaultServices()
    }

    // MARK: - Private Methods

    private func setupDefaultServices() {
        // Register default services
        register(UserDefaultsStorage(), forType: StorageServiceProtocol.self)
        register(KeychainStorage(), forType: SecureStorageProtocol.self)
        register(FileStorage.documents, forType: FileStorageProtocol.self)
    }
}

// MARK: - Convenience Extensions

public extension ServiceLocator {
    /// Get storage service
    var storage: StorageServiceProtocol {
        resolve(StorageServiceProtocol.self)!
    }

    /// Get secure storage service
    var secureStorage: SecureStorageProtocol {
        resolve(SecureStorageProtocol.self)!
    }

    /// Get file storage service
    var fileStorage: FileStorageProtocol {
        resolve(FileStorageProtocol.self)!
    }
}

// MARK: - Global Service Access

/// Global functions cho quick access
public func getService<T>(_ type: T.Type) -> T? {
    ServiceLocator.shared.resolve(type)
}

public func registerService<T>(_ service: T, forType type: T.Type) {
    ServiceLocator.shared.register(service, forType: type)
}

// MARK: - Example Usage

/*
 Usage Example:

 // 1. Register service:
 let customStorage = UserDefaultsStorage()
 ServiceLocator.shared.register(customStorage, forType: StorageServiceProtocol.self)

 // Or use global function:
 registerService(customStorage, forType: StorageServiceProtocol.self)

 // 2. Resolve service:
 let storage = ServiceLocator.shared.storage
 try? storage.save("value", forKey: "key")

 // Or use global function:
 if let storage = getService(StorageServiceProtocol.self) {
     try? storage.save("value", forKey: "key")
 }

 // 3. For testing:
 class MockStorage: StorageServiceProtocol {
     // Mock implementation
 }

 func setupTest() {
     ServiceLocator.shared.register(MockStorage(), forType: StorageServiceProtocol.self)
 }

 func tearDownTest() {
     ServiceLocator.shared.removeAll() // Resets to defaults
 }

 // Note: ServiceLocator is less type-safe than DI Container
 // Prefer DIContainer for most cases
 // Use ServiceLocator only when DI is not possible (e.g., static methods, extensions)
 */
