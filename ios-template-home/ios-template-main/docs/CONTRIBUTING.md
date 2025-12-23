# 🤝 Contributing to iOS Template

Cảm ơn bạn quan tâm đến việc contribute cho iOS Template! Tài liệu này sẽ hướng dẫn bạn quy trình contribute code.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Documentation](#documentation)

---

## Code of Conduct

Dự án này tuân theo [Code of Conduct](CODE_OF_CONDUCT.md). Bằng việc tham gia, bạn đồng ý tuân theo các quy tắc này.

---

## Getting Started

### Prerequisites

- macOS Sonoma hoặc mới hơn
- Xcode 15.0+
- Swift 5.9+
- Git
- Homebrew (khuyến nghị)

### Setup Development Environment

1. **Fork repository**

```bash
# Trên GitHub, click "Fork" button
```

2. **Clone forked repository**

```bash
git clone https://github.com/YOUR_USERNAME/ios-template.git
cd ios-template
```

3. **Add upstream remote**

```bash
git remote add upstream https://github.com/kienpro307/ios-template.git
```

4. **Open project**

```bash
open Package.swift
```

5. **Build project**

```bash
# Xcode: ⌘B
# hoặc terminal:
swift build
```

6. **Run tests**

```bash
swift test
# hoặc Xcode: ⌘U
```

---

## Development Workflow

### Branch Strategy

```
main (protected)
  ↓
develop (default branch)
  ↓
feature/your-feature-name
fix/bug-description
docs/documentation-update
```

### Creating a Feature Branch

```bash
# Sync với upstream
git checkout develop
git pull upstream develop

# Tạo feature branch
git checkout -b feature/my-new-feature
```

### Branch Naming Convention

- **Feature**: `feature/add-dark-mode-toggle`
- **Bug Fix**: `fix/login-crash-on-empty-email`
- **Documentation**: `docs/update-api-documentation`
- **Refactor**: `refactor/simplify-network-layer`
- **Test**: `test/add-onboarding-tests`

---

## Coding Standards

### Swift Style Guide

Chúng tôi tuân theo [Swift Style Guide](https://google.github.io/swift/) với một số customizations.

#### SwiftLint

Project sử dụng SwiftLint để enforce code style:

```bash
# Chạy SwiftLint
swiftlint lint

# Auto-fix (nếu có)
swiftlint --fix
```

**Lưu ý**: Code của bạn PHẢI pass SwiftLint trước khi submit PR.

### Code Conventions

#### 1. Naming

```swift
// ✅ Good
class UserProfileViewModel { }
func fetchUserData() { }
let isAuthenticated: Bool

// ❌ Bad
class usrPrfVm { }
func getData() { }
let auth: Bool
```

#### 2. Access Control

```swift
// ✅ Sử dụng access control phù hợp
public class FirebaseManager {
    private let container: Container
    internal var config: FirebaseConfig?
    public func configure() { }
}

// ❌ Không explicit access control
class FirebaseManager {
    let container: Container  // Mặc định internal
}
```

#### 3. Documentation Comments

**REQUIRED** cho tất cả public APIs:

```swift
/// Brief description of what this does
///
/// Detailed explanation if needed.
///
/// - Parameters:
///   - param1: Description of param1
///   - param2: Description of param2
/// - Returns: Description of return value
/// - Throws: Description of errors that can be thrown
///
/// ## Example:
/// ```swift
/// let result = myFunction(param1: value1, param2: value2)
/// ```
public func myFunction(param1: String, param2: Int) throws -> Result {
    // Implementation
}
```

#### 4. Code Organization

```swift
// MARK: - Type Definition
public class MyClass {

    // MARK: - Properties

    private let dependency: DependencyType
    public var publicProperty: String

    // MARK: - Initialization

    public init(dependency: DependencyType) {
        self.dependency = dependency
    }

    // MARK: - Public Methods

    public func publicMethod() { }

    // MARK: - Private Methods

    private func privateMethod() { }
}

// MARK: - Extensions

extension MyClass: SomeProtocol {
    // Protocol conformance
}
```

### Parameterized Component Pattern

Khi tạo reusable components, tuân theo pattern:

```swift
// 1. Config Model
public struct MyComponentConfig {
    public let title: String
    public let color: Color
    public let onComplete: () -> Void

    public init(
        title: String,
        color: Color = .theme.primary,
        onComplete: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.onComplete = onComplete
    }
}

// 2. View nhận config
public struct MyComponentView: View {
    let config: MyComponentConfig

    public init(config: MyComponentConfig) {
        self.config = config
    }

    public var body: some View {
        // Use config
    }
}

// 3. Default configs (optional)
public extension MyComponentConfig {
    static func `default`(onComplete: @escaping () -> Void) -> MyComponentConfig {
        MyComponentConfig(
            title: "Default Title",
            color: .blue,
            onComplete: onComplete
        )
    }
}
```

Xem [Component Pattern Guide](../COMPONENT_PATTERN.md) để biết chi tiết.

---

## Testing Guidelines

### Test Requirements

- **Reducers**: 90%+ coverage
- **Business Logic**: 80%+ coverage
- **Utilities**: 100% coverage
- **Overall**: 80%+ coverage

### Writing Tests

#### 1. Unit Tests

```swift
import XCTest
@testable import iOSTemplate

final class UserServiceTests: XCTestCase {
    var sut: UserService!  // System Under Test
    var mockStorage: MockStorage!

    override func setUp() {
        super.setUp()
        mockStorage = MockStorage()
        sut = UserService(storage: mockStorage)
    }

    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }

    func testSaveUser_ValidData_SavesSuccessfully() throws {
        // Given
        let user = User(id: "123", name: "John")

        // When
        try sut.save(user)

        // Then
        let saved = try mockStorage.load(User.self, forKey: "user_123")
        XCTAssertEqual(saved?.name, "John")
    }
}
```

#### 2. TCA Reducer Tests

```swift
import ComposableArchitecture
import XCTest
@testable import iOSTemplate

final class LoginReducerTests: XCTestCase {
    @MainActor
    func testLogin_ValidCredentials_Success() async {
        let store = TestStore(
            initialState: LoginReducer.State()
        ) {
            LoginReducer()
        }

        await store.send(.emailChanged("test@example.com")) {
            $0.email = "test@example.com"
        }

        await store.send(.passwordChanged("password123")) {
            $0.password = "password123"
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(.loginResponse(.success)) {
            $0.isLoading = false
            $0.isAuthenticated = true
        }
    }
}
```

#### 3. Mocking

```swift
// Mock protocols, not concrete types
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class MockNetworkService: NetworkServiceProtocol {
    var fetchCallCount = 0
    var fetchResult: Result<Any, Error> = .failure(NetworkError.unknown)

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        fetchCallCount += 1
        switch fetchResult {
        case .success(let value):
            return value as! T
        case .failure(let error):
            throw error
        }
    }
}
```

### Running Tests

```bash
# Tất cả tests
swift test

# Specific test
swift test --filter LoginReducerTests

# Với coverage
xcodebuild test -scheme iOSTemplate -enableCodeCoverage YES
```

---

## Pull Request Process

### Before Submitting PR

**Checklist:**

- [ ] Code tuân theo Swift Style Guide
- [ ] SwiftLint pass (`swiftlint lint`)
- [ ] Tất cả tests pass (`swift test`)
- [ ] Coverage requirements đạt
- [ ] Documentation comments cho public APIs
- [ ] README/docs updated nếu cần
- [ ] Commits tuân theo Conventional Commits

### Commit Message Format

Sử dụng [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**

```bash
feat(auth): add biometric authentication support

- Add BiometricService protocol
- Implement FaceID/TouchID authentication
- Add unit tests for BiometricService

Closes #123

---

fix(network): handle timeout errors correctly

Previously timeout errors were not properly caught,
causing app crashes.

Fixes #456

---

docs(api): update API documentation for FirebaseManager

- Add usage examples
- Update parameter descriptions
- Fix typos
```

### Creating Pull Request

1. **Push branch**

```bash
git push origin feature/my-new-feature
```

2. **Tạo PR trên GitHub**

- Base branch: `develop`
- Compare branch: `feature/my-new-feature`

3. **Fill PR template**

```markdown
## Description

Brief description of changes.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests added/updated
- [ ] All tests passing
- [ ] Manual testing performed

## Checklist

- [ ] Code follows style guide
- [ ] SwiftLint passes
- [ ] Documentation updated
- [ ] Tests added
- [ ] Coverage requirements met
```

4. **Request review**

Tag relevant reviewers.

5. **Address feedback**

```bash
# Make changes
git add .
git commit -m "fix: address PR feedback"
git push origin feature/my-new-feature
```

### PR Review Criteria

Reviewers sẽ kiểm tra:

1. **Code Quality**
   - Follows Swift style guide
   - Clean, readable code
   - Proper error handling
   - No code smells

2. **Architecture**
   - Follows project patterns
   - Proper separation of concerns
   - Dependency injection used correctly

3. **Testing**
   - Adequate test coverage
   - Tests are meaningful
   - Edge cases covered

4. **Documentation**
   - Public APIs documented
   - README updated if needed
   - Comments are clear

5. **Performance**
   - No performance regressions
   - Efficient algorithms
   - Proper memory management

---

## Documentation

### When to Update Docs

Update documentation khi:

- Thêm public API mới
- Thay đổi behavior của existing API
- Thêm feature mới
- Fix bug quan trọng
- Thay đổi architecture

### Documentation Files

- **README.md**: Project overview, quick start
- **ARCHITECTURE.md**: Architecture decisions
- **COMPONENT_PATTERN.md**: Pattern guide
- **API_DOCUMENTATION.md**: API reference
- **SETUP.md**: Setup instructions
- **CONTRIBUTING.md**: This file
- **docs/**: Detailed guides

### Doc Comments

```swift
/// Short description (< 80 chars)
///
/// Detailed explanation. Có thể nhiều paragraphs.
///
/// ## Usage:
/// ```swift
/// let manager = FirebaseManager.shared
/// try manager.configure(with: .auto)
/// ```
///
/// - Parameters:
///   - config: Configuration object
/// - Throws: `FirebaseError` if configuration fails
/// - Returns: Configuration result
/// - Important: Must call before using Firebase services
/// - Note: Thread-safe, can be called from any thread
public func configure(with config: FirebaseConfig) throws -> Bool {
    // ...
}
```

---

## 🎓 Additional Resources

### Learning Resources

- [Swift Style Guide](https://google.github.io/swift/)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Swinject Documentation](https://github.com/Swinject/Swinject)
- [Swift Package Manager](https://swift.org/package-manager/)

### Project Resources

- [Architecture Guide](../ARCHITECTURE.md)
- [Component Pattern](../COMPONENT_PATTERN.md)
- [API Documentation](./API_DOCUMENTATION.md)
- [Setup Guide](../SETUP.md)

### Community

- [GitHub Issues](https://github.com/kienpro307/ios-template/issues)
- [GitHub Discussions](https://github.com/kienpro307/ios-template/discussions)

---

## 🙏 Thank You!

Cảm ơn bạn đã contribute! Mỗi contribution, dù lớn hay nhỏ, đều giúp dự án tốt hơn.

**Happy Coding! 🚀**
