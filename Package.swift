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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.6.0/ReRune.xcframework.zip",
            checksum: "00a4a8b54d5903e29140d9071fc3824d64d6d2cf6bb67a9b4885257fb2a02150"
        )
    ]
)
