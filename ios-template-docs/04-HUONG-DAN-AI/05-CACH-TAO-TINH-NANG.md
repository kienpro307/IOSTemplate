# ➕ Cách Tạo Tính Năng Mới

## Bước 1: Tạo Cấu Trúc Folder
```
Features/
└── FeatureName/
    ├── FeatureNameReducer.swift
    ├── FeatureNameView.swift
    ├── Components/
    └── Models/
```

## Bước 2: Tạo Reducer
```swift
import ComposableArchitecture

@Reducer
struct FeatureNameReducer {
    @ObservableState
    struct State: Equatable {
        // State properties
        var items: [Item] = []
        var isLoading: Bool = false
        var error: String?
    }
    
    enum Action: Equatable {
        // User actions
        case onAppear
        case itemTapped(Item)
        
        // Internal actions
        case itemsResponse(Result<[Item], Error>)
    }
    
    @Dependency(\.itemService) var itemService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    // Gọi API
                    let items = try await itemService.fetchItems()
                    await send(.itemsResponse(.success(items)))
                } catch: { error, send in
                    await send(.itemsResponse(.failure(error)))
                }
                
            case .itemTapped(let item):
                // Xử lý khi tap item
                return .none
                
            case .itemsResponse(.success(let items)):
                state.isLoading = false
                state.items = items
                return .none
                
            case .itemsResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}
```

## Bước 3: Tạo View
```swift
struct FeatureNameView: View {
    @Bindable var store: StoreOf<FeatureNameReducer>
    
    var body: some View {
        // UI implementation
        List(store.items) { item in
            Text(item.name)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
```

## Bước 4: Register trong Parent
```swift
// Trong AppReducer
Scope(state: \.featureName, action: \.featureName) {
    FeatureNameReducer()
}
```

## Bước 5: Viết Tests
```swift
@MainActor
func testFeatureName() async {
    let store = TestStore(initialState: .init()) {
        FeatureNameReducer()
    }
    // Test cases
}
```
