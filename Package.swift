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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.11.0/ReRune.xcframework.zip",
            checksum: "2c05a7adb72e8d42b9da8e273bae7d4a28368400d51b1e4994e15165925d22aa"
        )
    ]
)
