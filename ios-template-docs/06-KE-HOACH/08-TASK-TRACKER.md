# 📋 TASK TRACKER - DANH SÁCH VIỆC CẦN LÀM

## 🎯 Cách Sử Dụng File Này

File này liệt kê TẤT CẢ các task cần làm để hoàn thành iOS Template. Khi AI được yêu cầu làm task nào, hãy:

1. Tìm task trong danh sách
2. Đọc chi tiết yêu cầu
3. Xem dependencies (task phụ thuộc)
4. Thực hiện theo đúng spec
5. Đánh dấu hoàn thành

---

## 📊 TỔNG QUAN TIẾN ĐỘ

```
Phase 0: Chuẩn bị         [████████░░] 75%  (3/4 tasks)
Phase 1: Nền tảng         [█████░░░░░] 50%  (3/6 tasks)
Phase 2: Core Services    [░░░░░░░░░░] 0%   (0/4 tasks)
Phase 3: Firebase         [░░░░░░░░░░] 0%   (0/5 tasks)
Phase 4: Features         [░░░░░░░░░░] 0%   (0/5 tasks)
Phase 5: Monetization     [░░░░░░░░░░] 0%   (0/2 tasks)
Phase 6: Testing          [░░░░░░░░░░] 0%   (0/2 tasks)
Phase 7: Documentation    [░░░░░░░░░░] 0%   (0/2 tasks)
─────────────────────────────────────────
TỔNG:                     [██░░░░░░░░] 20%  (6/30 tasks)
```

**📅 Ngày cập nhật:** December 23, 2024
**👤 Người thực hiện:** AI + Developer
**⏱️ Thời gian đã làm:** ~6 giờ
**⏱️ Thời gian còn lại:** ~74 giờ

---

## 🔵 PHASE 0: CHUẨN BỊ MÔI TRƯỜNG

### TASK 0.1: Tạo Xcode Project
```yaml
ID: P0-001
Tên: Khởi tạo Xcode Project
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: Không
Thời gian ước tính: 30 phút
Thời gian thực tế: 30 phút
Hoàn thành: December 23, 2024

Mô tả: |
  Tạo Xcode project mới với cấu hình chuẩn

Yêu cầu:
  - Project name: iOSTemplate
  - Bundle ID: com.template.ios
  - Interface: SwiftUI
  - Language: Swift
  - Minimum iOS: 16.0
  - Không chọn Core Data (thêm sau)
  - Include Tests: Yes

Output:
  - File iOSTemplate.xcodeproj
  - Folder structure cơ bản
  - Build thành công trên Simulator

Validation:
  - [ ] Project mở được trong Xcode
  - [ ] Build không lỗi
  - [ ] Run được trên Simulator
```

### TASK 0.2: Cấu hình Git Repository
```yaml
ID: P0-002
Tên: Setup Git repository
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: P0-001
Thời gian ước tính: 15 phút
Thời gian thực tế: 15 phút
Hoàn thành: December 23, 2024

Mô tả: |
  Khởi tạo Git với gitignore chuẩn cho iOS

Yêu cầu:
  - git init
  - Thêm .gitignore cho iOS/Swift
  - Tạo README.md
  - Initial commit

Output:
  - .git folder
  - .gitignore
  - README.md

Files cần tạo:
  .gitignore: |
    # Xcode
    build/
    DerivedData/
    *.xcuserstate
    *.xcscmblueprint
    
    # Swift Package Manager
    .swiftpm/
    .build/
    Packages/
    
    # CocoaPods (nếu dùng)
    Pods/
    
    # Secrets
    *.plist.secret
    GoogleService-Info.plist
    
    # OS
    .DS_Store
    *.swp
```

