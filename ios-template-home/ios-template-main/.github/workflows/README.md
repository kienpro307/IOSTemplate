# GitHub Actions Workflows

This directory contains CI/CD workflows for iOS Template project.

## Workflows Overview

### 🔨 CI Workflow (`ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual dispatch

**Jobs:**
1. **Build and Test**
   - Builds project for testing
   - Runs unit tests
   - Generates code coverage report
   - Uploads coverage to Codecov

2. **Build Release**
   - Builds release configuration
   - Archives build artifacts

3. **Security Scan**
   - Scans for hardcoded secrets
   - Checks for security TODOs
   - Audits dependencies

**Status Badge:**
```markdown
![CI](https://github.com/kienpro307/ios-template/workflows/CI/badge.svg)
```

---

### 🧹 Lint Workflow (`lint.yml`)

**Triggers:**
- Push to `main` or `develop`
- Pull requests
- Manual dispatch

**Jobs:**
1. **SwiftLint**
   - Runs SwiftLint checks
   - Generates HTML report for PRs

2. **SwiftFormat**
   - Checks code formatting

3. **Danger** (PR only)
   - Automated code review
   - PR size check
   - Checks for missing tests

4. **Code Quality**
   - Checks for large files
   - Documentation coverage check
   - Commented code detection

**Requirements:**
- SwiftLint installed on runner
- `.swiftlint.yml` configuration file

---

### 🚀 Release Workflow (`release.yml`)

**Triggers:**
- Push tags matching `v*.*.*` (e.g., v1.0.0)
- Manual dispatch with environment choice

**Jobs:**
1. **Build and Deploy**
   - Sets up code signing
   - Builds app archive
   - Exports IPA
   - Uploads to TestFlight/App Store
   - Creates GitHub release
   - Notifies team via Slack

2. **Cleanup**
   - Removes temporary keychains
   - Cleans build artifacts

**Required Secrets:**
```yaml
APPLE_ID: Apple ID email
APPLE_TEAM_ID: Team ID from developer portal
APPLE_APP_SPECIFIC_PASSWORD: App-specific password
DISTRIBUTION_CERTIFICATE: Base64 encoded .p12 certificate
CERTIFICATE_PASSWORD: Certificate password
KEYCHAIN_PASSWORD: Temporary keychain password
PROVISIONING_PROFILE: Base64 encoded provisioning profile
PROVISIONING_PROFILE_SPECIFIER: Profile name
SLACK_WEBHOOK: Slack webhook URL (optional)
```

**Usage:**

```bash
# Create and push tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Or manual dispatch from GitHub Actions UI
```

---

### 📦 Dependency Update Workflow (`dependency-update.yml`)

**Triggers:**
- Schedule: Every Monday at 9 AM UTC
- Manual dispatch

**Jobs:**
1. **Update Dependencies**
   - Updates Swift packages to latest versions
   - Runs tests with updated dependencies
   - Creates PR if changes detected

2. **Security Audit**
   - Audits dependencies for vulnerabilities
   - Creates issue if vulnerabilities found

**Features:**
- Automated dependency updates
- Zero-touch if no updates available
- Automatic PR creation
- Security vulnerability detection

---

## Setup Instructions

### 1. Enable GitHub Actions

```bash
# In your repository:
Settings → Actions → General
- Allow all actions and reusable workflows
- Allow GitHub Actions to create and approve pull requests (for dependency updates)
```

### 2. Add Required Secrets

```bash
# Navigate to:
Settings → Secrets and variables → Actions

# Add the following secrets:
- APPLE_ID
- APPLE_TEAM_ID
- APPLE_APP_SPECIFIC_PASSWORD
- DISTRIBUTION_CERTIFICATE (base64 encoded)
- CERTIFICATE_PASSWORD
- KEYCHAIN_PASSWORD
- PROVISIONING_PROFILE (base64 encoded)
- PROVISIONING_PROFILE_SPECIFIER
- SLACK_WEBHOOK (optional)
- CODECOV_TOKEN (optional, for coverage)
```

### 3. Generate Base64 Encoded Secrets

```bash
# Certificate
base64 -i Certificates.p12 | pbcopy

# Provisioning Profile
base64 -i Profile.mobileprovision | pbcopy
```

### 4. Configure Status Checks

```bash
# In repository settings:
Settings → Branches → Branch protection rules

# For main branch:
- Require status checks to pass before merging
  ✓ CI / Build and Test
  ✓ Lint / SwiftLint
- Require pull request reviews before merging
```

---

## Workflow Status

Check workflow runs:
```
https://github.com/kienpro307/ios-template/actions
```

Add status badges to README:
```markdown
![CI](https://github.com/kienpro307/ios-template/workflows/CI/badge.svg)
![Lint](https://github.com/kienpro307/ios-template/workflows/Lint/badge.svg)
![Release](https://github.com/kienpro307/ios-template/workflows/Release/badge.svg)
```

---

## Troubleshooting

### Workflow fails with "No space left on device"

```yaml
# Add cleanup step before build
- name: Free Disk Space
  run: |
    sudo rm -rf /usr/local/lib/android
    sudo rm -rf /usr/share/dotnet
```

### Code signing fails

```bash
# Verify secrets are correct:
- Check DISTRIBUTION_CERTIFICATE is base64 encoded
- Verify CERTIFICATE_PASSWORD matches
- Ensure PROVISIONING_PROFILE is valid
- Check APPLE_TEAM_ID is correct
```

### Tests timeout

```yaml
# Increase timeout in workflow
jobs:
  build:
    timeout-minutes: 60  # Default is 360
```

### SwiftLint not found

```yaml
# Install in workflow
- name: Install SwiftLint
  run: brew install swiftlint
```

---

## Best Practices

1. **Always test workflows locally first**
   ```bash
   # Use act to test locally
   brew install act
   act -j build
   ```

2. **Use caching to speed up builds**
   - Cache SPM dependencies
   - Cache CocoaPods
   - Cache build artifacts

3. **Minimize workflow runs**
   - Use path filters for specific changes
   - Skip CI for docs-only changes

4. **Security**
   - Never log secrets
   - Use GitHub Secrets for sensitive data
   - Rotate certificates regularly

5. **Notifications**
   - Set up Slack notifications for releases
   - Email notifications for failed builds

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)

---

**Last Updated**: November 2025
