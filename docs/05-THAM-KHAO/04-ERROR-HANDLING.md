# Error Handling

Hướng dẫn sử dụng error handling system.

---

## Error Hierarchy

```
AppError
├── NetworkError
├── DataError
├── BusinessError
└── SystemError
```

---

## Usage

### Throw Errors

```swift
throw AppError.network(.unauthorized)
throw AppError.data(.notFound)
throw AppError.business(.insufficientBalance)
```

### Catch & Map Errors

```swift
case .fetchData:
    return .run { send in
        do {
            let data = try await api.fetch()
            await send(.success(data))
        } catch {
            let appError = ErrorMapper.map(error)
            await send(.failure(appError))
        }
    }
```

### Display Errors

```swift
case .failure(let error):
    state.errorMessage = error.userMessage
    return .none
```

---

## Error Types

### NetworkError

- `.noConnection` - No internet
- `.timeout` - Request timeout
- `.unauthorized` - Auth failed
- `.serverError` - 5xx errors

### DataError

- `.notFound` - Data không tồn tại
- `.decodingFailed` - JSON decode fail
- `.invalidData` - Data không hợp lệ

### BusinessError

- `.insufficientBalance` - Không đủ tiền
- `.limitExceeded` - Vượt giới hạn
- `.invalidInput` - Input không hợp lệ

---

## User Messages

Mỗi error có `userMessage` tiếng Việt thân thiện:

```swift
let error = AppError.network(.noConnection)
print(error.userMessage)  // "Không có kết nối mạng"
```

---

## Retry Logic

```swift
case .retryButtonTapped:
    // Retry failed operation
    return .send(.fetchData)
```

---

## Xem Thêm

- [FAQ](03-FAQ.md)
- [Services Usage](../02-HUONG-DAN-SU-DUNG/02-SU-DUNG-SERVICES.md)

