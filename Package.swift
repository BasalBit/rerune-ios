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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.6.1/ReRune.xcframework.zip",
            checksum: "5f3820b60ea31385868b8fdd82909d440347e84137e4b41b774b7afcb0a19377"
        )
    ]
)
