# Installation

## Xcode

Use the new swift package manager integration to include the library.

## Package.swift

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 1, minor: 3)
  ]
)
```
