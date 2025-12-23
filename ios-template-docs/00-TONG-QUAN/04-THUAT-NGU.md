# 📖 Thuật Ngữ (Glossary)

## Mục Đích

Tài liệu này định nghĩa tất cả thuật ngữ được sử dụng trong dự án. **AI và developers** cần hiểu thống nhất các thuật ngữ này để giao tiếp hiệu quả.

---

## 1. Thuật Ngữ Kiến Trúc

### TCA (The Composable Architecture)
**Định nghĩa**: Một framework kiến trúc cho Swift applications, được phát triển bởi Point-Free.

**Đặc điểm**:
- Unidirectional data flow
- State được quản lý tập trung
- Side effects được kiểm soát
- Highly testable

**Ví dụ sử dụng**: "Dự án này sử dụng TCA để quản lý state và business logic."

---

### State (Trạng Thái)
**Định nghĩa**: Dữ liệu mô tả trạng thái hiện tại của một feature hoặc toàn bộ app.

**Trong TCA**:
```swift
@ObservableState
struct TrangThaiDangNhap {
    var email: String = ""
    var dangTai: Bool = false
}
```

**Tiếng Việt trong code**: `TrangThai`

---

### Action (Hành Động)
**Định nghĩa**: Sự kiện có thể xảy ra trong app, được gửi từ View đến Reducer.

**Trong TCA**:
```swift
enum HanhDongDangNhap {
    case emailThayDoi(String)
    case nutDangNhapNhan
}
```

**Tiếng Việt trong code**: `HanhDong`

---

### Reducer (Bộ Giảm)
**Định nghĩa**: Pure function xử lý Action và cập nhật State.

**Trong TCA**:
```swift
@Reducer
struct BoGiamDangNhap {
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Xử lý action
        }
    }
}
```

**Tiếng Việt trong code**: `BoGiam`

---

### Effect (Hiệu Ứng)
**Định nghĩa**: Side effect như API calls, database operations, được trả về từ Reducer.

**Trong TCA**:
```swift
return .run { send in
    let result = try await apiClient.dangNhap(email, matKhau)
    await send(.phanHoiDangNhap(.success(result)))
}
```

**Tiếng Việt trong code**: `HieuUng`

---

### Store (Kho)
**Định nghĩa**: Container chứa State và dispatch Actions đến Reducer.

**Trong TCA**:
```swift
let store = Store(initialState: TrangThaiDangNhap()) {
    BoGiamDangNhap()
}
```

**Tiếng Việt trong code**: `CuaHang` hoặc giữ nguyên `Store`

---

### Dependency (Phụ Thuộc)
**Định nghĩa**: External services mà Reducer cần để thực hiện side effects.

**Trong TCA**:
```swift
@Dependency(\.khachMang) var khachMang
@Dependency(\.luuTru) var luuTru
```

**Tiếng Việt trong code**: `PhuThuoc`

---

## 2. Thuật Ngữ Layer

### Presentation Layer (Tầng Trình Bày)
**Định nghĩa**: Layer chứa UI code (Views, Components).

**Chứa**:
- SwiftUI Views
- Custom Components
- View Modifiers
- Previews

---

### Feature Layer (Tầng Tính Năng)
**Định nghĩa**: Layer chứa business logic của từng feature.

**Chứa**:
- Reducers
- States
- Actions
- Feature-specific logic

---

### Domain Layer (Tầng Miền)
**Định nghĩa**: Layer chứa business models và rules.

**Chứa**:
- Domain Models
- Business Rules
- Protocols/Interfaces
- Use Cases

---

### Data Layer (Tầng Dữ Liệu)
**Định nghĩa**: Layer quản lý data persistence và retrieval.

**Chứa**:
- Repositories
- Data Sources
- Caching
- Mappers

---

### Infrastructure Layer (Tầng Hạ Tầng)
**Định nghĩa**: Layer chứa technical implementations.

**Chứa**:
- Network Client
- Database
- Storage
- Third-party SDKs

---

## 3. Thuật Ngữ Module

### Loi (Core)
**Định nghĩa**: Module lõi chứa shared code cho toàn bộ app.

**Chứa**:
- Base classes/protocols
- Utilities
- Extensions
- Constants

---

### GiaoDien (UI)
**Định nghĩa**: Module chứa UI components và theme.

**Chứa**:
- Design System
- Reusable Components
- Themes
- Animations

---

### DichVu (Services)
**Định nghĩa**: Module chứa external service integrations.

**Chứa**:
- Firebase services
- Authentication
- Payment
- Analytics

---

### TinhNang (Features)
**Định nghĩa**: Module chứa các feature modules.

**Chứa**:
- Individual features
- Feature-specific UI
- Feature reducers

---

## 4. Thuật Ngữ Kỹ Thuật

### SPM (Swift Package Manager)
**Định nghĩa**: Apple's native dependency manager cho Swift.

**Sử dụng**: Quản lý tất cả dependencies trong project.

---

### DI (Dependency Injection)
**Định nghĩa**: Design pattern để inject dependencies vào objects.

**Trong TCA**: Sử dụng `@Dependency` property wrapper.

---

### Repository Pattern
**Định nghĩa**: Pattern trừu tượng hóa data source.

**Mục đích**: Tách biệt business logic khỏi data access.

```swift
protocol GiaoThucKhoNguoiDung {
    func lay(id: String) async throws -> NguoiDung
    func luu(_ nguoiDung: NguoiDung) async throws
}
```

---

### MVVM
**Định nghĩa**: Model-View-ViewModel architecture pattern.

**Lưu ý**: Dự án này KHÔNG dùng MVVM, dùng TCA thay thế.

