# Network - API Communication Layer

## Tổng quan

Thư mục `Network/` chứa toàn bộ logic giao tiếp với backend API, sử dụng **Moya** framework wrapper around Alamofire. Đây là abstraction layer cung cấp type-safe, testable API client cho app.

### Chức năng chính
- Định nghĩa tất cả API endpoints với type safety
- Xử lý HTTP requests/responses với async/await
- Authentication token management tự động
- Error handling và mapping
- Mock/stub support cho testing
- Network logging trong debug mode

### Tác động đến toàn bộ app
- **Critical Impact**: Tất cả features cần network communication đều phụ thuộc vào layer này
- Quản lý authentication tokens cho toàn bộ app
- Cung cấp consistent error handling
- Enable offline testing với mock data
- Network monitoring và request tracking

---

## Cấu trúc Files

```
Network/
├── APITarget.swift           # API endpoints definition (285 dòng)
├── NetworkService.swift      # Service implementation (253 dòng)
└── Models/
    └── APIModels.swift       # Request/response models (235 dòng)
```

**Tổng cộng**: 773 dòng code, 3 files

---

## Chi tiết các Files

### 1. APITarget.swift (285 dòng)

**Chức năng**: Định nghĩa tất cả API endpoints sử dụng Moya TargetType protocol

#### Các struct/enum chính:

##### `APIConfiguration` (dòng 5-29)
Global configuration cho API layer.

**Static Properties**:
- `baseURL: URL` - Base URL theo environment
  - Development: `https://api-dev.example.com`
  - Staging: `https://api-staging.example.com`
  - Production: `https://api.example.com`
- `environment: Environment` - Current environment (default: `.development`)
- `apiVersion: String` - API version (`"v1"`)
- `timeoutInterval: TimeInterval` - Request timeout (30 seconds)
- `maxRetryCount: Int` - Max retries (3)

**Cách sử dụng**:
```swift
// Switch environment
APIConfiguration.environment = .production

// Access base URL
let url = APIConfiguration.baseURL
print(url) // https://api.example.com
```

**Tác động**: Thay đổi environment ảnh hưởng đến toàn bộ app API calls

##### `Environment` (dòng 32-36)
Enum cho API environments.

**Cases**:
- `.development` - Dev server
- `.staging` - Staging server
- `.production` - Production server

##### `APITarget` (dòng 41-65)
Main enum định nghĩa tất cả API endpoints.

**Nhóm Authentication** (4 endpoints):
- `.login(email: String, password: String)` - User login
- `.register(email: String, password: String, name: String)` - User registration
- `.refreshToken(refreshToken: String)` - Token refresh
- `.logout` - User logout

**Nhóm User** (3 endpoints):
- `.getUserProfile(userID: String)` - GET user profile
- `.updateUserProfile(userID: String, name: String)` - PUT update profile
- `.uploadAvatar(userID: String, imageData: Data)` - PUT upload avatar image

**Nhóm Content/Posts** (5 endpoints):
- `.getPosts(page: Int, limit: Int)` - GET posts list (paginated)
- `.getPost(postID: String)` - GET single post
- `.createPost(title: String, content: String)` - POST create post
- `.updatePost(postID: String, title: String, content: String)` - PUT update post
- `.deletePost(postID: String)` - DELETE post

**Nhóm Search** (1 endpoint):
- `.search(query: String, page: Int)` - Search với query string

**Generic**:
- `.custom(path: String, method: Moya.Method, parameters: [String: Any]?)` - Flexible custom endpoint

**Tổng cộng**: 14 endpoints được định nghĩa

#### TargetType Conformance (dòng 69-271)

##### `baseURL` (dòng 70-72)
Trả về base URL từ APIConfiguration.

##### `path` (dòng 74-116)
Construct path cho từng endpoint với API version.

**Examples**:
```swift
.login → "/v1/auth/login"
.getUserProfile("123") → "/v1/users/123"
.getPosts(1, 20) → "/v1/posts"
.search("swift", 1) → "/v1/search"
```

**Pattern**: `/[version]/[resource]/[id?]`

##### `method` (dòng 118-131)
HTTP method cho từng endpoint.

**Mapping**:
- **POST**: login, register, refreshToken, createPost
- **PUT**: updateUserProfile, updatePost, uploadAvatar
- **DELETE**: deletePost, logout
- **GET**: getUserProfile, getPosts, getPost, search

##### `task` (dòng 133-208)
Request task configuration (parameters, encoding, multipart).

