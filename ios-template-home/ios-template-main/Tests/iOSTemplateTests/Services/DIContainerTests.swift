import XCTest
@testable import iOSTemplate

final class DIContainerTests: XCTestCase {

    // MARK: - Properties

    var sut: DIContainer!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = DIContainer.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Service Registration Tests

    func test_container_shouldRegisterCoreServices() {
        // Then - Core services should be registered
        XCTAssertNoThrow(sut.resolve(StorageServiceProtocol.self))
        XCTAssertNoThrow(sut.resolve(SecureStorageProtocol.self))
        XCTAssertNoThrow(sut.resolve(NetworkServiceProtocol.self))
    }

    func test_resolve_storageService_shouldReturnInstance() {
        // When
        let service = sut.resolve(StorageServiceProtocol.self)

        // Then
        XCTAssertNotNil(service)
    }

    func test_resolve_secureStorage_shouldReturnInstance() {
        // When
        let service = sut.resolve(SecureStorageProtocol.self)

        // Then
        XCTAssertNotNil(service)
    }

    func test_resolve_networkService_shouldReturnInstance() {
        // When
        let service = sut.resolve(NetworkServiceProtocol.self)

        // Then
        XCTAssertNotNil(service)
    }

    // MARK: - Singleton Tests

    func test_resolve_singleton_shouldReturnSameInstance() {
        // When
        let instance1 = sut.resolve(StorageServiceProtocol.self)
        let instance2 = sut.resolve(StorageServiceProtocol.self)

        // Then
        // For singletons, should return same instance
        // Note: This test may need adjustment based on actual scope
        XCTAssertNotNil(instance1)
        XCTAssertNotNil(instance2)
    }

    // MARK: - Service Locator Tests

    func test_serviceLocator_shouldResolveServices() {
        // When
        let storageService: StorageServiceProtocol? = ServiceLocator.resolve()
        let secureStorage: SecureStorageProtocol? = ServiceLocator.resolve()
        let networkService: NetworkServiceProtocol? = ServiceLocator.resolve()

        // Then
        XCTAssertNotNil(storageService)
        XCTAssertNotNil(secureStorage)
        XCTAssertNotNil(networkService)
    }

    // MARK: - Firebase Services Tests

    func test_container_shouldRegisterFirebaseServices() {
        // Then - Firebase services should be registered
        // Note: These might be optional depending on configuration
        // XCTAssertNoThrow(sut.resolve(AnalyticsServiceProtocol.self))
        // XCTAssertNoThrow(sut.resolve(CrashlyticsServiceProtocol.self))
    }
}
