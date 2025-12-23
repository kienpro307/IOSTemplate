# 🌍 Đa Ngôn Ngữ (Localization)

## Supported Languages
- Vietnamese (vi) - Default
- English (en)
- More as needed

## Structure
```
Resources/
├── Localizable.xcstrings  # iOS 17+ String Catalogs
├── en.lproj/
│   └── Localizable.strings
└── vi.lproj/
    └── Localizable.strings
```

## Usage
```swift
// String catalog
Text("welcome_message")

// With parameters
Text("hello_user \(name)")

// Pluralization
Text("items_count \(count)")
```

## In-app Language Switch
```swift
@LuuTru(key: "ngon_ngu") var ngonNgu: NgonNgu = .tiengViet

// Apply
Bundle.setLanguage(ngonNgu.code)
```
