// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SakuraTalk",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SakuraTalk",
            targets: ["SakuraTalk"]
        )
    ],
    targets: [
        .target(
            name: "SakuraTalk",
            path: "SakuraTalk"
        )
    ]
)