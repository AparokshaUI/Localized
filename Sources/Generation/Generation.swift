//
//  Generation.swift
//  Localized
//
//  Created by david-swift on 02.03.2024.
//

import Foundation
import GenerationLibrary

try Generation.main()

/// A type containing the generation function for the plugin.
public enum Generation {

    /// Generate the Swift code for the plugin.
    public static func main() throws {
        let yml = try String(contentsOfFile: CommandLine.arguments[1])
        let content = try GenerationLibrary.Generation.getCode(yml: yml)
        let outputPathIndex = 2
        FileManager.default.createFile(
            atPath: CommandLine.arguments[outputPathIndex],
            contents: .init(("import Localized" + "\n\n" + content[0] + "\n\n" + content[1]).utf8)
        )
    }

}
