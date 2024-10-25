// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomFormStyle",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "CustomFormStyle",
            targets: ["CustomFormStyle"]),
    ],
    targets: [
        .target(
            name: "CustomFormStyle"),

    ]
)
