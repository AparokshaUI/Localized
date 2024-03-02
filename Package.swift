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
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.6"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit", from: "0.3.1")
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
        .macro(
            name: "LocalizedMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
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
            name: "Localized",
            dependencies: [
                "LocalizedMacros"
            ]
        ),
        .executableTarget(
            name: "MacroTests",
            dependencies: [
                "Localized"
            ],
            path: "Tests/MacroTests"
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
