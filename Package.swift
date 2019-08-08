// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "FontBlaster",
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [.target(name: "FontBlaster", path: "Sources")]
)
