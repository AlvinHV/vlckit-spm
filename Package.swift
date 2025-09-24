// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let vlcBinary = Target.binaryTarget(name: "VLCKit-all", url: "https://github.com/AlvinHV/vlckit-spm/releases/download/3.6.1/VLCKit-all.xcframework.zip", checksum: "c239e47af7ac183843c6be9b8d85609e22aa31e7741db508d53c403db9dc5b6e")

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
