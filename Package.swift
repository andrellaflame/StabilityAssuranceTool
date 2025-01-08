// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StabilityAssuranceTool",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "sat", targets: ["StabilityAssuranceTool"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "StabilityAssuranceTool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            exclude: [
                "Resources"
            ]
        ),
    ]
)
