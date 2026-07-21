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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.9.0/ReRune.xcframework.zip",
            checksum: "94eea810e559f6f86213a995a50b623ebed64feef26cc6a9b8a88973e86419b8"
        )
    ]
)
