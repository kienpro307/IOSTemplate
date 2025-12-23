# Quy tắc ngôn ngữ

## Tóm tắt

| Thành phần | Ngôn ngữ |
|------------|----------|
| Tên hàm, biến, class, struct, enum | Tiếng Anh |
| Comment, documentation | Tiếng Việt |
| Commit message | Tiếng Anh |
| File names | Tiếng Anh |

## Ví dụ đúng

```swift
// ✅ ĐÚNG
struct HomeReducer {
    struct State {
        var products: [Product] = []  // Danh sách sản phẩm
        var isLoading: Bool = false   // Đang tải dữ liệu
    }
    
    enum Action {
        case onAppear           // Khi view xuất hiện
        case productTapped(id)  // Khi tap vào sản phẩm
    }
}
```

## Ví dụ sai

```swift
// ❌ SAI - Không dùng tiếng Việt cho code
struct BoGiamTrangChu {
    var danhSachSanPham: [SanPham] = []
    var dangTai: Bool = false
}
```

## Chi tiết

Xem: `ios-template-docs/04-HUONG-DAN-AI/03-QUY-TAC-DAT-TEN.md`

