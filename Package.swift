// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftTokenField",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "SwiftTokenField",
            targets: ["SwiftTokenField"]
        )
    ],
    targets: [
        .target(
            name: "SwiftTokenField",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftTokenFieldTests",
            dependencies: ["SwiftTokenField"]
        )
    ]
)
