// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "FontBlaster",
    platforms: [.iOS(.v8)],
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [.target(name: "FontBlaster", path: "Sources")],  
    swiftLanguageVersions: [.v5]
)
