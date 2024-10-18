// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//let vlcBinary = Target.binaryTarget(name: "VLCKit-all", url: "https://github.com/AlvinHV/vlckit-spm/releases/download/3.6.0/VLCKit-all.xcframework.zip", checksum: "fdf9efcdd834eff6e149f0fdd784f864462bf5ac9de4b0f5079502b80e9c239c")
let vlcBinary = Target.binaryTarget(name: "VLCKit-all", url: "https://github.com/AlvinHV/vlckit-spm/releases/download/3.6.0/VLCKit-all.xcframework.zip", checksum: "fdf9efcdd834eff6e149f0fdd784f864462bf5ac9de4b0f5079502b80e9c239c")


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
