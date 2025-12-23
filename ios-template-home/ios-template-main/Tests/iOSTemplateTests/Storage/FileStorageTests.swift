import XCTest
@testable import iOSTemplate

final class FileStorageTests: XCTestCase {

    // MARK: - Properties

    var sut: FileStorage!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = FileStorage(directory: .temporary)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    func test_save_shouldCreateFile() throws {
        // Given
        let key = "test_save.json"
        let value = TestData(id: "123", content: "Hello World")

        // When
        try sut.save(value, forKey: key)

        // Then
        XCTAssertTrue(sut.exists(forKey: key))

        // Clean up
        try? sut.remove(forKey: key)
    }

    func test_save_shouldPersistData() throws {
        // Given
        let key = "test_persist_data.json"
        let value = TestData(id: "456", content: "Test Content")

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: TestData? = try sut.load(forKey: key)
        XCTAssertEqual(loaded?.id, value.id)
        XCTAssertEqual(loaded?.content, value.content)

        // Clean up
        try? sut.remove(forKey: key)
    }

    func test_save_overwriteExisting_shouldSucceed() throws {
        // Given
        let key = "test_overwrite.json"
        let value1 = TestData(id: "1", content: "First")
        let value2 = TestData(id: "2", content: "Second")

        // When
        try sut.save(value1, forKey: key)
        try sut.save(value2, forKey: key)

        // Then
        let loaded: TestData? = try sut.load(forKey: key)
        XCTAssertEqual(loaded?.id, value2.id)
        XCTAssertEqual(loaded?.content, value2.content)

        // Clean up
        try? sut.remove(forKey: key)
    }

    // MARK: - Load Tests

    func test_load_nonExistentFile_shouldReturnNil() throws {
        // Given
        let key = "non.existent.json"

        // When
        let loaded: TestData? = try sut.load(forKey: key)

        // Then
        XCTAssertNil(loaded)
    }

    func test_load_afterSave_shouldReturnCorrectData() throws {
        // Given
        let key = "test_saved.json"
        let value = TestData(id: "789", content: "Loaded Content")
        try sut.save(value, forKey: key)

        // When
        let loaded: TestData? = try sut.load(forKey: key)

        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, value.id)
        XCTAssertEqual(loaded?.content, value.content)

        // Clean up
        try? sut.remove(forKey: key)
    }

    // MARK: - Remove Tests

    func test_remove_shouldDeleteFile() throws {
        // Given
        let key = "test_to_remove.json"
        let value = TestData(id: "111", content: "To Remove")
        try sut.save(value, forKey: key)

        // When
        sut.remove(forKey: key)

        // Then
        let loaded: TestData? = try sut.load(forKey: key)
        XCTAssertNil(loaded)
        XCTAssertFalse(sut.exists(forKey: key))
    }

    func test_remove_nonExistentFile_shouldNotThrow() {
        // Given
        let key = "test_non_existent.json"

        // When/Then - Should not throw
        XCTAssertNoThrow(sut.remove(forKey: key))
    }

    // MARK: - Exists Tests

    func test_exists_whenFileExists_shouldReturnTrue() throws {
        // Given
        let key = "test_exists.json"
        try sut.save(TestData(id: "1", content: "Exists"), forKey: key)

        // When
        let exists = sut.exists(forKey: key)

        // Then
        XCTAssertTrue(exists)

        // Clean up
        try? sut.remove(forKey: key)
    }

    func test_exists_whenFileDoesNotExist_shouldReturnFalse() {
        // Given
        let key = "test_does_not_exist.json"

        // When
        let exists = sut.exists(forKey: key)

        // Then
        XCTAssertFalse(exists)
    }

    // MARK: - Complex Data Tests

    func test_save_complexObject_shouldSucceed() throws {
        // Given
        let key = "test_complex.json"
        let value = ComplexData(
            id: "complex-1",
            title: "Complex Object",
            items: ["item1", "item2", "item3"],
            metadata: ["key1": "value1", "key2": "value2"]
        )

        // When
        try sut.save(value, forKey: key)

        // Then
        let loaded: ComplexData? = try sut.load(forKey: key)
        XCTAssertEqual(loaded?.id, value.id)
        XCTAssertEqual(loaded?.title, value.title)
        XCTAssertEqual(loaded?.items, value.items)
        XCTAssertEqual(loaded?.metadata, value.metadata)

        // Clean up
        try? sut.remove(forKey: key)
    }
}

// MARK: - Test Models

struct TestData: Codable, Equatable {
    let id: String
    let content: String
}

struct ComplexData: Codable, Equatable {
    let id: String
    let title: String
    let items: [String]
    let metadata: [String: String]
}
