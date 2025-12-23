import XCTest
@testable import iOSTemplate

final class UserDefaultsStorageTests: XCTestCase {

    // MARK: - Properties

    var sut: UserDefaultsStorage!
    var testDefaults: UserDefaults!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        // Use test suite for isolation
        testDefaults = UserDefaults(suiteName: "com.iostemplate.tests")!
        testDefaults.removePersistentDomain(forName: "com.iostemplate.tests")

        sut = UserDefaultsStorage(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.iostemplate.tests")
        sut = nil
        testDefaults = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    func test_save_string_shouldSucceed() throws {
        // Given
        let key = "test.string"
        let value = "Hello World"

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: String? = try sut.load(forKey: key)
        XCTAssertEqual(loaded, value)
    }

    func test_save_int_shouldSucceed() throws {
        // Given
        let key = "test.int"
        let value = 42

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: Int? = try sut.load(forKey: key)
        XCTAssertEqual(loaded, value)
    }

    func test_save_bool_shouldSucceed() throws {
        // Given
        let key = "test.bool"
        let value = true

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: Bool? = try sut.load(forKey: key)
        XCTAssertEqual(loaded, value)
    }

    func test_save_double_shouldSucceed() throws {
        // Given
        let key = "test.double"
        let value = 3.14159

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: Double? = try sut.load(forKey: key)
        XCTAssertEqual(loaded, value, accuracy: 0.0001)
    }

    func test_save_complexObject_shouldSucceed() throws {
        // Given
        let key = "test.object"
        let value = TestModel(id: "123", name: "Test", age: 25)

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: TestModel? = try sut.load(forKey: key)
        XCTAssertEqual(loaded?.id, value.id)
        XCTAssertEqual(loaded?.name, value.name)
        XCTAssertEqual(loaded?.age, value.age)
    }

    // MARK: - Load Tests

    func test_load_nonExistentKey_shouldReturnNil() throws {
        // Given
        let key = "non.existent.key"

        // When
        let loaded: String? = try sut.load(forKey: key)

        // Then
        XCTAssertNil(loaded)
    }

    func test_load_afterRemove_shouldReturnNil() throws {
        // Given
        let key = "test.string"
        try sut.save("value", forKey: key)

        // When
        sut.remove(forKey: key)
        let loaded: String? = try sut.load(forKey: key)

        // Then
        XCTAssertNil(loaded)
    }

    // MARK: - Remove Tests

    func test_remove_shouldDeleteValue() throws {
        // Given
        let key = "test.remove"
        try sut.save("value", forKey: key)
        XCTAssertTrue(sut.exists(forKey: key))

        // When
        sut.remove(forKey: key)

        // Then
        XCTAssertFalse(sut.exists(forKey: key))
    }

    // MARK: - Clear Tests

    func test_clearAll_shouldRemoveAllValues() throws {
        // Given
        try sut.save("value1", forKey: "key1")
        try sut.save("value2", forKey: "key2")
        try sut.save(123, forKey: "key3")

        // When
        sut.clearAll()

        // Then
        let value1: String? = try sut.load(forKey: "key1")
        let value2: String? = try sut.load(forKey: "key2")
        let value3: Int? = try sut.load(forKey: "key3")

        XCTAssertNil(value1)
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }

    // MARK: - Exists Tests

    func test_exists_whenKeyExists_shouldReturnTrue() throws {
        // Given
        let key = "test.exists"
        try sut.save("value", forKey: key)

        // When
        let exists = sut.exists(forKey: key)

        // Then
        XCTAssertTrue(exists)
    }

    func test_exists_whenKeyDoesNotExist_shouldReturnFalse() {
        // Given
        let key = "non.existent.key"

        // When
        let exists = sut.exists(forKey: key)

        // Then
        XCTAssertFalse(exists)
    }

    // MARK: - Storage Keys Tests

    func test_storageKeys_shouldBeAccessible() {
        // Then
        XCTAssertEqual(StorageKey.userProfile, "user.profile")
        XCTAssertEqual(StorageKey.themeMode, "settings.theme_mode")
        XCTAssertEqual(StorageKey.hasCompletedOnboarding, "onboarding.completed")
        XCTAssertEqual(StorageKey.lastAppVersion, "app.last_version")
    }
}

// MARK: - Test Models

struct TestModel: Codable, Equatable {
    let id: String
    let name: String
    let age: Int
}
