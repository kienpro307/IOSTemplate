import XCTest
@testable import Features

/// Test cases cho Features module
final class FeaturesTests: XCTestCase {
    /// Test mẫu - kiểm tra Features khởi tạo thành công
    func testExample() throws {
        let features = Features()
        XCTAssertNotNil(features)
    }
}
