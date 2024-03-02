//
//  LocalizedMacro.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

import GenerationLibrary
import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `localized` macro, which takes YML 
/// as a string and converts it into two enumerations.
/// Access a specific language using `Localized.key.language`, or use `Localized.key.string`
/// which automatically uses the system language on Linux, macOS and Windows.
/// Use `Loc.key` for a quick access to the automatically localized value.
public struct LocalizedMacro: DeclarationMacro {

    /// The errors the expansion can throw.
    public enum LocalizedError: Error {

        /// The string literal syntax is invalid.
        case invalidStringLiteral
        /// The default language syntax is invalid.
        case invalidDefaultLanguage

    }

    /// Expand the `localized` macro.
    /// - Parameters:
    ///     - node: Information about the macro call.
    ///     - context: The expansion context.
    /// - Returns: The enumerations `Localized` and `Loc`.
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let `default` = node.argumentList.first?.expression.as(StringLiteralExprSyntax.self),
        let defaultLanguage = StringLiteral(`default`).value?.description else {
            throw LocalizedError.invalidDefaultLanguage
        }
        guard let syntax = node.argumentList.last?.expression.as(StringLiteralExprSyntax.self),
        var yml = StringLiteral(syntax).value else {
            throw LocalizedError.invalidStringLiteral
        }
        yml.append("\n\ndefault: \"\(defaultLanguage)\"")
        return try Generation.getCode(yml: yml).map { "\(raw: $0)" }
    }

}
