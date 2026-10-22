// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.4.0/ReRune.xcframework.zip",
            checksum: "9afb97d9d1ba72d71a6d3a4654eb8af47451fd8c17b7fcd2e61fd9943489e5ed"
        )
    ]
)
