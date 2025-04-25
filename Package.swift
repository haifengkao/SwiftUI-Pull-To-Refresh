// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIPullToRefresh",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),

    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftUIPullToRefresh",
            targets: ["SwiftUIPullToRefresh"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftUIPullToRefresh",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            ],
            resources: [.process("Assets")]
        ),
        .testTarget(
            name: "SwiftUIPullToRefreshTests",
            dependencies: ["SwiftUIPullToRefresh"]
        ),
    ]
)