**Chi tiết từng task**:

1. **Login** (dòng 135-139):
```swift
.requestParameters(
    parameters: ["email": email, "password": password],
    encoding: JSONEncoding.default
)
```
- Body: JSON `{"email": "...", "password": "..."}`

2. **Register** (dòng 141-149):
```swift
parameters: ["email": email, "password": password, "name": name]
```
- Body: JSON với email, password, name

3. **RefreshToken** (dòng 151-155):
```swift
parameters: ["refresh_token": refreshToken]
```

4. **UpdateUserProfile** (dòng 157-161):
```swift
parameters: ["name": name]
```

5. **UploadAvatar** (dòng 163-170):
```swift
let formData = MultipartFormData(
    provider: .data(imageData),
    name: "avatar",
    fileName: "avatar.jpg",
    mimeType: "image/jpeg"
)
return .uploadMultipart([formData])
```
- **Multipart form upload** cho image
- Field name: `"avatar"`
- MIME type: `"image/jpeg"`

6. **GetPosts** (dòng 172-176):
```swift
.requestParameters(
    parameters: ["page": page, "limit": limit],
    encoding: URLEncoding.queryString
)
```
- Query params: `?page=1&limit=20`

7. **CreatePost** (dòng 178-182):
```swift
parameters: ["title": title, "content": content]
```
- JSON body

8. **UpdatePost** (dòng 184-188):
```swift
parameters: ["title": title, "content": content]
```

9. **Search** (dòng 190-194):
```swift
parameters: ["q": query, "page": page],
encoding: URLEncoding.queryString
```
- Query string: `?q=swift&page=1`

10. **Custom** (dòng 196-203):
```swift
if let params = parameters {
    return .requestParameters(parameters: params, encoding: JSONEncoding.default)
}
return .requestPlain
```

11. **Default** (dòng 205-207):
```swift
return .requestPlain  // No parameters
```

##### `headers` (dòng 210-222)
Request headers với authentication.

**Default headers**:
```swift
"Content-Type": "application/json"
"Accept": "application/json"
```

**Conditional auth header**:
```swift
if let token = getAuthToken() {
    headers["Authorization"] = "Bearer \(token)"
}
```

**Token retrieval** (dòng 266-270):
```swift
private func getAuthToken() -> String? {
    // TODO: Get token from keychain
    return nil
}
```

##### `sampleData` (dòng 224-262)
Mock data cho testing và previews.

**Login/Register mock** (dòng 227-235):
```json
{
    "access_token": "mock_access_token",
    "refresh_token": "mock_refresh_token",
    "expires_in": 3600,
    "user_id": "123"
}
```

**getUserProfile mock** (dòng 237-245):
```json
{
    "id": "123",
    "email": "test@example.com",
    "name": "Test User",
    "avatar_url": null
}
```

**getPosts mock** (dòng 247-257):
```json
{
    "data": [],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 0
    }
}
```

**Usage**:
```swift
let mockProvider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.immediatelyStub)
// Requests sẽ trả về sampleData
```

#### AccessTokenAuthorizable (dòng 275-284)
Định nghĩa endpoints nào cần authentication.

**No auth needed**:
- `.login`, `.register` - Public endpoints

**Bearer token required**:
- All other endpoints - Protected resources

```swift
public var authorizationType: AuthorizationType? {
    switch self {
    case .login, .register:
        return nil
    default:
        return .bearer
    }
}
```

---

### 2. NetworkService.swift (253 dòng)

**Chức năng**: Implementation của NetworkServiceProtocol, wrapper around Moya provider

#### Các class chính:

##### `NetworkService` (dòng 5-179)
Main network service implementation.

**Properties**:
- `provider: MoyaProvider<APITarget>` - Moya provider instance
- `keychainStorage: SecureStorageProtocol` - Keychain để lấy tokens

**Initialization** (dòng 14-45):
```swift
public init(
    keychainStorage: SecureStorageProtocol,
    stubClosure: @escaping MoyaProvider<APITarget>.StubClosure = MoyaProvider.neverStub,
    plugins: [PluginType] = []
)
```

**Plugins configuration** (dòng 22-38):

1. **NetworkLoggerPlugin** (dòng 25-29):
```swift
#if DEBUG
allPlugins.append(NetworkLoggerPlugin(configuration: .init(
    logOptions: .verbose
)))
#endif
```
- Chỉ enable trong debug builds
- Log verbose (request/response details)

