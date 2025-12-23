# Testing Rules - iOS Template Project

## Testing Strategy

### Test Pyramid
```
        /\
       /UI\         10% - UI Tests (E2E)
      /____\
     /      \
    /Integration\ 30% - Integration Tests
   /____________\
  /              \
 /   Unit Tests   \  60% - Unit Tests
/__________________\
```

## Coverage Requirements

### Minimum Coverage by Layer
- **Reducers (TCA)**: 90%+
- **Business Logic/Services**: 80%+
- **Utilities/Extensions**: 100%
- **View Models**: 75%+
- **UI Components**: 50%+
- **Overall Project**: 80%+

### Critical Paths: 100% Coverage
- Authentication flow
- Payment processing
- Data persistence
- Network error handling
- Security features

## Test Naming Convention

### Pattern
```swift
func test_[stateUnderTest]_when[condition]_should[expectedBehavior]()
```

### Examples
```swift
// ✅ Good
func test_loginButton_whenTapped_shouldStartLoading()
func test_loginReducer_whenValidCredentials_shouldUpdateUserState()
func test_networkService_whenOffline_shouldReturnCachedData()
func test_userProfile_whenEmpty_shouldShowEmptyState()

// ❌ Bad
func testLogin()  // Too generic
func test1()  // Meaningless
func loginTest()  // Wrong prefix
func testUserLoginWhenButtonTapped()  // Wrong format
```

## Unit Testing

### TCA Reducer Tests

```swift
import ComposableArchitecture
import XCTest

@MainActor
final class LoginReducerTests: XCTestCase {

    func test_loginButton_whenTapped_shouldStartLoading() async {
        // Given
        let store = TestStore(
            initialState: Login.State(),
            reducer: { Login() }
        )

        // When
        await store.send(.loginButtonTapped) {
            // Then
            $0.isLoading = true
        }
    }

    func test_loginResponse_whenSuccess_shouldUpdateUser() async {
        // Given
        let user = User(id: "123", name: "Test User")
        let store = TestStore(
            initialState: Login.State(isLoading: true),
            reducer: { Login() }
        )

        // When
        await store.send(.loginResponse(.success(user))) {
            // Then
            $0.isLoading = false
            $0.user = user
        }
    }

    func test_loginResponse_whenFailure_shouldShowError() async {
        // Given
        let error = NetworkError.unauthorized
        let store = TestStore(
            initialState: Login.State(isLoading: true),
            reducer: { Login() }
        )

        // When
        await store.send(.loginResponse(.failure(error))) {
            // Then
            $0.isLoading = false
            $0.errorMessage = error.localizedDescription
        }
    }
}
```

### Service Tests with Mocks

```swift
import XCTest

final class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var mockAPIClient: MockAPIClient!
    var mockKeychain: MockKeychain!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockKeychain = MockKeychain()
        sut = AuthService(
            apiClient: mockAPIClient,
            keychain: mockKeychain
        )
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockKeychain = nil
        super.tearDown()
    }

    func test_login_whenValidCredentials_shouldReturnUser() async throws {
        // Given
        let expectedUser = User(id: "123", name: "Test")
        mockAPIClient.loginResult = .success(expectedUser)

        // When
        let user = try await sut.login(
            email: "test@example.com",
            password: "password123"
        )

        // Then
        XCTAssertEqual(user.id, expectedUser.id)
        XCTAssertEqual(user.name, expectedUser.name)
        XCTAssertTrue(mockKeychain.didSaveToken)
    }

    func test_login_whenInvalidCredentials_shouldThrowError() async {
        // Given
        mockAPIClient.loginResult = .failure(.unauthorized)

        // When/Then
        do {
            _ = try await sut.login(
                email: "test@example.com",
                password: "wrong"
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
```

### Testing Async/Await

```swift
func test_fetchData_shouldReturnData() async throws {
    // Given
    let expectedData = Data()
    mockService.dataToReturn = expectedData

    // When
    let data = try await sut.fetchData()

    // Then
    XCTAssertEqual(data, expectedData)
}

// Test with timeout
func test_longOperation_shouldCompleteWithinTimeout() async throws {
    // Use withTimeout from swift-async-algorithms
    try await withTimeout(.seconds(5)) {
        try await sut.longOperation()
    }
}
```

### Testing Combine Publishers

