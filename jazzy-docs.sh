#! /bin/sh

if [ ! -e SwiftDux.xcodeproj ]; then
  swift package generate-xcodeproj
fi

jazzy -x USE_SWIFT_RESPONSE_FILE=NO
mkdir -p ./docs/Guides/Images
cp ./Guides/Images/* ./docs/Guides/Images/
