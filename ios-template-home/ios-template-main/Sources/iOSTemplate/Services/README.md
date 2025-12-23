# Services - Dependency Injection & Service Layer

## Tổng quan

Thư mục `Services/` chứa infrastructure cho **Dependency Injection (DI)** và định nghĩa tất cả **service protocols** trong app. Đây là foundation layer cung cấp loose coupling, testability, và modularity cho toàn bộ ứng dụng.

### Chức năng chính
- Quản lý dependencies với Swinject DI Container
- Cung cấp Service Locator pattern cho edge cases
- Định nghĩa contracts (protocols) cho tất cả business services
- Support dependency injection với property wrappers
- Enable easy testing với mock implementations

### Tác động đến toàn bộ app
- **Critical Impact**: Mọi layer trong app phụ thuộc vào Services layer
- Quyết định cách dependencies được resolve và injected
- Ảnh hưởng đến testability của toàn bộ codebase
- Cung cấp single source of truth cho service instances
- Enable modular architecture và separation of concerns

---

## Cấu trúc Files

```
Services/
├── ServiceProtocols.swift    # Service interfaces (290 dòng)
└── DI/
    ├── DIContainer.swift     # Swinject DI container (261 dòng)
    └── ServiceLocator.swift  # Service locator pattern (139 dòng)
```

**Tổng cộng**: 690 dòng code, 3 files

---

## Chi tiết các Files

### 1. ServiceProtocols.swift (290 dòng)

**Chức năng**: Định nghĩa tất cả service protocol contracts cho app

#### Các protocol chính:

##### `NetworkServiceProtocol` (dòng 6-27)
Protocol cho network communication layer.

**Methods**:
- `request<T: Decodable>(endpoint:method:parameters:headers:) async throws -> T`
  - Generic async request method
  - Returns decoded type T
- `upload(endpoint:data:headers:) async throws -> Data`
  - Upload data to endpoint
- `download(endpoint:headers:) async throws -> URL`
  - Download file, returns local URL

**HTTPMethod enum** (dòng 30-36):
```swift
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
```

**Usage**:
```swift
@Dependency(\.networkService) var networkService

let user: UserProfile = try await networkService.request(
    endpoint: "/v1/users/123",
    method: .get,
    parameters: nil,
    headers: nil
)
```

##### `AuthServiceProtocol` (dòng 41-68)
Protocol cho authentication và authorization.

**Properties**:
- `isAuthenticated: Bool { get }` - Trạng thái đăng nhập
- `currentUserID: String? { get }` - ID của user hiện tại

**Methods**:
- `login(email:password:) async throws -> AuthResponse`
- `loginWithSocial(provider:) async throws -> AuthResponse`
- `logout() async throws`
- `refreshToken() async throws -> AuthResponse`
- `register(email:password:name:) async throws -> AuthResponse`
- `resetPassword(email:) async throws`
- `authenticateWithBiometric() async throws -> Bool`

**SocialProvider enum** (dòng 71-75):
```swift
public enum SocialProvider {
    case apple
    case google
    case facebook
}
```

**AuthResponse struct** (dòng 78-90):
```swift
public struct AuthResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let userID: String
}
```

##### `AnalyticsServiceProtocol` (dòng 95-107)
Protocol cho analytics tracking.

**Methods**:
- `trackEvent(_ event: AnalyticsEvent)` - Track custom event
- `trackScreen(_ screenName: String, parameters:)` - Screen view tracking
- `setUserProperty(_ value: String, forName:)` - User properties
- `setUserID(_ userID: String?)` - Set user identifier

**AnalyticsEvent struct** (dòng 110-118):
```swift
public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: Any]?
}
```

**Usage**:
```swift
let event = AnalyticsEvent(name: "button_clicked", parameters: [
    "screen": "home",
    "button_id": "login"
])
analyticsService.trackEvent(event)
```

##### `LoggingServiceProtocol` (dòng 123-138)
Protocol cho unified logging.

