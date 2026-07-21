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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.8.0/ReRune.xcframework.zip",
            checksum: "07269e04f2b5447eb3dc70b86225e2242b2973ef8bc6db5d3d9584d78eab91ee"
        )
    ]
)
