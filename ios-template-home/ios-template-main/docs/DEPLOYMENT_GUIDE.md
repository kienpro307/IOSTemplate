# 🚀 iOS Template - Deployment Guide

> Complete guide for deploying iOS Template to TestFlight and App Store

**Target Audience**: Developers, DevOps Engineers, Release Managers
**Last Updated**: November 2025

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Build Configurations](#build-configurations)
- [Code Signing](#code-signing)
- [Manual Deployment](#manual-deployment)
- [Automated Deployment (Fastlane)](#automated-deployment-fastlane)
- [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts

1. **Apple Developer Program** ($99/year)
   - Enroll tại: https://developer.apple.com/programs/
   - Required để distribute apps lên TestFlight/App Store

2. **App Store Connect** access
   - Login: https://appstoreconnect.apple.com/
   - Cần Admin/App Manager role

3. **GitHub** account (for CI/CD)

### Required Tools

```bash
# Xcode
xcode-select --version

# Command Line Tools
xcodebuild -version

# Fastlane (optional, for automation)
gem install fastlane

# CocoaPods (nếu dùng)
gem install cocoapods
```

---

## Environment Setup

### 1. Apple Developer Portal Setup

#### 1.1. Create App ID

1. Login vào [Apple Developer Portal](https://developer.apple.com/account/)
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. Click **+** để tạo App ID mới
4. Select **App IDs** → **App**
5. Điền thông tin:
   ```
   Description: iOS Template
   Bundle ID: com.yourcompany.iostemplate (Explicit)

   Capabilities:
   ✅ Push Notifications
   ✅ Sign in with Apple
   ✅ In-App Purchase (optional)
   ```
6. Click **Continue** → **Register**

#### 1.2. Create Certificates

**Development Certificate:**
```bash
# Xcode sẽ tự động tạo khi bạn chọn "Automatically manage signing"
# Hoặc tạo manual:
```

1. **Certificates** → **+**
2. Select **iOS App Development**
3. Follow wizard để generate CSR
4. Download certificate và double-click để install vào Keychain

**Distribution Certificate:**
1. **Certificates** → **+**
2. Select **App Store and Ad Hoc**
3. Upload CSR
4. Download và install

#### 1.3. Create Provisioning Profiles

**Development Profile:**
1. **Profiles** → **+**
2. Select **iOS App Development**
3. Select App ID
4. Select Development Certificates
5. Select Devices
6. Name: "iOS Template Development"
7. Download

**App Store Profile:**
1. **Profiles** → **+**
2. Select **App Store**
3. Select App ID
4. Select Distribution Certificate
5. Name: "iOS Template App Store"
6. Download

### 2. App Store Connect Setup

#### 2.1. Create App

1. Login vào [App Store Connect](https://appstoreconnect.apple.com/)
2. **My Apps** → **+** → **New App**
3. Điền thông tin:
   ```
   Platform: iOS
   Name: iOS Template
   Primary Language: English (US)
   Bundle ID: com.yourcompany.iostemplate
   SKU: ios-template-001
   ```

#### 2.2. App Information

```
App Name: iOS Template
Subtitle: Modern iOS Application Template
Category: Developer Tools / Productivity

Keywords: ios, template, swift, swiftui, tca

Description:
A modern, production-ready iOS template built with SwiftUI and
The Composable Architecture. Perfect for starting new iOS projects.

Features:
• TCA Architecture
• Firebase Integration
• Dark Mode Support
• And more...

Privacy Policy URL: https://yourwebsite.com/privacy
```

#### 2.3. Pricing and Availability

```
Price: Free (or your choice)
Availability: All countries (or select specific)
```

---

## Build Configurations

### 1. Scheme Configuration

Project có 3 build configurations:

```swift
// Debug - Development
Build Configuration: Debug
API Endpoint: https://api-dev.example.com
Firebase Config: GoogleService-Info-Dev.plist
Analytics: Disabled
Crashlytics: Disabled

// Staging - QA Testing
Build Configuration: Staging
API Endpoint: https://api-staging.example.com
Firebase Config: GoogleService-Info-Staging.plist
Analytics: Enabled
Crashlytics: Enabled

// Release - Production
Build Configuration: Release
API Endpoint: https://api.example.com
Firebase Config: GoogleService-Info.plist
Analytics: Enabled
Crashlytics: Enabled
```

### 2. Build Settings

```swift
// Debug
Swift Optimization Level: -Onone (No Optimization)
Enable Bitcode: No
Debug Information Format: DWARF with dSYM File
Strip Debug Symbols: No

// Release
Swift Optimization Level: -O (Optimize for Speed)
Enable Bitcode: No
Debug Information Format: DWARF with dSYM File
Strip Debug Symbols: Yes
```

---

## Code Signing

### Automatic Signing (Recommended for Development)

```swift
// In Xcode
1. Select project → Target
2. Signing & Capabilities tab
3. ✅ Automatically manage signing
4. Team: Select your team
5. Bundle Identifier: com.yourcompany.iostemplate
```

### Manual Signing (Required for CI/CD)

```swift
// In Xcode
1. ❌ Uncheck "Automatically manage signing"
2. Signing Certificate: iOS Distribution
3. Provisioning Profile: Select App Store profile

// For multiple configurations
Debug: iOS Development + Development Profile
Staging: iOS Distribution + Ad Hoc Profile
Release: iOS Distribution + App Store Profile
```

---

## Manual Deployment

### Build for TestFlight

#### Step 1: Archive

```bash
# From Xcode
1. Select "Any iOS Device (arm64)" as destination
2. Product → Archive
3. Wait for archive to complete
```

#### Step 2: Validate Archive

```bash
# In Organizer
1. Window → Organizer
2. Select your archive
3. Click "Validate App"
4. Select distribution method: "App Store Connect"
5. Select signing: "Automatically manage signing"
6. Click "Validate"
7. Wait for validation (2-5 minutes)
```

#### Step 3: Upload to App Store Connect

```bash
# In Organizer
1. Click "Distribute App"
2. Select "App Store Connect"
3. Select "Upload"
4. Signing: "Automatically manage signing"
5. Check options:
   ✅ Upload your app's symbols
   ✅ Manage Version and Build Number (optional)
6. Click "Upload"
7. Wait for upload (5-15 minutes)
```

#### Step 4: Submit for TestFlight

```bash
# In App Store Connect
1. Go to "TestFlight" tab
2. Select build
3. Fill "What to Test" notes
4. Add Internal/External testers
5. Click "Submit for Review" (if external testing)
```

### Build for App Store

```bash
# Same process nhưng:
1. Archive với Release configuration
2. Upload to App Store Connect
3. In App Store Connect:
   - My Apps → Your App
   - "+" Version or Platform
   - Fill all required info
   - Select build
   - Submit for Review
```

---

## Automated Deployment (Fastlane)

### 1. Install Fastlane

```bash
# Using Bundler (recommended)
sudo gem install bundler
bundle init
echo 'gem "fastlane"' >> Gemfile
bundle install

# Or direct install
sudo gem install fastlane -NV
```

### 2. Initialize Fastlane

```bash
fastlane init

# Select:
# 📦  Automate beta distribution to TestFlight
# Follow prompts to configure
```

### 3. Fastfile Configuration

See `/fastlane/Fastfile` (created in TASK 8.2.2)

### 4. Run Fastlane Lanes

```bash
# Beta release to TestFlight
fastlane beta

# Production release to App Store
fastlane release

# Run tests
fastlane test

# Take screenshots
fastlane screenshots
```

---

## CI/CD with GitHub Actions

### 1. Setup Repository Secrets

In GitHub repository → **Settings** → **Secrets and variables** → **Actions**:

```yaml
# Required secrets:
APPLE_ID: your.email@example.com
APPLE_TEAM_ID: XXXXXXXXXX
APP_IDENTIFIER: com.yourcompany.iostemplate
GIT_AUTHORIZATION: <base64 encoded git credentials>

# For Match (certificate management)
MATCH_PASSWORD: your-strong-password
MATCH_GIT_URL: https://github.com/yourorg/certificates
```

### 2. GitHub Actions Workflow

See `.github/workflows/release.yml` (created in TASK 8.2.1)

### 3. Trigger Deployment

```bash
# Manual trigger
GitHub → Actions → Select workflow → Run workflow

# Automatic on tag
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0

# Automatic on PR merge to main
git checkout main
git merge develop
git push origin main
```

---

## Troubleshooting

### Issue: "No valid code signing certificates found"

**Solution:**
```bash
# Revoke old certificates
1. Apple Developer → Certificates
2. Revoke expired/old certificates
3. Create new certificate
4. Download và install

# Or use Fastlane Match
fastlane match appstore --force_for_new_devices
```

### Issue: "Provisioning profile doesn't include signing certificate"

**Solution:**
```bash
# Regenerate profile
1. Apple Developer → Profiles
2. Delete old profile
3. Create new profile with correct certificate
4. Download và install in Xcode

# Or
Xcode → Preferences → Accounts → Download Manual Profiles
```

### Issue: "The archive is invalid"

**Solutions:**
```bash
# 1. Check bundle identifier
Target → General → Bundle Identifier phải khớp với App Store Connect

# 2. Check version/build number
Target → General → Version và Build phải unique

# 3. Clean build
Product → Clean Build Folder (⌘⇧K)
Delete Derived Data
Rebuild
```

### Issue: "Missing compliance for encryption"

**Solution:**
```swift
// Add to Info.plist
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

// Or declare trong App Store Connect nếu có encryption
```

### Issue: "Build stuck in 'Processing'"

**Wait time:**
- First build: 30-60 minutes
- Subsequent builds: 5-15 minutes

**If > 2 hours:**
```bash
# Contact Apple Support
# Or try uploading again
```

### Issue: Fastlane fails with "Could not find app"

**Solution:**
```bash
# Ensure app exists in App Store Connect
# Check app identifier matches
# Try:
fastlane deliver init
```

---

## Best Practices

### Version Numbering

Use **Semantic Versioning**:
```
MAJOR.MINOR.PATCH

1.0.0 - Initial release
1.1.0 - New features
1.1.1 - Bug fixes
2.0.0 - Breaking changes
```

**Build Numbers:**
```bash
# Auto-increment
agvtool next-version -all

# Set specific
agvtool new-version 42
```

### Release Checklist

**Before Archive:**
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Firebase configs updated
- [ ] API endpoints configured
- [ ] Analytics verified

**Before Submit:**
- [ ] Archive validated
- [ ] Tested on multiple devices
- [ ] Screenshots updated
- [ ] App description updated
- [ ] Privacy policy reviewed
- [ ] TestFlight tested by team

**After Submit:**
- [ ] Monitor crash reports
- [ ] Watch user feedback
- [ ] Prepare hotfix plan if needed

### Security

```bash
# Never commit:
- Certificates (.p12, .cer)
- Private keys
- Provisioning profiles (.mobileprovision)
- API keys
- Firebase configs (optional)

# Use .gitignore:
*.p12
*.cer
*.mobileprovision
GoogleService-Info*.plist
.env
secrets/
```

---

## Timeline Expectations

### TestFlight

```
Upload → Processing → Available to testers
         ↓             ↓
         30-60 min     Instant (internal)
                       1-2 days (external, first time)
                       Hours (external, subsequent)
```

### App Store Review

```
Submit → In Review → Approved → Released
         ↓            ↓          ↓
         1-3 days     1-2 days   Instant (manual release)
                                 Scheduled (auto release)

Total: 2-7 days average
```

---

## Resources

### Official Documentation

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Distribution Guide](https://developer.apple.com/distribute/)
- [Fastlane Docs](https://docs.fastlane.tools/)

### Tools

- [Fastlane](https://fastlane.tools/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Transporter](https://apps.apple.com/app/transporter/id1450874784) - Upload builds

### Community

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Fastlane Community](https://github.com/fastlane/fastlane/discussions)

---

## 📞 Support

Need help with deployment?

- **Email**: support@yourcompany.com
- **Slack**: #ios-deployment
- **Issues**: [GitHub Issues](https://github.com/kienpro307/ios-template/issues)

---

**Happy Deploying! 🚀**