### TASK 0.3: Setup Swift Package Manager
```yaml
ID: P0-003
Tên: Tạo Package.swift structure
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: P0-001
Thời gian ước tính: 1 giờ
Thời gian thực tế: 1 giờ
Hoàn thành: December 23, 2024

Deliverables:
  ✅ Package.swift với 4 modules (Core, UI, Services, Features)
  ✅ TCA 1.23.0 dependency
  ✅ Moya, Kingfisher, KeychainAccess dependencies
  ✅ Swift 6 language mode enabled
  ✅ Test targets configured

Mô tả: |
  Chuyển project sang dạng Swift Package với multi-module

Yêu cầu:
  - Tạo Package.swift
  - Định nghĩa 4 modules: Loi, GiaoDien, DichVu, TinhNang
  - Thêm dependencies cần thiết
  - Cấu hình test targets

Output:
  - Package.swift hoàn chỉnh
  - Folder Sources/ với 4 modules
  - Folder Tests/

Code mẫu: |
  // swift-tools-version: 5.9
  import PackageDescription
  
  let package = Package(
      name: "iOSTemplate",
      platforms: [.iOS(.v16)],
      products: [
          .library(name: "Loi", targets: ["Loi"]),
          .library(name: "GiaoDien", targets: ["GiaoDien"]),
          .library(name: "DichVu", targets: ["DichVu"]),
          .library(name: "TinhNang", targets: ["TinhNang"]),
      ],
      dependencies: [
          .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
          .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
          .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0"),
          .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
      ],
      targets: [
          .target(name: "Loi", dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              .product(name: "Moya", package: "Moya"),
              .product(name: "KeychainAccess", package: "KeychainAccess"),
          ]),
          .target(name: "GiaoDien", dependencies: ["Loi", .product(name: "Kingfisher", package: "Kingfisher")]),
          .target(name: "DichVu", dependencies: ["Loi"]),
          .target(name: "TinhNang", dependencies: ["Loi", "GiaoDien", "DichVu"]),
          .testTarget(name: "LoiTests", dependencies: ["Loi"]),
          .testTarget(name: "TinhNangTests", dependencies: ["TinhNang"]),
      ]
  )

Validation:
  - [ ] swift build thành công
  - [ ] swift test chạy được
  - [ ] Xcode resolve packages thành công
```

### TASK 0.4: Cấu hình SwiftLint
```yaml
ID: P0-004
Tên: Setup SwiftLint
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P0-001
Thời gian ước tính: 30 phút

Mô tả: |
  Tích hợp SwiftLint để enforce coding conventions

Output:
  - .swiftlint.yml
  - Build phase script

File .swiftlint.yml: |
  disabled_rules:
    - trailing_comma
    - todo
  
  opt_in_rules:
    - array_init
    - closure_spacing
    - empty_count
    - explicit_init
    - first_where
    - implicit_return
    - multiline_arguments
    - multiline_parameters
    - overridden_super_call
    - private_action
    - private_outlet
    - redundant_nil_coalescing
    - sorted_first_last
    - unavailable_function
    - unneeded_parentheses_in_closure_argument
    - vertical_parameter_alignment_on_call
  
  line_length:
    warning: 120
    error: 150
  
  file_length:
    warning: 400
    error: 500
  
  type_body_length:
    warning: 250
    error: 350
  
  function_body_length:
    warning: 40
    error: 60
  
  excluded:
    - DerivedData
    - .build
    - Pods
```

---

## 🔵 PHASE 1: NỀN TẢNG (FOUNDATION)

