# Thêm Dependency Mới

Hướng dẫn thêm Swift Package dependencies.

---

## Thêm Package

### 1. Package.swift

```swift
dependencies: [
    // ... existing ...
    .package(url: "https://github.com/owner/package.git", from: "1.0.0"),
]
```

### 2. Link to Target

```swift
.target(
    name: "Core",
    dependencies: [
        // ... existing ...
        .product(name: "PackageName", package: "package"),
    ]
)
```

### 3. Resolve Packages

```
Xcode → File → Packages → Resolve Package Versions
```

---

## Popular Packages

| Package | URL | Usage |
|---------|-----|-------|
| Alamofire | github.com/Alamofire/Alamofire | Network (alt to Moya) |
| SDWebImage | github.com/SDWebImage/SDWebImageSwiftUI | Images (alt to Kingfisher) |
| SwiftGen | github.com/SwiftGen/SwiftGen | Code generation |

---

## Xem Thêm

- [Dependencies Reference](../05-THAM-KHAO/01-DEPENDENCIES.md)
- [Xóa Tính Năng](03-XOA-TINH-NANG.md)

