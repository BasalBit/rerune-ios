// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.1.1/ReRune.xcframework.zip",
            checksum: "258298af7e83b85f276d347ed1f67647f0d0e992e5f9c0e9379a3660f959732c"
        )
    ]
)
