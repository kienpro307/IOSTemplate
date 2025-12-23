# Swift Code Conventions

## General Principles
1. **Clarity over brevity** - Code should be self-documenting
2. **Consistency** - Follow established patterns
3. **Type safety** - Leverage Swift's type system
4. **Protocol-oriented** - Prefer protocols over inheritance
5. **Value types first** - Use struct/enum when possible

## Naming Conventions

### Files
```swift
// Views
UserProfileView.swift
LoginView.swift

// Reducers
UserProfileReducer.swift
LoginReducer.swift

// Models
User.swift
UserModels.swift

// Services
APIClient.swift
DatabaseService.swift

// Protocols
Authenticatable.swift
Cacheable.swift
```

### Types
```swift
// Classes - PascalCase
class NetworkManager { }
class ImageCache { }

// Structs - PascalCase
struct User { }
struct AppState { }

// Enums - Singular, PascalCase
enum Result { }
enum HTTPMethod { }

// Protocols - Adjective or noun
protocol Codable { }
protocol DataSource { }
```

### Variables & Constants
```swift
// camelCase for variables/constants
let userName: String
var isLoading: Bool
private let apiKey: String

// Boolean variables - use is/has/should prefix
var isEnabled: Bool
var hasData: Bool
var shouldRefresh: Bool

// Collections - plural names
let users: [User]
let items: [String]
```

### Functions
```swift
// Verb prefix for actions
func fetchUserData()
func saveToDatabase()
func calculateTotal()

// Event handlers - did/will/should prefix
func didTapButton()
func willAppear()
func shouldReload()

// Factory methods - make prefix
func makeViewController() -> UIViewController
func makeAPIClient() -> APIClient
```

## Code Organization

### File Structure
```swift
// 1. Imports
import SwiftUI
import ComposableArchitecture

// 2. Type Definition
struct FeatureView: View {

    // 3. Properties
    let store: StoreOf<Feature>
    @State private var isPresented = false

    // 4. Body
    var body: some View {
        // ...
    }

    // 5. Private Methods
    private func setupView() {
        // ...
    }
}

// 6. Extensions
extension FeatureView {
    // ...
}

// 7. Previews
#if DEBUG
struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureView(store: Store(/* ... */))
    }
}
#endif
```

### Property Order
```swift
struct MyView: View {
    // 1. Store/ObservedObject
    let store: StoreOf<Feature>
    @ObservedObject var viewModel: ViewModel

    // 2. Environment
    @Environment(\.dismiss) var dismiss

    // 3. State
    @State private var text = ""

    // 4. Binding (if passed from parent)
    @Binding var isPresented: Bool

    // 5. Regular properties
    let title: String
    private let spacing: CGFloat = 16
}
```

## Comments

### Documentation Comments
```swift
/// Xử lý đăng nhập người dùng vào hệ thống
/// - Parameters:
///   - email: Email của người dùng
///   - password: Mật khẩu đã được mã hóa
/// - Returns: User object nếu thành công
/// - Throws: AuthError nếu xác thực thất bại
func login(email: String, password: String) async throws -> User {
    // Implementation
}
```

### Inline Comments
```swift
// ✅ Good - Giải thích WHY, not WHAT
// Cần delay 0.5s để animation hoàn thành trước khi navigate
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    navigate()
}

// ❌ Bad - Chỉ mô tả WHAT
// Delay 0.5 giây
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    navigate()
}
```

### Language
- **Comments**: Vietnamese
- **Code**: English
- **Documentation**: Vietnamese
- **Variable names**: English

## Best Practices

### Avoid Force Unwrapping
```swift
// ❌ Bad
let user = fetchUser()!
let name = user.name!

// ✅ Good
guard let user = fetchUser() else { return }
let name = user.name ?? "Unknown"
```

### Use Guard for Early Returns
```swift
// ❌ Bad
func process() {
    if let data = data {
        if data.isValid {
            // Long nested code
        }
    }
}

// ✅ Good
func process() {
    guard let data = data else { return }
    guard data.isValid else { return }

    // Clean code at original indentation level
}
```

