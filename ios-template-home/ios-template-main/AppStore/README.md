# App Store Assets

This directory contains all assets needed for App Store submission.

---

## 📁 Directory Structure

```
AppStore/
├── Screenshots/         # App screenshots for all device sizes
├── Icons/              # App icons in various sizes
├── Metadata/           # App Store metadata files
└── README.md           # This file
```

---

## 📱 Screenshots

### Required Sizes

#### iPhone

- **6.7" Display** (iPhone 15 Pro Max, iPhone 14 Pro Max)
  - Resolution: 1290 x 2796 pixels
  - Portrait: 1290 x 2796
  - Landscape: 2796 x 1290

- **6.5" Display** (iPhone 11 Pro Max, iPhone XS Max)
  - Resolution: 1242 x 2688 pixels
  - Portrait: 1242 x 2688
  - Landscape: 2688 x 1242

- **5.5" Display** (iPhone 8 Plus, iPhone 7 Plus)
  - Resolution: 1242 x 2208 pixels
  - Portrait: 1242 x 2208
  - Landscape: 2208 x 1242

#### iPad

- **12.9" Display** (iPad Pro 12.9")
  - Resolution: 2048 x 2732 pixels
  - Portrait: 2048 x 2732
  - Landscape: 2732 x 2048

- **11" Display** (iPad Pro 11")
  - Resolution: 1668 x 2388 pixels
  - Portrait: 1668 x 2388
  - Landscape: 2388 x 1668

### Screenshot Guidelines

1. **Number**: 3-10 screenshots per device size
2. **Format**: PNG or JPEG (PNG recommended)
3. **Color Space**: RGB
4. **Content**:
   - Show key features
   - Use actual app UI (no mockups)
   - Avoid text-heavy screenshots
   - Highlight unique features
   - Show value proposition

### Taking Screenshots

#### Using Fastlane

```bash
# Generate screenshots automatically
fastlane screenshots
```

#### Manual Screenshots

```bash
# 1. Run app on Simulator
# 2. Navigate to feature screen
# 3. Press ⌘S to save screenshot
# 4. Screenshots saved to Desktop
```

#### Using Xcode

```bash
# 1. Run UI Tests with screenshots
# 2. Tests capture screenshots automatically
# 3. Export from test results
```

### Screenshot Naming Convention

```
iPhone 6.7"/
├── 01_home.png
├── 02_explore.png
├── 03_profile.png
├── 04_settings.png
└── 05_feature.png

iPad 12.9"/
├── 01_home.png
├── 02_explore.png
└── ...
```

---

## 🎨 App Icon

### Required Sizes

```
App Store:
- 1024 x 1024 px (Required)

App Bundle:
- 180 x 180 px (@3x iPhone)
- 120 x 120 px (@2x iPhone)
- 167 x 167 px (@2x iPad Pro)
- 152 x 152 px (@2x iPad)
- 76 x 76 px (@1x iPad)
- 40 x 40 px (Spotlight)
- 29 x 29 px (Settings)
```

### Icon Guidelines

1. **Design**:
   - Simple and recognizable
   - No transparency
   - No alpha channels
   - Fill entire canvas
   - Rounded corners added by iOS

2. **Format**:
   - PNG or JPEG
   - RGB color space
   - No layers

3. **Content**:
   - Avoid text (if possible)
   - Avoid screenshots
   - Test on different backgrounds
   - Check visibility at small sizes

### Creating Icons

