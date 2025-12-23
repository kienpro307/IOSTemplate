# 🏷️ Quy Tắc Đặt Tên

## Nguyên Tắc Chung
- **Code (tên hàm, biến, class, struct, enum)**: Tiếng Anh
- **Comment, documentation**: Tiếng Việt
- **Tên file**: Tiếng Anh

## Files
- `[TypeName][Suffix].swift`
- Hậu tố: View, Reducer, Model, Service, Repository, Protocol, Tests

## Types
```swift
struct User { }                // PascalCase
enum LoadingState { }          // PascalCase
protocol RepositoryProtocol { } // PascalCase với suffix Protocol
```

## Variables & Functions
```swift
var userName: String           // camelCase
var isLoading: Bool            // Boolean với prefix: is, has, should, can
func fetchUser() { }           // Verb prefix
func didTapButton() { }        // Action handlers với did/will prefix
```

## TCA Naming
```swift
struct LoginState { }          // State: [Feature]State
enum LoginAction { }           // Action: [Feature]Action  
struct LoginReducer { }        // Reducer: [Feature]Reducer
```

## Constants
```swift
enum Constants {
    static let maxRetryCount = 3
    static let apiBaseURL = "https://api.example.com"
}
```

## Ví Dụ Đúng vs Sai
```swift
// ✅ ĐÚNG - Code tiếng Anh, comment tiếng Việt
struct HomeReducer {
    struct State {
        var products: [Product] = []  // Danh sách sản phẩm
        var isLoading: Bool = false   // Trạng thái đang tải
    }
    
    enum Action {
        case onAppear              // Khi view xuất hiện
        case fetchProducts         // Tải danh sách sản phẩm
        case productsResponse(Result<[Product], Error>)
    }
}

// ❌ SAI - Không dùng tiếng Việt cho code
struct BoGiamTrangChu {
    var danhSachSanPham: [SanPham] = []
    var dangTai: Bool = false
}
```
