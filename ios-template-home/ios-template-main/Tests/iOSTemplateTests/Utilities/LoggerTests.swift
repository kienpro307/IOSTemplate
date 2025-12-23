import XCTest
@testable import iOSTemplate

final class LoggerTests: XCTestCase {

    // MARK: - Properties

    var sut: Logger!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = Logger.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Log Level Tests

    func test_debug_shouldNotThrow() {
        // When/Then - Should not throw
        XCTAssertNoThrow(sut.debug("Debug message"))
    }

    func test_info_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(sut.info("Info message"))
    }

    func test_warning_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(sut.warning("Warning message"))
    }

    func test_error_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(sut.error("Error message"))
    }

    func test_error_withError_shouldNotThrow() {
        // Given
        let testError = NSError(domain: "test", code: 123, userInfo: nil)

        // When/Then
        XCTAssertNoThrow(sut.error("Error occurred", error: testError))
    }

    func test_verbose_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(sut.verbose("Verbose message"))
    }

    // MARK: - Global Functions Tests

    func test_logDebug_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(logDebug("Global debug"))
    }

    func test_logInfo_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(logInfo("Global info"))
    }

    func test_logWarning_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(logWarning("Global warning"))
    }

    func test_logError_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(logError("Global error"))
    }

    func test_logVerbose_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(logVerbose("Global verbose"))
    }

    // MARK: - File Info Tests

    func test_log_withFileInfo_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(
            sut.debug("Message with file info", file: "TestFile.swift", function: "testFunction", line: 42)
        )
    }

    // MARK: - Edge Cases

    func test_log_emptyMessage_shouldNotThrow() {
        // When/Then
        XCTAssertNoThrow(sut.debug(""))
        XCTAssertNoThrow(sut.info(""))
    }

    func test_log_longMessage_shouldNotThrow() {
        // Given
        let longMessage = String(repeating: "A", count: 10000)

        // When/Then
        XCTAssertNoThrow(sut.debug(longMessage))
    }

    func test_log_specialCharacters_shouldNotThrow() {
        // Given
        let specialMessage = "Message with 特殊文字 émojis 🚀 and symbols @#$%"

        // When/Then
        XCTAssertNoThrow(sut.debug(specialMessage))
    }

    // MARK: - Performance Tests

    func test_logging_performance() {
        // Measure performance
        measure {
            for i in 0..<1000 {
                sut.debug("Performance test message \(i)")
            }
        }
    }
}
