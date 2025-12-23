import SwiftUI
import ComposableArchitecture
import UIKit

/// Forgot Password view - Password recovery
public struct ForgotPasswordView: View {
    @Perception.Bindable var store: StoreOf<AppReducer>
    @SwiftUI.Environment(\.dismiss) private var dismiss: DismissAction

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    @State private var email: String = ""
    @State private var emailSent: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    public var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xxxl) {
                Spacer()

                if emailSent {
                    successView
                } else {
                    requestView
                }

                Spacer()
            }
            .padding(Spacing.xl)
            .background(Color.theme.background)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.theme.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Request View

    private var requestView: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            Image(systemName: "key.fill")
                .font(.system(size: 80))
                .foregroundColor(.theme.primary)
                .padding(.bottom, Spacing.md)

            // Title & Description
            VStack(spacing: Spacing.sm) {
                Text("Forgot Password?")
                    .font(.theme.displaySmall)
                    .foregroundColor(.theme.textPrimary)

                Text("Enter your email address and we'll send you instructions to reset your password")
                    .font(.theme.body)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

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
                .frame(maxWidth: .infinity)
                .background(Color.theme.error.opacity(0.1))
                .cornerRadius(CornerRadius.md)
            }

            // Email field
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Email Address")
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
            .padding(.top, Spacing.xl)

            // Send button
            Button {
                handleSendResetEmail()
            } label: {
                Group {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Sending...")
                        }
                    } else {
                        Text("Send Reset Link")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(isValidEmail ? Color.theme.primary : Color.theme.disabled)
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.md)
            }
            .disabled(!isValidEmail || isLoading)
            .padding(.top, Spacing.md)

            // Back to login
            Button {
                dismiss()
            } label: {
                Text("Back to Sign In")
                    .font(.theme.body)
                    .foregroundColor(.theme.primary)
            }
            .padding(.top, Spacing.sm)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: Spacing.xl) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.theme.success.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.theme.success)
            }
            .padding(.bottom, Spacing.md)

            // Success message
            VStack(spacing: Spacing.sm) {
                Text("Check Your Email")
                    .font(.theme.displaySmall)
                    .foregroundColor(.theme.textPrimary)

                Text("We've sent password reset instructions to")
                    .font(.theme.body)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)

                Text(email)
                    .font(.theme.bodyMediumBold)
                    .foregroundColor(.theme.primary)
                    .multilineTextAlignment(.center)

                Text("Please check your inbox and follow the instructions")
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.sm)
            }

            // Action buttons
            VStack(spacing: Spacing.md) {
                Button {
                    // Open mail app
                    if let url = URL(string: "message://") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Email App")
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(CornerRadius.md)
                }

                Button {
                    handleResendEmail()
                } label: {
                    Text("Resend Email")
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.theme.backgroundSecondary)
                        .foregroundColor(.theme.primary)
                        .cornerRadius(CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .stroke(Color.theme.primary, lineWidth: 1)
                        )
                }
                .disabled(isLoading)
            }
            .padding(.top, Spacing.xl)

            // Back to login
            Button {
                dismiss()
            } label: {
                Text("Back to Sign In")
                    .font(.theme.body)
                    .foregroundColor(.theme.textSecondary)
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Validation

    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Actions

    private func handleSendResetEmail() {
        guard isValidEmail else {
            errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        // TODO: Implement actual password reset
        store.send(.user(.forgotPassword(email: email)))

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            withAnimation {
                emailSent = true
            }
        }
    }

    private func handleResendEmail() {
        isLoading = true

        // TODO: Implement resend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview("Request") {
    ForgotPasswordView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}

#Preview("Success") {
    // Note: For success state preview, you would need to trigger the flow
    // This is a simplified preview showing the initial state
    ForgotPasswordView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
