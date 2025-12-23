# 📋 Context Dự Án Cho AI

## Dự Án Này Là Gì?
iOS Template - một codebase template cho ứng dụng iOS, sử dụng TCA architecture.

## Tech Stack
- Swift 5.9+, SwiftUI, iOS 16+
- TCA (The Composable Architecture)
- Moya (Networking)
- Firebase (Analytics, Crashlytics)
- StoreKit 2 (IAP)

## Cấu Trúc Module
```
Core → UI + Services → Features → App
```

## Quy Tắc Quan Trọng
1. **Code tiếng Anh, comment tiếng Việt**
2. Dùng TCA pattern cho tất cả features
3. Mỗi feature có Reducer, View, Components, Models
4. Test coverage > 80% cho business logic
5. **KHÔNG có authentication** - app không yêu cầu đăng nhập

## Ví Dụ Đúng
```swift
// ✅ ĐÚNG - Code tiếng Anh, comment tiếng Việt
struct HomeReducer {
    struct State {
        var products: [Product] = []  // Danh sách sản phẩm
        var isLoading: Bool = false   // Trạng thái đang tải
    }
}

// ❌ SAI - Không dùng tiếng Việt cho code
struct BoGiamTrangChu {
    var danhSachSanPham: [SanPham] = []
}
```

## Khi Tạo Code Mới
- Đọc file 05-CACH-TAO-TINH-NANG.md
- Tham khảo code templates trong 05-CODE-TEMPLATES/
- Follow naming conventions trong 03-QUY-TAC-DAT-TEN.md
