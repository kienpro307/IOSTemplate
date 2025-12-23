# 🔄 Luồng Dữ Liệu (Data Flow)

## 1. Unidirectional Data Flow

### 1.1 Nguyên Tắc Cơ Bản

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIDIRECTIONAL DATA FLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│         ┌──────────┐                                           │
│         │   VIEW   │ ◄──────────────────────┐                  │
│         └────┬─────┘                        │                  │
│              │                              │                  │
│         (1) User                       (5) Re-render           │
│         interacts                      with new state          │
│              │                              │                  │
│              ▼                              │                  │
│         ┌──────────┐                   ┌────┴─────┐           │
│         │  ACTION  │                   │  STATE   │           │
│         └────┬─────┘                   └────▲─────┘           │
│              │                              │                  │
│         (2) Dispatch                   (4) Mutate             │
│              │                              │                  │
│              ▼                              │                  │
│         ┌──────────┐                   ┌────┴─────┐           │
│         │  STORE   │ ─────────────────►│ REDUCER  │           │
│         └──────────┘     (3) Process   └──────────┘           │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Tại Sao Một Chiều?

| Lợi ích | Mô tả |
|---------|-------|
| **Predictable** | State chỉ thay đổi qua actions |
| **Debuggable** | Dễ trace nguyên nhân thay đổi |
| **Testable** | Logic tách biệt, dễ test |
| **No Race Conditions** | Không có concurrent mutations |

---

## 2. User Interaction Flow

### 2.1 Flow Chi Tiết

```
User taps button
       │
       ▼
┌─────────────────────┐
│ View captures event │  // View nhận sự kiện
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ store.send(.action) │  // Gửi action đến store
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Reducer processes   │  // Reducer xử lý
│ action, returns     │
│ new state + effect  │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
┌─────────┐  ┌─────────┐
│  State  │  │ Effect  │
│ updated │  │ executes│
└────┬────┘  └────┬────┘
     │            │
     ▼            ▼
┌─────────┐  ┌─────────┐
│  View   │  │  Send   │
│re-renders  │  action │
└─────────┘  └─────────┘
```

### 2.2 Ví Dụ Cụ Thể

```swift
// 1. View: User tap button
Button("Load Products") {
    store.send(.loadProductsTapped)
}

// 2. Action được gửi
enum Action {
    case loadProductsTapped
    case productsResponse(Result<[Product], Error>)
}

// 3. Reducer xử lý
var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case .loadProductsTapped:
            // Cập nhật state
            state.isLoading = true
            
            // Trả về effect
            return .run { send in
                let products = try await productService.fetchProducts()
                await send(.productsResponse(.success(products)))
            }
            
        case .productsResponse(.success(let products)):
            state.isLoading = false
            state.products = products
            return .none
            
        case .productsResponse(.failure(let error)):
            state.isLoading = false
            state.error = error.localizedDescription
            return .none
        }
    }
}

// 4. View tự động re-render với state mới
var body: some View {
    if store.isLoading {
        ProgressView()
    } else {
        List(store.products) { product in
            ProductRow(product: product)
        }
    }
}
```

---

## 3. API Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      API DATA FLOW                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐                                                  │
│  │   VIEW   │                                                  │
│  └────┬─────┘                                                  │
│       │ store.send(.fetchData)                                 │
│       ▼                                                        │
│  ┌──────────┐                                                  │
│  │ REDUCER  │                                                  │
│  │          │──────► state.isLoading = true                    │
│  │          │──────► return .run { ... }                       │
│  └────┬─────┘                                                  │
│       │                                                        │
│       ▼                                                        │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐ │
│  │  EFFECT  │───►│ NETWORK  │───►│ BACKEND  │───►│  JSON   │ │
│  │  (.run)  │    │ CLIENT   │    │   API    │    │ Response│ │
│  └──────────┘    └──────────┘    └──────────┘    └────┬────┘ │
│                                                        │      │
│                                                        ▼      │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────────┐│
│  │  ACTION  │◄───│  DECODE  │◄───│ try await send(.response)││
│  │ response │    │  JSON    │    └──────────────────────────┘│
│  └────┬─────┘    └──────────┘                                │
│       │                                                       │
│       ▼                                                       │
│  ┌──────────┐                                                 │
│  │ REDUCER  │                                                 │
│  │          │──────► state.isLoading = false                  │
│  │          │──────► state.data = response                    │
│  └────┬─────┘                                                 │
│       │                                                       │
│       ▼                                                       │
│  ┌──────────┐                                                 │
│  │   VIEW   │ re-renders với data mới                        │
│  └──────────┘                                                 │
│                                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Effect Lifecycle

