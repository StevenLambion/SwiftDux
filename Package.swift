// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftDux",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "SwiftDux",
      targets: ["SwiftDux", "SwiftDuxExtras"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-format.git", .branch("master")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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
