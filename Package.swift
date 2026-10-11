// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChiefOfStaff",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ChiefOfStaff",
            targets: ["ChiefOfStaff"]),
    ],
    targets: [
        .target(
            name: "ChiefOfStaff",
            dependencies: [],
            path: "Sources/ChiefOfStaff"
        ),
        .testTarget(
            name: "ChiefOfStaffTests",
            dependencies: ["ChiefOfStaff"],
            path: "Tests/ChiefOfStaffTests"
        ),
    ]
)