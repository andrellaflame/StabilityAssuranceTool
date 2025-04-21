// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StabilityAssuranceTool",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "sat",
            targets: ["StabilityAssuranceTool"]
        ),
        .plugin(
            name: "SATCommandPlugin",
            targets: ["SATCommandPlugin"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3")
    ],
    targets: [
        .executableTarget(
            name: "StabilityAssuranceTool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "Yams", package: "Yams")
            ],
            exclude: [
                "Resources"
            ]
        ),
        .plugin(
            name: "SATCommandPlugin",
            capability: .command(
                intent: .custom(verb: "sat", description: "Stability Assurance Tool"),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "When this command is run with the `--fix` option it may modify source files."
                    ),
                ]
            ),
            dependencies: [
                .target(name: "StabilityAssuranceTool")
            ],
            packageAccess: false
        ),
    ]
)