2. **AccessTokenPlugin** (dòng 32-38):
```swift
let authPlugin = AccessTokenPlugin { [weak keychainStorage] _ in
    guard let token = try? keychainStorage?.loadSecure(forKey: SecureStorageKey.accessToken) else {
        return ""
    }
    return token
}
```
- Tự động inject Bearer token vào headers
- Load token từ Keychain
- Weak reference để tránh retain cycle

**Provider creation** (dòng 41-44):
```swift
self.provider = MoyaProvider<APITarget>(
    stubClosure: stubClosure,
    plugins: allPlugins
)
```

#### NetworkServiceProtocol Implementation (dòng 49-84)

##### `request<T: Decodable>` (dòng 49-67)
Generic request method conform protocol.

**Signature**:
```swift
func request<T: Decodable>(
    endpoint: String,
    method: HTTPMethod,
    parameters: [String: Any]?,
    headers: [String: String]?
) async throws -> T
```

**Flow**:
1. Convert HTTPMethod → Moya.Method
2. Create `.custom` APITarget
3. Call `performRequest`
4. Return decoded object

**Usage**:
```swift
let user: UserProfile = try await networkService.request(
    endpoint: "/v1/users/123",
    method: .get,
    parameters: nil,
    headers: nil
)
```

##### `upload` (dòng 69-76)
Upload data endpoint.

**Status**: TODO - Not implemented yet
**Throws**: `ServiceError.notInitialized`

##### `download` (dòng 78-84)
Download file endpoint.

**Status**: TODO - Not implemented yet
**Throws**: `ServiceError.notInitialized`

#### Public Methods (dòng 89-112)

##### `request<T: Decodable>(_ target: APITarget)` (dòng 89-91)
Type-safe request với APITarget.

**Usage**:
```swift
// Thay vì string endpoint
let response: AuthResponse = try await networkService.request(
    .login(email: "user@example.com", password: "password")
)
```

**Advantage**: Compile-time safety, autocomplete

##### `requestData(_ target: APITarget)` (dòng 94-112)
Request without decoding, trả về raw Data.

**Implementation**:
```swift
try await withCheckedThrowingContinuation { continuation in
    provider.request(target) { result in
        switch result {
        case .success(let response):
            do {
                let filteredResponse = try response.filterSuccessfulStatusCodes()
                continuation.resume(returning: filteredResponse.data)
            } catch {
                continuation.resume(throwing: self.mapError(error))
            }
        case .failure(let error):
            continuation.resume(throwing: self.mapError(error))
        }
    }
}
```

**Flow**:
1. Async/await wrapper around Moya callback
2. Filter successful status codes (200-299)
3. Return raw data
4. Map errors

**Usage**:
```swift
let imageData = try await networkService.requestData(.getUserProfile("123"))
```

#### Private Methods (dòng 116-178)

##### `performRequest<T: Decodable>` (dòng 116-140)
Core request logic với JSON decoding.

**Flow**:
1. Moya provider.request() callback
2. Success: Filter status codes → Decode JSON → Resume
3. Failure: Map error → Throw

**JSON Decoding** (dòng 126-128):
```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let decodedObject = try decoder.decode(T.self, from: filteredResponse.data)
```

**Key strategy**: `convertFromSnakeCase`
- API: `"user_id"` → Swift: `userID`
- API: `"created_at"` → Swift: `createdAt`

##### `mapError(_ error: Error)` (dòng 142-178)
Map Moya errors → app-specific errors.

**HTTP Status Code Mapping** (dòng 145-156):
```swift
case .statusCode(let response):
    switch response.statusCode {
    case 401:
        return ServiceError.unauthorized
    case 400...499:
        return NetworkError.serverError(response.statusCode)
    case 500...599:
        return NetworkError.serverError(response.statusCode)
    default:
        return NetworkError.unknown
    }
```

**Mapping table**:
| HTTP Code | App Error |
|-----------|-----------|
| 401 | ServiceError.unauthorized |
| 400-499 | NetworkError.serverError(code) |
| 500-599 | NetworkError.serverError(code) |
| Other | NetworkError.unknown |

**NSURLError Mapping** (dòng 158-170):
```swift
case .underlying(let underlyingError, _):
    let nsError = underlyingError as NSError
    if nsError.domain == NSURLErrorDomain {
        if nsError.code == NSURLErrorNotConnectedToInternet ||
           nsError.code == NSURLErrorNetworkConnectionLost {
            return NetworkError.noConnection
        }
        if nsError.code == NSURLErrorTimedOut {
            return NetworkError.timeout
        }
    }
    return NetworkError.unknown
```

