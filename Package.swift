// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReRune",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ReRune",
            targets: ["ReRune"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ReRune",
            url: "https://github.com/BasalBit/rerune-ios/releases/download/0.2.1/ReRune.xcframework.zip",
            checksum: "b9601f2455906ad84a4f673e6ad81b21346335863d5de7a8fd1470476454148a"
        )
    ]
)
