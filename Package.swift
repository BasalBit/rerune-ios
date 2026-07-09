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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.5.1/ReRune.xcframework.zip",
            checksum: "4dd445c888d74d6e5af4fe7b128b9ee8b7a79f01e6b980a488f8f97ea666101f"
        )
    ]
)
