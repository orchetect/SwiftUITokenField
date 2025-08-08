// swift-tools-version:5.3

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
