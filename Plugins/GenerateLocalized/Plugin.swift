//
//  Plugin.swift
//  Localized
//
//  Created by david-swift on 02.03.24.
//

import Foundation
import PackagePlugin

/// The build tool plugin for generating Swift code from the `Localized.yml` file.
@main
struct Plugin: BuildToolPlugin {

    /// Create the commands for generating the code.
    /// - Parameters:
    ///     - context: The plugin context.
    ///     - target: The target.
    /// - Returns: The commands.
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let target = target.sourceModule,
        let inputFile = target.sourceFiles.first(
            where: { ["Localized.yml", "Localized.yaml"].contains($0.path.lastComponent) }
        ) else {
            return []
        }
        let outputFile = context.pluginWorkDirectory.appending(subpath: "Localized.swift")
        return [
            .buildCommand(
                displayName: "Generating Localized.swift",
                executable: try context.tool(named: "Generation").path,
                arguments: [inputFile.path.string, outputFile.string],
                inputFiles: [inputFile.path],
                outputFiles: [outputFile]
            )
        ]
    }

}
