# Quy trình tạo Feature mới

## Checklist

- [ ] Đọc 02-CODE/TCA.md
- [ ] Đọc 02-CODE/STRUCTURE.md
- [ ] Tạo folder structure
- [ ] Tạo Reducer
- [ ] Tạo View
- [ ] Tích hợp vào parent
- [ ] Cập nhật progress/DANG-LAM.md

## Bước 1: Tạo folder

```
Sources/Features/{FeatureName}/
├── {FeatureName}Reducer.swift
├── {FeatureName}View.swift
├── Components/
└── Models/
```

## Bước 2: Tạo Reducer

```swift
import ComposableArchitecture

@Reducer
struct {FeatureName}Reducer {
    @ObservableState
    struct State: Equatable {
        // State properties
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            // Delegate actions
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
```

## Bước 3: Tạo View

```swift
import ComposableArchitecture
import SwiftUI

struct {FeatureName}View: View {
    @Bindable var store: StoreOf<{FeatureName}Reducer>
    
    var body: some View {
        // View content
    }
}

#Preview {
    {FeatureName}View(
        store: Store(initialState: .init()) {
            {FeatureName}Reducer()
        }
    )
}
```

## Bước 4: Tích hợp vào parent

1. Thêm state vào parent State
2. Thêm action vào parent Action  
3. Scope reducer trong parent body
4. Thêm View vào parent View

## Templates

Xem: `ios-template-docs/05-CODE-TEMPLATES/`