**NSURLError mapping**:
| NSURLError | App Error |
|------------|-----------|
| NotConnectedToInternet | NetworkError.noConnection |
| NetworkConnectionLost | NetworkError.noConnection |
| TimedOut | NetworkError.timeout |
| Other | NetworkError.unknown |

#### HTTPMethod Extension (dòng 183-193)
Convert app HTTPMethod → Moya.Method.

```swift
extension HTTPMethod {
    func toMoyaMethod() -> Moya.Method {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        }
    }
}
```

##### `MockNetworkService` (dòng 198-252)
Mock implementation cho testing.

**Properties**:
- `shouldFail: Bool` - Simulate failure
- `mockData: Data?` - Response data
- `mockError: Error?` - Error to throw
- `requestCallCount: Int` - Track calls

**Request implementation** (dòng 206-224):
```swift
func request<T: Decodable>(...) async throws -> T {
    requestCallCount += 1

    if shouldFail {
        throw mockError ?? NetworkError.unknown
    }

    guard let data = mockData else {
        throw NetworkError.noConnection
    }

    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
}
```

**Usage trong tests**:
```swift
let mockService = MockNetworkService()
mockService.mockData = """
{"id": "123", "name": "Test"}
""".data(using: .utf8)

let user: UserProfile = try await mockService.request(
    endpoint: "/users/123",
    method: .get,
    parameters: nil,
    headers: nil
)

XCTAssertEqual(mockService.requestCallCount, 1)
XCTAssertEqual(user.name, "Test")
```

---

### 3. Models/APIModels.swift (235 dòng)

**Chức năng**: Request/Response models cho API communication

#### Các struct/enum chính:

##### `APIResponse<T: Codable>` (dòng 6-18)
Generic wrapper cho API responses.

**Structure**:
```swift
public struct APIResponse<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let errors: [APIError]?
}
```

**Usage**:
```swift
// Success response
let response: APIResponse<UserProfile> = try await networkService.request(.getUserProfile("123"))
if response.success, let user = response.data {
    print(user.name)
}

// Error response
if let errors = response.errors {
    for error in errors {
        print(error.message)
    }
}
```

**JSON Example**:
```json
{
    "success": true,
    "data": { "id": "123", "name": "John" },
    "message": "User fetched successfully",
    "errors": null
}
```

##### `APIError` (dòng 21-31)
Individual error model.

**Structure**:
```swift
public struct APIError: Codable, Error {
    public let code: String
    public let message: String
    public let field: String?
}
```

**Example**:
```json
{
    "code": "VALIDATION_ERROR",
    "message": "Email is invalid",
    "field": "email"
}
```

**Usage**:
```swift
if let errors = response.errors {
    for error in errors {
        if let field = error.field {
            print("\(field): \(error.message)")
        }
    }
}
```

##### `Pagination` (dòng 36-48)
Pagination metadata.

**Structure**:
```swift
public struct Pagination: Codable, Equatable {
    public let page: Int
    public let limit: Int
    public let total: Int
    public let totalPages: Int
}
```

**Example**:
```json
{
    "page": 1,
    "limit": 20,
    "total": 156,
    "totalPages": 8
}
```

##### `PaginatedResponse<T: Codable>` (dòng 51-59)
Generic paginated list response.

**Structure**:
```swift
public struct PaginatedResponse<T: Codable>: Codable {
    public let data: [T]
    public let pagination: Pagination
}
```

**Usage**:
```swift
let response: PaginatedResponse<Post> = try await networkService.request(
    .getPosts(page: 1, limit: 20)
)

print("Total posts: \(response.pagination.total)")
print("Current page: \(response.pagination.page)/\(response.pagination.totalPages)")

for post in response.data {
    print(post.title)
}
```

##### `LoginRequest` (dòng 64-72)
Login request payload.

**Structure**:
```swift
public struct LoginRequest: Codable {
    public let email: String
    public let password: String
}
```

##### `RegisterRequest` (dòng 75-85)
Register request payload.

**Structure**:
```swift
public struct RegisterRequest: Codable {
    public let email: String
    public let password: String
    public let name: String
}
```

##### `Post` (dòng 93-125)
Post content model.