### Prefer Immutability
```swift
// ❌ Bad
var total = 0
total = calculateTotal()

// ✅ Good
let total = calculateTotal()
```

### Use Trailing Closures
```swift
// ❌ Bad
fetchData(completion: { result in
    // Handle result
})

// ✅ Good
fetchData { result in
    // Handle result
}
```

### Explicit Self When Needed
```swift
class MyClass {
    var value = 0

    func update() {
        // ❌ Not needed
        self.value = 1

        // ✅ Only in closures or when disambiguating
        doAsync { [weak self] in
            self?.value = 1
        }
    }
}
```

## SwiftUI Specific

### View Composition
```swift
// ✅ Good - Small, focused views
struct ContentView: View {
    var body: some View {
        VStack {
            HeaderView()
            ContentList()
            FooterView()
        }
    }
}

// ❌ Bad - Monolithic view
struct ContentView: View {
    var body: some View {
        VStack {
            // 200 lines of UI code
        }
    }
}
```

### View Modifiers Order
```swift
Text("Hello")
    .font(.title)           // 1. Content modifiers
    .foregroundColor(.blue)
    .padding()              // 2. Layout modifiers
    .background(Color.gray)
    .cornerRadius(8)        // 3. Decorative modifiers
    .onTapGesture { }       // 4. Interaction modifiers
```

## TCA Specific

### State Properties
```swift
struct FeatureState: Equatable {
    // Always use let for state properties
    var isLoading = false
    var user: User?
    var errorMessage: String?

    // Nested states
    var childState: ChildState?
}
```

### Actions
```swift
enum FeatureAction: Equatable {
    // User actions - present tense
    case loginButtonTapped
    case emailChanged(String)

    // System events - past tense
    case userLoaded(User)
    case loginResponse(Result<User, Error>)

    // Child actions
    case child(ChildAction)
}
```

### Reducers
```swift
let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> { state, action, environment in
    switch action {
    case .loginButtonTapped:
        state.isLoading = true
        return environment.apiClient
            .login(state.email, state.password)
            .receive(on: environment.mainQueue)
            .catchToEffect(FeatureAction.loginResponse)

    case let .loginResponse(.success(user)):
        state.isLoading = false
        state.user = user
        return .none

    case let .loginResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
    }
}
```

## Error Handling

### Define Custom Errors
```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL không hợp lệ"
        case .noData:
            return "Không có dữ liệu"
        case .decodingFailed:
            return "Không thể giải mã dữ liệu"
        case .serverError(let code):
            return "Lỗi server: \(code)"
        }
    }
}
```

### Use Result Type
```swift
func fetchData() -> Result<Data, NetworkError> {
    // Implementation
}

// Usage
switch fetchData() {
case .success(let data):
    // Handle success
case .failure(let error):
    // Handle error
}
```

## Testing

### Test Function Names
```swift
// Pattern: test_[stateUnderTest]_[expectedBehavior]
func test_loginButton_whenTapped_startsLoading() { }
func test_loginResponse_whenSuccess_updatesUser() { }
func test_emailField_whenEmpty_showsError() { }
```

### Use Descriptive Assertions
```swift
// ❌ Bad
XCTAssertTrue(user.isValid)

// ✅ Good
XCTAssertTrue(user.isValid, "User should be valid after successful login")
```

## Performance

### Lazy Loading
```swift
// ✅ Use lazy for expensive computations
lazy var formattedDate: String = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
}()
```

### Avoid Retain Cycles
```swift
// ✅ Always use [weak self] in closures
apiClient.fetchData { [weak self] result in
    guard let self = self else { return }
    self.handleResult(result)
}
```

## File Size Limits
- **Views**: < 300 lines
- **Reducers**: < 400 lines
- **Services**: < 500 lines
- If exceeding limits, split into smaller files

## SwiftLint Integration
All these rules are enforced by SwiftLint configuration. Run:
```bash
swiftlint lint
swiftlint autocorrect
```
