# Naming Rules - iOS Template Project

## File Naming

### Views
```
Pattern: [Feature][Component]View.swift
Examples:
- LoginView.swift
- UserProfileView.swift
- SettingsListView.swift
- HomeTabView.swift
```

### Reducers (TCA)
```
Pattern: [Feature]Reducer.swift
Examples:
- LoginReducer.swift
- UserProfileReducer.swift
- SettingsReducer.swift
- AppReducer.swift
```

### Models
```
Pattern: [Entity].swift or [Feature]Models.swift
Examples:
- User.swift
- Post.swift
- AuthModels.swift
- NetworkModels.swift
```

### Services
```
Pattern: [Purpose]Service.swift or [Purpose]Client.swift
Examples:
- NetworkService.swift
- DatabaseService.swift
- APIClient.swift
- AuthService.swift
```

### Protocols
```
Pattern: [Capability]Protocol.swift or [Capability].swift
Examples:
- NetworkServiceProtocol.swift
- Authenticatable.swift
- Cacheable.swift
- DataSource.swift
```

## Code Naming

### Variables & Constants

```swift
// ✅ Good
let userName: String
let userAge: Int
var isLoading: Bool
var hasData: Bool
private let apiKey: String

// ❌ Bad
let name: String  // Too generic
let x: Int  // Not descriptive
var loading: Bool  // Missing is/has prefix
let API_KEY: String  // Use camelCase, not SNAKE_CASE
```

### Functions

```swift
// ✅ Good
func fetchUserData()
func saveToDatabase()
func didTapLoginButton()
func willAppear()
func makeAPIClient() -> APIClient

// ❌ Bad
func getData()  // Too generic
func tap()  // Missing context
func client() -> APIClient  // Missing make/create prefix
```

### Types

```swift
// ✅ Good
struct User { }
class NetworkManager { }
enum HTTPMethod { }
protocol Authenticatable { }

// ❌ Bad
struct user { }  // Wrong case
class networkManager { }  // Wrong case
enum HttpMethod { }  // HTTP should be all caps
protocol AuthProtocol { }  // Redundant Protocol suffix
```

## Folder Naming

```
// ✅ Good structure
Features/
  Authentication/
    Views/
    Models/
    Services/
  Home/
    Views/
    Models/
    Services/

// ❌ Bad structure
features/  // Wrong case
Auth/  // Too abbreviated
auth_module/  // Use PascalCase, not snake_case
```

## Constants & Environment

```swift
// ✅ Good
enum Constants {
    static let maxRetryCount = 3
    static let timeoutInterval: TimeInterval = 30
}

enum APIEndpoint {
    static let baseURL = "https://api.example.com"
    static let loginPath = "/auth/login"
}

// ❌ Bad
let MAX_RETRY = 3  // Use enum wrapper
let timeout = 30  // Missing type annotation
let api_url = "..."  // Use camelCase
```

## Test Naming

```swift
// ✅ Good
func test_login_whenValidCredentials_shouldSucceed()
func test_fetchUser_whenNetworkError_shouldReturnError()
func test_appReducer_whenLoginSuccess_shouldUpdateUserState()

// ❌ Bad
func testLogin()  // Not descriptive enough
func test1()  // Meaningless name
func loginTest()  // Wrong prefix
```

## Swiftlint Rules Enforced

```yaml
# Enforced by .swiftlint.yml
- type_name  # PascalCase for types
- variable_name  # camelCase for variables
- function_name  # camelCase for functions
- identifier_name  # Meaningful names
- file_name  # Match primary type
```

## Language Rules

- **File names**: English
- **Code (types, variables, functions)**: English
- **Comments**: Vietnamese
- **Documentation**: Vietnamese
- **Git commits**: Vietnamese for message, English for code references
- **UI Strings (before localization)**: English keys, Vietnamese values

## Examples

### Good Example
```swift
// UserProfileView.swift

import SwiftUI
import ComposableArchitecture

/// View hiển thị thông tin profile của user
struct UserProfileView: View {
    let store: StoreOf<UserProfile>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            // Implementation
        }
    }
}

// UserProfileReducer.swift

/// Reducer xử lý logic của UserProfile feature
struct UserProfile: Reducer {
    struct State: Equatable {
        var user: User?
        var isLoading = false
    }

    enum Action: Equatable {
        case fetchUserTapped
        case userResponse(TaskResult<User>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        // Implementation
    }
}
```

### Bad Example
```swift
// profile.swift  // ❌ Wrong file name

import SwiftUI

// ❌ No documentation
struct ProfileView: View {  // ❌ Not descriptive enough
    let s: Any  // ❌ Wrong type, not descriptive

    var body: some View {
        Text("Profile")
    }
}
```

## Summary

1. **Always use English** for code
2. **Use Vietnamese** for comments and docs
3. **Be descriptive** - clarity over brevity
4. **Follow conventions** consistently
5. **Use proper prefixes** (is/has/should for Bool, make/create for factories)
6. **PascalCase** for types
7. **camelCase** for variables/functions
8. **Meaningful names** - no abbreviations unless standard (URL, ID, API)