**Structure**:
```swift
public struct Post: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let content: String
    public let authorID: String
    public let authorName: String
    public let createdAt: Date
    public let updatedAt: Date
    public let likesCount: Int
    public let commentsCount: Int
}
```

**Conformances**:
- `Codable` - JSON serialization
- `Identifiable` - SwiftUI ForEach
- `Equatable` - Comparisons

**Usage trong SwiftUI**:
```swift
ForEach(posts) { post in
    PostRowView(post: post)
}
```

##### `CreatePostRequest` (dòng 128-136)
Create post payload.

**Structure**:
```swift
public struct CreatePostRequest: Codable {
    public let title: String
    public let content: String
}
```

##### `UpdatePostRequest` (dòng 139-147)
Update post payload (optional fields).

**Structure**:
```swift
public struct UpdatePostRequest: Codable {
    public let title: String?
    public let content: String?
}
```

**Usage**:
```swift
// Update only title
let request = UpdatePostRequest(title: "New Title", content: nil)

// Update only content
let request = UpdatePostRequest(title: nil, content: "New content")

// Update both
let request = UpdatePostRequest(title: "New Title", content: "New content")
```

##### `SearchResult` (dòng 152-166)
Search result item.

**Structure**:
```swift
public struct SearchResult: Codable, Identifiable {
    public let id: String
    public let type: SearchResultType
    public let title: String
    public let snippet: String
    public let imageURL: URL?
}
```

##### `SearchResultType` (dòng 169-173)
Type của search result.

**Cases**:
```swift
public enum SearchResultType: String, Codable {
    case post
    case user
    case tag
}
```

**Usage**:
```swift
switch result.type {
case .post:
    navigateToPost(result.id)
case .user:
    navigateToProfile(result.id)
case .tag:
    navigateToTag(result.id)
}
```

##### `UpdateProfileRequest` (dòng 178-188)
Update user profile payload.

**Structure**:
```swift
public struct UpdateProfileRequest: Codable {
    public let name: String?
    public let bio: String?
    public let website: URL?
}
```

##### Mock Data Extensions (dòng 192-234)
Mock data cho testing và previews.

**Post.mock** (dòng 193-203):
```swift
static let mock = Post(
    id: "1",
    title: "Sample Post",
    content: "This is a sample post content",
    authorID: "123",
    authorName: "John Doe",
    createdAt: Date(),
    updatedAt: Date(),
    likesCount: 42,
    commentsCount: 12
)
```

**Post.mockList** (dòng 205-233):
Array of 3 mock posts.

**Usage**:
```swift
#Preview {
    PostListView(posts: Post.mockList)
}
```

---

## Cách các Files hoạt động cùng nhau

### Request Flow Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  SwiftUI View / Feature                  │
│              (HomeView, ProfileView, etc.)              │
└────────────────────┬────────────────────────────────────┘
                     │ 1. Call API
                     ▼
┌─────────────────────────────────────────────────────────┐
│              NetworkService Instance                     │
│         (Injected via DI Container)                      │
└────────────────────┬────────────────────────────────────┘
                     │ 2. Create Request
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  APITarget Enum                          │
│   .login(email, password) / .getPosts(page, limit)      │
│                                                          │
│   ┌──────────────────────────────────────────┐         │
│   │ TargetType Protocol                       │         │
│   │ • baseURL (from APIConfiguration)         │         │
│   │ • path ("/v1/auth/login")                 │         │
│   │ • method (.post)                          │         │
│   │ • task (parameters + encoding)            │         │
│   │ • headers (Content-Type + Bearer token)   │         │
│   └──────────────────────────────────────────┘         │
└────────────────────┬────────────────────────────────────┘
                     │ 3. Execute
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Moya Provider + Plugins                     │
│   ┌─────────────┬──────────────┬──────────────────┐    │
│   │NetworkLogger│AccessToken   │Custom Plugins    │    │
│   │Plugin       │Plugin        │                  │    │
│   └─────────────┴──────────────┴──────────────────┘    │
└────────────────────┬────────────────────────────────────┘
                     │ 4. HTTP Request
                     ▼
┌─────────────────────────────────────────────────────────┐
│               Alamofire (URLSession)                     │
│           Actual network communication                   │
└────────────────────┬────────────────────────────────────┘
                     │ 5. HTTP Response
                     ▼
