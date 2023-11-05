// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v9),
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.

        // .library(
        //     name: "NDTree",
        //     targets: ["NDTree"]
        // ),

        .library(
            name: "ForceSimulation",
            targets: ["ForceSimulation"]
        ),

        .library(
            name: "Grape",
            targets: ["Grape"]
        ),

    ],

    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", exact: "1.0.0")
    ],

    targets: [

        .target(
            name: "Grape",
            dependencies: ["ForceSimulation"],
            path: "Sources/Grape"
        ),

        // .target(
        //     name: "NDTree",
        //     path: "Sources/NDTree",
        //     swiftSettings: [
        //         .unsafeFlags([
        //              "-cross-module-optimization",
        //             // "-whole-module-optimization",
        //             // "-whole-module-optimization",
        //             // "-Ounchecked",
        //         ]),

        //     ]
        // ),

        .testTarget(
            name: "NDTreeTests",
            dependencies: ["ForceSimulation"]
            // ,
            // swiftSettings: [
            //     .unsafeFlags([
            //          "-cross-module-optimization",
            //         // "-whole-module-optimization",
            //     ])
            // ]
        ),
        .target(
            name: "ForceSimulation",
            // dependencies: ["NDTree"],
            path: "Sources/ForceSimulation"
                // ,
                // swiftSettings: [
                //     .unsafeFlags([
                //          "-cross-module-optimization",
                //         // "-whole-module-optimization",
                //         // "-Ounchecked",
                //     ])
                // ]
        ),

        .testTarget(
            name: "ForceSimulationTests",
            dependencies: ["ForceSimulation"]
            // ,
            // swiftSettings: [
            //     .unsafeFlags([
            //          "-cross-module-optimization",
            //         // "-whole-module-optimization",
            //         // "-Ounchecked",
            //     ])
            // ]
        ),
    ]
)
