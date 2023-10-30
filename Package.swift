// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v7),
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.

        .library(
            name: "NDTree",
            targets: ["NDTree"]
        ),

        .library(
            name: "ForceSimulation",
            targets: ["ForceSimulation"]
        ),

    ],

    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", exact: "1.0.0")
    ],

    targets: [

        .target(
            name: "NDTree",
            path: "Sources/NDTree",
            swiftSettings: [
                .unsafeFlags([
                    "-cross-module-optimization",
                    // "-whole-module-optimization",
                    // "-whole-module-optimization",
                    // "-Ounchecked",
                ])
            ]
        ),

        .testTarget(
            name: "NDTreeTests",
            dependencies: ["NDTree"],
            swiftSettings: [
                .unsafeFlags([
                    "-cross-module-optimization",
                    // "-whole-module-optimization",
                ])
            ]
        ),
        .target(
            name: "ForceSimulation",
            dependencies: ["NDTree"],
            path: "Sources/ForceSimulation",
            swiftSettings: [
                .unsafeFlags([
                    "-cross-module-optimization",
                    // "-whole-module-optimization",
                    // "-Ounchecked",
                ])
            ]
            // , swiftSettings:[.unsafeFlags(["-whole-module-optimization", "-Ounchecked"])]
        ),

        .testTarget(
            name: "ForceSimulationTests",
            dependencies: ["ForceSimulation", "NDTree"],
            swiftSettings: [
                .unsafeFlags([
                    "-cross-module-optimization",
                    // "-whole-module-optimization",
                    // "-Ounchecked",
                ])
            ]),
    ]
)