**Methods**:
- `verbose(_ message: String, file:function:line:)` - Verbose logs
- `debug(_ message: String, file:function:line:)` - Debug logs
- `info(_ message: String, file:function:line:)` - Info logs
- `warning(_ message: String, file:function:line:)` - Warning logs
- `error(_ message: String, error:file:function:line:)` - Error logs

**Usage**:
```swift
loggingService.info("User logged in", file: #file, function: #function, line: #line)
loggingService.error("Network request failed", error: networkError)
```

##### `RemoteConfigServiceProtocol` (dòng 143-158)
Protocol cho remote configuration (Firebase Remote Config, etc).

**Methods**:
- `fetch() async throws` - Fetch latest config
- `getString(forKey:defaultValue:) -> String`
- `getBool(forKey:defaultValue:) -> Bool`
- `getInt(forKey:defaultValue:) -> Int`
- `getDouble(forKey:defaultValue:) -> Double`

**Usage**:
```swift
await remoteConfigService.fetch()
let featureEnabled = remoteConfigService.getBool(forKey: "new_feature_enabled", defaultValue: false)
```

##### `ImageCacheServiceProtocol` (dòng 163-178)
Protocol cho image caching.

**Methods**:
- `cacheImage(_ data: Data, forKey:)` - Cache image data
- `getCachedImage(forKey:) -> Data?` - Retrieve cached image
- `removeCachedImage(forKey:)` - Remove specific image
- `clearCache()` - Clear all cached images
- `cacheSize() -> Int64` - Get total cache size

##### `PushNotificationServiceProtocol` (dòng 183-201)
Protocol cho push notifications.

**Methods**:
- `requestPermission() async throws -> Bool`
- `registerForRemoteNotifications()`
- `handleDeviceToken(_ token: Data)`
- `handleNotification(_ userInfo:)`
- `subscribe(toTopic:)` - Subscribe to topic
- `unsubscribe(fromTopic:)` - Unsubscribe from topic

##### `LocationServiceProtocol` (dòng 206-218)
Protocol cho location services.

**Methods**:
- `requestPermission() async throws -> Bool`
- `getCurrentLocation() async throws -> Location`
- `startMonitoring()` - Start location monitoring
- `stopMonitoring()` - Stop monitoring

**Location struct** (dòng 221-233):
```swift
public struct Location: Codable {
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let timestamp: Date
}
```

#### Error Types (dòng 238-289)

##### `ServiceError` (dòng 238-259)
Common service layer errors.

**Cases**:
- `.notInitialized` - Service chưa được khởi tạo
- `.invalidConfiguration` - Config không hợp lệ
- `.unauthorized` - Unauthorized access
- `.networkError(Error)` - Network error wrapper
- `.unknown(Error)` - Unknown error wrapper

##### `NetworkError` (dòng 262-289)
Network-specific errors.

**Cases**:
- `.noConnection` - No internet connection
- `.timeout` - Request timeout
- `.serverError(Int)` - Server error với status code
- `.unauthorized` - 401 Unauthorized
- `.invalidResponse` - Invalid response format
- `.decodingError(Error)` - JSON decoding failed
- `.unknown` - Unknown network error

---

### 2. DI/DIContainer.swift (261 dòng)

**Chức năng**: Swinject-based Dependency Injection Container

#### Các class chính:

##### `DIContainer` (dòng 6-62)
Main DI container singleton.

**Properties**:
- `shared: DIContainer` - Singleton instance
- `container: Container` - Swinject container
- `assembler: Assembler` - Assembly orchestrator

**Initialization** (dòng 23-37):
```swift
private init() {
    self.container = Container()

    let assemblies: [Swinject.Assembly] = [
        StorageAssembly(),
        ServiceAssembly(),
        RepositoryAssembly()
    ]

    self.assembler = Assembler(assemblies, container: container)
}
```

**Public Methods**:

1. **`resolve<T>(_ type: T.Type) -> T?`** (dòng 42-44):
   - Resolve dependency by type
   - Returns nil if not registered

2. **`resolve<T, Arg>(_ type: T.Type, argument:) -> T?`** (dòng 47-49):
   - Resolve with argument
   - For dependencies requiring parameters

3. **`register<T>(_ type: T.Type, factory:)`** (dòng 52-56):
   - Register dependency (for testing)
   - Factory closure provides instance

