// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FontBlaster",
    platforms: [.iOS(.v11), .tvOS(.v11), .macOS(.v10_10)],
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [.target(name: "FontBlaster", path: "Sources")],  
    swiftLanguageVersions: [.v5]
)