### 4.1 Effect Execution

```swift
// Effect được trả về từ reducer
case .searchQueryChanged(let query):
    return .run { send in
        // 1. Effect bắt đầu execute
        try await Task.sleep(for: .milliseconds(300))
        
        // 2. Gọi dependency
        let results = try await searchService.search(query)
        
        // 3. Gửi action khi hoàn thành
        await send(.searchResponse(.success(results)))
    } catch: { error, send in
        // 4. Handle error
        await send(.searchResponse(.failure(error)))
    }
```

### 4.2 Effect Patterns

```swift
// Simple async
return .run { send in
    let data = try await service.fetch()
    await send(.dataResponse(.success(data)))
}

// With error handling
return .run { send in
    let data = try await service.fetch()
    await send(.dataResponse(.success(data)))
} catch: { error, send in
    await send(.dataResponse(.failure(error)))
}

// Cancellable
return .run { send in
    let data = try await service.fetch()
    await send(.dataResponse(.success(data)))
}
.cancellable(id: CancelID.fetch)

// Multiple effects (parallel)
return .merge(
    .run { send in /* fetch A */ },
    .run { send in /* fetch B */ }
)

// Sequential effects
return .concatenate(
    .send(.startLoading),
    .run { send in /* fetch */ },
    .send(.endLoading)
)
```

---

## 5. Parent-Child Communication

### 5.1 Parent → Child (State)

```swift
// Parent scope state xuống child
struct ParentReducer {
    struct State {
        var childState = ChildReducer.State()
    }
}

// View scope store
ChildView(
    store: store.scope(
        state: \.childState,
        action: \.child
    )
)
```

### 5.2 Child → Parent (Delegate)

```swift
// Child định nghĩa delegate actions
struct ChildReducer {
    enum Action {
        case delegate(Delegate)
        
        enum Delegate {
            case didSelectItem(Item)
            case didComplete
        }
    }
    
    // Khi cần thông báo parent
    case .itemTapped(let item):
        return .send(.delegate(.didSelectItem(item)))
}

// Parent handle delegate
struct ParentReducer {
    var body: some ReducerOf<Self> {
        Scope(state: \.child, action: \.child) {
            ChildReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .child(.delegate(.didSelectItem(let item))):
                // Handle item selected
                state.selectedItem = item
                return .none
                
            case .child(.delegate(.didComplete)):
                // Handle completion
                state.child = nil  // Dismiss child
                return .none
                
            case .child:
                return .none
            }
        }
    }
}
```

---

## 6. Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     ERROR HANDLING FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐                                                  │
│  │  EFFECT  │ throws error                                     │
│  └────┬─────┘                                                  │
│       │                                                        │
│       ▼                                                        │
│  ┌──────────────────────────────┐                              │
│  │ catch: { error, send in      │                              │
│  │   await send(.failure(error))│                              │
│  │ }                            │                              │
│  └────┬─────────────────────────┘                              │
│       │                                                        │
│       ▼                                                        │
│  ┌──────────┐                                                  │
│  │ REDUCER  │                                                  │
│  │ handles  │──────► state.error = error.message               │
│  │ failure  │──────► state.isLoading = false                   │
│  └────┬─────┘                                                  │
│       │                                                        │
│       ▼                                                        │
│  ┌──────────┐                                                  │
│  │   VIEW   │ shows error UI with retry option                 │
│  └──────────┘                                                  │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Key Takeaways

| Nguyên tắc | Mô tả |
|------------|-------|
| **One-way only** | Data chỉ chảy một chiều |
| **Single source of truth** | State là nguồn sự thật duy nhất |
| **Pure reducers** | Reducers không có side effects |
| **Effects are controlled** | Side effects qua Effect type |
| **Testable** | Mọi thứ đều có thể test |

---

*Hiểu rõ data flow giúp debug dễ dàng và code predictable.*
