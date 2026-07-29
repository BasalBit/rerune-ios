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
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.13.1/ReRune.xcframework.zip",
            checksum: "28a3e124f715fecd032865c83e047d1312761a684a7d35c06deabc12aff7ce58"
        )
    ]
)
