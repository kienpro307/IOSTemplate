import SwiftUI
import ComposableArchitecture

/// Registration view - Create new account
public struct RegistrationView: View {
    @Perception.Bindable var store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var acceptedTerms: Bool = false
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var validationErrors: [String] = []

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.theme.primary)
                            .padding(.bottom, Spacing.md)

                        Text("Create Account")
                            .font(.theme.displaySmall)
                            .foregroundColor(.theme.textPrimary)

                        Text("Join us and get started")
                            .font(.theme.body)
                            .foregroundColor(.theme.textSecondary)
                    }
                    .padding(.bottom, Spacing.xl)

                    // Validation Errors
                    if !validationErrors.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            ForEach(validationErrors, id: \.self) { error in
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.theme.error)
                                    Text(error)
                                        .font(.theme.caption)
                                        .foregroundColor(.theme.error)
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.theme.error.opacity(0.1))
                        .cornerRadius(CornerRadius.md)
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Full Name")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)

                        TextField("Enter your name", text: $name)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.words)
                            .padding(Spacing.md)
                            .background(Color.theme.backgroundSecondary)
                            .cornerRadius(CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.md)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Email")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)

                        TextField("Enter your email", text: $email)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(Spacing.md)
                            .background(Color.theme.backgroundSecondary)
                            .cornerRadius(CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.md)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Password")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)

                        HStack {
                            if showPassword {
                                TextField("Enter password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Enter password", text: $password)
                            }

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.theme.textSecondary)
                            }
                        }
                        .textFieldStyle(.plain)
                        .padding(Spacing.md)
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )

                        // Password strength indicator
                        PasswordStrengthView(password: password)
                    }

                    // Confirm Password field
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Confirm Password")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)

                        HStack {
                            if showConfirmPassword {
                                TextField("Re-enter password", text: $confirmPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Re-enter password", text: $confirmPassword)
                            }

                            Button {
                                showConfirmPassword.toggle()
                            } label: {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.theme.textSecondary)
                            }
                        }
                        .textFieldStyle(.plain)
                        .padding(Spacing.md)
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }

                    // Terms and conditions
                    Toggle(isOn: $acceptedTerms) {
                        HStack(spacing: Spacing.xs) {
                            Text("I agree to the")
                                .font(.theme.caption)
                            Button("Terms of Service") {
                                // Show terms
                            }
                            .font(.theme.captionBold)
                            Text("and")
                                .font(.theme.caption)
                            Button("Privacy Policy") {
                                // Show privacy policy
                            }
                            .font(.theme.captionBold)
                        }
                        .foregroundColor(.theme.textSecondary)
                    }
                    .toggleStyle(CheckboxToggleStyle())

                    // Register button
                    Button {
                        handleRegistration()
                    } label: {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(isFormValid ? Color.theme.primary : Color.theme.disabled)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.md)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, Spacing.md)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.theme.border)
                            .frame(height: 1)
                        Text("or sign up with")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)
                        Rectangle()
                            .fill(Color.theme.border)
                            .frame(height: 1)
                    }
                    .padding(.vertical, Spacing.md)

                    // Social registration buttons
                    VStack(spacing: Spacing.md) {
                        Button {
                            // TODO: Implement Apple registration
                            store.send(.user(.socialLogin(.apple)))
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Sign up with Apple")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.md)
                        }

                        Button {
                            // TODO: Implement Google registration
                            store.send(.user(.socialLogin(.google)))
                        } label: {
                            HStack {
                                Image(systemName: "g.circle")
                                Text("Sign up with Google")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.md)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                        }
                    }

                    // Sign in link
                    HStack {
                        Text("Already have an account?")
                            .font(.theme.caption)
                            .foregroundColor(.theme.textSecondary)

                        Button {
                            store.send(.navigation(.navigateTo(.login)))
                        } label: {
                            Text("Sign In")
                                .font(.theme.captionBold)
                                .foregroundColor(.theme.primary)
                        }
                    }
                    .padding(.top, Spacing.md)
                }
                .padding(Spacing.xl)
            }
            .background(Color.theme.background)
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !name.isEmpty &&
        isValidEmail(email) &&
        isValidPassword(password) &&
        password == confirmPassword &&
        acceptedTerms
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        password.count >= 8 &&
        password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
        password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    private func validateForm() -> [String] {
        var errors: [String] = []

        if name.isEmpty {
            errors.append("Name is required")
        }

        if !isValidEmail(email) {
            errors.append("Invalid email address")
        }

        if !isValidPassword(password) {
            errors.append("Password must be at least 8 characters with uppercase, lowercase, and numbers")
        }

        if password != confirmPassword {
            errors.append("Passwords do not match")
        }

        if !acceptedTerms {
            errors.append("You must accept the terms and conditions")
        }

        return errors
    }

    private func handleRegistration() {
        validationErrors = validateForm()

        guard validationErrors.isEmpty else {
            return
        }

        // TODO: Implement actual registration
        store.send(.user(.register(name: name, email: email, password: password)))
    }
}

// MARK: - Password Strength View

struct PasswordStrengthView: View {
    let password: String

    private var strength: PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 8 {
            return .weak
        } else if password.count < 12 {
            return .medium
        } else {
            return .strong
        }
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<3) { index in
                Rectangle()
                    .fill(colorForStrength(index))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)

        if !password.isEmpty {
            Text(strength.description)
                .font(.theme.caption)
                .foregroundColor(strength.color)
        }
    }

    private func colorForStrength(_ index: Int) -> Color {
        switch (strength, index) {
        case (.weak, 0):
            return .red
        case (.medium, 0...1):
            return .orange
        case (.strong, _):
            return .green
        default:
            return Color.theme.disabled
        }
    }
}

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong

    var description: String {
        switch self {
        case .none: return ""
        case .weak: return "Weak password"
        case .medium: return "Medium password"
        case .strong: return "Strong password"
        }
    }

    var color: Color {
        switch self {
        case .none: return .clear
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
}

// MARK: - Checkbox Toggle Style

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .theme.primary : .theme.textTertiary)
                configuration.label
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RegistrationView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
