// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSTemplate",
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
    ],
    targets: [
        // App target - Entry point
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
        
        // Core module
        .target(
            name: "Core",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            path: "Sources/Core"
        ),
        
        // UI module
        .target(
            name: "UI",
            dependencies: [
                "Core",
                .product(name: "Kingfisher", package: "Kingfisher"),
            ],
            path: "Sources/UI"
        ),
        
        // Services module
        .target(
            name: "Services",
            dependencies: ["Core"],
            path: "Sources/Services"
        ),
        
        // Features module
        .target(
            name: "Features",
            dependencies: ["Core", "UI", "Services"],
            path: "Sources/Features"
        ),
        
        // Tests
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features"],
            path: "Tests/FeaturesTests"
        ),
    ]
)
