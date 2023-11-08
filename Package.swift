// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.

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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],

    targets: [
        
        .target(
            name: "ForceSimulation",
            path: "Sources/ForceSimulation"
        ),

        .target(
            name: "Grape",
            dependencies: ["ForceSimulation"],
            path: "Sources/Grape",
            // link ForceSimulation in release mode
            swiftSettings: [.unsafeFlags(["-Xfrontend", "-disable-availability-checking"])]
        ),

        // .testTarget(
        //     name: "NDTreeTests",
        //     dependencies: ["ForceSimulation"]
        // ),

        .testTarget(
            name: "ForceSimulationTests",
            dependencies: ["ForceSimulation"]
        ),
        
        //     .testTarget(
        //         name: "GrapeTests",
        //         dependencies: ["Grape"]
        //     ),
    ]
)
