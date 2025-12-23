# Theme - Design System & UI Tokens

## Tổng quan

Thư mục `Theme/` chứa toàn bộ **Design System** của app - colors, typography, spacing, và component styles. Đây là single source of truth cho visual consistency và brand identity.

### Chức năng chính
- Centralized color palette với dark/light mode support
- Typography system với Dynamic Type support
- Spacing system based on 4pt grid
- Reusable button styles và component patterns
- Theme tokens cho toàn bộ UI
- Consistent design language

### Tác động đến toàn bộ app
- **Critical Impact**: Mọi UI element phụ thuộc vào Theme layer
- Quyết định visual identity và brand của app
- Ảnh hưởng đến accessibility (contrast, font sizes)
- Enable easy theming và white-labeling
- Ensure design consistency across features

---

## Cấu trúc Files

```
Theme/
├── Colors.swift                  # Color palette (227 dòng)
├── Typography.swift              # Font system (234 dòng)
├── Spacing.swift                 # Spacing & layout (306 dòng)
└── Components/
    └── ButtonStyles.swift        # Button styles (227 dòng)
```

**Tổng cộng**: 994 dòng code, 4 files

---

## Chi tiết các Files

### 1. Colors.swift (227 dòng)

**Chức năng**: Color palette với automatic dark/light mode support

#### Color.Theme (dòng 7-81)

Centralized color tokens sử dụng Asset Catalog.

##### Primary Colors (dòng 10-17)

```swift
public static let primary = Color("Primary", bundle: .module)
public static let secondary = Color("Secondary", bundle: .module)
public static let accent = Color("Accent", bundle: .module)
```

**Usage**:
- `primary` - Brand color chính (buttons, links)
- `secondary` - Secondary brand color
- `accent` - Highlights và focus states

##### Background Colors (dòng 21-28)

```swift
public static let background = Color("Background", bundle: .module)
public static let backgroundSecondary = Color("BackgroundSecondary", bundle: .module)
public static let backgroundTertiary = Color("BackgroundTertiary", bundle: .module)
```

**Hierarchy**:
- `background` - Main app background
- `backgroundSecondary` - Cards, sections
- `backgroundTertiary` - Subtle differentiation

##### Surface Colors (dòng 32-36)

```swift
public static let surface = Color("Surface", bundle: .module)
public static let surfaceVariant = Color("SurfaceVariant", bundle: .module)
```

**Usage**: Elevated elements (modals, dialogs)

##### Text Colors (dòng 40-50)

```swift
public static let textPrimary = Color("TextPrimary", bundle: .module)
public static let textSecondary = Color("TextSecondary", bundle: .module)
public static let textTertiary = Color("TextTertiary", bundle: .module)
public static let textDisabled = Color("TextDisabled", bundle: .module)
```

**Opacity levels**:
- `textPrimary` - 100% emphasis
- `textSecondary` - 70% emphasis
- `textTertiary` - 50% emphasis
- `textDisabled` - 38% emphasis

##### Semantic Colors (dòng 54-64)

```swift
public static let success = Color("Success", bundle: .module)
public static let warning = Color("Warning", bundle: .module)
public static let error = Color("Error", bundle: .module)
public static let info = Color("Info", bundle: .module)
```

**Usage**:
- `success` - Success states (green)
- `warning` - Warning states (yellow/orange)
- `error` - Error states (red)
- `info` - Information (blue)

##### Border Colors (dòng 68-72)

```swift
public static let border = Color("Border", bundle: .module)
public static let borderLight = Color("BorderLight", bundle: .module)
```

##### Overlay Colors (dòng 76-80)

```swift
public static let overlay = Color.black.opacity(0.5)
public static let scrim = Color.black.opacity(0.3)
```

**Usage**: Backgrounds cho modals và sheets

#### Convenience Extension (dòng 86-91)

```swift
public extension Color {
    static var theme: Color.Theme.Type {
        Color.Theme.self
    }
}
```

**Usage**:
```swift
Text("Hello")
    .foregroundColor(.theme.textPrimary)
    .background(.theme.backgroundSecondary)
```

#### UIColor Extensions (dòng 95-117)

