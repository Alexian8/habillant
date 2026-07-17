// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "HabitPlanKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "HabitPlanKit", targets: ["HabitPlanKit"]),
    ],
    targets: [
        .target(name: "HabitPlanKit"),
        .testTarget(name: "HabitPlanKitTests", dependencies: ["HabitPlanKit"]),
    ]
)
