// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LemmyMarkdownUI",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LemmyMarkdownUI",
            targets: ["LemmyMarkdownUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/appstefan/highlightswift.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "cmark-lemmy"),
        .target(
            name: "LemmyMarkdownUI",
            dependencies: [
                "cmark-lemmy",
                .product(name: "HighlightSwift", package: "highlightswift")
            ]),
        .testTarget(
            name: "LemmyMarkdownUITests",
            dependencies: ["LemmyMarkdownUI"]),
    ]
)
