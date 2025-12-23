# Quy tắc đặt tên

## Files

| Loại | Pattern | Ví dụ |
|------|---------|-------|
| Reducer | `{Feature}Reducer.swift` | `HomeReducer.swift` |
| View | `{Feature}View.swift` | `HomeView.swift` |
| Service | `{Name}Service.swift` | `AuthService.swift` |
| Model | `{Name}.swift` | `User.swift` |
| Test | `{Name}Tests.swift` | `HomeReducerTests.swift` |

## Code

### Structs/Classes

```swift
// PascalCase
struct HomeItem { }
class NetworkManager { }
```

### Functions/Variables

```swift
// camelCase
func fetchUserData() { }
var isLoading: Bool = false
let userName = "John"
```

### Enums

```swift
// PascalCase cho enum, camelCase cho cases
enum LoadingState {
    case idle
    case loading
    case loaded(data: Data)
    case failed(error: Error)
}
```

### Constants

```swift
// camelCase hoặc SCREAMING_SNAKE_CASE cho static
static let defaultTimeout = 30.0
static let MAX_RETRY_COUNT = 3
```

## TCA Specific

```swift
// State: PascalCase
struct State: Equatable { }

// Action: PascalCase enum, camelCase cases
enum Action {
    case onAppear
    case buttonTapped
    case delegate(Delegate)
}

// Delegate: PascalCase nested enum
enum Delegate: Equatable {
    case didComplete
    case didFail(Error)
}
```

## Chi tiết

Xem: `ios-template-docs/04-HUONG-DAN-AI/03-QUY-TAC-DAT-TEN.md`