┌─────────────────────────────────────────────────────────┐
│             NetworkService.performRequest                │
│                                                          │
│   ┌──────────────────────────────────────────┐         │
│   │ 1. Filter status codes (200-299)         │         │
│   │ 2. Decode JSON (snake_case → camelCase)  │         │
│   │ 3. Map errors (Moya → App errors)        │         │
│   │ 4. Return typed object                   │         │
│   └──────────────────────────────────────────┘         │
└────────────────────┬────────────────────────────────────┘
                     │ 6. Decoded Model
                     ▼
┌─────────────────────────────────────────────────────────┐
│              APIModels (Codable Structs)                 │
│   AuthResponse / Post / UserProfile / SearchResult      │
└────────────────────┬────────────────────────────────────┘
                     │ 7. Return to caller
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  SwiftUI View / Feature                  │
│              Update UI with response data                │
└─────────────────────────────────────────────────────────┘
```

### Chi tiết từng bước:

#### 1. View Call API
```swift
// HomeView.swift
struct HomeView: View {
    @Dependency(\.networkService) var networkService

    func loadPosts() async {
        do {
            let posts: PaginatedResponse<Post> = try await networkService.request(
                .getPosts(page: 1, limit: 20)
            )
            self.posts = posts.data
        } catch {
            print("Error: \(error)")
        }
    }
}
```

#### 2. APITarget Construction
```swift
// APITarget.swift
case .getPosts(page: 1, limit: 20):
    baseURL: https://api.example.com
    path: "/v1/posts"
    method: .get
    task: .requestParameters(
        parameters: ["page": 1, "limit": 20],
        encoding: URLEncoding.queryString
    )
    headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer xyz..."
    }
```

**Result**: `GET https://api.example.com/v1/posts?page=1&limit=20`

#### 3. Plugins Processing

**NetworkLoggerPlugin**:
```
--> GET /v1/posts?page=1&limit=20
Headers: {
  "Authorization": "Bearer xyz..."
  "Content-Type": "application/json"
}
```

**AccessTokenPlugin**:
```swift
// Automatically adds token from Keychain
let token = try? keychainStorage.loadSecure(forKey: .accessToken)
// Injects "Authorization: Bearer \(token)"
```

#### 4. Network Request
Alamofire executes actual HTTP request

#### 5. Response Processing
```swift
// NetworkService.performRequest()
provider.request(.getPosts(1, 20)) { result in
    switch result {
    case .success(let response):
        // 1. Filter status codes
        let filtered = try response.filterSuccessfulStatusCodes()

        // 2. Decode JSON
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let posts: PaginatedResponse<Post> = try decoder.decode(from: filtered.data)

        // 3. Return
        continuation.resume(returning: posts)

    case .failure(let error):
        // Map error
        let appError = mapError(error)
        continuation.resume(throwing: appError)
    }
}
```

#### 6. Model Decoding

**JSON Response**:
```json
{
    "data": [
        {
            "id": "1",
            "title": "First Post",
            "content": "Content...",
            "author_id": "123",
            "author_name": "Alice",
            "created_at": "2025-01-15T10:00:00Z",
            "updated_at": "2025-01-15T10:00:00Z",
            "likes_count": 42,
            "comments_count": 12
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 156,
        "total_pages": 8
    }
}
```

**Decoded to**:
```swift
PaginatedResponse<Post>(
    data: [
        Post(
            id: "1",
            title: "First Post",
            authorID: "123",  // author_id → authorID
            createdAt: Date(...),  // created_at → createdAt
            likesCount: 42  // likes_count → likesCount
        )
    ],
    pagination: Pagination(...)
)
```

#### 7. Return to View
View receives typed `PaginatedResponse<Post>` object.

---

## Cách các Functions hoạt động với nhau

### Example: Login Flow

```swift
// 1. View calls NetworkService
let response: AuthResponse = try await networkService.request(
    .login(email: "user@example.com", password: "password123")
)

// 2. NetworkService.performRequest is called
func performRequest<T: Decodable>(target: APITarget) async throws -> T {
    // Creates APITarget.login case

    // 3. APITarget constructs request
    baseURL: "https://api.example.com"
    path: "/v1/auth/login"
    method: .post
    task: .requestParameters(
        parameters: ["email": "user@example.com", "password": "password123"],
        encoding: JSONEncoding.default
    )
    headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
        // No Authorization header (login doesn't need auth)
    }

    // 4. Moya provider executes request
    provider.request(target) { result in
        // 5. Response received
        case .success(let response):
            // HTTP 200
            // Body: {"access_token": "...", "refresh_token": "...", "expires_in": 3600, "user_id": "123"}

            // 6. Filter status codes
            let filtered = try response.filterSuccessfulStatusCodes()

            // 7. Decode JSON
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let authResponse = try decoder.decode(AuthResponse.self, from: filtered.data)
            // AuthResponse(accessToken: "...", refreshToken: "...", expiresIn: 3600, userID: "123")

            // 8. Return to caller
            continuation.resume(returning: authResponse)
    }
}

// 9. View receives AuthResponse
// Save tokens to Keychain
try await keychainStorage.saveSecure(response.accessToken, forKey: .accessToken)
try await keychainStorage.saveSecure(response.refreshToken, forKey: .refreshToken)

// 10. Future requests automatically include token
// AccessTokenPlugin reads token from Keychain and injects it
```

