# 🐛 Cách Sửa Lỗi

## Debug Process
1. Reproduce lỗi
2. Check console logs
3. Xác định file/function gây lỗi
4. Fix và test
5. Viết regression test

## Common Issues

### Build Errors
- Clean build folder (Cmd+Shift+K)
- Delete Derived Data
- Reset package caches

### Runtime Crashes
- Check force unwraps
- Check array bounds
- Check nil optionals

### TCA Issues
- State not updating → Check Equatable
- Effect not running → Check .none vs .run
- Memory leak → Check @Dependency lifecycle

## Logging
```swift
@Dependency(\.nhatKy) var nhatKy

nhatKy.debug("Message")
nhatKy.error("Error: \(error)")
```
