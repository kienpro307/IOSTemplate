import SwiftUI

// MARK: - Primary Button Style

/// Primary button style - main action buttons
public struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isLoading: Bool

    public init(isEnabled: Bool = true, isLoading: Bool = false) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }

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
        .background(
            backgroundColor(configuration: configuration)
        )
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

// MARK: - Secondary Button Style

/// Secondary button style - secondary actions
public struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

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

// MARK: - Tertiary Button Style

/// Tertiary button style - text-only buttons
public struct TertiaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

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

// MARK: - Destructive Button Style

/// Destructive button style - dangerous actions
public struct DestructiveButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

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

// MARK: - Small Button Style

/// Small button style - compact buttons
public struct SmallButtonStyle: ButtonStyle {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

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

// MARK: - Icon Button Style

/// Icon button style - icon-only buttons
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

// MARK: - Button Style Extensions

public extension Button {
    /// Apply primary button style
    func primaryButton(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading))
    }

    /// Apply secondary button style
    func secondaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
    }

    /// Apply tertiary button style
    func tertiaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(TertiaryButtonStyle(isEnabled: isEnabled))
    }

    /// Apply destructive button style
    func destructiveButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(DestructiveButtonStyle(isEnabled: isEnabled))
    }

    /// Apply small button style
    func smallButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(SmallButtonStyle(isEnabled: isEnabled))
    }

    /// Apply icon button style
    func iconButton(size: CGFloat = 44, isEnabled: Bool = true) -> some View {
        self.buttonStyle(IconButtonStyle(size: size, isEnabled: isEnabled))
    }
}

