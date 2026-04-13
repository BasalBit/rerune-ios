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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.4.0/ReRune.xcframework.zip",
            checksum: "e4cd5f61885e45a723d23b9b4fac7af4d4e2959024a54d73807583f6d19b22ac"
        )
    ]
)
