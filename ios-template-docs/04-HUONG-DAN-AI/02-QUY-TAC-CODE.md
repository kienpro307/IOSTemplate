# 📝 Quy Tắc Code

## Nguyên Tắc Chung
- **Code (tên hàm, biến, class)**: Tiếng Anh
- **Comment, documentation**: Tiếng Việt

## SwiftLint Rules
- line_length: 120 (warning), 150 (error)
- file_length: 400 (warning), 500 (error)
- function_body_length: 40 (warning), 60 (error)

## Code Style
```swift
// ✅ ĐÚNG - Code tiếng Anh, comment tiếng Việt
struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // Nội dung trang chủ
            contentView
        }
    }
    
    /// View hiển thị nội dung chính
    private var contentView: some View {
        // ...
    }
}

// ❌ SAI - Code tiếng Việt
struct TrangChuView: View {
    var noiDung: some View { ... }
}
```

## Must Follow
- Không force unwrap (!)
- Không force cast (as!)
- Handle tất cả error cases
- Dùng async/await, không Combine
- Comment tiếng Việt cho logic phức tạp