```swift
import Combine

func test_publisher_shouldEmitValues() {
    // Given
    var cancellables = Set<AnyCancellable>()
    let expectation = expectation(description: "Publisher emits value")
    var receivedValue: String?

    // When
    sut.dataPublisher
        .sink { value in
            receivedValue = value
            expectation.fulfill()
        }
        .store(in: &cancellables)

    sut.triggerPublisher()

    // Then
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(receivedValue, "expected")
}
```

## Integration Testing

### Database Integration Tests

```swift
final class UserRepositoryIntegrationTests: XCTestCase {
    var repository: UserRepository!
    var coreDataStack: TestCoreDataStack!

    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        repository = UserRepository(context: coreDataStack.context)
    }

    override func tearDown() {
        coreDataStack.cleanup()
        repository = nil
        super.tearDown()
    }

    func test_saveUser_shouldPersistToDatabase() throws {
        // Given
        let user = User(id: "123", name: "Test")

        // When
        try repository.save(user)

        // Then
        let fetchedUser = try repository.fetch(id: "123")
        XCTAssertEqual(fetchedUser?.id, user.id)
        XCTAssertEqual(fetchedUser?.name, user.name)
    }
}
```

### Network Integration Tests

```swift
final class APIClientIntegrationTests: XCTestCase {
    var sut: APIClient!

    override func setUp() {
        super.setUp()
        // Use test environment
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut = APIClient(configuration: config)
    }

    func test_fetchUser_shouldReturnDecodedUser() async throws {
        // Given
        let jsonData = """
        {"id": "123", "name": "Test User"}
        """.data(using: .utf8)!

        MockURLProtocol.mockData = jsonData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let user: User = try await sut.fetch(endpoint: .user("123"))

        // Then
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.name, "Test User")
    }
}
```

## UI Testing

### SwiftUI View Tests

```swift
import ViewInspector
import XCTest

final class LoginViewTests: XCTestCase {

    func test_loginView_whenLoading_shouldShowProgressView() throws {
        // Given
        let store = Store(
            initialState: Login.State(isLoading: true),
            reducer: { Login() }
        )
        let view = LoginView(store: store)

        // When/Then
        XCTAssertNoThrow(try view.inspect().find(ViewType.ProgressView.self))
    }

    func test_loginButton_whenTapped_shouldSendAction() throws {
        // Given
        let store = TestStore(
            initialState: Login.State(),
            reducer: { Login() }
        )
        let view = LoginView(store: store.store)

        // When
        try view.inspect().find(button: "Login").tap()

        // Then
        // Verify action sent via store
    }
}
```

### XCUITest - End-to-End

```swift
final class LoginFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    func test_loginFlow_whenValidCredentials_shouldNavigateToHome() {
        // Given
        let emailField = app.textFields["email-field"]
        let passwordField = app.secureTextFields["password-field"]
        let loginButton = app.buttons["login-button"]

        // When
        emailField.tap()
        emailField.typeText("test@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
    }

    func test_loginFlow_whenInvalidCredentials_shouldShowError() {
        // Given
        let emailField = app.textFields["email-field"]
        let passwordField = app.secureTextFields["password-field"]
        let loginButton = app.buttons["login-button"]

        // When
        emailField.tap()
        emailField.typeText("invalid@example.com")

        passwordField.tap()
        passwordField.typeText("wrong")

        loginButton.tap()

        // Then
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
    }
}
```

## Mock Objects

### Creating Mocks

```swift
// Protocol
protocol NetworkServiceProtocol {
    func fetchData() async throws -> Data
}

// Mock Implementation
final class MockNetworkService: NetworkServiceProtocol {
    var fetchDataCallCount = 0
    var fetchDataResult: Result<Data, Error>?
    var fetchDataShouldThrow = false

    func fetchData() async throws -> Data {
        fetchDataCallCount += 1

        if fetchDataShouldThrow {
            throw NetworkError.unknown
        }

        guard let result = fetchDataResult else {
            fatalError("fetchDataResult not set")
        }

        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
```

### Using Mock Builder Pattern

```swift
final class MockUserBuilder {
    private var id = "default-id"
    private var name = "Default Name"
    private var email = "default@example.com"

    func withId(_ id: String) -> Self {
        self.id = id
        return self
    }

    func withName(_ name: String) -> Self {
        self.name = name
        return self
    }

    func withEmail(_ email: String) -> Self {
        self.email = email
        return self
    }

    func build() -> User {
        User(id: id, name: name, email: email)
    }
}

// Usage in tests
func test_example() {
    let user = MockUserBuilder()
        .withId("123")
        .withName("Test User")
        .build()

    // Test with user
}
```