### Example: Error Handling Flow

```swift
// 1. Request fails with 401 Unauthorized
provider.request(.getUserProfile("123")) { result in
    case .failure(let moyaError):
        // MoyaError.statusCode(response: 401)

        // 2. mapError converts to app error
        let appError = mapError(moyaError)
        // Returns: ServiceError.unauthorized

        // 3. Throw to caller
        continuation.resume(throwing: appError)
}

// 4. View catches error
do {
    let user = try await networkService.request(.getUserProfile("123"))
} catch ServiceError.unauthorized {
    // Token expired, refresh token
    try await refreshToken()
    // Retry request
} catch NetworkError.noConnection {
    // Show offline UI
    showOfflineBanner()
} catch {
    // Show generic error
    showErrorAlert(error.localizedDescription)
}
```

### Example: Multipart Upload Flow

```swift
// 1. Upload avatar image
let imageData = uiImage.jpegData(compressionQuality: 0.8)!

let response = try await networkService.request(
    .uploadAvatar(userID: "123", imageData: imageData)
)

// 2. APITarget.uploadAvatar constructs multipart
task: .uploadMultipart([
    MultipartFormData(
        provider: .data(imageData),
        name: "avatar",
        fileName: "avatar.jpg",
        mimeType: "image/jpeg"
    )
])

// 3. Moya sends multipart/form-data request
// Content-Type: multipart/form-data; boundary=...
// Body:
// ------boundary
// Content-Disposition: form-data; name="avatar"; filename="avatar.jpg"
// Content-Type: image/jpeg
//
// [binary image data]
// ------boundary--

// 4. Server responds with updated user profile
// {"id": "123", "avatar_url": "https://cdn.example.com/avatars/123.jpg"}
```

---

## Integration với App Components

### 1. Dependency Injection
```swift
// DIContainer.swift
container.register(NetworkServiceProtocol.self) { resolver in
    let keychainStorage = resolver.resolve(SecureStorageProtocol.self)!
    return NetworkService(keychainStorage: keychainStorage)
}
.inObjectScope(.container)  // Singleton
```

### 2. TCA Feature Integration
```swift
// HomeFeature.swift
@Reducer
struct HomeFeature {
    @Dependency(\.networkService) var networkService

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        case .loadPosts:
            return .run { send in
                do {
                    let posts: PaginatedResponse<Post> = try await networkService.request(
                        .getPosts(page: 1, limit: 20)
                    )
                    await send(.postsLoaded(posts.data))
                } catch {
                    await send(.error(error))
                }
            }
    }
}
```

### 3. Authentication Flow
```swift
// AuthService.swift
func login(email: String, password: String) async throws -> AuthResponse {
    // 1. Call network service
    let response: AuthResponse = try await networkService.request(
        .login(email: email, password: password)
    )

    // 2. Save tokens
    try await keychainStorage.saveSecure(response.accessToken, forKey: .accessToken)
    try await keychainStorage.saveSecure(response.refreshToken, forKey: .refreshToken)

    // 3. Return response
    return response
}
```

---

## Testing Strategies

### 1. Unit Tests với Mock Service
```swift
func testLoginSuccess() async throws {
    // Setup mock
    let mockService = MockNetworkService()
    mockService.mockData = """
    {
        "access_token": "test_token",
        "refresh_token": "test_refresh",
        "expires_in": 3600,
        "user_id": "123"
    }
    """.data(using: .utf8)

    // Test
    let response: AuthResponse = try await mockService.request(
        endpoint: "/v1/auth/login",
        method: .post,
        parameters: ["email": "test@example.com", "password": "password"],
        headers: nil
    )

    // Verify
    XCTAssertEqual(response.accessToken, "test_token")
    XCTAssertEqual(mockService.requestCallCount, 1)
}
```

