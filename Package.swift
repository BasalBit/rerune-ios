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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.10.0/ReRune.xcframework.zip",
            checksum: "cf65f0805a2e14f69f0af72cf007dd0bc0d41e3e1be270a884e53622fff8e775"
        )
    ]
)
