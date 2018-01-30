// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
    name: "IronPost",
    products: [
        .library(
            name: "IronPost",
            targets: ["IronPost"]),
    ],
    dependencies: [
        .package(url: "https://github.com/brian-schick/CLibetpan.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "CLibEtPan",
            dependencies: []),
        .target(
            name: "IronPost",
            dependencies: ["CLibEtPan"]),
    ]
)