## Test Data & Fixtures

```swift
enum TestFixtures {
    static let validUser = User(
        id: "test-123",
        name: "Test User",
        email: "test@example.com"
    )

    static let validCredentials = Credentials(
        email: "test@example.com",
        password: "password123"
    )

    static func makeUser(
        id: String = "default",
        name: String = "Default Name"
    ) -> User {
        User(id: id, name: name, email: "\(name)@example.com")
    }
}
```

## Performance Testing

```swift
func test_fetchUsers_shouldCompleteWithinTimeLimit() {
    // Measure execution time
    measure {
        let users = repository.fetchAllUsers()
        XCTAssertFalse(users.isEmpty)
    }

    // Set baseline in Xcode:
    // Product -> Perform Action -> Set Baseline
}

func test_imageProcessing_shouldNotExceedMemoryLimit() {
    // Measure memory usage
    let options = XCTMeasureOptions()
    options.invocationOptions = [.manuallyStop]

    measure(options: options) {
        let image = processLargeImage()
        XCTAssertNotNil(image)
    }
}
```

## Snapshot Testing

```swift
import SnapshotTesting

final class LoginViewSnapshotTests: XCTestCase {

    func test_loginView_lightMode() {
        let store = Store(
            initialState: Login.State(),
            reducer: { Login() }
        )
        let view = LoginView(store: store)

        assertSnapshot(
            matching: view,
            as: .image(layout: .device(config: .iPhone13Pro))
        )
    }

    func test_loginView_darkMode() {
        let store = Store(
            initialState: Login.State(),
            reducer: { Login() }
        )
        let view = LoginView(store: store)
            .preferredColorScheme(.dark)

        assertSnapshot(
            matching: view,
            as: .image(layout: .device(config: .iPhone13Pro))
        )
    }
}
```

## Test Organization

### Folder Structure
```
Tests/
├── UnitTests/
│   ├── Features/
│   │   ├── Auth/
│   │   │   ├── LoginReducerTests.swift
│   │   │   └── AuthServiceTests.swift
│   │   └── Profile/
│   ├── Services/
│   └── Utilities/
├── IntegrationTests/
│   ├── DatabaseTests/
│   └── NetworkTests/
├── UITests/
│   ├── LoginFlowUITests.swift
│   └── OnboardingUITests.swift
├── Mocks/
│   ├── MockNetworkService.swift
│   └── MockDatabase.swift
└── Fixtures/
    └── TestFixtures.swift
```

## Test Utilities

```swift
// XCTestCase extension
extension XCTestCase {
    func waitForAsync(timeout: TimeInterval = 5.0) async {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }

    func asyncExpectation(
        description: String,
        timeout: TimeInterval = 5.0,
        action: @escaping () async throws -> Void
    ) async throws {
        let expectation = expectation(description: description)

        Task {
            try await action()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: timeout)
    }
}
```

## Testing Best Practices

### DO ✅
- Write tests before fixing bugs (TDD)
- Keep tests simple and focused
- Use descriptive test names
- Test one thing per test
- Use arrange-act-assert pattern
- Mock external dependencies
- Test edge cases and error paths
- Maintain test data fixtures
- Run tests before committing
- Keep tests fast (< 100ms unit, < 1s integration)

### DON'T ❌
- Test implementation details
- Write flaky tests
- Depend on test execution order
- Use sleeps/waits (use expectations)
- Test framework code
- Share mutable state between tests
- Ignore failing tests
- Skip test cleanup
- Hardcode production URLs
- Leave commented-out test code

## Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter LoginReducerTests

# Run with coverage
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Run UI tests
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSTemplateUITests

# Generate coverage report
xcrun llvm-cov show \
  .build/debug/iOSTemplatePackageTests.xctest/Contents/MacOS/iOSTemplatePackageTests \
  -instr-profile .build/debug/codecov/default.profdata
```

## CI Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: swift test --enable-code-coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Test Coverage Reports

View coverage in Xcode:
1. Run tests with coverage enabled
2. Open Report Navigator (⌘9)
3. Select latest test report
4. Click Coverage tab

Or use command line:
```bash
xcodebuild test \
  -scheme iOSTemplate \
  -enableCodeCoverage YES \
  -resultBundlePath ./test-results

xcrun xccov view --report ./test-results.xcresult
```
