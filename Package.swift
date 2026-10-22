// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.4.1/ReRune.xcframework.zip",
            checksum: "b1ddc612a76a4e399305667cff07f224a4f034f2b3fb77b2a4697b0bcbb52e25"
        )
    ]
)
