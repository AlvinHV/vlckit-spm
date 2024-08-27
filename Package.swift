// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//let vlcBinary = Target.binaryTarget(name: "VLCKit-all", url: "https://github.com/tylerjonesio/vlckit-spm/releases/download/3.6.0/VLCKit-all.xcframework.zip", checksum: "c6d566aea6b69c7980216c8716fbf6241bbd1eedf1310f01ab5c0732c4a75b02")
let vlcBinary = Target.binaryTarget(name: "VLCKit-all", path: ".tmp/VLCKit-all.xcframework")


let package = Package(
    name: "vlckit-spm",
    platforms: [.macCatalyst(.v13), .iOS(.v11), .tvOS(.v11)],
    products: [
        .library(
            name: "VLCKitSPM",
            targets: ["VLCKitSPM"]),
    ],
    dependencies: [],
    targets: [
        vlcBinary,
        .target(
            name: "VLCKitSPM",
            dependencies: [
                .target(name: "VLCKit-all")
            ], linkerSettings: [
                .linkedFramework("QuartzCore", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("CoreText", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("AVFoundation", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("Security", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("CFNetwork", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("OpenGLES", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("VideoToolbox", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("CoreMedia", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedLibrary("c++", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedLibrary("xml2", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedLibrary("z", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedLibrary("bz2", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("Foundation", .when(platforms: [.macOS])),
                .linkedLibrary("iconv")
            ]),
    ]
)
