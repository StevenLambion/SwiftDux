// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "SwiftDux",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
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
      dependencies: ["SwiftDux"]),
  ]
)
