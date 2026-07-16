// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ReRune",
            targets: ["ReRune"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.7.0/ReRune.xcframework.zip",
            checksum: "68d44328ca20f15a5fb86f2d56c31e66628670f8c6d31949a4c07b208a034acb"
        )
    ]
)
