import SwiftUI

/// Spacing system cho consistent layouts
/// Based on 4pt grid system
public enum Spacing {
    // MARK: - Base Spacing Values

    /// 4pt - Minimal spacing
    public static let xs: CGFloat = 4

    /// 8pt - Small spacing
    public static let sm: CGFloat = 8

    /// 12pt - Medium-small spacing
    public static let md: CGFloat = 12

    /// 16pt - Standard spacing (base unit)
    public static let lg: CGFloat = 16

    /// 24pt - Large spacing
    public static let xl: CGFloat = 24

    /// 32pt - Extra large spacing
    public static let xxl: CGFloat = 32

    /// 48pt - Section spacing
    public static let xxxl: CGFloat = 48

    /// 64pt - Major section spacing
    public static let huge: CGFloat = 64

    // MARK: - Semantic Spacing

    /// Default padding for views
    public static let viewPadding: CGFloat = lg

    /// Card padding
    public static let cardPadding: CGFloat = lg

    /// List item padding
    public static let listItemPadding: CGFloat = md

    /// Section spacing
    public static let sectionSpacing: CGFloat = xl

    /// Content spacing (between elements)
    public static let contentSpacing: CGFloat = lg

    /// Compact spacing (tight layouts)
    public static let compactSpacing: CGFloat = sm

    // MARK: - Component-Specific

    /// Button padding
    public static let buttonPadding = EdgeInsets(
        top: md,
        leading: xl,
        bottom: md,
        trailing: xl
    )

    /// Small button padding
    public static let buttonSmallPadding = EdgeInsets(
        top: sm,
        leading: lg,
        bottom: sm,
        trailing: lg
    )

    /// Input field padding
    public static let inputPadding = EdgeInsets(
        top: md,
        leading: lg,
        bottom: md,
        trailing: lg
    )

    /// Sheet padding
    public static let sheetPadding: CGFloat = xl

    /// Navigation bar spacing
    public static let navBarSpacing: CGFloat = lg
}

// MARK: - View Extensions

public extension View {
    /// Apply standard view padding
    func standardPadding() -> some View {
        self.padding(Spacing.viewPadding)
    }

    /// Apply card padding
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }

    /// Apply compact padding
    func compactPadding() -> some View {
        self.padding(Spacing.compactSpacing)
    }

    /// Apply section spacing
    func sectionSpacing() -> some View {
        self.padding(.vertical, Spacing.sectionSpacing)
    }
}

// MARK: - Edge Insets Extensions

public extension EdgeInsets {
    /// Standard padding
    static let standard = EdgeInsets(
        top: Spacing.lg,
        leading: Spacing.lg,
        bottom: Spacing.lg,
        trailing: Spacing.lg
    )

    /// Horizontal padding only
    static let horizontal = EdgeInsets(
        top: 0,
        leading: Spacing.lg,
        bottom: 0,
        trailing: Spacing.lg
    )

    /// Vertical padding only
    static let vertical = EdgeInsets(
        top: Spacing.lg,
        leading: 0,
        bottom: Spacing.lg,
        trailing: 0
    )

    /// Small padding
    static let small = EdgeInsets(
        top: Spacing.sm,
        leading: Spacing.sm,
        bottom: Spacing.sm,
        trailing: Spacing.sm
    )

    /// Large padding
    static let large = EdgeInsets(
        top: Spacing.xl,
        leading: Spacing.xl,
        bottom: Spacing.xl,
        trailing: Spacing.xl
    )
}

// MARK: - Grid System

/// Grid system cho layouts
public enum Grid {
    /// Number of columns in grid
    public static let columns = 12

    /// Gutter between columns
    public static let gutter: CGFloat = Spacing.lg

    /// Half gutter
    public static let halfGutter: CGFloat = Spacing.sm

    /// Calculate column width
    /// - Parameters:
    ///   - span: Number of columns to span
    ///   - totalWidth: Total available width
    /// - Returns: Calculated width for span
    public static func columnWidth(span: Int, totalWidth: CGFloat) -> CGFloat {
        let gutterCount = CGFloat(columns - 1)
        let contentWidth = totalWidth - (gutterCount * gutter)
        let singleColumnWidth = contentWidth / CGFloat(columns)
        let spanGutters = CGFloat(span - 1) * gutter
        return (singleColumnWidth * CGFloat(span)) + spanGutters
    }
}

// MARK: - Border Radius

/// Border radius values
public enum CornerRadius {
    /// No radius
    public static let none: CGFloat = 0

    /// Small radius - subtle rounded corners
    public static let sm: CGFloat = 4

    /// Medium radius - standard rounded corners
    public static let md: CGFloat = 8

    /// Large radius - pronounced rounded corners
    public static let lg: CGFloat = 12

    /// Extra large radius - very round corners
    public static let xl: CGFloat = 16

    /// Circular - fully rounded (for circles)
    public static let circular: CGFloat = 9999

    // MARK: - Semantic Radius

    /// Button corner radius
    public static let button: CGFloat = md

    /// Card corner radius
    public static let card: CGFloat = lg

    /// Input field corner radius
    public static let input: CGFloat = md

    /// Sheet corner radius
    public static let sheet: CGFloat = xl

    /// Chip/Tag corner radius
    public static let chip: CGFloat = circular
}

// MARK: - Border Width

/// Border width values
public enum BorderWidth {
    /// Thin border
    public static let thin: CGFloat = 0.5

    /// Standard border
    public static let standard: CGFloat = 1

    /// Medium border
    public static let medium: CGFloat = 1.5

    /// Thick border
    public static let thick: CGFloat = 2

    /// Focus border (for input focus states)
    public static let focus: CGFloat = 2
}

// MARK: - Shadow

/// Shadow definitions
public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    public init(
        color: Color = .black.opacity(0.1),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    // MARK: - Predefined Shadows

    /// No shadow
    public static let none = ShadowStyle(radius: 0, y: 0)

    /// Small shadow - subtle elevation
    public static let sm = ShadowStyle(
        color: .black.opacity(0.05),
        radius: 2,
        y: 1
    )

    /// Medium shadow - standard cards
    public static let md = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 4,
        y: 2
    )

    /// Large shadow - elevated elements
    public static let lg = ShadowStyle(
        color: .black.opacity(0.15),
        radius: 8,
        y: 4
    )

    /// Extra large shadow - floating elements
    public static let xl = ShadowStyle(
        color: .black.opacity(0.2),
        radius: 16,
        y: 8
    )
}

public extension View {
    /// Apply shadow style
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
