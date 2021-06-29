// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SwiftDux",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .watchOS(.v7),
  ],
  products: [
    .library(
      name: "SwiftDux",
      targets: ["SwiftDux", "SwiftDuxExtras"]),
  ],
  targets: [
    .target(
      name: "SwiftDux",
      dependencies: []),
    .target(
      name: "SwiftDuxExtras",
      dependencies: ["SwiftDux"]),
    .testTarget(
      name: "SwiftDuxTests",
      dependencies: [
        "SwiftDux",
        "SwiftDuxExtras",
        "SnapshotTesting"],
      exclude: ["UI/__Snapshots__"]),
  ]
)
