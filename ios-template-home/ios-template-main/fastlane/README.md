# Fastlane Documentation

## Overview

Fastlane automates iOS deployment tasks including building, testing, code signing, and uploading to App Store Connect.

---

## Setup

### 1. Install Fastlane

```bash
# Using Bundler (recommended)
gem install bundler
bundle init
echo 'gem "fastlane"' >> Gemfile
bundle install

# Or direct install
sudo gem install fastlane -NV
```

### 2. Configure Environment

```bash
# Copy environment template
cp fastlane/.env.default fastlane/.env

# Edit .env with your values
nano fastlane/.env
```

### 3. Setup Match (Code Signing)

```bash
# Initialize Match repository
fastlane match init

# Generate certificates and profiles
fastlane match_development
fastlane match_appstore
```

---

## Available Lanes

### Testing

```bash
# Run all tests
fastlane test

# Run tests with coverage report
fastlane test_coverage
```

### Building

```bash
# Build app (debug)
fastlane build

# Build for release
fastlane build_release
```

### Deployment

```bash
# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

### Code Signing

```bash
# Setup development certificates
fastlane match_development

# Setup App Store certificates
fastlane match_appstore

# Sync all certificates
fastlane match_all

# Nuke all certificates (use with caution!)
fastlane match_nuke
```

### Utilities

```bash
# Take screenshots for App Store
fastlane screenshots

# Bump version number
fastlane bump_version type:major  # 1.0.0 -> 2.0.0
fastlane bump_version type:minor  # 1.0.0 -> 1.1.0
fastlane bump_version type:patch  # 1.0.0 -> 1.0.1

# Setup project for new developer
fastlane setup

# Clean build artifacts
fastlane clean

# Run SwiftLint
fastlane lint
fastlane lint_fix  # Auto-fix issues

# Validate project (lint + test + build)
fastlane validate
```

---

## Environment Variables

### Required

```bash
SCHEME              # Xcode scheme name
APP_IDENTIFIER      # Bundle identifier
APPLE_ID            # Apple ID email
APPLE_TEAM_ID       # Developer Team ID
```

### Optional

```bash
DEVICE              # Simulator device for testing
ITC_TEAM_ID         # App Store Connect Team ID
MATCH_GIT_URL       # Git URL for Match certificates
MATCH_PASSWORD      # Match encryption password
SLACK_URL           # Slack webhook for notifications
SKIP_TESTS          # Skip tests in deployment
SKIP_MATCH          # Skip Match code signing
```

---

## Workflows

### Beta Release to TestFlight

```bash
# 1. Ensure clean git state
git status

# 2. Checkout main branch
git checkout main
git pull

# 3. Run fastlane
fastlane beta

# This will:
# - Run tests
# - Build app
# - Upload to TestFlight
# - Increment build number
# - Commit and push changes
```

### Production Release to App Store

```bash
# 1. Ensure clean git state
git checkout main
git pull

# 2. Run release lane
fastlane release

# This will:
# - Prompt for version number
# - Run tests
# - Build app
# - Upload to App Store
# - Create git tag
# - Commit and push
```

### Update Certificates

```bash
# When adding new devices
fastlane match_development

# Before production build
fastlane match_appstore

# Sync all
fastlane match_all
```

---

## Match (Code Signing)

### What is Match?

Match stores your certificates and provisioning profiles in a git repository. This ensures all team members use the same code signing identities.

### Setup Match

```bash
# 1. Create private git repository
# (e.g., https://github.com/yourorg/certificates)

# 2. Update Matchfile
# Edit fastlane/Matchfile with your repo URL

# 3. Generate certificates
fastlane match_development
fastlane match_appstore

# 4. Share Match password with team
# Store in password manager
```

### Add New Device

```bash
# 1. Register device in Developer Portal
# 2. Update provisioning profiles
fastlane match_development

# Match will automatically include new devices
```

### Rotate Certificates

```bash
# If certificates are compromised
fastlane match_nuke type:development
fastlane match_nuke type:appstore

# Then regenerate
fastlane match_development
fastlane match_appstore
```

---

## Troubleshooting

### "Could not find certificate"

```bash
# Solution: Generate certificates with Match
fastlane match_development
fastlane match_appstore
```

### "Provisioning profile doesn't match"

```bash
# Solution: Regenerate profiles
fastlane match_development --force
```

### "Build failed with code 65"

```bash
# Solution: Clean and rebuild
fastlane clean
fastlane build
```

### "No devices for testing"

```bash
# Solution: Register device in Developer Portal
# Then update Match
fastlane match_development
```

### Stuck on "Processing" in App Store Connect

```bash
# Wait 30-60 minutes for first build
# Subsequent builds process faster (5-15 min)

# If > 2 hours, contact Apple Support
```

---

## Best Practices

### 1. Version Numbering

Use semantic versioning:
```
MAJOR.MINOR.PATCH

1.0.0 - Initial release
1.1.0 - New features
1.1.1 - Bug fixes
2.0.0 - Breaking changes
```

### 2. Git Workflow

```bash
# Always deploy from main branch
git checkout main
git pull

# Run fastlane
fastlane beta

# Fastlane will commit and push changes
```

### 3. Testing

```bash
# Always run tests before deployment
SKIP_TESTS=false

# In CI, tests are mandatory
```

### 4. Code Signing

```bash
# Use Match for team collaboration
# Never share .p12 files manually

# Store Match password in:
# - Password manager (1Password, LastPass)
# - CI secrets (GitHub, GitLab)
```

### 5. Notifications

```bash
# Setup Slack webhook for deployment notifications
# Set SLACK_URL in .env

# Notifications include:
# - Success/failure status
# - Build number
# - Version
# - Git commit
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
- name: Deploy to TestFlight
  run: fastlane beta
  env:
    APPLE_ID: ${{ secrets.APPLE_ID }}
    APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
    MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
deploy:
  script:
    - fastlane beta
  only:
    - main
```

---

## Resources

### Official Documentation

- [Fastlane Docs](https://docs.fastlane.tools/)
- [Match Guide](https://docs.fastlane.tools/actions/match/)
- [Available Actions](https://docs.fastlane.tools/actions/)

### Community

- [Fastlane GitHub](https://github.com/fastlane/fastlane)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/fastlane)
- [Fastlane Slack](https://fastlane-slackin.herokuapp.com/)

---

**For more details, see individual lane descriptions in `Fastfile`**
