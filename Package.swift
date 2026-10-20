// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ReRune", targets: ["ReRune"])],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/1.3.1/ReRune.xcframework.zip",
            checksum: "460d0e80c5e7902fd8050ee20ed556716083812cd698410f8117eefb75661576"
        )
    ]
)
