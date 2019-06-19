#! /bin/sh

if [ ! -e SwiftDux.xcodeproj ]; then
  swift package generate-xcodeproj
fi

jazzy -x -scheme,SwiftDux-Package -m SwiftDux
mkdir -p ./docs/Guides/Images
cp ./Guides/Images/* ./docs/Guides/Images/