### TASK 1.1: TCA Core Setup
```yaml
ID: P1-001
Tên: Tạo TCA Root Architecture
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: P0-003
Thời gian ước tính: 2 giờ
Thời gian thực tế: 2 giờ
Hoàn thành: December 23, 2024

Deliverables:
  ✅ Sources/Core/Architecture/AppState.swift
  ✅ Sources/Core/Architecture/AppAction.swift
  ✅ Sources/Core/Architecture/AppReducer.swift
  ✅ Sources/App/IOSTemplateApp.swift
  ✅ Sources/App/RootView.swift
  ✅ @ObservableState, @Reducer, @CasePathable macros
  ✅ Tab navigation structure
  ✅ Build success với TCA 1.23.0

Mô tả: |
  Tạo cấu trúc TCA gốc cho toàn bộ app

Files cần tạo:
  1. Sources/Loi/KienTruc/TrangThaiUngDung.swift
  2. Sources/Loi/KienTruc/HanhDongUngDung.swift
  3. Sources/Loi/KienTruc/BoGiamUngDung.swift
  4. Sources/UngDung/TemplateApp.swift
  5. Sources/UngDung/RootView.swift

Code TrangThaiUngDung.swift: |
  import ComposableArchitecture
  
  @ObservableState
  public struct TrangThaiUngDung: Equatable {
      // Navigation
      public var tabHienTai: Tab = .trangChu
      
      // User
      public var nguoiDung: NguoiDung?
      public var daXacThuc: Bool { nguoiDung != nil }
      
      // App state
      public var coKetNoiMang: Bool = true
      public var phienBan: String = "1.0.0"
      
      // Feature states
      public var dangNhap: TrangThaiDangNhap?
      public var trangChu: TrangThaiTrangChu = .init()
      public var caiDat: TrangThaiCaiDat = .init()
      
      public init() {}
      
      public enum Tab: String, CaseIterable, Equatable {
          case trangChu = "trang_chu"
          case timKiem = "tim_kiem"
          case thongBao = "thong_bao"
          case caiDat = "cai_dat"
      }
  }

Code BoGiamUngDung.swift: |
  import ComposableArchitecture
  
  @Reducer
  public struct BoGiamUngDung {
      public init() {}
      
      public enum HanhDong: Equatable {
          case khungNhinXuatHien
          case tabThayDoi(TrangThaiUngDung.Tab)
          
          case dangNhap(HanhDongDangNhap)
          case trangChu(HanhDongTrangChu)
          case caiDat(HanhDongCaiDat)
          
          case ketNoiMangThayDoi(Bool)
      }
      
      public var body: some ReducerOf<Self> {
          Reduce { state, action in
              switch action {
              case .khungNhinXuatHien:
                  return .none
                  
              case .tabThayDoi(let tab):
                  state.tabHienTai = tab
                  return .none
                  
              case .ketNoiMangThayDoi(let coKetNoi):
                  state.coKetNoiMang = coKetNoi
                  return .none
                  
              default:
                  return .none
              }
          }
          .ifLet(\.dangNhap, action: \.dangNhap) {
              BoGiamDangNhap()
          }
      }
  }

Validation:
  - [ ] Build thành công
  - [ ] App launch không crash
  - [ ] Tab navigation hoạt động
```

