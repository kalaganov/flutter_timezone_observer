// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_timezone_observer",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // The 'flutter-' prefix and hyphenated name are required by the Flutter
        // tool to locate the plugin's library product.
        .library(name: "flutter-timezone-observer", targets: ["flutter_timezone_observer"])
    ],
    dependencies: [
        // Provided by the Flutter tool at build time, one level up from this package.
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_timezone_observer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
