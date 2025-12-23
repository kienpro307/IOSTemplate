import XCTest
@testable import iOSTemplate

final class KeychainStorageTests: XCTestCase {

    // MARK: - Properties

    var sut: KeychainStorage!
    let testService = "com.iostemplate.tests"

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = KeychainStorage(service: testService)

        // Clean up before each test
        sut.clearAllSecure()
    }

    override func tearDown() {
        sut.clearAllSecure()
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    func test_saveSecure_string_shouldSucceed() throws {
        // Given
        let key = SecureStorageKey.accessToken
        let value = "test-token-12345"

        // When
        try sut.saveSecure(value, forKey: key)

        // Then
        let loaded = try sut.loadSecure(forKey: key)
        XCTAssertEqual(loaded, value)
    }

    func test_saveSecure_overwriteExisting_shouldSucceed() throws {
        // Given
        let key = SecureStorageKey.accessToken
        let value1 = "token1"
        let value2 = "token2"

        // When
        try sut.saveSecure(value1, forKey: key)
        try sut.saveSecure(value2, forKey: key) // Overwrite

        // Then
        let loaded = try sut.loadSecure(forKey: key)
        XCTAssertEqual(loaded, value2)
    }

    // MARK: - Load Tests

    func test_loadSecure_nonExistentKey_shouldReturnNil() throws {
        // Given
        let key = "non.existent.key"

        // When
        let loaded = try sut.loadSecure(forKey: key)

        // Then
        XCTAssertNil(loaded)
    }

    func test_loadSecure_afterSave_shouldReturnValue() throws {
        // Given
        let key = SecureStorageKey.refreshToken
        let value = "refresh-token-xyz"
        try sut.saveSecure(value, forKey: key)

        // When
        let loaded = try sut.loadSecure(forKey: key)

        // Then
        XCTAssertEqual(loaded, value)
    }

    // MARK: - Remove Tests

    func test_removeSecure_shouldDeleteValue() throws {
        // Given
        let key = SecureStorageKey.accessToken
        let value = "token-to-remove"
        try sut.saveSecure(value, forKey: key)

        // When
        sut.removeSecure(forKey: key)

        // Then
        let loaded = try sut.loadSecure(forKey: key)
        XCTAssertNil(loaded)
    }

    func test_removeSecure_nonExistentKey_shouldNotThrow() {
        // Given
        let key = "non.existent.key"

        // When/Then - Should not throw
        XCTAssertNoThrow(sut.removeSecure(forKey: key))
    }

    // MARK: - Clear Tests

    func test_clearAllSecure_shouldRemoveAllItems() throws {
        // Given
        try sut.saveSecure("token1", forKey: SecureStorageKey.accessToken)
        try sut.saveSecure("token2", forKey: SecureStorageKey.refreshToken)
        try sut.saveSecure("pin123", forKey: SecureStorageKey.userPIN)

        // When
        sut.clearAllSecure()

        // Then
        let token1 = try sut.loadSecure(forKey: SecureStorageKey.accessToken)
        let token2 = try sut.loadSecure(forKey: SecureStorageKey.refreshToken)
        let pin = try sut.loadSecure(forKey: SecureStorageKey.userPIN)

        XCTAssertNil(token1)
        XCTAssertNil(token2)
        XCTAssertNil(pin)
    }

    // MARK: - Secure Storage Keys Tests

    func test_secureStorageKeys_shouldBeAccessible() {
        // Then
        XCTAssertEqual(SecureStorageKey.accessToken, "secure.access_token")
        XCTAssertEqual(SecureStorageKey.refreshToken, "secure.refresh_token")
        XCTAssertEqual(SecureStorageKey.userPIN, "secure.user_pin")
        XCTAssertEqual(SecureStorageKey.biometricKey, "secure.biometric_key")
    }

    // MARK: - Multiple Keys Tests

    func test_multipleKeys_shouldBeIndependent() throws {
        // Given
        let key1 = SecureStorageKey.accessToken
        let key2 = SecureStorageKey.refreshToken
        let value1 = "access-token"
        let value2 = "refresh-token"

        // When
        try sut.saveSecure(value1, forKey: key1)
        try sut.saveSecure(value2, forKey: key2)

        // Then
        let loaded1 = try sut.loadSecure(forKey: key1)
        let loaded2 = try sut.loadSecure(forKey: key2)

        XCTAssertEqual(loaded1, value1)
        XCTAssertEqual(loaded2, value2)

        // Remove one key
        sut.removeSecure(forKey: key1)

        // Verify other key still exists
        let loaded1After = try sut.loadSecure(forKey: key1)
        let loaded2After = try sut.loadSecure(forKey: key2)

        XCTAssertNil(loaded1After)
        XCTAssertEqual(loaded2After, value2)
    }
}