4. **`removeAll()`** (dòng 59-61):
   - Remove all registrations
   - For test cleanup

**Convenience Properties** (dòng 66-100):

```swift
public extension DIContainer {
    // Storage Services
    var userDefaultsStorage: StorageServiceProtocol { ... }
    var keychainStorage: SecureStorageProtocol { ... }
    var fileStorage: FileStorageProtocol { ... }

    // Business Services
    var networkService: NetworkServiceProtocol? { ... }
    var authService: AuthServiceProtocol? { ... }
    var analyticsService: AnalyticsServiceProtocol? { ... }
    var loggingService: LoggingServiceProtocol? { ... }
    var remoteConfigService: RemoteConfigServiceProtocol? { ... }
}
```

**Usage**:
```swift
let storage = DIContainer.shared.userDefaultsStorage
let keychain = DIContainer.shared.keychainStorage
```

##### `StorageAssembly` (dòng 105-142)
Assembly cho storage layer dependencies.

**Registrations** (dòng 106-141):

1. **UserDefaultsStorage** (dòng 108-111):
```swift
container.register(StorageServiceProtocol.self) { _ in
    UserDefaultsStorage()
}
.inObjectScope(.container) // Singleton
```

2. **KeychainStorage** (dòng 114-117):
```swift
container.register(SecureStorageProtocol.self) { _ in
    KeychainStorage()
}
.inObjectScope(.container)
```

3. **FileStorage - Documents** (dòng 120-123):
```swift
container.register(FileStorageProtocol.self, name: "documents") { _ in
    FileStorage.documents
}
```

4. **FileStorage - Cache** (dòng 126-129):
```swift
container.register(FileStorageProtocol.self, name: "cache") { _ in
    FileStorage.cache
}
```

5. **FileStorage - Temporary** (dòng 132-135):
```swift
container.register(FileStorageProtocol.self, name: "temporary") { _ in
    FileStorage.temporary
}
```

6. **Default FileStorage** (dòng 138-140):
```swift
container.register(FileStorageProtocol.self) { resolver in
    resolver.resolve(FileStorageProtocol.self, name: "documents")!
}
```

**Scopes**:
- `.container` - Singleton scope, single instance
- Default - New instance mỗi lần resolve

##### `ServiceAssembly` (dòng 147-187)
Assembly cho business services (chưa implemented).

**TODO Items**:
- NetworkService registration (dòng 150-154)
- AuthService registration (dòng 157-164)
- AnalyticsService registration (dòng 167-171)
- LoggingService registration (dòng 174-178)
- RemoteConfigService registration (dòng 181-185)

**Example registration** (commented):
```swift
container.register(NetworkServiceProtocol.self) { resolver in
    NetworkService(
        keychainStorage: resolver.resolve(SecureStorageProtocol.self)!
    )
}
.inObjectScope(.container)
```

##### `RepositoryAssembly` (dòng 192-204)
Assembly cho repository layer (chưa implemented).

**TODO**: Register UserRepository và các repositories khác

##### `@Injected` Property Wrapper (dòng 209-223)
Property wrapper để inject dependencies.

**Implementation**:
```swift
@propertyWrapper
public struct Injected<T> {
    private let type: T.Type

    public init(_ type: T.Type) {
        self.type = type
    }

    public var wrappedValue: T {
        guard let resolved = DIContainer.shared.resolve(type) else {
            fatalError("Could not resolve type \(type)")
        }
        return resolved
    }
}
```

**Usage**:
```swift
class MyViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    @Injected(SecureStorageProtocol.self)
    var keychain: SecureStorageProtocol

    func saveData() {
        try? storage.save("value", forKey: "key")
    }
}
```

**Example Usage** (dòng 227-260):
```swift
// 1. Resolve dependencies
let storage = DIContainer.shared.userDefaultsStorage
let keychain = DIContainer.shared.keychainStorage

// 2. Use @Injected property wrapper
class MyViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol
}

// 3. For testing, register mocks
class MockStorage: StorageServiceProtocol {
    // Mock implementation
}

func setupTest() {
    DIContainer.shared.register(StorageServiceProtocol.self) { _ in
        MockStorage()
    }
}
```

