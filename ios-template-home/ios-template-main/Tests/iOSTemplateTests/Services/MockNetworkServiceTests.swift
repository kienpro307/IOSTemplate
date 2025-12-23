import XCTest
@testable import iOSTemplate

@MainActor
final class MockNetworkServiceTests: XCTestCase {

    // MARK: - Properties

    var sut: MockNetworkService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = MockNetworkService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Request Tests

    func test_request_whenSuccessful_shouldReturnDecodedData() async throws {
        // Given
        let mockUser = TestUser(id: "123", name: "Test User")
        let mockData = try JSONEncoder().encode(mockUser)
        sut.mockData = mockData
        sut.shouldFail = false

        // When
        let result: TestUser = try await sut.request(
            endpoint: "/users",
            method: .get,
            parameters: nil,
            headers: nil
        )

        // Then
        XCTAssertEqual(result.id, mockUser.id)
        XCTAssertEqual(result.name, mockUser.name)
        XCTAssertEqual(sut.requestCallCount, 1)
    }

    func test_request_whenShouldFail_shouldThrowError() async {
        // Given
        sut.shouldFail = true
        sut.mockError = NetworkError.noConnection

        // When/Then
        do {
            let _: TestUser = try await sut.request(
                endpoint: "/users",
                method: .get,
                parameters: nil,
                headers: nil
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
            if let networkError = error as? NetworkError,
               case .noConnection = networkError {
                // Success - correct error type
            } else {
                XCTFail("Wrong error type")
            }
        }

        XCTAssertEqual(sut.requestCallCount, 1)
    }

    func test_request_whenNoMockData_shouldThrowNoConnectionError() async {
        // Given
        sut.mockData = nil
        sut.shouldFail = false

        // When/Then
        do {
            let _: TestUser = try await sut.request(
                endpoint: "/users",
                method: .get,
                parameters: nil,
                headers: nil
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func test_upload_whenSuccessful_shouldReturnData() async throws {
        // Given
        let mockData = Data("success".utf8)
        sut.mockData = mockData
        sut.shouldFail = false

        // When
        let result = try await sut.upload(
            endpoint: "/upload",
            data: Data(),
            headers: nil
        )

        // Then
        XCTAssertEqual(result, mockData)
        XCTAssertEqual(sut.requestCallCount, 1)
    }

    func test_upload_whenFails_shouldThrowError() async {
        // Given
        sut.shouldFail = true
        sut.mockError = NetworkError.serverError(500)

        // When/Then
        do {
            _ = try await sut.upload(
                endpoint: "/upload",
                data: Data(),
                headers: nil
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func test_download_whenSuccessful_shouldReturnURL() async throws {
        // Given
        sut.shouldFail = false

        // When
        let result = try await sut.download(
            endpoint: "/download",
            headers: nil
        )

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(sut.requestCallCount, 1)
    }

    func test_requestCallCount_shouldIncrementCorrectly() async throws {
        // Given
        let mockData = try JSONEncoder().encode(TestUser(id: "1", name: "Test"))
        sut.mockData = mockData

        // When
        _ = try? await sut.request(endpoint: "/test", method: .get, parameters: nil, headers: nil) as TestUser
        _ = try? await sut.upload(endpoint: "/upload", data: Data(), headers: nil)
        _ = try? await sut.download(endpoint: "/download", headers: nil)

        // Then
        XCTAssertEqual(sut.requestCallCount, 3)
    }
}

// MARK: - Test Models

struct TestUser: Codable {
    let id: String
    let name: String
}
