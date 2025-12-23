// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSTemplate",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "iOSTemplate",
            targets: ["iOSTemplate"]
        ),
    ],
    dependencies: [
        // The Composable Architecture
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "1.0.0"
        ),
        // Swinject for Dependency Injection
        .package(
            url: "https://github.com/Swinject/Swinject.git",
            from: "2.8.0"
        ),
        // Kingfisher for image loading and caching
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            from: "7.0.0"
        ),
        // KeychainAccess for secure storage
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
            from: "4.0.0"
        ),
        // Moya for networking
        .package(
            url: "https://github.com/Moya/Moya.git",
            from: "15.0.0"
        ),
        // Firebase for analytics, crashlytics, push notifications, remote config
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.19.0"
        ),
    ],
    targets: [
        .target(
            name: "iOSTemplate",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Moya", package: "Moya"),
                // Firebase
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
            ],
            path: "Sources/iOSTemplate"
        ),
        .testTarget(
            name: "iOSTemplateTests",
            dependencies: [
                "iOSTemplate",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Tests/iOSTemplateTests"
        ),
    ]
)