---

### 3. DI/ServiceLocator.swift (139 dòng)

**Chức năng**: Service Locator pattern as alternative to DI

**Khi nào dùng**: Khi không thể inject dependencies (static methods, extensions, global functions)

##### `ServiceLocator` (dòng 5-69)
Service locator implementation.

**Properties**:
- `shared: ServiceLocator` - Singleton
- `services: [String: Any]` - Service registry
- `lock: NSLock` - Thread-safe access

**Methods**:

1. **`register<T>(_ service: T, forType: T.Type)`** (dòng 26-32):
```swift
public func register<T>(_ service: T, forType type: T.Type) {
    lock.lock()
    defer { lock.unlock() }

    let key = String(describing: type)
    services[key] = service
}
```
- Thread-safe registration
- Uses type name as key

2. **`resolve<T>(_ type: T.Type) -> T?`** (dòng 35-41):
```swift
public func resolve<T>(_ type: T.Type) -> T? {
    lock.lock()
    defer { lock.unlock() }

    let key = String(describing: type)
    return services[key] as? T
}
```
- Thread-safe resolution
- Returns nil if not found

3. **`remove<T>(_ type: T.Type)`** (dòng 44-50):
   - Remove specific service
   - Thread-safe

4. **`removeAll()`** (dòng 53-59):
   - Clear all services
   - Re-setup defaults
   - For testing cleanup

**Setup Default Services** (dòng 63-68):
```swift
private func setupDefaultServices() {
    register(UserDefaultsStorage(), forType: StorageServiceProtocol.self)
    register(KeychainStorage(), forType: SecureStorageProtocol.self)
    register(FileStorage.documents, forType: FileStorageProtocol.self)
}
```

**Convenience Extensions** (dòng 73-88):
```swift
public extension ServiceLocator {
    var storage: StorageServiceProtocol {
        resolve(StorageServiceProtocol.self)!
    }

    var secureStorage: SecureStorageProtocol {
        resolve(SecureStorageProtocol.self)!
    }

    var fileStorage: FileStorageProtocol {
        resolve(FileStorageProtocol.self)!
    }
}
```

**Global Functions** (dòng 93-99):
```swift
public func getService<T>(_ type: T.Type) -> T? {
    ServiceLocator.shared.resolve(type)
}

public func registerService<T>(_ service: T, forType type: T.Type) {
    ServiceLocator.shared.register(service, forType: type)
}
```

**Usage** (dòng 104-138):
```swift
// 1. Register service
let customStorage = UserDefaultsStorage()
ServiceLocator.shared.register(customStorage, forType: StorageServiceProtocol.self)

// Or use global function
registerService(customStorage, forType: StorageServiceProtocol.self)

// 2. Resolve service
let storage = ServiceLocator.shared.storage
try? storage.save("value", forKey: "key")

// Or use global function
if let storage = getService(StorageServiceProtocol.self) {
    try? storage.save("value", forKey: "key")
}

// 3. For testing
class MockStorage: StorageServiceProtocol {
    // Mock implementation
}

func setupTest() {
    ServiceLocator.shared.register(MockStorage(), forType: StorageServiceProtocol.self)
}

func tearDownTest() {
    ServiceLocator.shared.removeAll() // Resets to defaults
}
```

**Note**: ServiceLocator is less type-safe than DI Container. Prefer DIContainer for most cases.

---

## Cách các Files hoạt động cùng nhau

### Dependency Flow Architecture

