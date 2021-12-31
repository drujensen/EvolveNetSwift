// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "EvolveNet",
    products: [
        .library(name: "EvolveNet", targets: ["EvolveNet"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "EvolveNet", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "EvolveNetTests", dependencies: ["EvolveNet"]),
    ]
)
