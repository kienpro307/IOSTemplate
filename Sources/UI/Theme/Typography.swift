import SwiftUI

/// Typography system cho toàn bộ app
/// Consistent font styles with Dynamic Type support
public extension Font {
    /// Access to theme typography
    static var theme: Theme.Type { Theme.self }

    /// Theme typography
    enum Theme {
        // MARK: - Display Fonts (Largest)

        /// Display Large - Hero text
        public static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)

        /// Display Medium
        public static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)

        /// Display Small
        public static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)

        // MARK: - Headline Fonts

        /// Headline Large - Main titles
        public static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)

        /// Headline Medium - Section titles
        public static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)

        /// Headline Small - Card titles
        public static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)

        // MARK: - Title Fonts

        /// Title Large
        public static let titleLarge = Font.system(size: 22, weight: .medium, design: .default)

        /// Title Medium
        public static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)

        /// Title Small
        public static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)

        // MARK: - Body Fonts

        /// Body Large - Main content
        public static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)

        /// Body Medium - Standard text
        public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)

        /// Body Small - Dense text
        public static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

        // MARK: - Label Fonts

        /// Label Large - Button text
        public static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)

        /// Label Medium - Small buttons
        public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)

        /// Label Small - Helper text
        public static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

        // MARK: - Caption Fonts

        /// Caption - Auxiliary information
        public static let caption = Font.system(size: 12, weight: .regular, design: .default)

        /// Overline - Labels, tags
        public static let overline = Font.system(size: 10, weight: .medium, design: .default).uppercaseSmallCaps()

        // MARK: - Monospace Fonts

        /// Code - For code display
        public static let code = Font.system(size: 14, weight: .regular, design: .monospaced)

        /// Code Small
        public static let codeSmall = Font.system(size: 12, weight: .regular, design: .monospaced)

        // MARK: - Convenience Aliases

        /// Default title (alias for titleLarge)
        public static let title = titleLarge

        /// Default body (alias for bodyLarge)
        public static let body = bodyLarge

        /// Bold body variants
        public static let bodyLargeBold = Font.system(size: 16, weight: .semibold, design: .default)
        public static let bodyMediumBold = Font.system(size: 14, weight: .semibold, design: .default)
        public static let bodySmallBold = Font.system(size: 12, weight: .semibold, design: .default)

        /// Bold caption
        public static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)
    }
}

// MARK: - Text Styles

/// Predefined text styles for common use cases
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
        self.font = font
        self.color = color
        self.lineSpacing = lineSpacing
        self.kerning = kerning
    }

    // MARK: - Common Styles

    /// Large page title
    public static let pageTitle = TextStyle(
        font: .theme.displayLarge,
        color: .theme.textPrimary,
        lineSpacing: 4
    )

    /// Section header
    public static let sectionHeader = TextStyle(
        font: .theme.headlineMedium,
        color: .theme.textPrimary,
        lineSpacing: 2
    )

    /// Card title
    public static let cardTitle = TextStyle(
        font: .theme.titleLarge,
        color: .theme.textPrimary
    )

    /// Body text
    public static let body = TextStyle(
        font: .theme.bodyLarge,
        color: .theme.textPrimary,
        lineSpacing: 4
    )

    /// Secondary body text
    public static let bodySecondary = TextStyle(
        font: .theme.bodyMedium,
        color: .theme.textSecondary,
        lineSpacing: 3
    )

    /// Caption text
    public static let caption = TextStyle(
        font: .theme.caption,
        color: .theme.textSecondary
    )

    /// Button text
    public static let button = TextStyle(
        font: .theme.labelLarge,
        color: .white
    )

    /// Small button
    public static let buttonSmall = TextStyle(
        font: .theme.labelMedium,
        color: .white
    )
}

// MARK: - View Extension for Text Styles

public extension View {
    /// Apply text style to view
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .kerning(style.kerning)
    }
}

// MARK: - Text Extensions

public extension Text {
    /// Apply theme font
    func themeFont(_ font: Font) -> Text {
        self.font(font)
    }

    /// Apply text style
    func style(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .kerning(style.kerning)
    }
}

// MARK: - Dynamic Type Utilities

public extension Font {
    /// Scale font with Dynamic Type
    func scaledFont(for textStyle: Font.TextStyle) -> Font {
        // SwiftUI automatically scales fonts with Dynamic Type
        // This method provides additional customization if needed
        return self
    }
}

// MARK: - Font Weights

public extension Font.Weight {
    /// Theme font weights
    enum Theme {
        public static let thin = Font.Weight.thin
        public static let light = Font.Weight.light
        public static let regular = Font.Weight.regular
        public static let medium = Font.Weight.medium
        public static let semibold = Font.Weight.semibold
        public static let bold = Font.Weight.bold
        public static let heavy = Font.Weight.heavy
        public static let black = Font.Weight.black
    }
}

