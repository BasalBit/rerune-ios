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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.0.0/ReRune.xcframework.zip",
            checksum: "6213e84bc5024cd052f68ae85e10ea41ad92c0138c008ac0592c66ec94e2f6b2"
        )
    ]
)
