# TCA Pattern

## Cấu trúc cơ bản

```swift
@Reducer
struct FeatureReducer {
    @ObservableState
    struct State: Equatable {
        // Properties
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            // Actions gửi lên parent
        }
    }
    
    @Dependency(\.someService) var someService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // Side effect
                }
            case .delegate:
                return .none
            }
        }
    }
}
```

## Nguyên tắc

| Nguyên tắc | Mô tả |
|------------|-------|
| State là struct | Conform `Equatable` |
| Action là enum | Tất cả user interactions |
| Side effects qua Effect | Không trực tiếp trong reducer |
| Dependencies qua @Dependency | Không dùng global/singleton |
| Logic ở Reducer | Không ở View |

## Cross-Reducer Communication

```swift
// ✅ PATTERN: Parent Forwards (RECOMMENDED)
// Parent owns child states, forwards delegate actions

// Child reducer
enum Action {
    case delegate(Delegate)
    enum Delegate {
        case itemSelected(Item)
    }
}

// Parent reducer
case .child(.delegate(.itemSelected(let item))):
    // Handle in parent
    return .none
```

## Anti-patterns

```swift
// ❌ Business logic in View
Button("Load") {
    Task {
        let data = try await api.fetch() // SAI
    }
}

// ❌ Global state
class GlobalManager {
    static let shared = GlobalManager() // SAI
}
```

## Chi tiết

Xem: `ios-template-docs/01-KIEN-TRUC/10-TCA-PATTERNS-SOLID.md`

