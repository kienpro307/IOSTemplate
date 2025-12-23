# Accessibility Testing Guide

## Overview

This guide provides comprehensive accessibility testing procedures for the iOS Template project. Accessibility ensures that all users, including those with disabilities, can use the app effectively.

## Table of Contents

1. [Testing Tools](#testing-tools)
2. [VoiceOver Testing](#voiceover-testing)
3. [Dynamic Type Testing](#dynamic-type-testing)
4. [Color Contrast Testing](#color-contrast-testing)
5. [Touch Target Testing](#touch-target-testing)
6. [Keyboard Navigation](#keyboard-navigation)
7. [Reduce Motion](#reduce-motion)
8. [Automated Tests](#automated-tests)

---

## Testing Tools

### Xcode Accessibility Inspector

1. **Open Accessibility Inspector**
   - Xcode → Open Developer Tool → Accessibility Inspector
   - Or: `Cmd + Shift + 2` while running simulator

2. **Features**
   - Inspect element properties
   - Audit accessibility issues
   - Run automated tests
   - Simulate VoiceOver

### iOS Settings

Enable accessibility features in iOS:

```
Settings → Accessibility
- VoiceOver
- Display & Text Size → Larger Text
- Motion → Reduce Motion
- Display & Text Size → Increase Contrast
```

---

## VoiceOver Testing

### Manual Testing Steps

1. **Enable VoiceOver**
   ```
   Settings → Accessibility → VoiceOver → On
   Or: Triple-click home button (if configured)
   ```

2. **Basic Gestures**
   - **Single tap**: Select element
   - **Double tap**: Activate element
   - **Swipe right**: Next element
   - **Swipe left**: Previous element
   - **Two-finger swipe up**: Read all from current position
   - **Rotor (two fingers rotate)**: Navigation mode

3. **Test Checklist**
   - [ ] All interactive elements are accessible
   - [ ] Labels are descriptive and meaningful
   - [ ] Reading order is logical
   - [ ] Images have meaningful descriptions
   - [ ] Buttons clearly describe their action
   - [ ] Form fields have labels
   - [ ] Error messages are announced
   - [ ] Loading states are announced
   - [ ] Navigation is clear

### VoiceOver Best Practices

**DO:**
```swift
Button("Login") { }
    .accessibilityLabel("Login to your account")
    .accessibilityHint("Double tap to login")

Image("profile")
    .accessibilityLabel("User profile picture")
```

**DON'T:**
```swift
// Bad - no accessibility label
Button { } label: {
    Image(systemName: "arrow.right")
}

// Bad - redundant "button" in label
Button("Submit") { }
    .accessibilityLabel("Submit button") // VoiceOver already says "button"
```

---

## Dynamic Type Testing

### Testing Different Sizes

1. **Enable Larger Text**
   ```
   Settings → Accessibility → Display & Text Size → Larger Text
   ```

2. **Test All Sizes**
   - Extra Small (xSmall)
   - Small
   - Medium (Default)
   - Large
   - Extra Large (xLarge)
   - Extra Extra Large (xxLarge)
   - Extra Extra Extra Large (xxxLarge)

3. **Accessibility Sizes**
   - Accessibility Medium (accessibilityMedium)
   - Accessibility Large (accessibilityLarge)
   - Accessibility Extra Large (accessibilityExtraLarge)
   - Accessibility Extra Extra Large (accessibilityExtraExtraLarge)
   - Accessibility Extra Extra Extra Large (accessibilityExtraExtraExtraLarge)

### Test Checklist

- [ ] Text doesn't truncate
- [ ] Layouts adapt to larger text
- [ ] Buttons remain tappable
- [ ] No overlapping elements
- [ ] Scrolling works properly
- [ ] All content is readable

### Implementation

```swift
Text("Welcome")
    .font(.title)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge

VStack {
    Text("Label")
    Text("Value")
}
.dynamicTypeSize(.large...DynamicTypeSize.accessibility5) // Support all sizes
```

---

## Color Contrast Testing

### WCAG Standards

- **Normal text**: 4.5:1 minimum contrast ratio
- **Large text** (18pt+ or 14pt+ bold): 3:1 minimum
- **UI components**: 3:1 minimum

### Testing Tools

1. **Xcode Accessibility Inspector**
   - Select element
   - View "Contrast" section
   - Check ratio against background

2. **Online Tools**
   - [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
   - [Contrast Ratio Calculator](https://contrast-ratio.com/)

### Test Checklist

- [ ] Text on background meets 4.5:1
- [ ] Large text meets 3:1
- [ ] Buttons meet 3:1
- [ ] Icons meet 3:1
- [ ] Focus indicators meet 3:1
- [ ] Error states meet contrast requirements

### Implementation

```swift
// Good contrast
Text("Title")
    .foregroundColor(.primary) // Adapts to light/dark mode
    .background(Color.theme.background)

// Support high contrast mode
Text("Important")
    .foregroundColor(Color.primary)
    .environment(\.accessibilityReduceTransparency, true)
```

---

## Touch Target Testing

### Apple HIG Requirements

- **Minimum size**: 44x44 points
- **Recommended**: 48x48 points or larger
- **Spacing**: 8pt minimum between targets

### Test Checklist

- [ ] All buttons are at least 44x44pt
- [ ] Tap targets don't overlap
- [ ] Small icons have padding to increase hit area
- [ ] List items are easy to tap

### Implementation

```swift
// Expand hit area
Button("Action") { }
    .frame(minWidth: 44, minHeight: 44)

// Add padding to small icons
Image(systemName: "star")
    .font(.system(size: 20))
    .padding()
    .frame(minWidth: 44, minHeight: 44)

// List items
Button { } label: {
    HStack {
        Text("Item")
        Spacer()
    }
    .frame(minHeight: 44)
}
```

---

## Keyboard Navigation

### Test Checklist

- [ ] Tab order is logical
- [ ] All interactive elements are reachable
- [ ] Focus indicators are visible
- [ ] Return key moves to next field
- [ ] Done button dismisses keyboard
- [ ] Form validation works with keyboard

### Implementation

```swift
TextField("Email", text: $email)
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)
    .submitLabel(.next)
    .onSubmit {
        // Move to next field
        focusedField = .password
    }

TextField("Password", text: $password)
    .textContentType(.password)
    .keyboardType(.default)
    .submitLabel(.done)
    .onSubmit {
        // Submit form
        login()
    }
```

---

## Reduce Motion

### Testing

1. **Enable Reduce Motion**
   ```
   Settings → Accessibility → Motion → Reduce Motion
   ```

2. **Test Checklist**
   - [ ] Animations are minimal or removed
   - [ ] Parallax effects are disabled
   - [ ] Screen transitions are simple
   - [ ] Functionality remains intact
   - [ ] No functionality depends on motion

### Implementation

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    VStack {
        // ...
    }
    .animation(reduceMotion ? .none : .spring(), value: showDetail)
}

// Alternative transitions
.transition(
    reduceMotion ? .opacity : .slide
)
```

---

## Automated Tests

### XCTest Accessibility Tests

See `AccessibilityUITests.swift` for automated tests covering:

- VoiceOver label verification
- Touch target size validation
- Reading order verification
- Color contrast checks (manual verification needed)
- Keyboard navigation

### Running Tests

```bash
# Run all accessibility tests
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSTemplateUITests/AccessibilityUITests

# Run specific test
xcodebuild test \
  -scheme iOSTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSTemplateUITests/AccessibilityUITests/test_accessibility_minTouchTargetSize
```

---

## Accessibility Audit Checklist

### Before Release

- [ ] Run Xcode Accessibility Inspector audit
- [ ] Test with VoiceOver enabled
- [ ] Test all Dynamic Type sizes
- [ ] Verify color contrast ratios
- [ ] Check touch target sizes
- [ ] Test with Reduce Motion enabled
- [ ] Test with Increase Contrast enabled
- [ ] Test keyboard navigation
- [ ] Review accessibility labels
- [ ] Test error announcements
- [ ] Verify loading state announcements

### Continuous Testing

- [ ] Include accessibility in code review
- [ ] Run automated accessibility tests in CI
- [ ] Test new features with VoiceOver
- [ ] Update accessibility labels when UI changes
- [ ] Monitor accessibility-related crashes

---

## Common Issues and Fixes

### Issue: Button not accessible

**Problem:**
```swift
Button { action() } label: {
    Image(systemName: "plus")
}
```

**Fix:**
```swift
Button { action() } label: {
    Image(systemName: "plus")
}
.accessibilityLabel("Add item")
```

### Issue: Custom view not accessible

**Problem:**
```swift
struct CustomButton: View {
    var body: some View {
        VStack {
            Image(systemName: "star")
            Text("Favorite")
        }
    }
}
```

**Fix:**
```swift
struct CustomButton: View {
    var body: some View {
        VStack {
            Image(systemName: "star")
            Text("Favorite")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Favorite")
        .accessibilityHint("Double tap to favorite this item")
    }
}
```

### Issue: Text truncated at large sizes

**Problem:**
```swift
Text("Long text here")
    .frame(width: 200)
```

**Fix:**
```swift
Text("Long text here")
    .lineLimit(nil)
    .fixedSize(horizontal: false, vertical: true)
```

---

## Resources

### Apple Documentation

- [Accessibility Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Supporting VoiceOver](https://developer.apple.com/documentation/accessibility/supporting-voiceover-in-your-app)
- [Accessibility Modifiers](https://developer.apple.com/documentation/swiftui/view-accessibility)

### WCAG Guidelines

- [WCAG 2.1 Overview](https://www.w3.org/WAI/WCAG21/quickref/)
- [Understanding WCAG](https://www.w3.org/WAI/WCAG21/Understanding/)

### Testing Tools

- [Xcode Accessibility Inspector](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/OSXAXTestingApps.html)
- [Accessibility Scanner](https://support.google.com/accessibility/android/answer/6376570)

---

## Contact

For accessibility questions or issues:
- Review Apple's Accessibility documentation
- Test with real users who use accessibility features
- Use Xcode's Accessibility Inspector
- Follow WCAG 2.1 Level AA guidelines
