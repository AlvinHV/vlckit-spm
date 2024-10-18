#!/bin/sh

rm -rf .tmp/ || true

TAG_VERSION="3.6.0"
IOS_URL="https://download.videolan.org/pub/cocoapods/prod/MobileVLCKit-3.6.0-c73b779f-dd8bfdba.tar.xz"
TVOS_URL="https://download.videolan.org/pub/cocoapods/prod/TVVLCKit-3.6.0-c73b779f-dd8bfdba.tar.xz"

mkdir .tmp/

# Download and extract the frameworks
wget -O .tmp/MobileVLCKit.tar.xz $IOS_URL
tar -xf .tmp/MobileVLCKit.tar.xz -C .tmp/

wget -O .tmp/TVVLCKit.tar.xz $TVOS_URL
tar -xf .tmp/TVVLCKit.tar.xz -C .tmp/


IOS_LOCATION=".tmp/MobileVLCKit-binary/MobileVLCKit.xcframework"
TVOS_LOCATION=".tmp/TVVLCKit-binary/TVVLCKit.xcframework"

mkdir -p "$IOS_LOCATION/maccatalyst-arm64_x86_64/"

IOS_SIM_BINARY="$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework"
TVOS_BINARY="$TVOS_LOCATION/tvos-arm64/TVVLCKit.framework"
IOS_BINARY="$IOS_LOCATION/ios-arm64_armv7_armv7s/MobileVLCKit.framework"
MACOS_BINARY="$IOS_LOCATION/maccatalyst-arm64_x86_64/MobileVLCKit.framework"

cp -r "$IOS_SIM_BINARY" "$MACOS_BINARY"

# For iOS Simulator: Remove i386, keep x86_64 and arm64
lipo -remove i386 "$IOS_SIM_BINARY/MobileVLCKit" -output "$IOS_SIM_BINARY/MobileVLCKit"
# For iOS Device: Keep only arm64
lipo -thin arm64 "$IOS_BINARY/MobileVLCKit" -output "$IOS_BINARY/MobileVLCKit"

# Set minimum macCatalyst version using vtool
vtool -set-build-version 6 13.0 15.0 -replace "$IOS_BINARY/MobileVLCKit" -output "$MACOS_BINARY/MobileVLCKit"

vtool -arch arm64 -set-build-version 3 10.2 15.4 -replace "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/TVVLCKit.framework/TVVLCKit" -output "$TVOS_LOCATION/tvos-arm64/TVVLCKit.framework/TVVLCKit"

# For tvOS: Keep only arm64
lipo -thin arm64 "$TVOS_BINARY/TVVLCKit" -output "$TVOS_BINARY/TVVLCKit"

# Create universal binary for macCatalyst and iOS arm64
xcodebuild -create-xcframework \
    -framework "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/TVVLCKit.framework" \
    -framework "$TVOS_BINARY"  \
    -framework "$IOS_SIM_BINARY" \
    -framework "$IOS_BINARY" \
    -framework "$MACOS_BINARY" \
    -output .tmp/VLCKit-all.xcframework
    
# Compress the resulting xcframework
ditto -c -k --sequesterRsrc --keepParent ".tmp/VLCKit-all.xcframework" ".tmp/VLCKit-all.xcframework.zip"

# Update the package file with the new hash
PACKAGE_HASH=$(shasum -a 256 ".tmp/VLCKit-all.xcframework.zip" | awk '{ print $1 }')
PACKAGE_STRING="Target.binaryTarget(name: \"VLCKit-all\", url: \"https:\/\/github.com\/AlvinHV\/vlckit-spm\/releases\/download\/$TAG_VERSION\/VLCKit-all.xcframework.zip\", checksum: \"$PACKAGE_HASH\")"
echo "Updating package definition for xcframework with hash $PACKAGE_HASH"
sed -i '' -e "s/let vlcBinary.*/let vlcBinary = $PACKAGE_STRING/" Package.swift

# Copy license file
cp -f .tmp/MobileVLCKit-binary/COPYING.txt ./LICENSE
