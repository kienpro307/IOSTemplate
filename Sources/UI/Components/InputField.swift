import SwiftUI

/// Text input field với theme styling
public struct InputField: View {
    let title: String?
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let errorMessage: String?
    let isEnabled: Bool

    public init(
        title: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.isEnabled = isEnabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let title = title {
                Text(title)
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textPrimary)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.theme.bodyLarge)
            .foregroundColor(.theme.textPrimary)
            .padding(Spacing.inputPadding)
            .background(Color.theme.backgroundSecondary)
            .cornerRadius(CornerRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.input)
                    .stroke(
                        borderColor,
                        lineWidth: BorderWidth.standard
                    )
            )
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.6)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.theme.caption)
                    .foregroundColor(.theme.error)
                    .padding(.leading, Spacing.sm)
            }
        }
    }

    private var borderColor: Color {
        if let _ = errorMessage {
            return .theme.error
        }
        return .theme.border
    }
}

// MARK: - Preview

#Preview("Input Field") {
    VStack(spacing: Spacing.lg) {
        InputField(
            title: "Email",
            placeholder: "Nhập email",
            text: .constant("")
        )

        InputField(
            title: "Mật khẩu",
            placeholder: "Nhập mật khẩu",
            text: .constant(""),
            isSecure: true
        )

        InputField(
            title: "Email",
            placeholder: "Nhập email",
            text: .constant(""),
            errorMessage: "Email không hợp lệ"
        )

        InputField(
            title: "Disabled",
            placeholder: "Không thể nhập",
            text: .constant(""),
            isEnabled: false
        )
    }
    .padding()
}

