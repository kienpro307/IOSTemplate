# 🔧 Mô-đun LOI (Core Module)

## Tổng Quan
Module LOI là nền tảng của toàn bộ ứng dụng, không phụ thuộc module nào khác.

## Cấu Trúc
```
Loi/
├── KienTruc/           # TCA base setup
├── TiemPhuThuoc/       # Dependency injection
├── Mang/               # Networking (Moya)
├── LuuTru/             # Storage wrappers
├── CSDuLieu/           # Database (Core Data)
├── BoNhoDem/           # Caching
├── TienIch/            # Utilities & Extensions
├── NhatKy/             # Logging
└── Loi/                # Error types
```

## Dependencies
- ComposableArchitecture 1.15+
- Moya 15.0+
- KeychainAccess 4.2+

## Public APIs
- `KhachMang` - HTTP client protocol và implementation
- `LuuTru` - UserDefaults property wrapper
- `KeychainBaoBoc` - Keychain wrapper
- `LoiUngDung` - Unified error types
- `BoGhiNhatKy` - Logger service
