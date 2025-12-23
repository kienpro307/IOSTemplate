# Auth - Authentication Features

## Tổng quan

Thư mục `Auth/` chứa **authentication screens và flows** của ứng dụng. Đây là entry point cho non-authenticated users, handle login, registration, và social authentication.

### Chức năng chính
- Email/password authentication
- Social login (Apple, Google) placeholders
- Registration flow navigation
- Mock authentication for development
- Input validation
- Error handling

### Tác động đến toàn bộ app
- **Critical Impact**: Entry point cho users vào app
- Quản lý authentication state transition
- Trigger AppState update khi login success
- Navigate to main app sau authentication
- Tích hợp với Keychain để save tokens

---

## Cấu trúc Files

```
Auth/
└── LoginView.swift      # Login screen (170 dòng)
```

**Tổng cộng**: 1 file, 170 dòng code

---

## Chi tiết File: LoginView.swift (170 dòng)

### Component Overview

```swift
public struct LoginView: View {
    @Bindable var store: StoreOf<AppReducer>
    @State private var email: String = ""
    @State private var password: String = ""

    public var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                // Logo, Title, Email/Password fields
                // Login button, Social login, Sign up link
            }
        }
    }
}
```

### Local State (dòng 12-13)

**Form Fields**:
```swift
@State private var email: String = ""
@State private var password: String = ""
```

**Purpose**:
- Local form input state
- Not part of AppState (temporary UI state)
- Cleared after login

**Pattern**: Local state for UI, Global state (AppState) for app data

---

## UI Structure

### 1. Logo Section (dòng 18-22)

```swift
Image(systemName: "lock.shield")
    .font(.system(size: 80))
    .foregroundColor(.theme.primary)
    .padding(.bottom, Spacing.xxl)
```

**Visual**: Large lock icon, brand primary color

### 2. Title Section (dòng 24-34)

```swift
VStack(spacing: Spacing.sm) {
    Text("Welcome Back")
        .font(.theme.title)
        .foregroundColor(.theme.textPrimary)

    Text("Sign in to continue")
        .font(.theme.body)
        .foregroundColor(.theme.textSecondary)
}
```

**Content**:
- Main title: "Welcome Back"
- Subtitle: "Sign in to continue"
- Design System typography và colors

### 3. Email Field (dòng 36-49)

```swift
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
```

**Configuration**:
- `textInputAutocapitalization(.never)` - No auto-caps for email
- `keyboardType(.emailAddress)` - Email keyboard layout
- Label + TextField pattern
- Design System styling

### 4. Password Field (dòng 51-62)

```swift
VStack(alignment: .leading, spacing: Spacing.xs) {
    Text("Password")
        .font(.theme.caption)
        .foregroundColor(.theme.textSecondary)

    SecureField("Enter your password", text: $password)
        .textFieldStyle(.plain)
        .padding(Spacing.md)
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
}
```

**Security**: Uses `SecureField` để hide password input

### 5. Login Button (dòng 64-75)

```swift
Button {
    handleLogin()
} label: {
    Text("Sign In")
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.theme.primary)
        .foregroundColor(.white)
        .cornerRadius(CornerRadius.md)
}
.padding(.top, Spacing.md)
```

**Action**: Calls `handleLogin()` method

**Style**: Full-width primary button

### 6. Divider (dòng 77-89)

```swift
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
```

**Visual**: `───── or ─────`

### 7. Social Login Buttons (dòng 91-124)

**Apple Login** (dòng 93-105):
```swift
Button {
    // TODO: Implement Apple login
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
```

**Status**: Placeholder - Not implemented
**TODO**: Line 94

**Google Login** (dòng 107-123):
```swift
Button {
    // TODO: Implement Google login
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
```

**Status**: Placeholder - Not implemented
**TODO**: Line 108

**Styling**: Black button (Apple), White button with border (Google)

### 8. Sign Up Link (dòng 128-141)

```swift
HStack {
    Text("Don't have an account?")
        .font(.theme.caption)
        .foregroundColor(.theme.textSecondary)

    Button {
        // TODO: Navigate to sign up
    } label: {
        Text("Sign Up")
            .font(.theme.captionBold)
            .foregroundColor(.theme.primary)
    }
}
```

**Status**: Placeholder - Not implemented
**TODO**: Line 135

---

## Login Logic

### handleLogin() Method (dòng 148-156)