UIKit interoperability.

```swift
public extension UIColor {
    enum Theme {
        public static let primary = UIColor(Color.theme.primary)
        public static let secondary = UIColor(Color.theme.secondary)
        // ...
    }
}
```

**Usage** (in UIKit):
```swift
view.backgroundColor = UIColor.Theme.background
label.textColor = UIColor.Theme.textPrimary
```

#### Color Utilities (dòng 121-180)

##### Hex Color Init (dòng 124-148)

```swift
init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)

    let r, g, b, a: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
        (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
    case 6: // RGB (24-bit)
        (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
    case 8: // ARGB (32-bit)
        (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
        (r, g, b, a) = (0, 0, 0, 255)
    }

    self.init(
        .sRGB,
        red: Double(r) / 255,
        green: Double(g) / 255,
        blue:  Double(b) / 255,
        opacity: Double(a) / 255
    )
}
```

**Usage**:
```swift
let color1 = Color(hex: "#FF5733")
let color2 = Color(hex: "FF5733")
let color3 = Color(hex: "F57")       // 12-bit
let color4 = Color(hex: "FF5733AA")  // With alpha
```

##### Lighten/Darken (dòng 151-158)

```swift
func lighter(by percentage: Double = 0.3) -> Color {
    self.adjust(by: abs(percentage))
}

func darker(by percentage: Double = 0.3) -> Color {
    self.adjust(by: -abs(percentage))
}
```

**Usage**:
```swift
let lightPrimary = Color.theme.primary.lighter(by: 0.2)
let darkPrimary = Color.theme.primary.darker(by: 0.2)
```

#### Semantic Color Sets (dòng 185-226)

Predefined color combinations.

##### `ColorSet` enum (dòng 185-213)

```swift
public enum ColorSet {
    public static let success = ColorSetModel(
        foreground: .theme.success,
        background: Color.theme.success.opacity(0.1),
        border: .theme.success
    )

    public static let warning = ColorSetModel(...)
    public static let error = ColorSetModel(...)
    public static let info = ColorSetModel(...)
}
```

##### `ColorSetModel` (dòng 216-226)

```swift
public struct ColorSetModel {
    public let foreground: Color
    public let background: Color
    public let border: Color
}
```

**Usage**:
```swift
// Success badge
Text("Success")
    .foregroundColor(ColorSet.success.foreground)
    .padding()
    .background(ColorSet.success.background)
    .overlay(
        RoundedRectangle(cornerRadius: 8)
            .stroke(ColorSet.success.border, lineWidth: 1)
    )
```

---

### 2. Typography.swift (234 dòng)

**Chức năng**: Typography system với Dynamic Type support

#### Font.Theme (dòng 7-89)

Comprehensive font scale.

##### Display Fonts (dòng 10-17)

Largest text styles for hero sections.

```swift
public static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
public static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
public static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
```

**Usage**: Landing pages, splash screens

##### Headline Fonts (dòng 21-28)

Main section titles.

```swift
public static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
public static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
public static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
```

**Usage**: Page titles, section headers

##### Title Fonts (dòng 32-39)

Subsection titles.

```swift
public static let titleLarge = Font.system(size: 22, weight: .medium, design: .default)
public static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
public static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
```

**Usage**: Card titles, list headers

##### Body Fonts (dòng 43-50)

Main content text.

```swift
public static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
public static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
```

**Usage**: Paragraphs, descriptions

##### Label Fonts (dòng 54-61)

UI labels và buttons.

```swift
public static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
public static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
```

**Usage**: Button text, form labels

##### Caption Fonts (dòng 65-69)

Auxiliary text.

```swift
public static let caption = Font.system(size: 12, weight: .regular, design: .default)
public static let overline = Font.system(size: 10, weight: .medium, design: .default).uppercaseSmallCaps()
```

**Usage**: Timestamps, metadata

##### Monospace Fonts (dòng 73-77)

Code display.

```swift
public static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
public static let codeSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
```

**Usage**: Code snippets, technical data

##### Aliases (dòng 81-88)

```swift
public static let title = titleLarge
public static let body = bodyLarge
public static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)
```

