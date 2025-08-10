// swift-tools-version: 6.0
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "SwiftUITokenField",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "SwiftUITokenField",
            targets: ["SwiftUITokenField"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUITokenField",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftUITokenFieldTests",
            dependencies: ["SwiftUITokenField"]
        )
    ]
)
