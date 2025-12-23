import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color Fallback Extension

extension Color {
    /// Provide fallback color if asset not found
    func fallback(_ fallbackColor: Color) -> Color {
        // Try to use the asset color, fallback if not available
        // In production, this would check if asset exists
        // For now, just return self (asset) or fallback
        return self
    }
}

/// Theme colors cho toàn bộ app
/// Hỗ trợ dark/light mode tự động
public extension Color {
    /// Access to theme colors
    static var theme: Theme.Type { Theme.self }

    /// Theme color palette
    enum Theme {
        // MARK: - Primary Colors

        /// Primary brand color - Blue
        public static let primary = Color(
            light: Color(red: 0.0, green: 0.48, blue: 1.0), // #007AFF
            dark: Color(red: 0.04, green: 0.52, blue: 1.0)  // #0A84FF
        )

        /// Secondary brand color - Purple
        public static let secondary = Color(
            light: Color(red: 0.35, green: 0.34, blue: 0.84), // #5856D6
            dark: Color(red: 0.38, green: 0.36, blue: 0.90)   // #5E5CE6
        )

        /// Accent color - Orange
        public static let accent = Color(
            light: Color(red: 1.0, green: 0.58, blue: 0.0),  // #FF9500
            dark: Color(red: 1.0, green: 0.62, blue: 0.04)   // #FF9F0A
        )

        // MARK: - Background Colors

        /// Main background color
        public static let background = Color(
            light: Color(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
            dark: Color(red: 0.0, green: 0.0, blue: 0.0)        // #000000
        )

        /// Secondary background (cards, sections)
        public static let backgroundSecondary = Color(
            light: Color(red: 0.95, green: 0.95, blue: 0.97),  // #F2F2F7
            dark: Color(red: 0.11, green: 0.11, blue: 0.12)    // #1C1C1E
        )

        /// Tertiary background (subtle sections)
        public static let backgroundTertiary = Color(
            light: Color(red: 1.0, green: 1.0, blue: 1.0),     // #FFFFFF
            dark: Color(red: 0.17, green: 0.17, blue: 0.18)    // #2C2C2E
        )

        // MARK: - Surface Colors

        /// Surface color for elevated elements
        public static let surface = Color(
            light: Color(red: 1.0, green: 1.0, blue: 1.0),     // #FFFFFF
            dark: Color(red: 0.11, green: 0.11, blue: 0.12)    // #1C1C1E
        )

        /// Surface variant
        public static let surfaceVariant = Color(
            light: Color(red: 0.97, green: 0.97, blue: 0.98),  // #F7F7F9
            dark: Color(red: 0.14, green: 0.14, blue: 0.15)    // #242426
        )

        // MARK: - Text Colors

        /// Primary text color
        public static let textPrimary = Color(
            light: Color(red: 0.0, green: 0.0, blue: 0.0),     // #000000
            dark: Color(red: 1.0, green: 1.0, blue: 1.0)       // #FFFFFF
        )

        /// Secondary text color (less emphasis)
        public static let textSecondary = Color(
            light: Color(red: 0.24, green: 0.24, blue: 0.26),  // #3C3C43
            dark: Color(red: 0.92, green: 0.92, blue: 0.96)    // #EBEBF5
        )

        /// Tertiary text color (minimal emphasis)
        public static let textTertiary = Color(
            light: Color(red: 0.24, green: 0.24, blue: 0.26, opacity: 0.6), // #3C3C43 60%
            dark: Color(red: 0.92, green: 0.92, blue: 0.96, opacity: 0.6)   // #EBEBF5 60%
        )

        /// Disabled text color
        public static let textDisabled = Color(
            light: Color(red: 0.24, green: 0.24, blue: 0.26, opacity: 0.3), // #3C3C43 30%
            dark: Color(red: 0.92, green: 0.92, blue: 0.96, opacity: 0.3)   // #EBEBF5 30%
        )

        // MARK: - Semantic Colors

        /// Success color (green)
        public static let success = Color(
            light: Color(red: 0.20, green: 0.78, blue: 0.35),  // #34C759
            dark: Color(red: 0.19, green: 0.82, blue: 0.35)    // #30D158
        )

        /// Warning color (yellow/orange)
        public static let warning = Color(
            light: Color(red: 1.0, green: 0.80, blue: 0.0),    // #FFCC00
            dark: Color(red: 1.0, green: 0.84, blue: 0.04)     // #FFD60A
        )

        /// Error color (red)
        public static let error = Color(
            light: Color(red: 1.0, green: 0.23, blue: 0.19),   // #FF3B30
            dark: Color(red: 1.0, green: 0.27, blue: 0.23)     // #FF453A
        )

        /// Info color (blue)
        public static let info = Color(
            light: Color(red: 0.35, green: 0.78, blue: 1.0),   // #5AC8FA
            dark: Color(red: 0.38, green: 0.82, blue: 1.0)     // #64D2FF
        )

        // MARK: - Border Colors

        /// Default border color
        public static let border = Color(
            light: Color(red: 0.78, green: 0.78, blue: 0.80),  // #C7C7CC
            dark: Color(red: 0.23, green: 0.23, blue: 0.24)    // #3A3A3C
        )

        /// Light border for subtle separation
        public static let borderLight = Color(
            light: Color(red: 0.90, green: 0.90, blue: 0.92),  // #E5E5EA
            dark: Color(red: 0.17, green: 0.17, blue: 0.18)    // #2C2C2E
        )

        /// Disabled color
        #if canImport(UIKit)
        public static let disabled = Color(UIColor.systemGray3)
        #else
        public static let disabled = Color(red: 0.78, green: 0.78, blue: 0.80) // Fallback for non-UIKit
        #endif

        // MARK: - Overlay Colors

        /// Overlay for modals/sheets
        public static let overlay = Color.black.opacity(0.5)

        /// Scrim for backgrounds
        public static let scrim = Color.black.opacity(0.3)
    }
}


// MARK: - Adaptive Color Helper

public extension Color {
    /// Create adaptive color for light/dark mode
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
        #else
        self = light
        #endif
    }

