// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [
        .macOS(.v12), 
        .iOS(.v13),
        .watchOS(.v10),
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
    targets: [
        
        .target(
            name: "NDTree",
            path: "Sources/NDTree",
            swiftSettings:[.unsafeFlags(["-whole-module-optimization", "-Ounchecked"])]
        ),

        .testTarget(
            name: "NDTreeTests",
            dependencies: ["NDTree"]),

        .target(
            name: "ForceSimulation",
            dependencies: ["NDTree"],
            path: "Sources/ForceSimulation",
            swiftSettings:[.unsafeFlags(["-whole-module-optimization", "-Ounchecked"])]
        ),

        .testTarget(
            name: "ForceSimulationTests",
            dependencies: ["ForceSimulation", "NDTree"]),
    ]
)
