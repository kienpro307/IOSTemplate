import XCTest
@testable import iOSTemplate

final class MemoryCacheTests: XCTestCase {

    // MARK: - Properties

    var sut: MemoryCache<String, TestCacheObject>!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = MemoryCache()
    }

    override func tearDown() {
        sut.removeAll()
        sut = nil
        super.tearDown()
    }

    // MARK: - Set Tests

    func test_insert_shouldStoreValue() {
        // Given
        let key = "test-key"
        let value = TestCacheObject(id: "1", data: "Test Data")

        // When
        sut.insert(value, forKey: key)

        // Then
        let retrieved = sut.value(forKey: key)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, value.id)
        XCTAssertEqual(retrieved?.data, value.data)
    }

    func test_insert_overwriteExisting_shouldSucceed() {
        // Given
        let key = "overwrite-key"
        let value1 = TestCacheObject(id: "1", data: "First")
        let value2 = TestCacheObject(id: "2", data: "Second")

        // When
        sut.insert(value1, forKey: key)
        sut.insert(value2, forKey: key)

        // Then
        let retrieved = sut.value(forKey: key)
        XCTAssertEqual(retrieved?.id, value2.id)
        XCTAssertEqual(retrieved?.data, value2.data)
    }

    // MARK: - Value Tests

    func test_value_nonExistentKey_shouldReturnNil() {
        // Given
        let key = "non-existent"

        // When
        let retrieved = sut.value(forKey: key)

        // Then
        XCTAssertNil(retrieved)
    }

    func test_value_afterInsert_shouldReturnValue() {
        // Given
        let key = "get-key"
        let value = TestCacheObject(id: "123", data: "Cached Data")
        sut.insert(value, forKey: key)

        // When
        let retrieved = sut.value(forKey: key)

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, value.id)
    }

    // MARK: - Remove Tests

    func test_removeValue_shouldDeleteValue() {
        // Given
        let key = "remove-key"
        let value = TestCacheObject(id: "1", data: "To Remove")
        sut.insert(value, forKey: key)

        // When
        sut.removeValue(forKey: key)

        // Then
        let retrieved = sut.value(forKey: key)
        XCTAssertNil(retrieved)
    }

    func test_removeValue_nonExistentKey_shouldNotCrash() {
        // Given
        let key = "non-existent"

        // When/Then - Should not crash
        XCTAssertNoThrow(sut.removeValue(forKey: key))
    }

    // MARK: - RemoveAll Tests

    func test_removeAll_shouldClearCache() {
        // Given
        sut.insert(TestCacheObject(id: "1", data: "Data 1"), forKey: "key1")
        sut.insert(TestCacheObject(id: "2", data: "Data 2"), forKey: "key2")
        sut.insert(TestCacheObject(id: "3", data: "Data 3"), forKey: "key3")

        // When
        sut.removeAll()

        // Then
        XCTAssertNil(sut.value(forKey: "key1"))
        XCTAssertNil(sut.value(forKey: "key2"))
        XCTAssertNil(sut.value(forKey: "key3"))
    }

    // MARK: - Multiple Keys Tests

    func test_multipleKeys_shouldBeIndependent() {
        // Given
        let key1 = "key1"
        let key2 = "key2"
        let value1 = TestCacheObject(id: "1", data: "Data 1")
        let value2 = TestCacheObject(id: "2", data: "Data 2")

        // When
        sut.insert(value1, forKey: key1)
        sut.insert(value2, forKey: key2)

        // Then
        let retrieved1 = sut.value(forKey: key1)
        let retrieved2 = sut.value(forKey: key2)

        XCTAssertEqual(retrieved1?.id, value1.id)
        XCTAssertEqual(retrieved2?.id, value2.id)

        // Remove one key
        sut.removeValue(forKey: key1)

        // Verify other key still exists
        XCTAssertNil(sut.value(forKey: key1))
        XCTAssertNotNil(sut.value(forKey: key2))
    }

    // MARK: - Performance Tests

    func test_cache_performance() {
        measure {
            for i in 0..<1000 {
                let key = "key-\(i)"
                let value = TestCacheObject(id: "\(i)", data: "Data \(i)")
                sut.insert(value, forKey: key)
            }
        }
    }
}

// MARK: - DiskCache Tests

final class DiskCacheTests: XCTestCase {

    // MARK: - Properties

    var sut: DiskCache<String, TestCacheObject>!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        do {
            sut = try DiskCache(name: "TestCache")
        } catch {
            XCTFail("Failed to initialize DiskCache: \(error)")
        }
    }

    override func tearDown() {
        try? sut?.removeAll()
        sut = nil
        super.tearDown()
    }

    // MARK: - Insert Tests

    func test_insert_shouldPersistToDisk() throws {
        // Given
        let key = "disk-key"
        let value = TestCacheObject(id: "1", data: "Disk Data")

        // When
        try sut.insert(value, forKey: key)

        // Then
        let retrieved = try sut.value(forKey: key)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, value.id)
        XCTAssertEqual(retrieved?.data, value.data)
    }

    // MARK: - Value Tests

    func test_value_nonExistentKey_shouldReturnNil() throws {
        // Given
        let key = "non-existent"

        // When
        let retrieved = try sut.value(forKey: key)

        // Then
        XCTAssertNil(retrieved)
    }

    // MARK: - Remove Tests

    func test_removeValue_shouldDeleteFromDisk() throws {
        // Given
        let key = "remove-disk-key"
        let value = TestCacheObject(id: "1", data: "To Remove")
        try sut.insert(value, forKey: key)

        // When
        try sut.removeValue(forKey: key)

        // Then
        let retrieved = try sut.value(forKey: key)
        XCTAssertNil(retrieved)
    }

    // MARK: - RemoveAll Tests

    func test_removeAll_shouldClearAllFiles() throws {
        // Given
        try sut.insert(TestCacheObject(id: "1", data: "Data 1"), forKey: "key1")
        try sut.insert(TestCacheObject(id: "2", data: "Data 2"), forKey: "key2")
        try sut.insert(TestCacheObject(id: "3", data: "Data 3"), forKey: "key3")

        // When
        try sut.removeAll()

        // Then
        XCTAssertNil(try sut.value(forKey: "key1"))
        XCTAssertNil(try sut.value(forKey: "key2"))
        XCTAssertNil(try sut.value(forKey: "key3"))
    }
}

// MARK: - Test Models

class TestCacheObject: Codable {
    let id: String
    let data: String

    init(id: String, data: String) {
        self.id = id
        self.data = data
    }
}
