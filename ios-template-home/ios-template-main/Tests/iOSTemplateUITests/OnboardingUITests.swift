import XCTest

final class OnboardingUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Flow Tests

    func test_onboardingFlow_shouldDisplayAllPages() throws {
        // Given - Fresh install
        // Reset onboarding state if needed

        // Then - Should show onboarding
        let welcomeText = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))

        // When - Swipe through pages
        app.swipeLeft()

        // Then - Should show second page
        let secondPageText = app.staticTexts["Explore Features"]
        XCTAssertTrue(secondPageText.exists)

        // When - Swipe to third page
        app.swipeLeft()

        // Then - Should show third page
        let thirdPageText = app.staticTexts["Get Started"]
        XCTAssertTrue(thirdPageText.exists)
    }

    func test_onboardingFlow_skipButton_shouldNavigateToLogin() throws {
        // Given
        let skipButton = app.buttons["Skip"]

        // When
        if skipButton.exists {
            skipButton.tap()
        }

        // Then - Should navigate to login
        let loginTitle = app.staticTexts["Login"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 3))
    }

    func test_onboardingFlow_completeButton_shouldNavigateToLogin() throws {
        // Given - Navigate to last page
        app.swipeLeft()
        app.swipeLeft()

        let completeButton = app.buttons["Get Started"]

        // When
        completeButton.tap()

        // Then - Should navigate to login
        let loginTitle = app.staticTexts["Login"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Accessibility Tests

    func test_onboardingFlow_accessibility_allElementsShouldBeAccessible() throws {
        // Given
        let welcomeText = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))

        // Then - All elements should be accessible
        XCTAssertTrue(welcomeText.isHittable)

        if app.buttons["Skip"].exists {
            XCTAssertTrue(app.buttons["Skip"].isHittable)
        }

        // Test page indicator
        let pageIndicator = app.pageIndicators.firstMatch
        if pageIndicator.exists {
            XCTAssertTrue(pageIndicator.isHittable)
        }
    }
}
