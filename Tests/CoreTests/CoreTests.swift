import XCTest
@testable import Core

final class CoreTests: XCTestCase {
    func testExample() throws {
        let core = Core()
        XCTAssertEqual(Core.version, "1.0.0")
    }
}
