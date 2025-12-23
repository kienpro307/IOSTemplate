// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IOSTemplate",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "UI", targets: ["UI"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "Features", targets: ["Features"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
        // Firebase for analytics, crashlytics, push notifications, remote config
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ],
    targets: [
        // MARK: - Module Core
        // Module cốt lõi chứa architecture, dependencies và navigation
        .target(
            name: "Core",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources/Core"
        ),
        
        // MARK: - Module UI
        // Module chứa design system và UI components
        .target(
            name: "UI",
            dependencies: [
                "Core",
                .product(name: "Kingfisher", package: "Kingfisher"),
            ],
            path: "Sources/UI"
        ),
        
        // MARK: - Module Services
        // Module chứa tích hợp dịch vụ bên ngoài
        .target(
            name: "Services",
            dependencies: [
                "Core",
                // Firebase
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Services"
        ),
        
        // MARK: - Module Features
        // Module chứa các tính năng nghiệp vụ
        .target(
            name: "Features",
            dependencies: [
                "Core",
                "UI",
                "Services",
            ],
            path: "Sources/Features"
        ),
        
        // MARK: - Ứng dụng chính
        // Target chính để chạy ứng dụng
        .executableTarget(
            name: "App",
            dependencies: [
                "Core",
                "UI",
                "Services",
                "Features",
            ],
            path: "Sources/App"
        ),
        
        // MARK: - Tests
        // Các test targets
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features"]
        ),
    ]
)
