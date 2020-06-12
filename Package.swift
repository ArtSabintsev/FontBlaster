// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "FontBlaster",
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [.target(name: "FontBlaster", path: "Sources")],
    platforms: [.iOS(.v8)],  
    swiftLanguageVersions: [.v5]
)
