# Installation

## Xcode

Search for SwiftDux in Xcode's Swift Package Manager integration.

## Package.swift

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", from: "2.0.0")
  ]
)
```