### TASK 1.2: Dependency Injection Setup
```yaml
ID: P1-002
Tên: Setup Dependency System
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: P1-001
Thời gian ước tính: 2 giờ
Thời gian thực tế: 1.5 giờ
Hoàn thành: December 23, 2024

Deliverables:
  ✅ Sources/Core/Dependencies/NetworkClientKey.swift
  ✅ Sources/Core/Dependencies/StorageKey.swift
  ✅ Sources/Core/Dependencies/AnalyticsKey.swift
  ✅ Protocol-based design (Sendable)
  ✅ Live + Mock implementations
  ✅ DependencyKey registration
  ✅ @Dependency property wrapper usage

Mô tả: |
  Tạo hệ thống dependency injection theo TCA

Files cần tạo:
  1. Sources/Loi/TiemPhuThuoc/KhachMangKey.swift
  2. Sources/Loi/TiemPhuThuoc/LuuTruKey.swift
  3. Sources/Loi/TiemPhuThuoc/KeychainKey.swift
  4. Sources/Loi/TiemPhuThuoc/PhanTichKey.swift

Code mẫu KhachMangKey.swift: |
  import ComposableArchitecture
  
  // MARK: - Protocol
  public protocol GiaoThucKhachMang: Sendable {
      func request<T: Decodable>(_ endpoint: DiemCuoi) async throws -> T
      func upload(_ data: Data, to endpoint: DiemCuoi) async throws -> URL
  }
  
  // MARK: - Live Implementation
  public struct KhachMangThuc: GiaoThucKhachMang {
      public init() {}
      
      public func request<T: Decodable>(_ endpoint: DiemCuoi) async throws -> T {
          // Real implementation với Moya
      }
      
      public func upload(_ data: Data, to endpoint: DiemCuoi) async throws -> URL {
          // Real implementation
      }
  }
  
  // MARK: - Test Implementation
  public struct KhachMangGia: GiaoThucKhachMang {
      public var ketQuaRequest: Any?
      public var loiRequest: Error?
      
      public init() {}
      
      public func request<T: Decodable>(_ endpoint: DiemCuoi) async throws -> T {
          if let loi = loiRequest { throw loi }
          guard let ketQua = ketQuaRequest as? T else {
              throw NSError(domain: "Test", code: 0)
          }
          return ketQua
      }
      
      public func upload(_ data: Data, to endpoint: DiemCuoi) async throws -> URL {
          URL(string: "https://example.com/uploaded")!
      }
  }
  
  // MARK: - Dependency Key
  public struct KhachMangKey: DependencyKey {
      public static let liveValue: GiaoThucKhachMang = KhachMangThuc()
      public static let testValue: GiaoThucKhachMang = KhachMangGia()
      public static let previewValue: GiaoThucKhachMang = KhachMangGia()
  }
  
  extension DependencyValues {
      public var khachMang: GiaoThucKhachMang {
          get { self[KhachMangKey.self] }
          set { self[KhachMangKey.self] = newValue }
      }
  }

Validation:
  - [ ] @Dependency inject được
  - [ ] Test có thể override dependency
  - [ ] Preview dùng được mock
```

### TASK 1.3: Navigation System
```yaml
ID: P1-003
Tên: Tạo Navigation Architecture
Trạng thái: ✅ HOÀN THÀNH
Ưu tiên: P0 (Critical)
Phụ thuộc: P1-001
Thời gian ước tính: 3 giờ
Thời gian thực tế: 2.5 giờ
Hoàn thành: December 23, 2024

Deliverables:
  ✅ Sources/Core/Navigation/Destination.swift (11 common screens)
  ✅ Sources/Core/Navigation/DeepLink.swift (URL parsing)
  ✅ NavigationStack integration (SwiftUI native)
  ✅ Modal presentation với custom Binding
  ✅ Deep linking support (myapp://settings, etc.)
  ✅ @CasePathable for actions
  ✅ Common screens only: Settings, Policy, Onboarding, About
  ✅ Removed business-specific screens

Notes:
  - Template design: Chỉ common features, không business logic
  - TCA 1.23+ pattern: NavigationLink(value:) + .navigationDestination(for:)
  - Custom Binding cho modal (store là get-only)
  - Destination conform Identifiable cho .sheet(item:)

Mô tả: |
  Tạo hệ thống navigation với Tab + Stack

Files cần tạo:
  1. Sources/Loi/DieuHuong/DiemDen.swift
  2. Sources/Loi/DieuHuong/BoQuanLyDieuHuong.swift
  3. Sources/UngDung/RootView.swift (update)
  4. Sources/UngDung/MainTabView.swift

Code DiemDen.swift: |
  import Foundation
  
  public enum DiemDen: Hashable {
      // Auth
      case dangNhap
      case dangKy
      case quenMatKhau
      
      // Main
      case chiTietSanPham(id: String)
      case hoSoNguoiDung(id: String)
      case caiDat
      case thongTinCaNhan
      case doiMatKhau
      
      // Common
      case webView(url: URL)
      case hinhAnhToanManHinh(url: URL)
  }

Code MainTabView.swift: |
  import ComposableArchitecture
  import SwiftUI
  
  struct MainTabView: View {
      @Bindable var store: StoreOf<BoGiamUngDung>
      
      var body: some View {
          TabView(selection: $store.tabHienTai.sending(\.tabThayDoi)) {
              NavigationStack {
                  TrangChuView(store: store.scope(state: \.trangChu, action: \.trangChu))
              }
              .tabItem {
                  Label("Trang chủ", systemImage: "house")
              }
              .tag(TrangThaiUngDung.Tab.trangChu)
              
              NavigationStack {
                  TimKiemView(store: store.scope(state: \.timKiem, action: \.timKiem))
              }
              .tabItem {
                  Label("Tìm kiếm", systemImage: "magnifyingglass")
              }
              .tag(TrangThaiUngDung.Tab.timKiem)
              
              NavigationStack {
                  CaiDatView(store: store.scope(state: \.caiDat, action: \.caiDat))
              }
              .tabItem {
                  Label("Cài đặt", systemImage: "gear")
              }
              .tag(TrangThaiUngDung.Tab.caiDat)
          }
      }
  }

Validation:
  - [ ] Tab navigation hoạt động
  - [ ] NavigationStack push/pop đúng
  - [ ] Deep linking hoạt động
```

