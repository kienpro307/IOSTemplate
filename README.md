# iOS Template

Mẫu ứng dụng iOS sử dụng TCA (The Composable Architecture).

## Công nghệ sử dụng
- Swift 5.9+
- iOS 16+
- SwiftUI
- TCA (The Composable Architecture)
- Moya (Network)
- KeychainAccess (Lưu trữ bảo mật)
- Kingfisher (Tải ảnh)

## Cấu trúc dự án

```
Sources/
├── App/           # Entry point và RootView
├── Core/          # Logic cốt lõi
│   ├── Architecture/  # State, Action, Reducer
│   ├── Dependencies/  # Các dependency clients
│   └── Navigation/    # Deep link và Destination
├── Features/      # Các tính năng nghiệp vụ
├── Services/      # Tích hợp dịch vụ bên ngoài
└── UI/            # Design system và components
```

## Hướng dẫn cài đặt

1. Clone repository
2. Mở `iOSTemplate.xcodeproj`
3. Build & Run

## Hướng dẫn phát triển

### Thêm tính năng mới

1. Tạo reducer mới trong `Sources/Features/`
2. Định nghĩa State, Action và body reducer
3. Tạo View tương ứng
4. Thêm navigation case trong `Destination.swift` nếu cần

### Dependencies

Các dependency đã được cấu hình sẵn:
- `networkClient`: Gọi API
- `storageClient`: Lưu trữ UserDefaults
- `keychainClient`: Lưu trữ bảo mật (token, password)
- `dateClient`: Xử lý Date (dễ mock cho testing)

## Giấy phép

MIT License
