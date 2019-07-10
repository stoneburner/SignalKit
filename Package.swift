// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SignalKit",
    products: [
        .library(
            name: "SignalKit",
            targets: ["SignalKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SignalKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SignalKitTests",
            dependencies: ["SignalKit"],
            path: "Tests"
        ),
    ]
)