---

### Observable
**Định nghĩa**: Object có thể được observe để detect changes.

**Trong SwiftUI**: `@Observable`, `@ObservableState`

---

### Codable
**Định nghĩa**: Protocol để encode/decode data.

**Sử dụng**: JSON parsing, data persistence.

```swift
struct NguoiDung: Codable {
    let id: String
    let ten: String
}
```

---

## 5. Thuật Ngữ Swift

### Struct vs Class
**Struct**: Value type, copied when assigned.
**Class**: Reference type, shared when assigned.

**Quy tắc**: Ưu tiên Struct trừ khi cần Class.

---

### Optional
**Định nghĩa**: Type có thể nil hoặc có giá trị.

```swift
var ten: String?  // Optional String
var tuoi: Int = 0 // Non-optional Int
```

---

### Async/Await
**Định nghĩa**: Swift concurrency model.

```swift
func layDuLieu() async throws -> Data {
    // Async code
}
```

---

### Property Wrapper
**Định nghĩa**: Type that wraps property với custom behavior.

**Ví dụ**: `@State`, `@Binding`, `@Published`, `@Dependency`

---

## 6. Thuật Ngữ Firebase

### Analytics
**Định nghĩa**: Service tracking user behavior.

### Crashlytics
**Định nghĩa**: Service báo cáo crash.

### Remote Config
**Định nghĩa**: Service cấu hình app từ xa (feature flags).

### FCM (Firebase Cloud Messaging)
**Định nghĩa**: Service push notifications.

---

## 7. Thuật Ngữ Business

### IAP (In-App Purchase)
**Định nghĩa**: Mua hàng trong app.

**Types**:
- Consumable: Dùng 1 lần
- Non-consumable: Mua 1 lần, dùng mãi
- Subscription: Đăng ký định kỳ

---

### Onboarding
**Định nghĩa**: First-time user experience.

**Mục đích**: Giới thiệu app, xin permissions, setup account.

---

### Feature Flag
**Định nghĩa**: Toggle để enable/disable features.

**Sử dụng**: A/B testing, gradual rollout.

---

## 8. Thuật Ngữ Testing

### Unit Test
**Định nghĩa**: Test individual unit of code (function, class).

### Integration Test
**Định nghĩa**: Test multiple units working together.

### UI Test
**Định nghĩa**: Test app UI via automation.

### Mock
**Định nghĩa**: Fake object thay thế real dependency trong test.

### Stub
**Định nghĩa**: Predefined response cho test.

---

## 9. Thuật Ngữ Tiếng Việt Trong Code

| English | Tiếng Việt | Sử dụng trong |
|---------|------------|---------------|
| User | NguoiDung | Models |
| Login | DangNhap | Features |
| Register | DangKy | Features |
| Settings | CaiDat | Features |
| Home | TrangChu | Features |
| Loading | DangTai | States |
| Error | Loi | States |
| Success | ThanhCong | States |
| Button | Nut | Components |
| TextField | ONhapLieu | Components |
| List | DanhSach | Components |
| Card | The | Components |
| Network | Mang | Services |
| Storage | LuuTru | Services |
| Cache | BoNhoDem | Services |
| Repository | Kho | Data |
| Service | DichVu | Services |
| Manager | BoQuanLy | Services |
| Helper | TroGiup | Utilities |
| Extension | PhanMoRong | Utilities |
| Protocol | GiaoThuc | Interfaces |
| View | KhungNhin | UI |
| State | TrangThai | Architecture |
| Action | HanhDong | Architecture |
| Reducer | BoGiam | Architecture |
| Effect | HieuUng | Architecture |
| Theme | ChuDe | UI |
| Color | MauSac | UI |
| Font | KieuChu | UI |
| Spacing | KhoangCach | UI |

---

## 10. Abbreviations (Viết Tắt)

| Viết tắt | Đầy đủ | Nghĩa |
|----------|--------|-------|
| TCA | The Composable Architecture | Framework kiến trúc |
| DI | Dependency Injection | Tiêm phụ thuộc |
| SPM | Swift Package Manager | Quản lý gói |
| IAP | In-App Purchase | Mua trong app |
| FCM | Firebase Cloud Messaging | Push notification |
| API | Application Programming Interface | Giao diện lập trình |
| UI | User Interface | Giao diện người dùng |
| UX | User Experience | Trải nghiệm người dùng |
| CI | Continuous Integration | Tích hợp liên tục |
| CD | Continuous Deployment | Triển khai liên tục |
| QA | Quality Assurance | Đảm bảo chất lượng |
| PR | Pull Request | Yêu cầu merge code |
| IDE | Integrated Development Environment | Môi trường phát triển |

---

## 11. Cách Sử Dụng Trong Giao Tiếp

### Với AI
Khi giao tiếp với AI về dự án:

```
✅ Đúng:
"Tạo Reducer cho feature DangNhap theo TCA pattern"
"Thêm Effect để gọi API layNguoiDung"
"Implement KhoNguoiDung với Repository pattern"

❌ Sai:
"Tạo ViewModel cho login" (không dùng MVVM)
"Thêm RxSwift observable" (không dùng RxSwift)
```

### Trong Code Review
```
✅ Đúng:
"State này nên được đặt trong TrangThaiDangNhap"
"Action này thiếu case xử lý lỗi"
"Cần thêm Dependency cho khachMang"

❌ Sai:
"ViewModel này cần refactor" (không có ViewModel)
```

---

*Glossary này sẽ được cập nhật khi có thuật ngữ mới. Mọi thành viên (kể cả AI) cần tuân theo định nghĩa này.*
