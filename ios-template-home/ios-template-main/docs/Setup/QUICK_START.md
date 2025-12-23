# 🚀 Quick Start Guide

Get iOS Template running in 5 minutes!

---

## ⚡ Fastest Setup

### 1. Clone & Open

```bash
git clone https://github.com/kienpro307/ios-template.git
cd ios-template
open Package.swift  # Opens in Xcode
```

### 2. Wait for Dependencies

Xcode will automatically:
- Download all Swift packages (TCA, Swinject, Firebase, etc.)
- Index the code
- Build the project

**⏱️ First time: 5-10 minutes**

### 3. Run!

```bash
# In Xcode:
# 1. Select scheme: iOSTemplate
# 2. Select device: iPhone 15 Pro
# 3. Press ⌘R (Run)
```

**Done! App is running on Simulator** 🎉

---

## 📱 Run on Real iPhone

### Quick Method (No Apple Developer Account Needed)

1. **Connect iPhone** via cable
2. **Trust computer** on iPhone
3. **Select your iPhone** in Xcode
4. **Change Bundle ID**:
   - Target → General
   - Bundle Identifier: `com.yourname.iostemplate`
5. **Select Team**:
   - Signing & Capabilities
   - Team: Your Apple ID
6. **Run** (⌘R)
7. **Trust Developer** on iPhone:
   - Settings → General → VPN & Device Management
   - Trust your Apple ID

---

## 🧪 Run Tests

```bash
# In Xcode
⌘U

# Or Terminal
swift test
```

---

## 🔧 Common Issues

### "No package dependencies found"

**Fix:**
```bash
# In Xcode
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions
```

### "Build failed" with SwiftLint

**Fix:**
```bash
# Install SwiftLint
brew install swiftlint
```

### "Untrusted Developer" on iPhone

**Fix:**
```bash
# On iPhone
Settings → General → VPN & Device Management
→ Trust developer certificate
```

---

## 📚 Next Steps

Once running, explore:

1. **Features**: Home, Explore, Profile, Settings tabs
2. **Code**: Check `Sources/iOSTemplate/` structure
3. **Documentation**: Read `docs/API_DOCUMENTATION.md`
4. **Customize**: Modify colors, add features

---

## 🚀 Deploy to TestFlight (Optional)

**Prerequisites:**
- Apple Developer account ($99/year)
- Fastlane installed

```bash
# Install Fastlane
gem install fastlane

# Deploy
fastlane beta
```

---

## 📖 Full Documentation

- **[Setup Guide](SETUP.md)** - Detailed setup instructions
- **[API Docs](docs/API_DOCUMENTATION.md)** - API reference
- **[Deployment](docs/DEPLOYMENT_GUIDE.md)** - Deploy to App Store
- **[Contributing](docs/CONTRIBUTING.md)** - Contribute code

---

## 🆘 Need Help?

- **GitHub Issues**: [Report bugs](https://github.com/kienpro307/ios-template/issues)
- **Documentation**: Check `docs/` folder
- **Stack Overflow**: Tag with `ios`, `swift`, `swiftui`

---

**Happy Coding! 🎉**