#### Convenience Extension (dòng 94-99)

```swift
public extension Font {
    static var theme: Font.Theme.Type {
        Font.Theme.self
    }
}
```

**Usage**:
```swift
Text("Title")
    .font(.theme.headlineLarge)
```

#### TextStyle (dòng 104-175)

Predefined text styles với color, spacing, kerning.

##### TextStyle struct (dòng 104-120)

```swift
public struct TextStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    let kerning: CGFloat

    public init(
        font: Font,
        color: Color = .theme.textPrimary,
        lineSpacing: CGFloat = 0,
        kerning: CGFloat = 0
    ) {
        // ...
    }
}
```

##### Common Styles (dòng 125-175)

```swift
public static let pageTitle = TextStyle(
    font: .theme.displayLarge,
    color: .theme.textPrimary,
    lineSpacing: 4
)

public static let sectionHeader = TextStyle(
    font: .theme.headlineMedium,
    color: .theme.textPrimary,
    lineSpacing: 2
)

public static let cardTitle = TextStyle(
    font: .theme.titleLarge,
    color: .theme.textPrimary
)

public static let body = TextStyle(
    font: .theme.bodyLarge,
    color: .theme.textPrimary,
    lineSpacing: 4
)

public static let bodySecondary = TextStyle(
    font: .theme.bodyMedium,
    color: .theme.textSecondary,
    lineSpacing: 3
)

public static let caption = TextStyle(
    font: .theme.caption,
    color: .theme.textSecondary
)

public static let button = TextStyle(
    font: .theme.labelLarge,
    color: .white
)
```

#### View Extensions (dòng 179-188)

```swift
public extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .kerning(style.kerning)
    }
}
```

**Usage**:
```swift
Text("Welcome")
    .textStyle(.pageTitle)

VStack {
    Text("Section")
        .textStyle(.sectionHeader)
    Text("Content")
        .textStyle(.body)
}
```

#### Text Extensions (dòng 192-206)

```swift
public extension Text {
    func themeFont(_ font: Font) -> Text {
        self.font(font)
    }

    func style(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .kerning(style.kerning)
    }
}
```

---

### 3. Spacing.swift (306 dòng)

**Chức năng**: Spacing system based on 4pt grid

#### Spacing enum (dòng 5-83)

##### Base Spacing Values (dòng 8-30)

4pt increments.

```swift
public static let xs: CGFloat = 4      // 4pt
public static let sm: CGFloat = 8      // 8pt
public static let md: CGFloat = 12     // 12pt
public static let lg: CGFloat = 16     // 16pt (base unit)
public static let xl: CGFloat = 24     // 24pt
public static let xxl: CGFloat = 32    // 32pt
public static let xxxl: CGFloat = 48   // 48pt
public static let huge: CGFloat = 64   // 64pt
```

**4pt Grid System**:
- All spacing divisible by 4
- Consistent rhythm
- Easy to calculate

##### Semantic Spacing (dòng 34-50)

Named spacing for specific use cases.

```swift
public static let viewPadding: CGFloat = lg          // 16pt
public static let cardPadding: CGFloat = lg          // 16pt
public static let listItemPadding: CGFloat = md     // 12pt
public static let sectionSpacing: CGFloat = xl      // 24pt
public static let contentSpacing: CGFloat = lg      // 16pt
public static let compactSpacing: CGFloat = sm      // 8pt
```

##### Component-Specific (dòng 54-83)

EdgeInsets for components.

```swift
public static let buttonPadding = EdgeInsets(
    top: md,
    leading: xl,
    bottom: md,
    trailing: xl
)

public static let buttonSmallPadding = EdgeInsets(
    top: sm,
    leading: lg,
    bottom: sm,
    trailing: lg
)

public static let inputPadding = EdgeInsets(
    top: md,
    leading: lg,
    bottom: md,
    trailing: lg
)

public static let sheetPadding: CGFloat = xl
public static let navBarSpacing: CGFloat = lg
```

#### View Extensions (dòng 87-107)