### TASK 1.4: Theme System
```yaml
ID: P1-004
Tên: Tạo Design System
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P0-003
Thời gian ước tính: 3 giờ

Mô tả: |
  Tạo theme system với colors, fonts, spacing

Files cần tạo:
  1. Sources/GiaoDien/ChuDe/MauSac.swift
  2. Sources/GiaoDien/ChuDe/KieuChu.swift
  3. Sources/GiaoDien/ChuDe/KhoangCach.swift
  4. Sources/GiaoDien/ChuDe/ChuDe.swift
  5. Resources/Assets.xcassets/Colors/

Code MauSac.swift: |
  import SwiftUI
  
  public enum MauSac {
      // MARK: - Primary
      public static let chinh = Color("Primary", bundle: .module)
      public static let chinhNhat = Color("PrimaryLight", bundle: .module)
      public static let chinhDam = Color("PrimaryDark", bundle: .module)
      
      // MARK: - Secondary
      public static let phu = Color("Secondary", bundle: .module)
      
      // MARK: - Semantic
      public static let thanhCong = Color("Success", bundle: .module)
      public static let canhBao = Color("Warning", bundle: .module)
      public static let loi = Color("Error", bundle: .module)
      public static let thongTin = Color("Info", bundle: .module)
      
      // MARK: - Background
      public static let nen = Color("Background", bundle: .module)
      public static let nenPhu = Color("BackgroundSecondary", bundle: .module)
      public static let beMat = Color("Surface", bundle: .module)
      
      // MARK: - Text
      public static let chuChinh = Color("TextPrimary", bundle: .module)
      public static let chuPhu = Color("TextSecondary", bundle: .module)
      public static let chuMo = Color("TextTertiary", bundle: .module)
      
      // MARK: - Border
      public static let vien = Color("Border", bundle: .module)
      public static let vienNhat = Color("BorderLight", bundle: .module)
  }

Code KhoangCach.swift: |
  import SwiftUI
  
  public enum KhoangCach {
      /// 4pt
      public static let xxxNho: CGFloat = 4
      /// 8pt
      public static let xxNho: CGFloat = 8
      /// 12pt
      public static let xNho: CGFloat = 12
      /// 16pt
      public static let nho: CGFloat = 16
      /// 20pt
      public static let trungBinh: CGFloat = 20
      /// 24pt
      public static let lon: CGFloat = 24
      /// 32pt
      public static let xLon: CGFloat = 32
      /// 48pt
      public static let xxLon: CGFloat = 48
      /// 64pt
      public static let xxxLon: CGFloat = 64
  }

Validation:
  - [ ] Dark mode tự động switch
  - [ ] Dynamic Type hoạt động
  - [ ] Colors nhất quán
```