```
┌─────────────────────────────────────────────────────┐
│           App Launch / @main Entry Point             │
└────────────────────┬────────────────────────────────┘
                     │ 1. Initialize
                     ▼
┌─────────────────────────────────────────────────────┐
│              DIContainer.shared                      │
│         (Singleton initialization)                   │
└────────────────────┬────────────────────────────────┘
                     │ 2. Load Assemblies
                     ▼
┌───────────┬──────────────┬──────────────────────────┐
│ Storage   │  Service     │  Repository              │
│ Assembly  │  Assembly    │  Assembly                │
└─────┬─────┴──────┬───────┴────────┬─────────────────┘
      │            │                 │
      │ 3. Register Dependencies     │
      ▼            ▼                 ▼
┌─────────────────────────────────────────────────────┐
│            Swinject Container                        │
│                                                      │
│  StorageServiceProtocol → UserDefaultsStorage       │
│  SecureStorageProtocol → KeychainStorage            │
│  FileStorageProtocol → FileStorage.documents        │
│  NetworkServiceProtocol → NetworkService (TODO)     │
│  AuthServiceProtocol → AuthService (TODO)           │
└────────────────────┬────────────────────────────────┘
                     │ 4. Resolve on Demand
                     ▼
┌─────────────────────────────────────────────────────┐
│              ViewModels / Features                   │
│                                                      │
│  @Injected(StorageServiceProtocol.self)             │
│  var storage: StorageServiceProtocol                │
│                                                      │
│  OR                                                  │
│                                                      │
│  let storage = DIContainer.shared.userDefaultsStorage│
└─────────────────────────────────────────────────────┘
```

### Chi tiết từng bước:

#### 1. App Initialization
```swift
@main
struct iOSTemplateApp: App {
    // DIContainer.shared tự động initialize khi app start
    init() {
        // Assemblies được load tự động
        setupServices()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
```

#### 2. Assembly Registration
```swift
// DIContainer.init() tự động gọi
private init() {
    self.container = Container()

    // Load tất cả assemblies
    let assemblies: [Assembly] = [
        StorageAssembly(),    // Register storage services
        ServiceAssembly(),    // Register business services
        RepositoryAssembly()  // Register repositories
    ]

    self.assembler = Assembler(assemblies, container: container)
}
```

#### 3. Dependency Resolution

**Cách 1: Property Wrapper**
```swift
class HomeViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    func loadData() {
        // storage tự động được resolved
        let data: UserProfile? = try? storage.load(forKey: "user.profile")
    }
}
```

**Cách 2: Direct Resolution**
```swift
class SettingsView: View {
    let keychain = DIContainer.shared.keychainStorage

    func saveToken(_ token: String) {
        try? keychain.saveSecure(token, forKey: SecureStorageKey.accessToken)
    }
}
```

**Cách 3: ServiceLocator (for edge cases)**
```swift
extension String {
    func log() {
        // Can't inject in extensions, use ServiceLocator
        if let logger = getService(LoggingServiceProtocol.self) {
            logger.info(self)
        }
    }
}
```

---

## Integration Patterns

### Pattern 1: ViewModel Dependency Injection

```swift
@Reducer
struct HomeFeature {
    struct State: Equatable {
        var posts: [Post] = []
    }

    enum Action {
        case loadPosts
        case postsLoaded([Post])
    }

    @Dependency(\.networkService) var networkService
    @Dependency(\.loggingService) var loggingService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadPosts:
                return .run { send in
                    do {
                        loggingService?.info("Loading posts")
                        let posts: [Post] = try await networkService!.request(
                            endpoint: "/v1/posts",
                            method: .get,
                            parameters: nil,
                            headers: nil
                        )
                        await send(.postsLoaded(posts))
                    } catch {
                        loggingService?.error("Failed to load posts", error: error)
                    }
                }
            case .postsLoaded(let posts):
                state.posts = posts
                return .none
            }
        }
    }
}
```

### Pattern 2: Service Composition

```swift
// AuthService depends on NetworkService and KeychainStorage
class AuthService: AuthServiceProtocol {
    @Injected(NetworkServiceProtocol.self)
    private var networkService: NetworkServiceProtocol

    @Injected(SecureStorageProtocol.self)
    private var keychainStorage: SecureStorageProtocol

    func login(email: String, password: String) async throws -> AuthResponse {
        // 1. Call network service
        let response: AuthResponse = try await networkService.request(
            endpoint: "/v1/auth/login",
            method: .post,
            parameters: ["email": email, "password": password],
            headers: nil
        )

        // 2. Save tokens to keychain
        try keychainStorage.saveSecure(response.accessToken, forKey: SecureStorageKey.accessToken)
        try keychainStorage.saveSecure(response.refreshToken, forKey: SecureStorageKey.refreshToken)

        return response
    }
}

// Register in ServiceAssembly
container.register(AuthServiceProtocol.self) { resolver in
    AuthService(
        networkService: resolver.resolve(NetworkServiceProtocol.self)!,
        keychainStorage: resolver.resolve(SecureStorageProtocol.self)!
    )
}
.inObjectScope(.container)
```

