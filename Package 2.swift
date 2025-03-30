// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FlexAI Client",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FlexAIClient",
            targets: ["FlexAIClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlexAIClient",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "FlexAIClientTests",
            dependencies: ["FlexAIClient"],
            path: "Tests"),
    ]
) 