### TASK 1.5: UI Components Library
```yaml
ID: P1-005
Tên: Tạo Base UI Components
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P1-004
Thời gian ước tính: 4 giờ

Mô tả: |
  Tạo thư viện UI components tái sử dụng

Files cần tạo:
  1. Sources/GiaoDien/ThanhPhan/Nut/NutChinh.swift
  2. Sources/GiaoDien/ThanhPhan/Nut/NutPhu.swift
  3. Sources/GiaoDien/ThanhPhan/TruongNhap/TruongNhapLieu.swift
  4. Sources/GiaoDien/ThanhPhan/TruongNhap/TruongMatKhau.swift
  5. Sources/GiaoDien/ThanhPhan/The/TheSanPham.swift
  6. Sources/GiaoDien/ThanhPhan/TrangThai/KhungNhinDangTai.swift
  7. Sources/GiaoDien/ThanhPhan/TrangThai/KhungNhinTrong.swift
  8. Sources/GiaoDien/ThanhPhan/TrangThai/KhungNhinLoi.swift

Code NutChinh.swift: |
  import SwiftUI
  
  public struct NutChinh: View {
      let tieuDe: String
      let dangTai: Bool
      let tatChuc: Bool
      let hanhDong: () -> Void
      
      public init(
          _ tieuDe: String,
          dangTai: Bool = false,
          tatChuc: Bool = false,
          hanhDong: @escaping () -> Void
      ) {
          self.tieuDe = tieuDe
          self.dangTai = dangTai
          self.tatChuc = tatChuc
          self.hanhDong = hanhDong
      }
      
      public var body: some View {
          Button(action: hanhDong) {
              HStack(spacing: KhoangCach.xxNho) {
                  if dangTai {
                      ProgressView()
                          .tint(.white)
                  }
                  Text(tieuDe)
                      .font(.headline)
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, KhoangCach.nho)
              .background(tatChuc ? MauSac.chuMo : MauSac.chinh)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
          .disabled(tatChuc || dangTai)
      }
  }
  
  #Preview {
      VStack(spacing: 16) {
          NutChinh("Đăng nhập") {}
          NutChinh("Đang tải...", dangTai: true) {}
          NutChinh("Tắt chức năng", tatChuc: true) {}
      }
      .padding()
  }

Validation:
  - [ ] Components có Preview
  - [ ] Dark/Light mode OK
  - [ ] Accessibility OK
```

### TASK 1.6: Storage Wrappers
```yaml
ID: P1-006
Tên: Tạo Storage Wrappers
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P0-003
Thời gian ước tính: 2 giờ

Mô tả: |
  Tạo wrappers cho UserDefaults và Keychain

Files cần tạo:
  1. Sources/Loi/LuuTru/LuuTruNguoiDung.swift
  2. Sources/Loi/LuuTru/KeychainBaoBoc.swift
  3. Sources/Loi/LuuTru/KhoaLuuTru.swift

Code LuuTruNguoiDung.swift: |
  import Foundation
  
  @propertyWrapper
  public struct LuuTruNguoiDung<T: Codable> {
      private let khoa: String
      private let giaTriMacDinh: T
      private let userDefaults: UserDefaults
      
      public init(
          _ khoa: String,
          giaTriMacDinh: T,
          userDefaults: UserDefaults = .standard
      ) {
          self.khoa = khoa
          self.giaTriMacDinh = giaTriMacDinh
          self.userDefaults = userDefaults
      }
      
      public var wrappedValue: T {
          get {
              guard let data = userDefaults.data(forKey: khoa),
                    let value = try? JSONDecoder().decode(T.self, from: data) else {
                  return giaTriMacDinh
              }
              return value
          }
          set {
              if let data = try? JSONEncoder().encode(newValue) {
                  userDefaults.set(data, forKey: khoa)
              }
          }
      }
  }
  
  // Usage example:
  // @LuuTruNguoiDung("user.name", giaTriMacDinh: "")
  // var tenNguoiDung: String

Code KeychainBaoBoc.swift: |
  import Foundation
  import KeychainAccess
  
  public actor KeychainBaoBoc {
      private let keychain: Keychain
      
      public init(service: String = Bundle.main.bundleIdentifier ?? "com.template.ios") {
          self.keychain = Keychain(service: service)
      }
      
      public enum Khoa: String {
          case accessToken = "access_token"
          case refreshToken = "refresh_token"
          case userId = "user_id"
          case pinCode = "pin_code"
      }
      
      public func luu(_ giaTri: String, choKhoa khoa: Khoa) throws {
          try keychain.set(giaTri, key: khoa.rawValue)
      }
      
      public func lay(_ khoa: Khoa) throws -> String? {
          try keychain.get(khoa.rawValue)
      }
      
      public func xoa(_ khoa: Khoa) throws {
          try keychain.remove(khoa.rawValue)
      }
      
      public func xoaTatCa() throws {
          try keychain.removeAll()
      }
  }

Validation:
  - [ ] Save/Load hoạt động
  - [ ] Keychain bảo mật
  - [ ] Handle errors
```

