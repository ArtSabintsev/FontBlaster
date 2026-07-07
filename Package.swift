// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FontBlaster",
    platforms: [.iOS(.v17), .tvOS(.v17), .macOS(.v14)],
    products: [.library(name: "FontBlaster", targets: ["FontBlaster"])],
    targets: [
        .target(name: "FontBlaster", path: "Sources"),
        .testTarget(name: "FontBlasterTests",
                    dependencies: ["FontBlaster"],
                    path: "Tests",
                    resources: [.copy("Fonts")])
    ],
    swiftLanguageVersions: [.v5]
)
