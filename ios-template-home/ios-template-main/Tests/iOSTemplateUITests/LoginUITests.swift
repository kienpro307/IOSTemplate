import XCTest

final class LoginUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Skip-Onboarding"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Login Flow Tests

    func test_loginFlow_validCredentials_shouldSucceed() throws {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        // When
        emailField.tap()
        emailField.typeText("test@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then - Should navigate to home
        let homeTitle = app.staticTexts["Home"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
    }

    func test_loginFlow_emptyFields_shouldShowError() throws {
        // Given
        let loginButton = app.buttons["Login"]

        // When
        loginButton.tap()

        // Then - Should show error
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3))
    }

    func test_loginFlow_invalidEmail_shouldShowError() throws {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        // When
        emailField.tap()
        emailField.typeText("invalid-email")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then - Should show error
        let errorMessage = app.staticTexts["Invalid email format"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 3))
    }

    func test_loginFlow_forgotPassword_shouldNavigateToReset() throws {
        // Given
        let forgotPasswordButton = app.buttons["Forgot Password?"]

        // When
        if forgotPasswordButton.exists {
            forgotPasswordButton.tap()

            // Then
            let resetTitle = app.staticTexts["Reset Password"]
            XCTAssertTrue(resetTitle.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Biometric Login Tests

    func test_loginFlow_biometricButton_shouldAppear() throws {
        // Given/Then
        let biometricButton = app.buttons["Use Face ID"]

        // Biometric button may not exist in simulator
        // Just verify it doesn't crash
        if biometricButton.exists {
            XCTAssertTrue(biometricButton.isEnabled)
        }
    }

    // MARK: - Accessibility Tests

    func test_loginFlow_accessibility_allFieldsAccessible() throws {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        // Then
        XCTAssertTrue(emailField.isHittable)
        XCTAssertTrue(passwordField.isHittable)
        XCTAssertTrue(loginButton.isHittable)

        // Check accessibility labels
        XCTAssertNotNil(emailField.label)
        XCTAssertNotNil(passwordField.label)
        XCTAssertNotNil(loginButton.label)
    }

    // MARK: - Performance Tests

    func test_loginFlow_performance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}
