# Quy trình sửa lỗi

## Checklist

- [ ] Hiểu rõ lỗi (reproduce)
- [ ] Tìm root cause
- [ ] Sửa lỗi
- [ ] Test fix
- [ ] Cập nhật progress

## Bước 1: Reproduce lỗi

- Đọc mô tả lỗi
- Xác định steps to reproduce
- Confirm lỗi xảy ra

## Bước 2: Tìm root cause

```
Checklist tìm lỗi:
├── State management issue?
│   └── Check reducer logic
├── Side effect issue?
│   └── Check Effect handling
├── UI binding issue?
│   └── Check @Bindable, store.send()
├── Dependency issue?
│   └── Check @Dependency injection
└── Race condition?
    └── Check async/await flow
```

## Bước 3: Sửa lỗi

### Principles
- Sửa đúng root cause, không patch
- Không break existing functionality
- Keep changes minimal

### Common fixes

```swift
// Fix: State not updating
// Check: Action đã được handle chưa?
case .someAction:
    state.value = newValue  // Phải mutate state
    return .none

// Fix: Side effect not triggered
// Check: Return Effect đúng chưa?
case .buttonTapped:
    return .run { send in
        await send(.dataLoaded(data))
    }

// Fix: View not re-rendering
// Check: State conform Equatable?
@ObservableState
struct State: Equatable { }  // Phải có Equatable
```

## Bước 4: Test fix

- Verify lỗi đã được sửa
- Regression test các features liên quan
- Run unit tests nếu có

## Bước 5: Commit

```
fix(<scope>): <description>

- Root cause: ...
- Solution: ...
```

## Chi tiết

Xem: `ios-template-docs/04-HUONG-DAN-AI/06-CACH-SUA-LOI.md`

