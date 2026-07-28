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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.12.0/ReRune.xcframework.zip",
            checksum: "87ad71a36a73ecec5ed2f1609beafb20fa7871f3cef43e25dafbd23fad299466"
        )
    ]
)
