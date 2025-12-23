# App Store Submission Checklist

Complete checklist for submitting iOS Template to App Store.

---

## 📋 Pre-Submission Checklist

### 1. App Completion

- [ ] All features implemented and working
- [ ] No placeholder content or "Lorem Ipsum"
- [ ] All UI screens designed and polished
- [ ] Dark mode tested and working
- [ ] All device sizes tested (iPhone, iPad)
- [ ] Landscape and portrait orientations working (if supported)
- [ ] App doesn't crash on launch
- [ ] No console errors or warnings

### 2. Testing

- [ ] Tested on physical device
- [ ] Tested on multiple iOS versions (16.0+)
- [ ] Tested on multiple device sizes
- [ ] Unit tests passing
- [ ] UI tests passing
- [ ] Performance tested (no lag, smooth animations)
- [ ] Memory leaks checked
- [ ] Network error handling tested
- [ ] Offline functionality tested (if applicable)

### 3. App Store Connect Setup

- [ ] App created in App Store Connect
- [ ] Bundle ID matches project
- [ ] App name available (max 30 characters)
- [ ] SKU configured
- [ ] Version number set (1.0.0)
- [ ] Build number set

### 4. Screenshots

- [ ] 6.7" iPhone screenshots (1290 x 2796) - REQUIRED
  - [ ] Minimum 3 screenshots
  - [ ] Maximum 10 screenshots
  - [ ] PNG or JPEG format
  - [ ] Show key features

- [ ] 5.5" iPhone screenshots (1242 x 2208) - Optional
  - [ ] Minimum 3 screenshots
  - [ ] Same content as 6.7" version

- [ ] 12.9" iPad screenshots (2048 x 2732) - If iPad supported
  - [ ] Minimum 3 screenshots
  - [ ] iPad-optimized UI shown

- [ ] All screenshots:
  - [ ] Use actual app UI (no mockups)
  - [ ] High quality, not blurry
  - [ ] Correct orientation
  - [ ] No status bar issues
  - [ ] Proper text readability

### 5. App Icon

- [ ] 1024x1024 App Store icon created
- [ ] PNG or JPEG format
- [ ] RGB color space
- [ ] No transparency
- [ ] No alpha channels
- [ ] Rounded corners NOT applied (iOS adds automatically)
- [ ] Icon looks good at all sizes
- [ ] Tested on light and dark backgrounds
- [ ] All app icon sizes in Assets.xcassets

### 6. Metadata

- [ ] App Name (max 30 characters)
  ```
  iOS Template
  ```

- [ ] Subtitle (max 30 characters)
  ```
  Modern iOS Development Template
  ```

- [ ] Description (max 4000 characters)
  - [ ] Compelling opening
  - [ ] Key features listed
  - [ ] Benefits explained
  - [ ] Call to action
  - [ ] No grammar/spelling errors

- [ ] Keywords (max 100 characters)
  ```
  ios,template,swift,swiftui,development,app,tca,firebase,developer,tools
  ```
  - [ ] Relevant to app
  - [ ] No competitor names
  - [ ] No category names
  - [ ] Comma-separated

- [ ] Promotional Text (max 170 characters)
  - [ ] Highlights current features/promotions
  - [ ] Can be updated without resubmission

- [ ] What's New (for updates, max 4000 characters)
  - [ ] Lists new features
  - [ ] Bug fixes mentioned
  - [ ] Thank users

### 7. URLs

- [ ] Support URL
  ```
  https://github.com/kienpro307/ios-template
  ```
  - [ ] Valid and accessible
  - [ ] Provides actual support

- [ ] Marketing URL (optional)
  ```
  https://yourwebsite.com
  ```

- [ ] Privacy Policy URL (REQUIRED)
  ```
  https://yourwebsite.com/privacy
  ```
  - [ ] Accessible without login
  - [ ] Describes data collection
  - [ ] Describes data usage
  - [ ] Contact information included

### 8. Categories

- [ ] Primary Category selected
  ```
  Developer Tools
  ```

- [ ] Secondary Category (optional)
  ```
  Productivity
  ```

### 9. Age Rating

- [ ] Age Rating questionnaire completed
- [ ] Appropriate rating assigned (4+, 9+, 12+, 17+)
- [ ] Content accurately described

Example for iOS Template:
```
Rating: 4+
Reasons:
- No objectionable content
- No violence
- No mature themes
```

### 10. Pricing & Availability

- [ ] Price tier selected
  ```
  Free (or your choice)
  ```

- [ ] Territories selected
  ```
  All countries (or specific)
  ```

- [ ] Release date chosen
  - [ ] Automatic (when approved)
  - [ ] Manual
  - [ ] Scheduled date

### 11. App Privacy

- [ ] Privacy nutrition label completed
- [ ] Data collection disclosed
  - [ ] Contact Info
  - [ ] User ID
  - [ ] Usage Data
  - [ ] Diagnostics
  - [ ] etc.

- [ ] Data linked to user (if applicable)
- [ ] Data used for tracking (if applicable)
- [ ] Third-party SDKs disclosed (Firebase, etc.)

### 12. App Review Information

- [ ] Contact information provided
  - [ ] First name
  - [ ] Last name
  - [ ] Email
  - [ ] Phone number