```swift
public extension View {
    func standardPadding() -> some View {
        self.padding(Spacing.viewPadding)
    }

    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }

    func compactPadding() -> some View {
        self.padding(Spacing.compactSpacing)
    }

    func sectionSpacing() -> some View {
        self.padding(.vertical, Spacing.sectionSpacing)
    }
}
```

**Usage**:
```swift
VStack {
    Text("Title")
}
.standardPadding()
.background(.theme.surface)
```

#### EdgeInsets Extensions (dòng 111-151)

```swift
public extension EdgeInsets {
    static let standard = EdgeInsets(
        top: Spacing.lg,
        leading: Spacing.lg,
        bottom: Spacing.lg,
        trailing: Spacing.lg
    )

    static let horizontal = EdgeInsets(
        top: 0,
        leading: Spacing.lg,
        bottom: 0,
        trailing: Spacing.lg
    )

    static let vertical = EdgeInsets(
        top: Spacing.lg,
        leading: 0,
        bottom: Spacing.lg,
        trailing: 0
    )

    static let small = EdgeInsets(...)
    static let large = EdgeInsets(...)
}
```

#### Grid System (dòng 156-178)

12-column grid system.

```swift
public enum Grid {
    public static let columns = 12
    public static let gutter: CGFloat = Spacing.lg
    public static let halfGutter: CGFloat = Spacing.sm

    public static func columnWidth(span: Int, totalWidth: CGFloat) -> CGFloat {
        let gutterCount = CGFloat(columns - 1)
        let contentWidth = totalWidth - (gutterCount * gutter)
        let singleColumnWidth = contentWidth / CGFloat(columns)
        let spanGutters = CGFloat(span - 1) * gutter
        return (singleColumnWidth * CGFloat(span)) + spanGutters
    }
}
```

**Usage**:
```swift
let screenWidth: CGFloat = 375
let halfWidth = Grid.columnWidth(span: 6, totalWidth: screenWidth)
```

#### CornerRadius (dòng 183-218)

Border radius values.

```swift
public enum CornerRadius {
    public static let none: CGFloat = 0
    public static let sm: CGFloat = 4
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 12
    public static let xl: CGFloat = 16
    public static let circular: CGFloat = 9999

    // Semantic
    public static let button: CGFloat = md
    public static let card: CGFloat = lg
    public static let input: CGFloat = md
    public static let sheet: CGFloat = xl
    public static let chip: CGFloat = circular
}
```

**Usage**:
```swift
RoundedRectangle(cornerRadius: CornerRadius.card)
    .fill(.theme.surface)
```

#### BorderWidth (dòng 223-238)

```swift
public enum BorderWidth {
    public static let thin: CGFloat = 0.5
    public static let standard: CGFloat = 1
    public static let medium: CGFloat = 1.5
    public static let thick: CGFloat = 2
    public static let focus: CGFloat = 2
}
```

#### ShadowStyle (dòng 243-305)

Predefined shadow styles.

```swift
public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    // Predefined
    public static let none = ShadowStyle(radius: 0, y: 0)

    public static let sm = ShadowStyle(
        color: .black.opacity(0.05),
        radius: 2,
        y: 1
    )

    public static let md = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 4,
        y: 2
    )

    public static let lg = ShadowStyle(
        color: .black.opacity(0.15),
        radius: 8,
        y: 4
    )

    public static let xl = ShadowStyle(
        color: .black.opacity(0.2),
        radius: 16,
        y: 8
    )
}

public extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
```

**Usage**:
```swift
VStack {
    // Content
}
.background(.white)
.cornerRadius(CornerRadius.card)
.shadow(.md)
```

---

### 4. Components/ButtonStyles.swift (227 dòng)

**Chức năng**: Reusable button styles

#### PrimaryButtonStyle (dòng 6-53)

Main action buttons.

```swift
public struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isLoading: Bool

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }

            configuration.label
                .font(.theme.labelLarge)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.buttonPadding)
        .background(backgroundColor(configuration: configuration))
        .cornerRadius(CornerRadius.button)
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        .opacity(opacity)
        .disabled(!isEnabled || isLoading)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        if !isEnabled {
            return Color.theme.textDisabled
        }
        return configuration.isPressed
            ? Color.theme.primary.opacity(0.8)
            : Color.theme.primary
    }

    private var opacity: Double {
        if !isEnabled { return 0.6 }
        if isLoading { return 0.8 }
        return 1.0
    }
}
```