Use [Asset Catalog Creator](https://apps.apple.com/app/asset-catalog-creator/id866571115) or similar tools to generate all sizes from 1024x1024 master.

---

## 📝 App Store Metadata

### App Information

Create `Metadata/app_info.txt`:

```
App Name: iOS Template
Subtitle: Modern iOS Development Template
```

### Description

Create `Metadata/description.txt` (max 4000 characters):

```
[Engaging opening line]

KEY FEATURES:
• Feature 1
• Feature 2
• Feature 3

[Detailed description]

BENEFITS:
• Benefit 1
• Benefit 2

[Call to action]
```

### Keywords

Create `Metadata/keywords.txt` (max 100 characters, comma-separated):

```
ios,template,swift,swiftui,development,app
```

### Promotional Text

Create `Metadata/promotional_text.txt` (max 170 characters):

```
[Current promotion or highlight]
Updates without resubmission!
```

### What's New

Create `Metadata/whats_new.txt` (max 4000 characters):

```
Version 1.0.0

NEW FEATURES:
• Feature addition

IMPROVEMENTS:
• Performance boost
• Bug fixes

Thank you for using iOS Template!
```

---

## 🎬 App Preview Video (Optional)

### Specifications

- **Length**: 15-30 seconds
- **Format**: M4V, MP4, or MOV
- **Resolution**: Same as screenshots
- **Size**: Max 500 MB
- **Orientation**: Portrait or Landscape

### Content Guidelines

1. Show app in use
2. No talking heads
3. No pricing information
4. No competitor mentions
5. Match app functionality

---

## 📋 Checklist

### Before Submission

**Screenshots:**
- [ ] 6.7" iPhone (required)
- [ ] 5.5" iPhone (optional)
- [ ] 12.9" iPad (if iPad supported)
- [ ] All screenshots follow guidelines
- [ ] Screenshots show actual app UI
- [ ] No placeholder content

**Icons:**
- [ ] 1024x1024 App Store icon
- [ ] All required app icon sizes
- [ ] No transparency
- [ ] High quality

**Metadata:**
- [ ] App name (max 30 characters)
- [ ] Subtitle (max 30 characters)
- [ ] Description (max 4000 characters)
- [ ] Keywords (max 100 characters)
- [ ] Promotional text (max 170 characters)
- [ ] What's New (for updates)
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] Privacy Policy URL

**Categories:**
- [ ] Primary category selected
- [ ] Secondary category (optional)

**Age Rating:**
- [ ] Completed questionnaire
- [ ] Appropriate rating

**Pricing:**
- [ ] Price tier selected
- [ ] Availability selected

---

## 🛠️ Tools

### Screenshot Tools

- [Fastlane Snapshot](https://docs.fastlane.tools/actions/snapshot/) - Automated screenshots
- [Screenshot Creator](https://apps.apple.com/app/screenshot-creator/id1238399722) - Frame screenshots
- [Previewed](https://previewed.app/) - Device frames

### Icon Tools

- [Asset Catalog Creator](https://apps.apple.com/app/asset-catalog-creator/id866571115)
- [Icon Set Creator](https://apps.apple.com/app/icon-set-creator/id939343785)
- [MakeAppIcon](https://makeappicon.com/) - Online generator

### Design Tools

- [Figma](https://figma.com/) - Design mockups
- [Sketch](https://sketch.com/) - macOS design tool
- [Canva](https://canva.com/) - Quick graphics

---

## 📐 Templates

### Screenshot Frame Templates

Located in `Screenshots/templates/`:
- iPhone frames (light/dark)
- iPad frames (light/dark)
- Marketing frames

### Description Template

See `Metadata/templates/description_template.md`

---

## 🌍 Localization

### Multi-Language Support

For each language, create:

```
Metadata/
├── en-US/              # English
│   ├── description.txt
│   ├── keywords.txt
│   └── whats_new.txt
├── vi-VN/              # Vietnamese
│   ├── description.txt
│   ├── keywords.txt
│   └── whats_new.txt
└── ...
```

### Supported Languages

Common languages to support:
- English (US)
- Spanish
- French
- German
- Japanese
- Simplified Chinese
- Korean

---

## 📚 Resources

### Official Guidelines

- [App Store Screenshot Specifications](https://help.apple.com/app-store-connect/#/devd274dd925)
- [App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [App Store Product Page](https://developer.apple.com/app-store/product-page/)

### Best Practices

- [App Store Optimization](https://developer.apple.com/app-store/search/)
- [Writing Great Descriptions](https://developer.apple.com/app-store/discoverability/)

---

**Last Updated**: November 2025