---

## 🔵 PHASE 2: CORE SERVICES

### TASK 2.1: Network Layer
```yaml
ID: P2-001
Tên: Tạo Network Client với Moya
Trạng thái: ⬜ Chưa làm
Ưu tiên: P0 (Critical)
Phụ thuộc: P1-002
Thời gian ước tính: 4 giờ

Files cần tạo:
  1. Sources/Loi/Mang/DiemCuoi.swift
  2. Sources/Loi/Mang/KhachMangThuc.swift
  3. Sources/Loi/Mang/LoiMang.swift
  4. Sources/Loi/Mang/Interceptor/AuthInterceptor.swift
  5. Sources/Loi/Mang/Interceptor/LoggingInterceptor.swift
```

### TASK 2.2: Database Layer
```yaml
ID: P2-002
Tên: Setup Core Data / SwiftData
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P0-003
Thời gian ước tính: 3 giờ
```

### TASK 2.3: Cache System
```yaml
ID: P2-003
Tên: Implement Cache Layer
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P2-002
Thời gian ước tính: 2 giờ
```

### TASK 2.4: Error Handling
```yaml
ID: P2-004
Tên: Tạo Error Handling System
Trạng thái: ⬜ Chưa làm
Ưu tiên: P0 (Critical)
Phụ thuộc: P1-001
Thời gian ước tính: 2 giờ
```

---

## 🔵 PHASE 3: FIREBASE INTEGRATION

### TASK 3.1: Firebase Setup
```yaml
ID: P3-001
Tên: Tích hợp Firebase SDK
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P0-003
Thời gian ước tính: 2 giờ
```

### TASK 3.2: Analytics Service
```yaml
ID: P3-002
Tên: Implement Analytics
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P3-001
Thời gian ước tính: 2 giờ
```

### TASK 3.3: Crashlytics
```yaml
ID: P3-003
Tên: Setup Crashlytics
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P3-001
Thời gian ước tính: 1 giờ
```

### TASK 3.4: Remote Config
```yaml
ID: P3-004
Tên: Implement Remote Config
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P3-001
Thời gian ước tính: 2 giờ
```

### TASK 3.5: Push Notifications
```yaml
ID: P3-005
Tên: Setup FCM
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P3-001
Thời gian ước tính: 3 giờ
```

---

## 🔵 PHASE 4: FEATURES

