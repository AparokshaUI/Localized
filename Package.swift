// swift-tools-version: 5.9
//
//  Package.swift
//  Localized
//
//  Created by david-swift on 27.02.24.
//

import CompilerPluginSupport
import PackageDescription

/// The Localized package.
let package = Package(
    name: "Localized",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Localized",
            targets: ["Localized"]
        ),
        .plugin(
            name: "GenerateLocalized",
            targets: ["GenerateLocalized"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.6")
    ],
    targets: [
        .target(
            name: "GenerationLibrary",
            dependencies: [
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .executableTarget(
            name: "Generation",
            dependencies: [
                "GenerationLibrary"
            ]
        ),
        .plugin(
            name: "GenerateLocalized",
            capability: .buildTool(),
            dependencies: [
                "Generation"
            ]
        ),
        .target(
            name: "Localized"
        ),
        .executableTarget(
            name: "PluginTests",
            dependencies: [
                "Localized"
            ],
            path: "Tests/PluginTests",
            resources: [
                .process("Localized.yml")
            ],
            plugins: [
                "GenerateLocalized"
            ]
        )
    ]
)
