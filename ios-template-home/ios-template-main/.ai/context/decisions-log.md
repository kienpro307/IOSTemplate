# Architectural Decisions Log

## ADR-001: Choose TCA (The Composable Architecture)
**Date:** November 13, 2024
**Status:** Accepted

**Context:**
Need a predictable state management solution for SwiftUI app that is testable and maintainable.

**Decision:**
Use TCA (The Composable Architecture) for state management.

**Consequences:**
- ✅ Predictable state flow
- ✅ Highly testable business logic
- ✅ Great SwiftUI integration
- ✅ Composable features
- ⚠️ Learning curve for new developers
- ⚠️ Boilerplate code

---

## ADR-002: Swift Package Manager for Dependencies
**Date:** November 13, 2024
**Status:** Accepted

**Context:**
Need to manage third-party dependencies for the project.

**Decision:**
Use Swift Package Manager (SPM) instead of CocoaPods.

**Consequences:**
- ✅ Native Xcode integration
- ✅ Faster build times
- ✅ No Ruby dependencies
- ✅ Better Xcode Cloud support
- ⚠️ Some packages not available on SPM

---

## ADR-003: iOS 16 Minimum Target
**Date:** November 13, 2024
**Status:** Accepted

**Context:**
Choose minimum iOS version for the template.

**Decision:**
Set iOS 16.0 as minimum deployment target.

**Consequences:**
- ✅ Access to modern SwiftUI APIs
- ✅ Better performance
- ✅ 90%+ market coverage
- ⚠️ Cannot support older devices

---

## ADR-004: Swinject for Dependency Injection
**Date:** November 13, 2024
**Status:** Accepted

**Context:**
Need a DI framework that works well with Swift and TCA.

**Decision:**
Use Swinject for dependency injection container.

**Consequences:**
- ✅ Mature and stable
- ✅ Good documentation
- ✅ Protocol-oriented
- ✅ Thread-safe
- ⚠️ Runtime dependency resolution
