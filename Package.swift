// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Stylizer",

    platforms: [
        .iOS("9.0"),
        .macOS("10.10"),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "Stylizer", targets: ["Stylizer"])
    ],

    targets: [
        .target(name: "Stylizer"),
        .testTarget(name: "StylizerTests", dependencies: ["Stylizer"])
    ],

    swiftLanguageVersions: [.version("5")]
)