**Features**:
- Loading state với ProgressView
- Press animation (scale effect)
- Disabled state
- Full width option

#### SecondaryButtonStyle (dòng 58-85)

Secondary actions.

```swift
public struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.labelLarge)
            .foregroundColor(isEnabled ? .theme.primary : .theme.textDisabled)
            .frame(maxWidth: .infinity)
            .padding(Spacing.buttonPadding)
            .background(Color.theme.backgroundSecondary)
            .cornerRadius(CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .stroke(
                        isEnabled ? Color.theme.primary : Color.theme.border,
                        lineWidth: BorderWidth.standard
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}
```

**Features**:
- Outlined style
- Background color
- Border stroke

#### TertiaryButtonStyle (dòng 90-107)

Text-only buttons.

```swift
public struct TertiaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.labelLarge)
            .foregroundColor(isEnabled ? .theme.primary : .theme.textDisabled)
            .padding(.vertical, Spacing.sm)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}
```

**Usage**: Links, text buttons

#### DestructiveButtonStyle (dòng 112-136)

Dangerous actions.

```swift
public struct DestructiveButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.labelLarge)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Spacing.buttonPadding)
            .background(
                isEnabled
                    ? Color.theme.error
                    : Color.theme.textDisabled
            )
            .cornerRadius(CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}
```

**Usage**: Delete, logout, cancel subscription

#### SmallButtonStyle (dòng 141-164)

Compact buttons.

```swift
public struct SmallButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.labelMedium)
            .foregroundColor(.white)
            .padding(Spacing.buttonSmallPadding)
            .background(
                isEnabled
                    ? Color.theme.primary
                    : Color.theme.textDisabled
            )
            .cornerRadius(CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}
```

#### IconButtonStyle (dòng 169-192)

Icon-only circular buttons.

```swift
public struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    let isEnabled: Bool

    public init(size: CGFloat = 44, isEnabled: Bool = true) {
        self.size = size
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(isEnabled ? .theme.textPrimary : .theme.textDisabled)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.theme.backgroundSecondary)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}
```

**Usage**: Close buttons, action icons

#### Button Extensions (dòng 196-227)

Convenience methods.

```swift
public extension Button {
    func primaryButton(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading))
    }

    func secondaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
    }

    func tertiaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(TertiaryButtonStyle(isEnabled: isEnabled))
    }

    func destructiveButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(DestructiveButtonStyle(isEnabled: isEnabled))
    }

    func smallButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(SmallButtonStyle(isEnabled: isEnabled))
    }

    func iconButton(size: CGFloat = 44, isEnabled: Bool = true) -> some View {
        self.buttonStyle(IconButtonStyle(size: size, isEnabled: isEnabled))
    }
}
```

**Usage**:
```swift
Button("Login") {
    login()
}
.primaryButton(isLoading: isLoading)

Button("Cancel") {
    cancel()
}
.secondaryButton()

Button("Delete") {
    delete()
}
.destructiveButton()

Button {
    close()
} label: {
    Image(systemName: "xmark")
}
.iconButton()
```

---

## Cách các Files hoạt động cùng nhau

### Theme System Architecture

```
┌─────────────────────────────────────────────────────┐
│                SwiftUI Views                         │
│           (HomeView, ProfileView, etc.)             │
└────────────────────┬────────────────────────────────┘
                     │ Apply theme tokens
                     ▼
┌─────────────────────────────────────────────────────┐
│              Theme Layer                             │
│  ┌───────────┬────────────┬────────────┬─────────┐ │
│  │Colors     │Typography  │Spacing     │Buttons  │ │
│  └─────┬─────┴──────┬─────┴──────┬─────┴────┬────┘ │
└────────┼────────────┼────────────┼──────────┼──────┘
         │            │            │          │
         ▼            ▼            ▼          ▼
┌─────────────────────────────────────────────────────┐
│           Asset Catalog (Colors.xcassets)            │
│                                                      │
│  Primary (Light/Dark variants)                      │
│  Background (Light/Dark variants)                   │
│  Text colors (Light/Dark variants)                  │
│  Semantic colors (Success/Warning/Error)            │
└─────────────────────────────────────────────────────┘
```

