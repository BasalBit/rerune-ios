// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.3.0/ReRune.xcframework.zip",
            checksum: "991cc8c74e87020c85263377bd3e73aa428d26fa1b2455e09c9047d41c72d4db"
        )
    ]
)
