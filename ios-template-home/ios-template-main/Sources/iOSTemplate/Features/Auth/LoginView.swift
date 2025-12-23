import SwiftUI
import ComposableArchitecture

/// Login view - Reusable login với configurable content
///
/// **Pattern: Parameterized Component**
///
/// View này được design để reuse cho nhiều apps khác nhau.
/// Mỗi app pass LoginConfig riêng với branding và logic customize.
///
/// ## Usage:
/// ```swift
/// // App A - Banking
/// let bankingConfig = LoginConfig(
///     title: "Banking Login",
///     primaryColor: .green,
///     onLogin: { email, password in
///         // Banking-specific login logic
///     }
/// )
/// LoginView(store: store, config: bankingConfig)
///
/// // App B - Fitness
/// let fitnessConfig = LoginConfig(
///     title: "Fitness Login",
///     logoIcon: "figure.run",
///     primaryColor: .orange,
///     showSocialLogin: false,
///     onLogin: { email, password in
///         // Fitness-specific login logic
///     }
/// )
/// LoginView(store: store, config: fitnessConfig)
/// ```
///
/// ## Customization:
/// - **Content**: Title, subtitle, logo icon
/// - **Behavior**: onLogin, onSignUp, onSocialLogin closures
/// - **UI**: Colors, button text
/// - **Features**: Show/hide social login, sign up link
///
public struct LoginView: View {
    // MARK: - Properties

    let store: StoreOf<AppReducer>
    let config: LoginConfig

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showForgotPassword: Bool = false
    @State private var showRegistration: Bool = false

    // MARK: - Initialization

    /// Khởi tạo LoginView với custom config
    ///
    /// - Parameters:
    ///   - store: TCA Store
    ///   - config: LoginConfig customize cho app
    public init(store: StoreOf<AppReducer>, config: LoginConfig) {
        self.store = store
        self.config = config
    }

    /// Convenience init với default config
    ///
    /// Dùng khi không cần customize, sử dụng template default
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default { email, password in
            // Default mock login
            let mockProfile = UserProfile(
                id: "123",
                email: email,
                name: "User"
            )
            store.send(AppAction.user(.loginSuccess(mockProfile)))
        }
    }

    // MARK: - Body

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Logo với icon từ config
                        if let logoIcon = config.logoIcon {
                            Image(systemName: logoIcon)
                                .font(.system(size: 80))
                                .foregroundColor(config.primaryColor)
                                .padding(.bottom, Spacing.xxl)
                        }

                        // Title từ config
                        VStack(spacing: Spacing.sm) {
                            Text(config.title)
                                .font(.theme.title)
                                .foregroundColor(.theme.textPrimary)

                            Text(config.subtitle)
                                .font(.theme.body)
                                .foregroundColor(.theme.textSecondary)
                        }
                        .padding(.bottom, Spacing.xl)

                        // Error message
                        if let errorMessage {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.theme.error)
                                Text(errorMessage)
                                    .font(.theme.caption)
                                    .foregroundColor(.theme.error)
                            }
                            .padding(Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.theme.error.opacity(0.1))
                            .cornerRadius(CornerRadius.md)
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
                                .padding(Spacing.md)
                                .background(Color.theme.backgroundSecondary)
                                .cornerRadius(CornerRadius.md)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                Text("Password")
                                    .font(.theme.caption)
                                    .foregroundColor(.theme.textSecondary)

                                Spacer()

                                Button {
                                    showForgotPassword = true
                                } label: {
                                    Text("Forgot?")
                                        .font(.theme.caption)
                                        .foregroundColor(config.primaryColor)
                                }
                            }

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
                        }

                        // Login button với text từ config
                        Button {
                            handleLogin()
                        } label: {
                            Group {
                                if isLoading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Signing In...")
                                    }
                                } else {
                                    Text(config.loginButtonText)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(isFormValid ? config.primaryColor : Color.theme.disabled)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.md)
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.top, Spacing.md)

                        // Social login buttons (optional - theo config)
                        if config.showSocialLogin {
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.theme.border)
                                    .frame(height: 1)
                                Text("or")
                                    .font(.theme.caption)
                                    .foregroundColor(.theme.textSecondary)
                                Rectangle()
                                    .fill(Color.theme.border)
                                    .frame(height: 1)
                            }
                            .padding(.vertical, Spacing.xl)

                            // Social login buttons
                            VStack(spacing: Spacing.md) {
                                Button {
                                    if let onSocialLogin = config.onSocialLogin {
                                        onSocialLogin(.apple)
                                    } else {
                                        store.send(AppAction.user(.socialLogin(.apple)))
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "apple.logo")
                                        Text("Continue with Apple")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(Spacing.md)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(CornerRadius.md)
                                }

                                Button {
                                    if let onSocialLogin = config.onSocialLogin {
                                        onSocialLogin(.google)
                                    } else {
                                        store.send(AppAction.user(.socialLogin(.google)))
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "g.circle")
                                        Text("Continue with Google")
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
                        }

                        Spacer()

                        // Sign up link (optional - theo config)
                        if config.showSignUpLink {
                            HStack {
                                Text("Don't have an account?")
                                    .font(.theme.caption)
                                    .foregroundColor(.theme.textSecondary)

                                Button {
                                    if let onSignUp = config.onSignUp {
                                        onSignUp()
                                    } else {
                                        showRegistration = true
                                    }
                                } label: {
                                    Text(config.signUpLinkText)
                                        .font(.theme.captionBold)
                                        .foregroundColor(config.primaryColor)
                                }
                            }
                            .padding(.top, Spacing.md)
                        }
                    }
                    .padding(Spacing.xl)
                }
                .background(config.backgroundColor)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(store: store)
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView(store: store)
            }
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        isValidEmail(email) && !password.isEmpty
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Private Methods

    private func handleLogin() {
        guard isFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        // Gọi closure từ config - mỗi app có logic riêng
        // Nếu config không có onLogin, fallback to store action
        config.onLogin(email, password)
    }
}

// MARK: - Preview

#Preview("Default Config") {
    LoginView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}

#Preview("Custom Config - Banking") {
    LoginView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        },
        config: LoginConfig(
            title: "Banking Login",
            subtitle: "Secure access to your account",
            logoIcon: "banknote",
            primaryColor: .green,
            loginButtonText: "Sign In to Bank",
            onLogin: { email, password in
                print("Banking login: \(email)")
            },
            onSocialLogin: { provider in
                print("Banking social login: \(provider)")
            }
        )
    )
}

#Preview("Custom Config - Fitness") {
    LoginView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        },
        config: LoginConfig(
            title: "Fitness Login",
            subtitle: "Track your workouts",
            logoIcon: "figure.run",
            primaryColor: .orange,
            backgroundColor: .black,
            loginButtonText: "Start Training",
            showSocialLogin: false,
            showSignUpLink: false,
            onLogin: { email, password in
                print("Fitness login: \(email)")
            }
        )
    )
}
