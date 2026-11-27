// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mutex",
    products: [
        .library(
            name: "Mutex",
            targets: ["Mutex"]
        ),
    ],
    targets: [
        .target(
            name: "Mutex",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(name: "MutexTests", dependencies: ["Mutex"])

    ]
)
