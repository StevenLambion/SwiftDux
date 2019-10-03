#! /bin/sh

if [ ! -e SwiftDux.xcodeproj ]; then
  swift package generate-xcodeproj
fi

# Set gh-pages branch to the docs directory.
git worktree add docs gh-pages

rm -rf docs/*

# Generate documentation
jazzy -x USE_SWIFT_RESPONSE_FILE=NO
mkdir -p ./docs/Guides/Images
cp ./Guides/Images/* ./docs/Guides/Images/

# Deploy to gh-pages branch locally.
cd ./docs || exit

git add --all
git commit -m "Documentation changes"

cd ..
git worktree remove docs

