// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "xcode-version-icon",
    platforms: [
        .macOS(.v10_12)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "xcode-version-icon",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ])
    ]
)
