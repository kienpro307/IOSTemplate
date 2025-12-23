# ⚠️ Xử Lý Lỗi (Error Handling)

## 1. Error Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Error Occurs]                                                 │
│        │                                                        │
│        ▼                                                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│  │   Catch     │───►│   Map to    │───►│   Send      │        │
│  │   Error     │    │  AppError   │    │  Action     │        │
│  └─────────────┘    └─────────────┘    └─────────────┘        │
│                                              │                  │
│                                              ▼                  │
│                     ┌─────────────────────────────────┐        │
│                     │         REDUCER                  │        │
│                     │  • Update state.error           │        │
│                     │  • Log to Crashlytics           │        │
│                     │  • Show appropriate UI          │        │
│                     └─────────────────────────────────┘        │
│                                              │                  │
│              ┌───────────────┬───────────────┤                 │
│              ▼               ▼               ▼                 │
│        ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│        │  Toast  │    │  Alert  │    │Full Page│              │
│        │ (Minor) │    │(Important│    │(Critical│              │
│        └─────────┘    └─────────┘    └─────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Error Types

### 2.1 App Error Hierarchy

```swift
// Root error type - Loại lỗi gốc
enum AppError: Error, Equatable {
    case network(NetworkError)
    case data(DataError)
    case business(BusinessError)
    case system(SystemError)
    
    var userMessage: String {
        switch self {
        case .network(let error): return error.userMessage
        case .data(let error): return error.userMessage
        case .business(let error): return error.userMessage
        case .system(let error): return error.userMessage
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .network: return true
        case .data: return true
        case .business: return false
        case .system: return false
        }
    }
}
```

### 2.2 Specific Error Types

```swift
// Network errors - Lỗi mạng
enum NetworkError: Error, Equatable {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case notFound
    
    var userMessage: String {
        switch self {
        case .noConnection:
            return "Không có kết nối mạng. Vui lòng kiểm tra lại."
        case .timeout:
            return "Yêu cầu quá thời gian. Vui lòng thử lại."
        case .serverError(let code):
            return "Lỗi server (\(code)). Vui lòng thử lại sau."
        case .invalidResponse:
            return "Dữ liệu không hợp lệ."
        case .notFound:
            return "Không tìm thấy dữ liệu."
        }
    }
}

// Data errors - Lỗi dữ liệu
enum DataError: Error, Equatable {
    case decodingFailed
    case databaseError
    case notFound
}

// Business errors - Lỗi nghiệp vụ
enum BusinessError: Error, Equatable {
    case insufficientBalance
    case limitExceeded
    case invalidInput(String)
}
```

---

## 3. Error Handling in Reducer

### 3.1 Basic Pattern

```swift
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var error: AppError?
        var items: [Item] = []
    }
    
    enum Action: Equatable {
        case fetchData
        case dataResponse(Result<[Item], Error>)
        case retry
        case clearError
    }
    
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.errorReporter) var errorReporter
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchData:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let items = try await networkClient.fetchItems()
                        await send(.dataResponse(.success(items)))
                    } catch {
                        await send(.dataResponse(.failure(error)))
                    }
                }
                
            case .dataResponse(.success(let items)):
                state.isLoading = false
                state.items = items
                return .none
                
            case .dataResponse(.failure(let error)):
                state.isLoading = false
                state.error = mapToAppError(error)
                
                // Log to Crashlytics
                return .run { _ in
                    errorReporter.log(error)
                }
                
            case .retry:
                return .send(.fetchData)
                
            case .clearError:
                state.error = nil
                return .none
            }
        }
    }
    
    private func mapToAppError(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(networkError)
        }
        // ... map other errors
        return .system(.unknown(error.localizedDescription))
    }
}
```

---

## 4. Error UI Components

### 4.1 Error View

```swift
struct ErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Đã xảy ra lỗi")
                .font(.headline)
            
            Text(error.userMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                if error.canRetry, let onRetry {
                    Button("Thử lại") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let onDismiss {
                    Button("Đóng") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
```

### 4.2 Toast Error

```swift
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, warning, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle"
            case .error: return "xmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .info: return "info.circle"
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: type.icon)
            Text(message)
        }
        .padding()
        .background(type.color.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
```

---

## 5. Best Practices

```
✅ DO:
• Map all errors to user-friendly messages
• Log errors to Crashlytics
• Provide retry option when possible
• Show appropriate UI for error severity
• Clear error state after user acknowledges

❌ DON'T:
• Show raw error messages to users
• Silently swallow errors
• Block UI on non-critical errors
• Forget to handle error states in UI
```

---

*Xử lý lỗi tốt giúp user experience tốt hơn và debug dễ dàng hơn.*
