#!/bin/sh
#
rm -rf .tmp/ || true

TAG_VERSION="4.0-20241003"
IOS_URL="https://artifacts.videolan.org/VLCKit/dev-artifacts-VLCKit-iOS-main/VLCKit-iOS-4.0-20241003-1407.tar.xz"
TVOS_URL="https://artifacts.videolan.org/VLCKit/dev-artifacts-VLCKit-tvOS-main/VLCKit-tvOS-4.0-20241003-1410.tar.xz"

mkdir .tmp/

#Download and generate MobileVLCKit
wget -O .tmp/MobileVLCKit.tar.xz $IOS_URL
tar -xf .tmp/MobileVLCKit.tar.xz -C .tmp/

#Download and generate VLCKit
wget -O .tmp/VLCKit.tar.xz $MACOS_URL
tar -xf .tmp/VLCKit.tar.xz -C .tmp/

#Download and generate TVVLCKit
wget -O .tmp/TVVLCKit.tar.xz $TVOS_URL
tar -xf .tmp/TVVLCKit.tar.xz -C .tmp/

IOS_LOCATION=".tmp/VLCKit-iOS-binary/VLCKit.xcframework"
TVOS_LOCATION=".tmp/VLCKit-tvOS-binary/VLCKit.xcframework"

mkdir -p "$IOS_LOCATION/maccatalyst-arm64_x86_64/"

IOS_SIM_BINARY="$IOS_LOCATION/ios-arm64_x86_64-simulator/VLCKit.framework"
TVOS_BINARY="$TVOS_LOCATION/tvos-arm64/VLCKit.framework"
IOS_BINARY="$IOS_LOCATION/ios-arm64/VLCKit.framework"
MACOS_BINARY="$IOS_LOCATION/maccatalyst-arm64_x86_64/VLCKit.framework"

cp -r "$IOS_SIM_BINARY" "$MACOS_BINARY"

# Set minimum macCatalyst version using vtool
vtool -set-build-version 6 13.0 15.0 -replace "$IOS_SIM_BINARY/VLCKit" -output "$MACOS_BINARY/VLCKit"

vtool -arch arm64 -set-build-version 3 10.2 15.4 -replace "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/VLCKit.framework/VLCKit" -output "$TVOS_LOCATION/tvos-arm64/VLCKit.framework/VLCKit"

# For tvOS: Keep only arm64
lipo -thin arm64 "$TVOS_BINARY/VLCKit" -output "$TVOS_BINARY/VLCKit"

# Create universal binary for macCatalyst and iOS arm64
xcodebuild -create-xcframework \
    -framework "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/VLCKit.framework" \
    -framework "$TVOS_BINARY"  \
    -framework "$IOS_SIM_BINARY" \
    -framework "$IOS_BINARY" \
    -framework "$MACOS_BINARY" \
    -output .tmp/VLCKit.xcframework
    
# Compress the resulting xcframework
ditto -c -k --sequesterRsrc --keepParent ".tmp/VLCKit.xcframework" ".tmp/VLCKit.xcframework.zip"

# Update the package file with the new hash
PACKAGE_HASH=$(shasum -a 256 ".tmp/VLCKit.xcframework.zip" | awk '{ print $1 }')

PACKAGE_STRING="Target.binaryTarget(name: \"VLCKit-all\", url: \"https:\/\/github.com\/tylerjonesio\/vlckit-spm\/releases\/download\/$TAG_VERSION\/VLCKit-all.xcframework.zip\", checksum: \"$PACKAGE_HASH\")"
echo "Changing package definition for xcframework with hash $PACKAGE_HASH"
sed -i '' -e "s/let vlcBinary.*/let vlcBinary = $PACKAGE_STRING/" Package.swift

cp -f .tmp/MobileVLCKit-binary/COPYING.txt ./LICENSE
