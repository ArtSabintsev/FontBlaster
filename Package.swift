// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FontBlaster",
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [.target(name: "FontBlaster", path: "Sources")]
)
