# Quy trình viết Test

## Checklist

- [ ] Đọc 02-CODE/TCA.md (Dependency section)
- [ ] Xác định test cases
- [ ] Viết unit tests
- [ ] Run tests
- [ ] Cập nhật progress

## Test Structure

```
Tests/
├── CoreTests/
│   └── {Feature}ReducerTests.swift
└── FeaturesTests/
    └── {Feature}Tests.swift
```

## TCA Reducer Test Template

```swift
import ComposableArchitecture
import XCTest

@testable import Features

final class {Feature}ReducerTests: XCTestCase {
    
    @MainActor
    func test_onAppear_loadsData() async {
        let store = TestStore(
            initialState: {Feature}Reducer.State()
        ) {
            {Feature}Reducer()
        } withDependencies: {
            $0.someService = .mock
        }
        
        await store.send(.onAppear)
        
        await store.receive(.dataLoaded(mockData)) {
            $0.items = mockData
        }
    }
    
    @MainActor
    func test_buttonTapped_updatesState() async {
        let store = TestStore(
            initialState: {Feature}Reducer.State()
        ) {
            {Feature}Reducer()
        }
        
        await store.send(.buttonTapped) {
            $0.isActive = true
        }
    }
}
```

## Test Cases cần có

| Loại | Mô tả |
|------|-------|
| Happy path | Flow chính hoạt động đúng |
| Error cases | Xử lý lỗi đúng cách |
| Edge cases | Boundary conditions |
| State mutations | State thay đổi đúng |
| Side effects | Effects được trigger đúng |

## Mock Dependencies

```swift
extension SomeService {
    static let mock = Self(
        fetch: { _ in .mockData },
        save: { _ in }
    )
}
```

## Chi tiết

Xem: `ios-template-docs/05-CODE-TEMPLATES/06-TEST-TEMPLATE.swift`

