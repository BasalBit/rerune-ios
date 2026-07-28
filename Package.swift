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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.13.0/ReRune.xcframework.zip",
            checksum: "7ab83bdee596ae4f610759d19e714f59a2269499cdb0156776139a2e7d275fa2"
        )
    ]
)