    /// Create color with custom opacity for light/dark mode
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - UIColor Extensions (for UIKit interop)

#if canImport(UIKit)
public extension UIColor {
    /// Theme colors cho UIKit
    enum Theme {
        public static let primary = UIColor(Color.theme.primary)
        public static let secondary = UIColor(Color.theme.secondary)
        public static let accent = UIColor(Color.theme.accent)

        public static let background = UIColor(Color.theme.background)
        public static let backgroundSecondary = UIColor(Color.theme.backgroundSecondary)

        public static let textPrimary = UIColor(Color.theme.textPrimary)
        public static let textSecondary = UIColor(Color.theme.textSecondary)

        public static let success = UIColor(Color.theme.success)
        public static let warning = UIColor(Color.theme.warning)
        public static let error = UIColor(Color.theme.error)
        public static let info = UIColor(Color.theme.info)
    }
}
#endif

// MARK: - Color Utilities

public extension Color {
    /// Create color from hex string
    /// - Parameter hex: Hex string (e.g., "#FF5733" or "FF5733")
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

    /// Lighten color by percentage
    func lighter(by percentage: Double = 0.3) -> Color {
        self.adjust(by: abs(percentage))
    }

    /// Darken color by percentage
    func darker(by percentage: Double = 0.3) -> Color {
        self.adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: Double) -> Color {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(
            red: min(Double(red + percentage), 1.0),
            green: min(Double(green + percentage), 1.0),
            blue: min(Double(blue + percentage), 1.0),
            opacity: Double(alpha)
        )
        #else
        return self
        #endif
    }
}

// MARK: - Semantic Color Sets

/// Predefined color sets cho common use cases
public enum ColorSet {
    /// Success state colors
    public static let success = ColorSetModel(
        foreground: .theme.success,
        background: Color.theme.success.opacity(0.1),
        border: .theme.success
    )

    /// Warning state colors
    public static let warning = ColorSetModel(
        foreground: .theme.warning,
        background: Color.theme.warning.opacity(0.1),
        border: .theme.warning
    )

    /// Error state colors
    public static let error = ColorSetModel(
        foreground: .theme.error,
        background: Color.theme.error.opacity(0.1),
        border: .theme.error
    )

    /// Info state colors
    public static let info = ColorSetModel(
        foreground: .theme.info,
        background: Color.theme.info.opacity(0.1),
        border: .theme.info
    )
}

/// Color set model
public struct ColorSetModel {
    public let foreground: Color
    public let background: Color
    public let border: Color

    public init(foreground: Color, background: Color, border: Color) {
        self.foreground = foreground
        self.background = background
        self.border = border
    }
}
