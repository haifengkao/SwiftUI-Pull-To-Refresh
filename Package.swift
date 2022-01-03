// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// manual build: swift build -Xswiftc "-sdk" -Xswiftc "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.0.sdk" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios12.1-simulator"
import PackageDescription

let package = Package(
    name: "SwiftUIPullToRefresh",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftUIPullToRefresh",
            targets: ["SwiftUIPullToRefresh"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", .upToNextMinor(from: "0.1.3")),
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftUIPullToRefresh",
            dependencies: [
                .product(name: "Introspect", package: "Introspect"),
            ],
            path: "SwiftUIPullToRefresh/Classes"
        ),
        .target(
            name: "SwiftUIPullToRefreshExample",
            dependencies: ["SwiftUIPullToRefresh"],
            path: "Example/Shared"
        ),
        .testTarget(
            name: "Tests iOS",
            dependencies: [
                "SwiftUIPullToRefresh",
                "Quick",
                "Nimble",
            ],
            path: "Example/Tests iOS"
        ),
        .testTarget(
            name: "Tests macOS",
            dependencies: [
                "SwiftUIPullToRefresh",
                "Quick",
                "Nimble",
            ],
            path: "Example/Tests macOS"
        ),
    ]
)
