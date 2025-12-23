import XCTest

final class MainFlowUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Logged-In"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    func test_mainFlow_tabNavigation_shouldWork() throws {
        // Given - Should start on Home tab
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        XCTAssertTrue(homeTab.isSelected)

        // When - Navigate to Explore
        let exploreTab = app.tabBars.buttons["Explore"]
        exploreTab.tap()

        // Then
        XCTAssertTrue(exploreTab.isSelected)
        let exploreTitle = app.navigationBars["Explore"].firstMatch
        XCTAssertTrue(exploreTitle.exists)

        // When - Navigate to Profile
        let profileTab = app.tabBars.buttons["Profile"]
        profileTab.tap()

        // Then
        XCTAssertTrue(profileTab.isSelected)

        // When - Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Then
        XCTAssertTrue(settingsTab.isSelected)
    }

    func test_mainFlow_homeTab_shouldDisplayContent() throws {
        // Given
        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()

        // Then - Should show home content
        let welcomeMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Welcome'")).firstMatch
        XCTAssertTrue(welcomeMessage.waitForExistence(timeout: 3))
    }

    func test_mainFlow_profileTab_shouldDisplayUserInfo() throws {
        // Given
        let profileTab = app.tabBars.buttons["Profile"]

        // When
        profileTab.tap()

        // Then - Should show user profile
        let profileTitle = app.staticTexts["Profile"]
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 3))
    }

    func test_mainFlow_settingsTab_shouldDisplayOptions() throws {
        // Given
        let settingsTab = app.tabBars.buttons["Settings"]

        // When
        settingsTab.tap()

        // Then - Should show settings
        let settingsTitle = app.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))

        // Should have common settings options
        let themeOption = app.cells.containing(NSPredicate(format: "label CONTAINS[c] 'Theme'")).firstMatch
        let notificationOption = app.cells.containing(NSPredicate(format: "label CONTAINS[c] 'Notification'")).firstMatch

        // At least one setting should be visible
        XCTAssertTrue(themeOption.exists || notificationOption.exists)
    }

    // MARK: - Logout Flow Tests

    func test_mainFlow_logout_shouldReturnToLogin() throws {
        // Given - Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // When - Tap logout
        let logoutButton = app.buttons["Logout"]
        if logoutButton.exists {
            logoutButton.tap()

            // Then - Should return to login
            let loginTitle = app.staticTexts["Login"]
            XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Accessibility Tests

    func test_mainFlow_accessibility_tabBarAccessible() throws {
        // Then - All tab bar items should be accessible
        let homeTab = app.tabBars.buttons["Home"]
        let exploreTab = app.tabBars.buttons["Explore"]
        let profileTab = app.tabBars.buttons["Profile"]
        let settingsTab = app.tabBars.buttons["Settings"]

        XCTAssertTrue(homeTab.isHittable)
        XCTAssertTrue(exploreTab.isHittable)
        XCTAssertTrue(profileTab.isHittable)
        XCTAssertTrue(settingsTab.isHittable)
    }

    // MARK: - State Persistence Tests

    func test_mainFlow_statePersistence_shouldMaintainSelectedTab() throws {
        // Given - Select Profile tab
        let profileTab = app.tabBars.buttons["Profile"]
        profileTab.tap()

        // When - Background and foreground app
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.activate()

        // Then - Should still be on Profile tab
        XCTAssertTrue(profileTab.isSelected)
    }
}