```swift
private func handleLogin() {
    // Mock login - TODO: Implement actual authentication
    let mockProfile = UserProfile(
        id: "123",
        email: email,
        name: "User"
    )
    store.send(.user(.loginSuccess(mockProfile)))
}
```

#### Current Implementation (Mock)

**Flow**:
1. Create mock UserProfile
2. Use email from form input
3. Dispatch `.user(.loginSuccess(profile))` action
4. No API call, no validation

**Mock Data**:
- `id`: Always "123"
- `email`: From form input
- `name`: Always "User"

#### TODO: Implement Real Authentication (Line 149)

**Proper Implementation**:
```swift
private func handleLogin() async {
    // 1. Validate input
    guard !email.isEmpty, !password.isEmpty else {
        showError("Please enter email and password")
        return
    }

    guard isValidEmail(email) else {
        showError("Invalid email format")
        return
    }

    // 2. Show loading
    isLoading = true

    do {
        // 3. Call API
        let response: AuthResponse = try await networkService.request(
            .login(email: email, password: password)
        )

        // 4. Save tokens
        try await keychainStorage.saveSecure(
            response.accessToken,
            forKey: .accessToken
        )
        try await keychainStorage.saveSecure(
            response.refreshToken,
            forKey: .refreshToken
        )

        // 5. Fetch user profile
        let profile: UserProfile = try await networkService.request(
            .getUserProfile(response.userID)
        )

        // 6. Dispatch success
        store.send(.user(.loginSuccess(profile)))

    } catch ServiceError.unauthorized {
        showError("Invalid email or password")
    } catch NetworkError.noConnection {
        showError("No internet connection")
    } catch {
        showError("Login failed. Please try again.")
    }

    isLoading = false
}
```

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**: None (LoginView doesn't read state)

**Write to AppState**:
```swift
store.send(.user(.loginSuccess(profile)))
```

### Actions Dispatched

**Login Success**:
```swift
store.send(.user(.loginSuccess(mockProfile)))
```

**Action Definition** (Core/AppAction.swift):
```swift
public enum UserAction: Equatable {
    case loginSuccess(UserProfile)
    // ...
}
```

**Handler** (Core/AppReducer.swift):
```swift
private func handleUserAction(
    _ state: inout AppState,
    _ action: UserAction
) -> Effect<AppAction> {
    switch action {
    case .loginSuccess(let profile):
        state.user.profile = profile
        // Save token to Keychain (TODO)
        return .send(.navigation(.selectTab(.home)))
    // ...
    }
}
```

---

## Navigation Flow

### Login Success Flow

```
LoginView
    ↓
User taps "Sign In"
    ↓
handleLogin()
    ↓
store.send(.user(.loginSuccess(profile)))
    ↓
AppReducer.handleUserAction
    ↓
state.user.profile = profile
isAuthenticated = true
    ↓
return .send(.navigation(.selectTab(.home)))
    ↓
AppReducer.handleNavigationAction
    ↓
state.navigation.selectedTab = .home
    ↓
RootView re-renders
    ↓
Shows MainTabView (authenticated)
    ↓
Home tab selected
```

### Sign Up Navigation (TODO)

```
LoginView
    ↓
User taps "Sign Up"
    ↓
Navigate to RegisterView (not implemented)
```

---

## Design System Usage

### Colors

```swift
// Background
Color.theme.background
Color.theme.backgroundSecondary

// Text
Color.theme.textPrimary
Color.theme.textSecondary

// Brand
Color.theme.primary

// Border
Color.theme.border
```

### Typography

```swift
.font(.theme.title)        // "Welcome Back"
.font(.theme.body)         // "Sign in to continue"
.font(.theme.caption)      // Labels, hints
.font(.theme.captionBold)  // "Sign Up" link
```

### Spacing

```swift
.padding(Spacing.xs)    // 4pt - Label spacing
.padding(Spacing.sm)    // 8pt - Title spacing
.padding(Spacing.md)    // 12pt - Button, TextField padding
.padding(Spacing.xl)    // 24pt - Section spacing
.padding(Spacing.xxl)   // 32pt - Logo padding
```

### Corner Radius

```swift
.cornerRadius(CornerRadius.md)  // 8pt - Buttons, TextFields
```

---

## Best Practices

### 1. Local vs Global State

```swift
// ✅ Good - Local state for form input
@State private var email: String = ""
@State private var password: String = ""

// ❌ Bad - Don't put form input in AppState
// AppState should only have app-level data
```

### 2. Input Validation

```swift
// TODO: Add validation
private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
```

### 3. Error Handling

```swift
// TODO: Add error state
@State private var errorMessage: String?
@State private var showError: Bool = false

// Show alert
.alert("Error", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(errorMessage ?? "An error occurred")
}
```

### 4. Loading State

```swift
// TODO: Add loading state
@State private var isLoading: Bool = false

// Disable button when loading
Button("Sign In") {
    handleLogin()
}
.disabled(isLoading)

// Show progress
if isLoading {
    ProgressView()
}
```

---

## Testing

### Unit Tests

**Test Mock Login**:
```swift
func testMockLogin() async {
    let store = TestStore(
        initialState: AppState()
    ) {
        AppReducer()
    }

    let mockProfile = UserProfile(
        id: "123",
        email: "test@example.com",
        name: "User"
    )

    await store.send(.user(.loginSuccess(mockProfile))) {
        $0.user.profile = mockProfile
    }

    await store.receive(.navigation(.selectTab(.home))) {
        $0.navigation.selectedTab = .home
    }

    XCTAssertTrue(store.state.user.isAuthenticated)
}
```

**Test Email Validation** (when implemented):
```swift
func testEmailValidation() {
    XCTAssertTrue(isValidEmail("test@example.com"))
    XCTAssertFalse(isValidEmail("invalid-email"))
    XCTAssertFalse(isValidEmail("@example.com"))
}
```

### UI Tests

```swift
func testLoginUI() throws {
    let app = XCUIApplication()
    app.launch()

    // Find elements
    let emailField = app.textFields["Enter your email"]
    let passwordField = app.secureTextFields["Enter your password"]
    let signInButton = app.buttons["Sign In"]

    // Enter credentials
    emailField.tap()
    emailField.typeText("test@example.com")

    passwordField.tap()
    passwordField.typeText("password123")

    // Tap login
    signInButton.tap()

    // Verify navigation to home
    XCTAssertTrue(app.navigationBars["Home"].exists)
}
```

---

## Preview

```swift
#Preview {
    LoginView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        }
    )
}
```

**Preview Shows**:
- Login form
- Email/password fields
- Social login buttons
- Sign up link

---

## Future Enhancements

### 1. Biometric Authentication

```swift
// TODO: Add Face ID / Touch ID
Button("Sign In with Face ID") {
    authenticateWithBiometrics()
}

private func authenticateWithBiometrics() {
    let context = LAContext()
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login") { success, error in
        if success {
            // Login
        }
    }
}
```

### 2. Remember Me

```swift
// TODO: Add remember me toggle
@State private var rememberMe: Bool = false

Toggle("Remember Me", isOn: $rememberMe)

// Save email to UserDefaults if enabled
```

### 3. Forgot Password

```swift
// TODO: Add forgot password link
Button("Forgot Password?") {
    navigateToForgotPassword()
}
```

### 4. Input Validation

```swift
// TODO: Real-time validation
TextField("Enter your email", text: $email)
    .onChange(of: email) { _, newValue in
        validateEmail(newValue)
    }

// Show validation errors
if !emailIsValid {
    Text("Invalid email format")
        .foregroundColor(.theme.error)
        .font(.theme.caption)
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: UserProfile model
- **Core/AppAction**: UserAction.loginSuccess
- **Core/AppReducer**: Login success handler
- **Design System**: Colors, Typography, Spacing
- **Network**: API calls (when implemented)
- **Storage**: Keychain for tokens (when implemented)

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Navigation flow
- [Core/README.md](../../Core/README.md) - AppState, AppAction
- [Network/README.md](../../Network/README.md) - API integration
- [Storage/README.md](../../Storage/README.md) - Keychain storage

---

## TODO Items

**LoginView.swift**:
- **Dòng 94**: Implement Apple login với Sign in with Apple
- **Dòng 108**: Implement Google login với Firebase/Google SDK
- **Dòng 135**: Navigate to sign up screen (create RegisterView)
- **Dòng 149**: Implement actual authentication logic:
  - Email/password validation
  - API call to login endpoint
  - Token storage in Keychain
  - Error handling
  - Loading state
  - User profile fetch

**Additional TODOs**:
- Add biometric authentication (Face ID/Touch ID)
- Add "Remember Me" functionality
- Add "Forgot Password" flow
- Add real-time input validation
- Add password strength indicator
- Add loading spinner during login
- Add error alert/toast messages
- Add keyboard dismiss on tap
- Add accessibility labels
- Add localization support

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
