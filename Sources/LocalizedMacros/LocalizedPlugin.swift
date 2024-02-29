//
//  LocalizedPlugin.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// The compiler plugin offering the `localized` macro.
@main
struct LocalizedPlugin: CompilerPlugin {

    /// The macros.
    let providingMacros: [Macro.Type] = [
        LocalizedMacro.self
    ]

}
