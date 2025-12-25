# Viết Tests

Hướng dẫn viết unit tests cho TCA reducers.

---

## Test Setup

### Test Store

```swift
import XCTest
import ComposableArchitecture
@testable import Features

@MainActor
final class FeatureReducerTests: XCTestCase {
    func testFeature() async {
        let store = TestStore(
            initialState: FeatureState()
        ) {
            FeatureReducer()
        } withDependencies: {
            // Mock dependencies
            $0.networkClient = .mock
            $0.analytics = .mock
        }
        
        // Test actions
        await store.send(.action) {
            // Assert state changes
            $0.property = newValue
        }
    }
}
```

---

## Testing Patterns

### Async Operations

```swift
func testFetchData() async {
    let store = TestStore(
        initialState: FeatureState()
    ) {
        FeatureReducer()
    }
    
    // Send action
    await store.send(.fetchData) {
        $0.isLoading = true
    }
    
    // Receive response
    await store.receive(\.dataResponse.success) {
        $0.isLoading = false
        $0.data = expectedData
    }
}
```

### Effects

```swift
func testEffect() async {
    let store = TestStore(
        initialState: FeatureState()
    ) {
        FeatureReducer()
    } withDependencies: {
        $0.continuousClock = ImmediateClock()
    }
    
    await store.send(.startTimer)
    await store.receive(\.timerTick)
}
```

---

## Mock Dependencies

### Network Client Mock

```swift
extension NetworkClientProtocol {
    static var mock: Self {
        Self(
            request: { _ in
                // Return mock data
                return MockData()
            }
        )
    }
}
```

---

## Run Tests

```bash
⌘U (Command + U)
```

---

## Xem Thêm

- [Tạo Feature Mới](01-TAO-TINH-NANG-MOI.md)

