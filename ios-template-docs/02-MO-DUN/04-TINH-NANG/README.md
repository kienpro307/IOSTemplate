# 🚀 Mô-đun FEATURES (Features Module)

## Tổng Quan
Module chứa các business features của app.

## Cấu Trúc
```
Features/
├── Onboarding/          # Onboarding flow
├── Home/                # Home screen
├── Search/              # Search feature (optional)
├── Notifications/       # Notifications (optional)
└── Settings/            # Settings
```

**Lưu ý:**
- App **KHÔNG** có Authentication
- App **KHÔNG** có Profile

## Feature Template
```
FeatureName/
├── [Feature]Reducer.swift   # State, Action, Reducer
├── [Feature]View.swift      # Main view
├── Components/              # Feature components
└── Models/                  # Feature models
```

## Lưu Ý
- Code dùng tiếng Anh
- Comment dùng tiếng Việt
- App **KHÔNG** có authentication
- App **KHÔNG** có profile
