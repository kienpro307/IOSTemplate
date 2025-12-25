# Theme & UI Components

Hướng dẫn sử dụng Design System trong iOS Template.

---

## Colors

### Usage

```swift
import UI

Text("Hello")
    .foregroundColor(Colors.primary)
    .background(Colors.surface)
```

### Available Colors

| Color | Usage |
|-------|-------|
| `Colors.primary` | Brand color |
| `Colors.secondary` | Secondary actions |
| `Colors.background` | Screen background |
| `Colors.surface` | Card/surface background |
| `Colors.textPrimary` | Main text |
| `Colors.textSecondary` | Secondary text |
| `Colors.error` | Error states |
| `Colors.success` | Success states |

---

## Typography

### Usage

```swift
Text("Headline")
    .font(Typography.headlineLarge)

Text("Body text")
    .font(Typography.bodyMedium)
```

### Scale

| Style | Size | Usage |
|-------|------|-------|
| `displayLarge` | 57pt | Hero text |
| `headlineLarge` | 32pt | Page titles |
| `titleLarge` | 22pt | Card titles |
| `bodyLarge` | 16pt | Body text |
| `bodyMedium` | 14pt | Body text |
| `labelMedium` | 12pt | Labels |

---

## Spacing

### Usage

```swift
VStack(spacing: Spacing.medium) {
    Text("Title")
    Text("Content")
}
.padding(Spacing.large)
```

### Values (4pt grid)

| Constant | Value | Usage |
|----------|-------|-------|
| `Spacing.xxs` | 4pt | Tight spacing |
| `Spacing.xs` | 8pt | Small gaps |
| `Spacing.small` | 12pt | Default spacing |
| `Spacing.medium` | 16pt | Content padding |
| `Spacing.large` | 24pt | Section spacing |
| `Spacing.xlarge` | 32pt | Large gaps |

---

## Components

### Buttons

```swift
Button("Primary") {
    // Action
}
.buttonStyle(.primary)

Button("Secondary") {
    // Action
}
.buttonStyle(.secondary)
```

### Loading View

```swift
if isLoading {
    LoadingView()
}
```

---

## Xem Thêm

- [Cấu Trúc Dự Án](../01-BAT-DAU/02-CAU-TRUC-DU-AN.md)

