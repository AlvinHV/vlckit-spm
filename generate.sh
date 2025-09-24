#!/bin/sh

rm -rf .tmp/ || true

TAG_VERSION="3.6.1"
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

IOS_SIM_BINARY="$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework"
TVOS_BINARY="$TVOS_LOCATION/tvos-arm64/TVVLCKit.framework"
IOS_BINARY="$IOS_LOCATION/ios-arm64_armv7_armv7s/MobileVLCKit.framework"

# For iOS Device: Keep only arm64
lipo -thin arm64 "$IOS_BINARY/MobileVLCKit" -output "$IOS_BINARY/MobileVLCKit"

xcodebuild -create-xcframework \
    -framework "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/TVVLCKit.framework" \
    -framework "$TVOS_BINARY"  \
    -framework "$IOS_SIM_BINARY" \
    -framework "$IOS_BINARY" \
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
