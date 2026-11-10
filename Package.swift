// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.7.0/ReRune.xcframework.zip",
            checksum: "9440f634ea69f2f76a4c3e40293159ffd11fe256e8bc4805ab68afcb3434214e"
        )
    ]
)