### Pattern 3: Protocol-Oriented Testing

```swift
// Mock implementation
class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var shouldFail = false

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) async throws -> T {
        if shouldFail {
            throw NetworkError.unknown
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.invalidResponse
        }

        return response
    }
}

// Test with mock
func testLoginSuccess() async throws {
    // Setup
    let mockNetwork = MockNetworkService()
    mockNetwork.mockResponse = AuthResponse(
        accessToken: "test_token",
        refreshToken: "test_refresh",
        expiresIn: 3600,
        userID: "123"
    )

    DIContainer.shared.register(NetworkServiceProtocol.self) { _ in
        mockNetwork
    }

    // Test
    let authService = AuthService()
    let response = try await authService.login(email: "test@example.com", password: "password")

    // Verify
    XCTAssertEqual(response.accessToken, "test_token")
}
```

---

## Testing Strategies

### 1. Unit Testing với Mock Services

```swift
class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockNetwork: MockNetworkService!
    var mockStorage: MockStorage!

    override func setUp() {
        super.setUp()

        // Setup mocks
        mockNetwork = MockNetworkService()
        mockStorage = MockStorage()

        // Register mocks
        DIContainer.shared.register(NetworkServiceProtocol.self) { _ in
            self.mockNetwork
        }
        DIContainer.shared.register(StorageServiceProtocol.self) { _ in
            self.mockStorage
        }

        // Create SUT
        sut = HomeViewModel()
    }

    override func tearDown() {
        DIContainer.shared.removeAll()
        super.tearDown()
    }

    func testLoadPosts() async throws {
        // Given
        let mockPosts = [Post.mock, Post.mock]
        mockNetwork.mockResponse = mockPosts

        // When
        await sut.loadPosts()

        // Then
        XCTAssertEqual(sut.posts.count, 2)
    }
}
```

### 2. Integration Testing

```swift
class AuthIntegrationTests: XCTestCase {
    func testCompleteAuthFlow() async throws {
        // Use real implementations
        let networkService = NetworkService(
            keychainStorage: KeychainStorage()
        )
        let authService = AuthService(
            networkService: networkService,
            keychainStorage: KeychainStorage()
        )

        // Test real flow
        let response = try await authService.login(
            email: "test@example.com",
            password: "password"
        )

        XCTAssertNotNil(response.accessToken)

        // Verify token was saved
        let keychain = KeychainStorage()
        let savedToken = try keychain.loadSecure(forKey: SecureStorageKey.accessToken)
        XCTAssertEqual(savedToken, response.accessToken)
    }
}
```

### 3. Testing với ServiceLocator

```swift
func testServiceLocator() {
    // Setup
    let mockStorage = MockStorage()
    ServiceLocator.shared.register(mockStorage, forType: StorageServiceProtocol.self)

    // Test
    let storage = ServiceLocator.shared.storage
    try? storage.save("test", forKey: "key")

    // Verify
    XCTAssertTrue(mockStorage.saveCalled)

    // Cleanup
    ServiceLocator.shared.removeAll()
}
```

---

## Best Practices

### 1. Prefer Protocol over Concrete Types

```swift
// ✅ Good - Depend on protocol
class MyViewModel {
    @Injected(NetworkServiceProtocol.self)
    var networkService: NetworkServiceProtocol
}

// ❌ Bad - Depend on concrete type
class MyViewModel {
    let networkService = NetworkService()
}
```

### 2. Use Singleton Scope for Stateful Services

```swift
// Services với state nên là singleton
container.register(AuthServiceProtocol.self) { resolver in
    AuthService()
}
.inObjectScope(.container) // ✅ Singleton

// Stateless services có thể là transient
container.register(DateFormatterProtocol.self) { _ in
    DateFormatter()
}
// ✅ New instance mỗi lần resolve
```