### TASK 4.1: Authentication Feature
```yaml
ID: P4-001
Tên: Tạo Auth Module hoàn chỉnh
Trạng thái: ⬜ Chưa làm
Ưu tiên: P0 (Critical)
Phụ thuộc: P1-003, P2-001
Thời gian ước tính: 8 giờ

Files cần tạo:
  - TinhNang/XacThuc/DangNhap/DangNhapReducer.swift
  - TinhNang/XacThuc/DangNhap/DangNhapView.swift
  - TinhNang/XacThuc/DangKy/DangKyReducer.swift
  - TinhNang/XacThuc/DangKy/DangKyView.swift
  - TinhNang/XacThuc/QuenMatKhau/QuenMatKhauReducer.swift
  - TinhNang/XacThuc/QuenMatKhau/QuenMatKhauView.swift
  - DichVu/XacThuc/DichVuXacThuc.swift
  - DichVu/XacThuc/NhaCungCap/GoogleAuth.swift
  - DichVu/XacThuc/NhaCungCap/AppleAuth.swift
```

### TASK 4.2: Onboarding Feature
```yaml
ID: P4-002
Tên: Tạo Onboarding Flow
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P1-005
Thời gian ước tính: 4 giờ
```

### TASK 4.3: Home Feature
```yaml
ID: P4-003
Tên: Tạo Home Screen
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P1-003
Thời gian ước tính: 4 giờ
```

### TASK 4.4: Settings Feature
```yaml
ID: P4-004
Tên: Tạo Settings Screen
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P1-006
Thời gian ước tính: 4 giờ
```

### TASK 4.5: Profile Feature
```yaml
ID: P4-005
Tên: Tạo Profile Screen
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P4-001
Thời gian ước tính: 3 giờ
```

---

## 🔵 PHASE 5: MONETIZATION

### TASK 5.1: In-App Purchase
```yaml
ID: P5-001
Tên: Tích hợp StoreKit 2
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P4-001
Thời gian ước tính: 6 giờ
```

### TASK 5.2: AdMob Integration
```yaml
ID: P5-002
Tên: Tích hợp Google AdMob
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P3-001
Thời gian ước tính: 4 giờ
```

---

## 🔵 PHASE 6: TESTING

### TASK 6.1: Unit Tests
```yaml
ID: P6-001
Tên: Viết Unit Tests cho Reducers
Trạng thái: ⬜ Chưa làm
Ưu tiên: P1 (High)
Phụ thuộc: P4-001
Thời gian ước tính: 6 giờ
```

### TASK 6.2: UI Tests
```yaml
ID: P6-002
Tên: Viết UI Tests cho Critical Paths
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P4-001
Thời gian ước tính: 4 giờ
```

---

## 🔵 PHASE 7: DOCUMENTATION & CI/CD

### TASK 7.1: CI/CD Pipeline
```yaml
ID: P7-001
Tên: Setup GitHub Actions
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: P6-001
Thời gian ước tính: 3 giờ
```

### TASK 7.2: API Documentation
```yaml
ID: P7-002
Tên: Generate API Docs
Trạng thái: ⬜ Chưa làm
Ưu tiên: P2 (Medium)
Phụ thuộc: All features
Thời gian ước tính: 2 giờ
```

---

## 📊 TỔNG KẾT

| Phase | Số tasks | Ưu tiên P0 | Ưu tiên P1 | Ưu tiên P2 |
|-------|----------|------------|------------|------------|
| Phase 0 | 4 | 3 | 1 | 0 |
| Phase 1 | 6 | 3 | 3 | 0 |
| Phase 2 | 4 | 2 | 1 | 1 |
| Phase 3 | 5 | 0 | 3 | 2 |
| Phase 4 | 5 | 1 | 3 | 1 |
| Phase 5 | 2 | 0 | 1 | 1 |
| Phase 6 | 2 | 0 | 1 | 1 |
| Phase 7 | 2 | 0 | 0 | 2 |
| **TỔNG** | **30** | **9** | **13** | **8** |

**Thời gian ước tính tổng: ~80 giờ (10 ngày làm việc)**

---

*File này cần được cập nhật khi hoàn thành task. AI agent nên đánh dấu task đã hoàn thành.*