### Example: Building a Card Component

```swift
struct ProfileCard: View {
    let name: String
    let bio: String
    let isOnline: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Text(name)
                    .font(.theme.titleLarge)
                    .foregroundColor(.theme.textPrimary)

                Spacer()

                // Status badge
                if isOnline {
                    Text("Online")
                        .font(.theme.labelSmall)
                        .foregroundColor(ColorSet.success.foreground)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(ColorSet.success.background)
                        .cornerRadius(CornerRadius.chip)
                }
            }

            // Bio
            Text(bio)
                .font(.theme.bodyMedium)
                .foregroundColor(.theme.textSecondary)
                .lineSpacing(4)

            // Action button
            Button("View Profile") {
                viewProfile()
            }
            .primaryButton()
        }
        .padding(Spacing.cardPadding)
        .background(.theme.backgroundSecondary)
        .cornerRadius(CornerRadius.card)
        .shadow(.md)
    }
}
```

**Theme tokens used**:
- Colors: `.theme.textPrimary`, `.theme.textSecondary`, `.theme.backgroundSecondary`
- Typography: `.theme.titleLarge`, `.theme.bodyMedium`, `.theme.labelSmall`
- Spacing: `Spacing.md`, `Spacing.sm`, `Spacing.xs`, `Spacing.cardPadding`
- Corner radius: `CornerRadius.card`, `CornerRadius.chip`
- Shadow: `ShadowStyle.md`
- Button: `PrimaryButtonStyle`
- Color set: `ColorSet.success`

---

## Usage Examples

### Example 1: Login Screen

```swift
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Logo
            Image("logo")
                .resizable()
                .frame(width: 120, height: 120)
                .padding(.bottom, Spacing.xxl)

            // Title
            Text("Welcome Back")
                .textStyle(.pageTitle)

            Text("Sign in to continue")
                .textStyle(.bodySecondary)

            // Input fields
            VStack(spacing: Spacing.lg) {
                TextField("Email", text: $email)
                    .padding(Spacing.inputPadding)
                    .background(.theme.backgroundSecondary)
                    .cornerRadius(CornerRadius.input)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.input)
                            .stroke(.theme.border, lineWidth: BorderWidth.standard)
                    )

                SecureField("Password", text: $password)
                    .padding(Spacing.inputPadding)
                    .background(.theme.backgroundSecondary)
                    .cornerRadius(CornerRadius.input)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.input)
                            .stroke(.theme.border, lineWidth: BorderWidth.standard)
                    )
            }

            // Buttons
            VStack(spacing: Spacing.md) {
                Button("Sign In") {
                    login()
                }
                .primaryButton(isLoading: isLoading)

                Button("Forgot Password?") {
                    resetPassword()
                }
                .tertiaryButton()
            }

            Spacer()

            // Sign up
            HStack {
                Text("Don't have an account?")
                    .textStyle(.bodySecondary)

                Button("Sign Up") {
                    signUp()
                }
                .tertiaryButton()
            }
        }
        .standardPadding()
        .background(.theme.background)
    }
}
```

### Example 2: Settings List

```swift
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false

    var body: some View {
        List {
            Section {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Receive push notifications"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                }

                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Enable dark theme"
                ) {
                    Toggle("", isOn: $darkModeEnabled)
                }
            } header: {
                Text("Preferences")
                    .font(.theme.labelMedium)
                    .foregroundColor(.theme.textSecondary)
            }

            Section {
                Button("Logout") {
                    logout()
                }
                .destructiveButton()
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, Spacing.lg)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: () -> Content

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.theme.primary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textPrimary)

                Text(subtitle)
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
            }

            Spacer()

            content()
        }
        .padding(.vertical, Spacing.sm)
    }
}
```

### Example 3: Error Banner

