#!/bin/sh

# Please run in root direction like 'sh scripts/build_macos_android.sh'
read -p 'Build version: ' AF_VERSION

# remove old build
rm -rf build/$AF_VERSION/

# macOS
mkdir -p build/$AF_VERSION/macos
cd src
flutter build macos --release
cd ..
mv src/build/macos/Build/Products/Release/anime_finder.app build/$AF_VERSION/macos/AnimeFinder.app
ln -s /Applications build/$AF_VERSION/macos/
hdiutil create -volname AnimeFinder -srcfolder build/$AF_VERSION/macos -ov -format UDZO build/$AF_VERSION/macos/AnimeFinder_${AF_VERSION}_macOS_universal.dmg
rm -rf build/$AF_VERSION/macos/AnimeFinder.app
rm build/$AF_VERSION/macos/Applications
echo "Build Complete for macOS"

# android
mkdir -p build/$AF_VERSION/android
cd src
flutter build apk --release
cd ..
mv src/build/app/outputs/flutter-apk/app-release.apk build/$AF_VERSION/android/AnimeFinder_${AF_VERSION}_android.apk
echo "Build Complete for android"