### 2. Integration Tests với Stubbed Moya
```swift
func testRealAPITarget() async throws {
    let provider = MoyaProvider<APITarget>(
        stubClosure: MoyaProvider.immediatelyStub
    )

    // Uses sampleData from APITarget
    let data = try await provider.request(.login(email: "test", password: "test"))

    // Verify sampleData is valid JSON
    let response = try JSONDecoder().decode(AuthResponse.self, from: data)
    XCTAssertEqual(response.userID, "123")
}
```

### 3. Error Handling Tests
```swift
func testUnauthorizedError() async {
    let mockService = MockNetworkService()
    mockService.shouldFail = true
    mockService.mockError = ServiceError.unauthorized

    do {
        let _: UserProfile = try await mockService.request(
            endpoint: "/v1/users/123",
            method: .get,
            parameters: nil,
            headers: nil
        )
        XCTFail("Should throw error")
    } catch ServiceError.unauthorized {
        // Expected
    } catch {
        XCTFail("Wrong error type")
    }
}
```

---

## Best Practices

### 1. Always use APITarget
```swift
// ✅ Good - Type safe
let posts: PaginatedResponse<Post> = try await networkService.request(
    .getPosts(page: 1, limit: 20)
)

// ❌ Bad - String endpoints error-prone
let posts: PaginatedResponse<Post> = try await networkService.request(
    endpoint: "/v1/posts?page=1&limit=20",
    method: .get,
    parameters: nil,
    headers: nil
)
```

### 2. Handle all error cases
```swift
do {
    let user = try await networkService.request(.getUserProfile("123"))
} catch ServiceError.unauthorized {
    // Refresh token and retry
} catch NetworkError.noConnection {
    // Show offline UI
} catch NetworkError.timeout {
    // Offer retry
} catch NetworkError.serverError(let code) {
    // Show server error with code
} catch {
    // Generic error handling
}
```

### 3. Use mock data cho previews
```swift
#Preview {
    PostListView(posts: Post.mockList)
}
```

### 4. Implement retry logic
```swift
func requestWithRetry<T: Decodable>(
    _ target: APITarget,
    maxRetries: Int = 3
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await networkService.request(target)
        } catch NetworkError.timeout, NetworkError.noConnection {
            lastError = error
            try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            continue
        } catch {
            throw error
        }
    }

    throw lastError ?? NetworkError.unknown
}
```

---

## Configuration Guide

### Switching Environments
```swift
// AppDelegate.swift / @main
#if DEBUG
APIConfiguration.environment = .development
#elseif STAGING
APIConfiguration.environment = .staging
#else
APIConfiguration.environment = .production
#endif
```

### Custom Plugins
```swift
// Custom logging plugin
class CustomAnalyticsPlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            Analytics.trackAPISuccess(endpoint: target.path, statusCode: response.statusCode)
        case .failure(let error):
            Analytics.trackAPIFailure(endpoint: target.path, error: error)
        }
    }
}

// Use in NetworkService
let networkService = NetworkService(
    keychainStorage: keychain,
    plugins: [CustomAnalyticsPlugin()]
)
```

---

## Performance Considerations

### 1. Request Timeout
Default: 30 seconds (APIConfiguration.timeoutInterval)

### 2. Retry Logic
Default max retries: 3 (APIConfiguration.maxRetryCount)

### 3. Caching
Consider implementing response caching:
```swift
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .returnCacheDataElseLoad
configuration.urlCache = URLCache(
    memoryCapacity: 10 * 1024 * 1024,  // 10 MB
    diskCapacity: 50 * 1024 * 1024     // 50 MB
)
```

---

## Dependencies

- **Moya**: Type-safe network abstraction layer
- **Alamofire**: Underlying HTTP networking
- **Foundation**: Codable, URLSession

---

## Related Documentation

- [Services Layer](/Sources/iOSTemplate/Services/README.md) - Service protocols and DI
- [Storage Layer](/Sources/iOSTemplate/Storage/README.md) - Token storage (Keychain)
- [Core Layer](/Sources/iOSTemplate/Core/README.md) - AppState integration

---

## TODO Items

**NetworkService.swift**:
- Dòng 74-75: Implement upload() method
- Dòng 82-83: Implement download() method

**APITarget.swift**:
- Dòng 268: Implement getAuthToken() từ Keychain

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
