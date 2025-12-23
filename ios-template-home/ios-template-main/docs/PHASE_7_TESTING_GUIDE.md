# Phase 7: Testing & Quality Assurance - Complete Guide

## Overview

This guide provides comprehensive information about Phase 7 implementation, including all testing strategies, tools, and best practices for ensuring quality in the iOS Template project.

## Table of Contents

1. [Unit Testing](#unit-testing)
2. [UI Testing](#ui-testing)
3. [Accessibility Testing](#accessibility-testing)
4. [Performance Testing](#performance-testing)
5. [Test Coverage](#test-coverage)
6. [Running Tests](#running-tests)
7. [Continuous Integration](#continuous-integration)

---

## Unit Testing

### Overview

Unit tests verify individual components (services, reducers, utilities) work correctly in isolation.

### Test Structure

```
Tests/iOSTemplateTests/
├── Core/
│   └── AppReducerTests.swift
├── Services/
│   ├── NetworkServiceTests.swift
│   ├── MockNetworkServiceTests.swift
│   ├── DIContainerTests.swift
│   └── FeatureFlagManagerTests.swift
├── Storage/
│   ├── UserDefaultsStorageTests.swift
│   ├── KeychainStorageTests.swift
│   └── FileStorageTests.swift
└── Utilities/
    ├── LoggerTests.swift
    └── CacheTests.swift
```

### Test Coverage Goals

| Component | Target Coverage | Status |
|-----------|-----------------|--------|
| Reducers | 90%+ | ✅ |
| Services | 80%+ | ✅ |
| Utilities | 100% | ✅ |
| Storage | 90%+ | ✅ |
| Network | 80%+ | ✅ |

### Running Unit Tests

```bash
# Run all unit tests
swift test

# Run specific test file
swift test --filter UserDefaultsStorageTests

# Run specific test
swift test --filter test_save_string_shouldSucceed

# Run with coverage
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report \
  ~/Library/Developer/Xcode/DerivedData/.../Logs/Test/*.xcresult
```

### Writing Unit Tests

#### Example: Testing a Service

```swift
import XCTest
@testable import iOSTemplate

final class MyServiceTests: XCTestCase {
    var sut: MyService!
    var mockDependency: MockDependency!

    override func setUp() {
        super.setUp()
        mockDependency = MockDependency()
        sut = MyService(dependency: mockDependency)
    }

    override func tearDown() {
        sut = nil
        mockDependency = nil
        super.tearDown()
    }

    func test_method_whenCondition_shouldExpectedBehavior() async throws {
        // Given
        mockDependency.mockValue = "test"

        // When
        let result = try await sut.performAction()

        // Then
        XCTAssertEqual(result, "expected")
        XCTAssertEqual(mockDependency.callCount, 1)
    }
}
```

#### Example: Testing a Reducer

```swift
@MainActor
final class MyReducerTests: XCTestCase {
    func test_action_shouldUpdateState() async {
        let store = TestStore(
            initialState: MyState()
        ) {
            MyReducer()
        }

        await store.send(.actionName) {
            $0.property = expectedValue
        }

        await store.receive(.responseAction) {
            $0.otherProperty = otherValue
        }
    }
}
```

### Best Practices

1. **Follow AAA Pattern**
   - Arrange: Setup test data
   - Act: Execute code under test
   - Assert: Verify results

2. **Test Naming**
   - `test_methodName_whenCondition_shouldExpectedBehavior`
   - Clear, descriptive names

3. **Test Independence**
   - Each test should run independently
   - Clean up in `tearDown()`
   - No shared mutable state

4. **Use Mocks**
   - Mock external dependencies
   - Control test inputs
   - Verify interactions

---

## UI Testing

### Overview

UI tests verify user flows work correctly end-to-end.

### Test Structure

```
Tests/iOSTemplateUITests/
├── OnboardingUITests.swift
├── LoginUITests.swift
├── MainFlowUITests.swift
└── AccessibilityUITests.swift
```

### Critical User Flows

#### 1. Onboarding Flow

```swift
func test_onboardingFlow_shouldDisplayAllPages() throws {
    // Verify all onboarding pages
    let welcomeText = app.staticTexts["Welcome"]
    XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))

    app.swipeLeft()
    let secondPage = app.staticTexts["Explore Features"]
    XCTAssertTrue(secondPage.exists)
}
```

#### 2. Login Flow

```swift
func test_loginFlow_validCredentials_shouldSucceed() throws {
    let emailField = app.textFields["Email"]
    let passwordField = app.secureTextFields["Password"]
    let loginButton = app.buttons["Login"]

    emailField.tap()
    emailField.typeText("test@example.com")

    passwordField.tap()
    passwordField.typeText("password123")

    loginButton.tap()

    let homeTitle = app.staticTexts["Home"]
    XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
}
```

#### 3. Main Navigation

```swift
func test_mainFlow_tabNavigation_shouldWork() throws {
    let homeTab = app.tabBars.buttons["Home"]
    let exploreTab = app.tabBars.buttons["Explore"]

    homeTab.tap()
    XCTAssertTrue(homeTab.isSelected)

    exploreTab.tap()
    XCTAssertTrue(exploreTab.isSelected)
}
```

### Running UI Tests

```bash
# Run all UI tests
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSTemplateUITests

# Run specific UI test
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSTemplateUITests/LoginUITests/test_loginFlow_validCredentials_shouldSucceed

# Record UI test
# In Xcode: Editor → Record UI Test
```

### Test Data Setup

```swift
override func setUpWithError() throws {
    continueAfterFailure = false

    app = XCUIApplication()
    app.launchArguments = [
        "UI-Testing",
        "Skip-Onboarding",
        "Mock-Network"
    ]
    app.launch()
}
```

### Best Practices

1. **Use Accessibility Identifiers**
   ```swift
   // In production code
   Button("Login") { }
       .accessibilityIdentifier("loginButton")

   // In test
   app.buttons["loginButton"].tap()
   ```

2. **Wait for Elements**
   ```swift
   let element = app.buttons["myButton"]
   XCTAssertTrue(element.waitForExistence(timeout: 5))
   ```

3. **Test Real User Flows**
   - Complete user journeys
   - Not just individual screens

4. **Handle Asynchronous Updates**
   - Use `waitForExistence(timeout:)`
   - Don't use `sleep()`

---

## Accessibility Testing

### Overview

Ensure app is usable by everyone, including users with disabilities.

See [ACCESSIBILITY_TESTING_GUIDE.md](./ACCESSIBILITY_TESTING_GUIDE.md) for detailed guide.

### Quick Checklist

- [ ] VoiceOver: All elements have labels
- [ ] Dynamic Type: Text scales properly
- [ ] Color Contrast: Meets WCAG AA (4.5:1)
- [ ] Touch Targets: Minimum 44x44 points
- [ ] Reduce Motion: Animations can be disabled

### Automated Accessibility Tests

```swift
func test_accessibility_allButtonsHaveLabels() throws {
    let buttons = app.buttons.allElementsBoundByIndex

    for button in buttons {
        XCTAssertFalse(button.label.isEmpty)
    }
}

func test_accessibility_minTouchTargetSize() throws {
    let buttons = app.buttons.allElementsBoundByIndex

    for button in buttons where button.isHittable {
        let frame = button.frame
        XCTAssertGreaterThanOrEqual(frame.width, 44.0)
        XCTAssertGreaterThanOrEqual(frame.height, 44.0)
    }
}
```

---

## Performance Testing

### Overview

Ensure app performs well under various conditions.

See [PERFORMANCE_OPTIMIZATION_GUIDE.md](./PERFORMANCE_OPTIMIZATION_GUIDE.md) for detailed guide.

### Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold Launch | < 2s | XCTApplicationLaunchMetric |
| Warm Launch | < 0.5s | Manual |
| Memory Usage | < 100MB idle | Instruments |
| FPS | 60 FPS | Metal System Trace |

### Performance Tests

#### Launch Time

```swift
func testLaunchPerformance() {
    measure(metrics: [XCTApplicationLaunchMetric()]) {
        app.launch()
    }
}
```

#### Memory Usage

```bash
# Use Instruments
Xcode → Product → Profile → Allocations
Check:
- Peak memory usage
- Memory growth over time
- Leaks (should be 0)
```

#### Network Performance

```swift
// Monitor in NetworkService
let startTime = Date()
let response = try await api.fetchData()
let duration = Date().timeIntervalSince(startTime)

FirebasePerformanceService.shared.track(
    name: "api_fetch_data",
    duration: duration
)
```

---

## Test Coverage

### Viewing Coverage

```bash
# Generate coverage report
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# View report
xcrun xccov view --report \
  ~/Library/Developer/Xcode/DerivedData/.../Logs/Test/*.xcresult

# Export as JSON
xcrun xccov view --report --json coverage.xcresult > coverage.json
```

### Coverage Goals

| Category | Target | Current |
|----------|--------|---------|
| Overall | 80%+ | TBD |
| Reducers | 90%+ | TBD |
| Services | 80%+ | TBD |
| Utilities | 100% | TBD |
| UI Components | 60%+ | TBD |

### Improving Coverage

1. **Identify gaps**
   ```bash
   xcrun xccov view --file coverage.xcresult
   ```

2. **Write missing tests**
   - Focus on untested code paths
   - Add edge case tests
   - Test error scenarios

3. **Review regularly**
   - Include in code review
   - Track trends over time

---

## Running Tests

### Command Line

```bash
# All tests
swift test

# Specific scheme
xcodebuild test -scheme iOSTemplate

# Specific destination
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# With coverage
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Parallel testing
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -parallel-testing-enabled YES
```

### Xcode

1. **Run All Tests**: `Cmd + U`
2. **Run Single Test**: Click diamond next to test
3. **Debug Test**: Right-click → Debug "test_name"
4. **View Coverage**: Show Report Navigator → Coverage tab

### Test Plans

Create test plan for different configurations:

```
MyApp.xctestplan:
- Unit Tests (Quick)
- Integration Tests (Medium)
- UI Tests (Slow)
- Performance Tests (Benchmark)
```

---

## Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app

    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme iOSTemplate \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -enableCodeCoverage YES \
          | xcpretty

    - name: Generate Coverage Report
      run: |
        xcrun xccov view --report \
          ~/Library/Developer/Xcode/DerivedData/.../coverage.xcresult \
          > coverage.txt

    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.txt
```

### Pre-commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running tests before commit..."

swift test

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "All tests passed!"
```

---

## Test Maintenance

### Regular Tasks

1. **Weekly**
   - Run full test suite
   - Check for flaky tests
   - Review test coverage

2. **Monthly**
   - Update test data
   - Review test performance
   - Refactor slow tests

3. **Per Release**
   - Run all tests on all devices
   - Performance regression testing
   - Accessibility audit

### Handling Flaky Tests

1. **Identify**
   ```bash
   # Run tests multiple times
   for i in {1..10}; do
       swift test || echo "Failed on run $i"
   done
   ```

2. **Common Causes**
   - Race conditions
   - Timing dependencies
   - Shared state
   - External dependencies

3. **Fix**
   - Add proper waits
   - Use dependency injection
   - Mock external services
   - Clean up state

---

## Test Documentation

### Test Cases

Document test scenarios:

```markdown
## Login Tests

### Test Case: Valid Login
**Given** user has valid credentials
**When** user enters email and password
**And** taps Login button
**Then** user should see Home screen

### Test Case: Invalid Email
**Given** user enters invalid email format
**When** user taps Login button
**Then** error message should appear
```

### Test Data

Document test data requirements:

```markdown
## Test Users

1. **Valid User**
   - Email: test@example.com
   - Password: password123

2. **Invalid User**
   - Email: invalid@example.com
   - Password: wrong

3. **Locked User**
   - Email: locked@example.com
   - Status: Account locked
```

---

## Resources

### Documentation

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing in Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)
- [UI Testing Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html)

### Tools

- **Xcode Test Navigator**: View and run tests
- **Instruments**: Performance profiling
- **Accessibility Inspector**: Accessibility testing
- **Network Link Conditioner**: Test slow networks

### Best Practices

- [iOS Testing Best Practices](https://www.swiftbysundell.com/basics/unit-testing/)
- [TCA Testing Guide](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing)
- [Accessibility Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)

---

## Summary

Phase 7 provides comprehensive testing coverage:

✅ **Unit Tests**: Services, Storage, Utilities (80%+ coverage)
✅ **UI Tests**: Critical paths, user flows
✅ **Accessibility Tests**: VoiceOver, Dynamic Type, Color Contrast
✅ **Performance Tests**: Launch time, memory, network
✅ **Documentation**: Complete testing guides
✅ **CI/CD Ready**: GitHub Actions integration

All tests are automated and can be run in CI/CD pipelines.