```swift
struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(ColorSet.error.foreground)

            Text(message)
                .font(.theme.bodyMedium)
                .foregroundColor(ColorSet.error.foreground)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .iconButton(size: 32)
        }
        .padding(Spacing.lg)
        .background(ColorSet.error.background)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(ColorSet.error.border, lineWidth: BorderWidth.standard)
        )
        .shadow(.sm)
        .padding(.horizontal, Spacing.lg)
    }
}
```

---

## Best Practices

### 1. Always Use Theme Tokens

```swift
// ✅ Good - Use theme tokens
Text("Title")
    .foregroundColor(.theme.textPrimary)
    .background(.theme.backgroundSecondary)

// ❌ Bad - Hardcoded colors
Text("Title")
    .foregroundColor(.black)
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
```

### 2. Use Semantic Spacing

```swift
// ✅ Good - Semantic spacing
VStack(spacing: Spacing.contentSpacing) {
    // Content
}
.padding(Spacing.cardPadding)

// ❌ Bad - Magic numbers
VStack(spacing: 14) {
    // Content
}
.padding(18)
```

### 3. Leverage TextStyle

```swift
// ✅ Good - Use TextStyle
Text("Welcome")
    .textStyle(.pageTitle)

// ❌ Bad - Manual styling
Text("Welcome")
    .font(.system(size: 57, weight: .bold))
    .foregroundColor(.primary)
    .lineSpacing(4)
```

### 4. Use Button Style Extensions

```swift
// ✅ Good - Use extensions
Button("Login") { login() }
    .primaryButton(isLoading: isLoading)

// ❌ Bad - Manual buttonStyle
Button("Login") { login() }
    .buttonStyle(PrimaryButtonStyle(isEnabled: true, isLoading: isLoading))
```

### 5. Consistent Component Building

```swift
// ✅ Good - Consistent pattern
VStack(spacing: Spacing.lg) {
    Text("Title")
        .font(.theme.headlineLarge)
        .foregroundColor(.theme.textPrimary)

    Text("Description")
        .font(.theme.bodyMedium)
        .foregroundColor(.theme.textSecondary)
}
.padding(Spacing.cardPadding)
.background(.theme.surface)
.cornerRadius(CornerRadius.card)
.shadow(.md)
```

---

## Accessibility Considerations

### 1. Dynamic Type Support

All fonts automatically scale với user's preferred text size:
```swift
Text("Content")
    .font(.theme.bodyLarge) // Automatically scales
```

### 2. Color Contrast

Ensure sufficient contrast ratios:
- Text Primary: 4.5:1 minimum (AA standard)
- Large text: 3:1 minimum
- UI elements: 3:1 minimum

### 3. Touch Targets

Minimum 44x44 points:
```swift
Button { } label: {
    Image(systemName: "heart")
}
.iconButton(size: 44) // Meets minimum touch target
```

---

## Dark Mode Support

### Asset Catalog Configuration

Colors.xcassets structure:
```
Colors.xcassets/
├── Primary.colorset/
│   └── Contents.json
│       {
│         "colors": [
│           { "idiom": "universal", "appearances": [{"value": "light"}] },
│           { "idiom": "universal", "appearances": [{"value": "dark"}] }
│         ]
│       }
```

### Automatic Switching

SwiftUI automatically switches colors based on system appearance:
```swift
// Automatically adapts
Text("Title")
    .foregroundColor(.theme.textPrimary)
    .background(.theme.background)
```

---

## Performance Considerations

### 1. Color Asset Caching

Asset catalog colors are cached by system - no performance overhead.

### 2. Font Performance

System fonts are highly optimized. Custom fonts should be used sparingly.

### 3. Shadow Performance

Shadows can impact performance:
```swift
// ✅ Good - Use shadows sparingly
Card()
    .shadow(.md) // Only on elevated elements

// ❌ Bad - Too many shadows
List {
    ForEach(items) { item in
        Row()
            .shadow(.lg) // Performance hit with many items
    }
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **Foundation**: Swift standard library

---

## Related Documentation

- [Core Layer](/Sources/iOSTemplate/Core/README.md) - App state (theme mode)
- [Storage Layer](/Sources/iOSTemplate/Storage/README.md) - Theme preferences storage

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
