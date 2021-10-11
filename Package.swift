// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KrwJSON",
    products: [
        .library(
            name: "KrwJSON",
            targets: ["KrwJSON"]),
    ],
    targets: [
        .target(
            name: "KrwJSON",
            dependencies: []),
        .testTarget(
            name: "KrwJSONTests",
            dependencies: ["KrwJSON"]),
    ]
)
