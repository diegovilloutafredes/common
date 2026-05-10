// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "Common",
            path: "XCFramework/Common.xcframework"
        )
    ]
)
