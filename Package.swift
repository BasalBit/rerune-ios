// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.6.0/ReRune.xcframework.zip",
            checksum: "9f7e2097fa7181e18137122b2bae911bae37f4db142733e38fb6baa7c23b5a2c"
        )
    ]
)
