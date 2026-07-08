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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.5.0/ReRune.xcframework.zip",
            checksum: "c97cb496d48c5dae4f1cb8336bea0863c83520fc02de99c9a38925e7fbe7ca21"
        )
    ]
)
