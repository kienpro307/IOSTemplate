# Feature Template

## Feature Name: [Feature Name]

### Overview
Brief description of the feature and its purpose.

### User Stories
- As a user, I want to...
- So that I can...

## Architecture

### State
```swift
@Reducer
struct [Feature] {
    @ObservableState
    struct State: Equatable {
        // TODO: Define state properties
        var isLoading = false
        var errorMessage: String?
    }
}
```

### Actions
```swift
enum Action {
    // User actions
    case viewAppeared
    case buttonTapped

    // Internal actions
    case dataResponse(TaskResult<Data>)

    // Delegate actions
    case delegate(Delegate)

    enum Delegate {
        case didComplete
    }
}
```

### Dependencies
```swift
@Dependency(\.apiClient) var apiClient
@Dependency(\.database) var database
```

## UI Components

### Main View
- Screen layout description
- User interactions
- Navigation

### Sub-Components
1. Component 1
2. Component 2

## Data Flow

1. User action triggers...
2. Reducer handles...
3. Effect executes...
4. State updates...
5. View re-renders...

## Testing Strategy

### Unit Tests
- [ ] Reducer logic tests
- [ ] Service tests
- [ ] Utility tests

### Integration Tests
- [ ] API integration
- [ ] Database operations

### UI Tests
- [ ] Critical user flow
- [ ] Error states

## Files to Create

```
Features/[Feature]/
├── [Feature]View.swift
├── [Feature]Reducer.swift
├── Models/
│   └── [Feature]Models.swift
├── Components/
│   ├── Component1.swift
│   └── Component2.swift
└── Tests/
    ├── [Feature]ReducerTests.swift
    └── [Feature]ViewTests.swift
```

## Dependencies

### Internal
- Core/
- Theme/
- Services/

### External
- ComposableArchitecture

## Acceptance Criteria

- [ ] Feature works as described
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] No regressions

## Notes
Additional notes or considerations...
