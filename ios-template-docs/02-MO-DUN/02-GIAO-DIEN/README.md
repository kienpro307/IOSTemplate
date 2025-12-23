# 🎨 Mô-đun GIAO DIEN (UI Module)

## Tổng Quan
Module UI chứa Design System và reusable components.

## Cấu Trúc
```
GiaoDien/
├── ChuDe/              # Theme System
│   ├── MauSac.swift    # Colors
│   ├── KieuChu.swift   # Typography
│   └── KhoangCach.swift # Spacing
├── ThanhPhan/          # Components
│   ├── Nut/            # Buttons
│   ├── TruongNhap/     # Text fields
│   ├── The/            # Cards
│   ├── DanhSach/       # Lists
│   └── TrangThai/      # Loading, Empty, Error
├── BoSuaDoi/           # View Modifiers
└── HieuUng/            # Animations
```

## Usage
```swift
import GiaoDien

// Button
NutChinh(tieuDe: "Đăng nhập") { }

// Theme colors
Color.mauChinh
```
