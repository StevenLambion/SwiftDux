#! /bin/sh

if [ ! -e SwiftDux.xcodeproj ]; then
  swift package generate-xcodeproj
fi

jazzy

