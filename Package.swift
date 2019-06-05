// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RAGTextField",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "RAGTextField", targets: ["RAGTextField"])
    ],
    targets: [
        .target(name: "RAGTextField")
    ]
)
