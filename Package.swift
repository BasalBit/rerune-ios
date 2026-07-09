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
            checksum: "146bedbe87fbab8fa05db6b0b8c4e8a770cf86f380c5ac5002315080112d0472"
        )
    ]
)
