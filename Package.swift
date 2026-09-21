// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.2.0/ReRune.xcframework.zip",
            checksum: "f4170ba5068459b7f7cb7f06e21148bda3f79542ae48c050d38dc77cec8af2c3"
        )
    ]
)