### 3. Register Dependencies in Assemblies

```swift
// ✅ Good - Organized in assemblies
class NetworkAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NetworkServiceProtocol.self) { resolver in
            NetworkService(
                keychainStorage: resolver.resolve(SecureStorageProtocol.self)!
            )
        }
    }
}

// ❌ Bad - Register ad-hoc
DIContainer.shared.register(NetworkServiceProtocol.self) { _ in
    NetworkService(...)
}
```

### 4. Avoid Service Locator when DI is Possible

```swift
// ✅ Good - Use DI
class MyViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol
}

// ❌ Bad - Use ServiceLocator unnecessarily
class MyViewModel {
    func save() {
        let storage = ServiceLocator.shared.storage
    }
}
```

### 5. Mock All External Dependencies in Tests

```swift
class FeatureTests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Register ALL mocks
        DIContainer.shared.register(NetworkServiceProtocol.self) { _ in MockNetwork() }
        DIContainer.shared.register(StorageServiceProtocol.self) { _ in MockStorage() }
        DIContainer.shared.register(AnalyticsServiceProtocol.self) { _ in MockAnalytics() }
    }

    override func tearDown() {
        DIContainer.shared.removeAll()
        super.tearDown()
    }
}
```

---

## Common Patterns

### Pattern: Lazy Service Resolution

```swift
class ViewModel {
    // Lazy resolution - only created when accessed
    private lazy var networkService: NetworkServiceProtocol? = {
        DIContainer.shared.networkService
    }()

    func loadData() {
        // Service chỉ được resolved khi method được gọi
        networkService?.request(...)
    }
}
```

### Pattern: Factory Pattern với DI

```swift
protocol RepositoryFactory {
    func makeUserRepository() -> UserRepositoryProtocol
    func makePostRepository() -> PostRepositoryProtocol
}

class DefaultRepositoryFactory: RepositoryFactory {
    @Injected(NetworkServiceProtocol.self)
    var networkService: NetworkServiceProtocol

    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository(
            networkService: networkService,
            storage: storage
        )
    }
}
```

### Pattern: Environment-Specific Services

```swift
class DIConfiguration {
    static func configure(environment: Environment) {
        switch environment {
        case .development:
            // Mock services for development
            DIContainer.shared.register(NetworkServiceProtocol.self) { _ in
                MockNetworkService()
            }
        case .staging:
            // Real services with staging endpoints
            APIConfiguration.environment = .staging
        case .production:
            // Production services
            APIConfiguration.environment = .production
        }
    }
}
```

---

## Dependencies

- **Swinject**: Dependency Injection framework
- **Foundation**: Swift standard library

---

## Related Documentation

- [Storage Layer](/Sources/iOSTemplate/Storage/README.md) - Storage implementations
- [Network Layer](/Sources/iOSTemplate/Network/README.md) - Network service
- [Core Layer](/Sources/iOSTemplate/Core/README.md) - App architecture

---

## TODO Items

**ServiceAssembly** (DIContainer.swift):
- Dòng 150-154: Register NetworkService implementation
- Dòng 157-164: Register AuthService implementation
- Dòng 167-171: Register AnalyticsService implementation
- Dòng 174-178: Register LoggingService implementation
- Dòng 181-185: Register RemoteConfigService implementation

**RepositoryAssembly** (DIContainer.swift):
- Dòng 195-202: Register UserRepository và các repositories

---

## Migration Guide

### Thêm Service mới:

1. **Định nghĩa protocol** trong ServiceProtocols.swift
2. **Implement service** trong module tương ứng
3. **Register trong Assembly**:
```swift
container.register(YourServiceProtocol.self) { resolver in
    YourService(
        dependency: resolver.resolve(DependencyProtocol.self)!
    )
}
.inObjectScope(.container)
```
4. **Add convenience property** trong DIContainer extension
5. **Use via DI**:
```swift
@Injected(YourServiceProtocol.self)
var yourService: YourServiceProtocol
```

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