- [ ] Demo account credentials (if login required)
  ```
  Email: test@example.com
  Password: TestPassword123
  ```

- [ ] Notes for reviewer
  ```
  - This is a developer template app
  - No login required for main features
  - Firebase services configured
  ```

- [ ] Attachment files (if needed)
  - [ ] Documents
  - [ ] Videos
  - [ ] Screenshots

### 13. Export Compliance

- [ ] Export compliance information provided
- [ ] Encryption usage declared
  ```
  For iOS Template:
  ☑️ App uses standard encryption (HTTPS)
  ☐ App uses proprietary encryption
  ```

- [ ] If using encryption:
  - [ ] ERN (Encryption Registration Number) provided
  - [ ] OR exemption claimed

### 14. Build

- [ ] Archive created successfully
- [ ] Archive validated (no errors)
- [ ] Build uploaded to App Store Connect
- [ ] Build processing completed
- [ ] Build assigned to version
- [ ] dSYMs uploaded (for crash reports)
- [ ] Build number unique

### 15. Final Checks

- [ ] All fields completed in App Store Connect
- [ ] No red flags or missing information
- [ ] Screenshots match app functionality
- [ ] App version matches build version
- [ ] Copyright information correct
- [ ] App ready for review

---

## 🚀 Submission Steps

### Step 1: Prepare Build

```bash
# 1. Ensure clean git state
git status

# 2. Bump version
fastlane bump_version type:major  # or minor/patch

# 3. Run tests
fastlane test

# 4. Build and upload
fastlane beta  # TestFlight
# or
fastlane release  # App Store
```

### Step 2: Complete App Store Connect

1. Login to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Click "+" to create new version
4. Fill all required information:
   - Screenshots
   - Description
   - Keywords
   - etc.
5. Select build
6. Complete all sections until no errors

### Step 3: Submit for Review

1. Review all information
2. Click "Submit for Review"
3. Confirm submission
4. Wait for review (2-7 days typically)

### Step 4: Monitor Status

```
Waiting for Review → In Review → Approved/Rejected
```

- Check App Store Connect daily
- Respond to any App Review messages within 24 hours
- Monitor email for updates

### Step 5: Release

Once approved:

**Manual Release:**
1. Go to App Store Connect
2. Click "Release This Version"
3. App goes live in ~24 hours

**Automatic Release:**
- App releases immediately after approval

---

## ⚠️ Common Rejection Reasons

### 1. Crashes and Bugs

**Issue:** App crashes on launch or during use

**Solution:**
- Test thoroughly before submission
- Fix all crashes
- Handle all error cases

### 2. Incomplete Information

**Issue:** Missing required metadata or screenshots

**Solution:**
- Complete ALL fields in App Store Connect
- Follow size requirements exactly
- Provide accurate information

### 3. Privacy Issues

**Issue:** Privacy policy missing or inadequate

**Solution:**
- Include comprehensive privacy policy
- Accurately disclose data collection
- Provide opt-out mechanisms

### 4. Design Issues

**Issue:** UI doesn't match iOS guidelines

**Solution:**
- Follow [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- Use native iOS components
- Ensure accessibility

### 5. Functionality Issues

**Issue:** App doesn't work as described

**Solution:**
- Ensure description matches functionality
- All advertised features work
- Provide clear instructions

### 6. Content Issues

**Issue:** Inappropriate or misleading content

**Solution:**
- Remove placeholder content
- Accurate screenshots
- Honest description

### 7. Guideline Violations

**Issue:** Violates App Store Review Guidelines

**Solution:**
- Read [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Comply with all rules
- Remove prohibited content

---

## 📧 Communication with App Review

### If Rejected

1. **Read rejection message carefully**
2. **Understand the issue**
3. **Fix the problem**
4. **Respond in Resolution Center** (if needed)
5. **Resubmit**

### Response Template

```
Dear App Review Team,

Thank you for your feedback regarding [Issue].

We have addressed this by [Your fix].

Specifically:
- [Change 1]
- [Change 2]
- [Change 3]

We believe the app now complies with [Guideline X.X].

Please let us know if you need any additional information.

Thank you for your time.

Best regards,
[Your Name]
```

---

## 📊 Post-Submission

### Monitor

- [ ] App Review status
- [ ] Crash reports
- [ ] User reviews
- [ ] Analytics

### Respond

- [ ] Reply to user reviews
- [ ] Fix critical bugs quickly
- [ ] Plan updates based on feedback

### Update

- [ ] Regular updates every 1-2 months
- [ ] Fix bugs
- [ ] Add requested features
- [ ] Improve based on analytics

---

## 🎉 After Approval

### Celebrate! 🎊

Your app is live on the App Store!

### Next Steps

1. **Monitor Analytics**
   - Downloads
   - Active users
   - Retention
   - Crash-free rate

2. **Gather Feedback**
   - Read reviews
   - Track support requests
   - Monitor social media

3. **Plan Updates**
   - Bug fixes
   - New features
   - Performance improvements

4. **Marketing**
   - Share on social media
   - Write blog post
   - Submit to app directories
   - Reach out to press

---

## 📚 Resources

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Product Page](https://developer.apple.com/app-store/product-page/)

---

**Good luck with your submission! 🚀**

**Last Updated**: November 2025
