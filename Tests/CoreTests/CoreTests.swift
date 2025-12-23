import XCTest
@testable import Core

/// Test cases cho Core module
final class CoreTests: XCTestCase {
    /// Test mẫu - kiểm tra phiên bản Core
    func testExample() throws {
        let core = Core()
        XCTAssertEqual(Core.version, "1.0.0")
    }
}
