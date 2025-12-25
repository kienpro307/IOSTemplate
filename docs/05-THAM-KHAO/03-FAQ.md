# FAQ - Câu Hỏi Thường Gặp

---

## Setup & Installation

### Q: Build failed với "No such module 'ComposableArchitecture'"

**A:** Reset package caches:

```bash
Xcode → File → Packages → Reset Package Caches
Xcode → File → Packages → Resolve Package Versions
```

### Q: Firebase không hoạt động

**A:** Check:
1. `GoogleService-Info.plist` đã add vào project chưa?
2. File có check "Copy items if needed" không?
3. Firebase initialized trong `Main.swift` chưa?

---

## Development

### Q: Làm sao tạo feature mới?

**A:** Follow 5 bước:
1. Tạo State
2. Tạo Action
3. Tạo Reducer
4. Tạo View
5. Tích hợp vào AppReducer

Xem chi tiết: [Tạo Feature Mới](../02-HUONG-DAN-SU-DUNG/01-TAO-TINH-NANG-MOI.md)

### Q: State không update trong View

**A:** Check:
- State có `@ObservableState` macro không?
- View có `@Bindable var store` không?
- Action được send đúng không?

---

## Testing

### Q: Tests failed

**A:** 
1. Check mock dependencies đã setup chưa
2. Verify state changes trong `$0.property = value`
3. Check async effects với `.receive()`

---

## Firebase

### Q: Analytics không track events

**A:**
1. Firebase initialized chưa?
2. GoogleService-Info.plist đúng không?
3. Check Firebase Console (có delay 24h)

---

## IAP

### Q: Purchase không hoạt động

**A:**
1. Product IDs match App Store Connect chưa?
2. Test với sandbox account chưa?
3. StoreKit configuration đúng chưa?

---

## Performance

### Q: App chạy chậm

**A:**
1. Profile với Instruments (⌘I)
2. Check memory leaks
3. Optimize heavy views
4. Use `.task` thay vì `.onAppear` cho async operations

---

## Xem Thêm

- [Troubleshooting](../01-BAT-DAU/03-CHAY-THU.md)
- [Error Handling](04-ERROR-HANDLING.md)

