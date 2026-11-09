// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.6.1/ReRune.xcframework.zip",
            checksum: "15a196dbd58d12733ca78e8f3e3d79071c2c8dc29a6e46688eaaa51eb7f92e56"
        )
    ]
)
