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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.2.2/ReRune.xcframework.zip",
            checksum: "ee5976e533129a6f0e7073b4a1ae6069e83c0d53f4863e79c8ecdcb04d5f50b9"
        )
    ]
)
