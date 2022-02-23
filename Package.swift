// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FCUUID",
    products: [
        .library(
            name: "FCUUID",
            targets: ["FCUUID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/UICKeyChainStore", .upToNextMajor(from: "2.2.1")),
    ],
    targets: [
        .target(
            name: "FCUUID",
            dependencies: ["UICKeyChainStore"],
            path: ".",
            exclude: ["FCUUID.podspec", "LICENSE", "README.md"],
            sources: ["FCUUID"],
            resources: nil,
            publicHeadersPath: "FCUUID/"
        )
    ]
)
