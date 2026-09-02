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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.1.0/ReRune.xcframework.zip",
            checksum: "04a7c5775434590df8ac02a0fcbe8238f7115d4b23da5a5e5ba217748b404b91"
        )
    ]
)
