// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QuadTree",
            targets: ["QuadTree"]
        ),

        .library(
            name: "NDTree",
            targets: ["NDTree"]
        ),

        .library(
            name: "ForceSimulation",
            targets: ["ForceSimulation"]
        ),

        .library(
            name: "Grape",
            targets: ["Grape"]
        ),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "QuadTree",
            path: "Sources/QuadTree"
        ),

        .target(
            name: "NDTree",
            path: "Sources/NDTree"
        ),

        .testTarget(
            name: "NDTreeTests",
            dependencies: ["NDTree"]),

        .target(
            name: "Grape", dependencies: ["QuadTree", "ForceSimulation"],
            path: "Sources/Grape"
        ),

        .target(
            name: "ForceSimulation",
            dependencies: ["QuadTree"],
            path: "Sources/ForceSimulation"
        ),

        .testTarget(
            name: "QuadTreeTests",
            dependencies: ["QuadTree"]),

        .testTarget(
            name: "ForceSimulationTests",
            dependencies: ["ForceSimulation", "QuadTree"]),
    ]
)
