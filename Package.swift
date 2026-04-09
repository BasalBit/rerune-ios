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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.3.0/ReRune.xcframework.zip",
            checksum: "a4fd7bd43649678e6ace269de4965d1e4b9868c8f0e96287f637f1b0bafd61c1"
        )
    ]
)
