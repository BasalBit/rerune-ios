// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.5.0/ReRune.xcframework.zip",
            checksum: "76f0c0198228a9b6246b447235f7d594d57f70355a50b06a7bec8d3b16b8d224"
        )
    ]
)
