// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FOLDER_TO_ITUNES",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FolderToItunesApp",
            targets: ["FolderToItunesApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "FolderToItunesApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
