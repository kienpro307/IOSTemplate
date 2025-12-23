# Cấu trúc File/Folder

## Project Structure

```
Sources/
├── App/                    # App entry point
│   ├── Main.swift
│   └── RootView.swift
├── Core/                   # Core layer
│   ├── Architecture/       # TCA root
│   ├── Dependencies/       # DI keys
│   └── Navigation/         # Navigation
├── Features/               # Feature modules
│   └── {Feature}/
│       ├── {Feature}Reducer.swift
│       ├── {Feature}View.swift
│       ├── Components/
│       └── Models/
├── Services/               # Business services
└── UI/                     # Shared UI components
```

## Single Feature Structure

```
Features/
└── Home/
    ├── HomeReducer.swift      # TCA Reducer
    ├── HomeView.swift         # SwiftUI View
    ├── Components/            # Feature-specific UI
    │   ├── HomeHeader.swift
    │   └── HomeCard.swift
    └── Models/                # Feature-specific models
        └── HomeItem.swift
```

## Multi-Module Package

```
Package/
├── Package.swift
├── Sources/
│   └── ModuleName/
│       ├── Public/           # Public API
│       └── Internal/         # Internal implementation
└── Tests/
    └── ModuleNameTests/
```

## 4-Tier Architecture

```
TIER 4: APPS        → XTranslate, BankingApp
TIER 3: DOMAIN      → XTranslateKit, BankingKit  
TIER 2: SERVICES    → iOSMonetizationKit, iOSAnalyticsKit
TIER 1: FOUNDATION  → iOSLocationKit, iOSRemoteConfigKit
```

Dependency flow: **Tier 4 → 3 → 2 → 1** (higher can depend on lower only)

## Chi tiết

Xem: `ios-template-docs/01-KIEN-TRUC/08-MULTI-MODULE-ARCHITECTURE.md`

