//
//  LocalizedMacro.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

// swiftlint:disable force_unwrapping force_cast

import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros
import Yams

/// Implementation of the `localized` macro, which takes YML 
/// as a string and converts it into two enumerations.
/// Access a specific language using `Localized.key.language`, or use `Localized.key.string`
/// which automatically uses the system language on Linux, macOS and Windows.
/// Use `Loc.key` for a quick access to the automatically localized value.
public struct LocalizedMacro: DeclarationMacro {

    /// Number of spaces for indentation 1.
    static let indentOne = 4
    /// Number of spaces for indentation 2.
    static let indentTwo = 8
    /// Number of spaces for indentation 3.
    static let indentThree = 12

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
        guard let `default` = node.argumentList.first?.expression.as(StringLiteralExprSyntax.self) else {
            throw LocalizedError.invalidDefaultLanguage
        }
        guard let syntax = node.argumentList.last?.expression.as(StringLiteralExprSyntax.self) else {
            throw LocalizedError.invalidStringLiteral
        }
        let dictionary = try Yams.load(yaml: StringLiteral(syntax).value!) as! [String: [String: String]]
        return [
            """
            enum Localized {

                static var yml: String {
                    \"""
            \(raw: indent(StringLiteral(syntax).value!.description, by: indentTwo))
                    \"""
                }

            \(raw: generateEnumCases(dictionary: dictionary))

                var string: String { string(for: System.getLanguage()) }

            \(raw: generateTranslations(dictionary: dictionary))

            \(raw: generateLanguageFunction(dictionary: dictionary, defaultLanguage: `default`))

            }
            """,
            """
            enum Loc {

            \(raw: generateStaticLocVariables(dictionary: dictionary))

            }
            """
        ]
    }

    /// Generate the cases for the `Localized` enumeration.
    /// - Parameter dictionary: The parsed YML.
    /// - Returns: The syntax.
    static func generateEnumCases(dictionary: [String: [String: String]]) -> String {
        var result = ""
        for entry in dictionary {
            let key = parse(key: entry.key)
            if key.1.isEmpty {
                result.append("""
                    case \(entry.key)
                """)
            } else {
                var line = "case \(key.0)("
                for argument in key.1 {
                    line += "\(argument): String, "
                }
                line.removeLast(", ".count)
                line += ")"
                result.append("""
                    \(line)
                """)
            }
        }
        return result
    }

    /// Generate the static variables and functions for the `Loc` type.
    /// - Parameter dictionary: The parsed YML.
    /// - Returns: The syntax.
    static func generateStaticLocVariables(dictionary: [String: [String: String]]) -> String {
        var result = ""
        for entry in dictionary {
            let key = parse(key: entry.key)
            if key.1.isEmpty {
                result.append("""
                    static var \(entry.key): String { Localized.\(entry.key).string }
                """)
            } else {
                var line = "static func \(key.0)("
                for argument in key.1 {
                    line += "\(argument): String, "
                }
                line.removeLast(", ".count)
                line += ") -> String {\n" + indent("Localized.\(key.0)(", by: indentOne)
                for argument in key.1 {
                    line += "\(argument): \(argument), "
                }
                line.removeLast(", ".count)
                line += ").string"
                line += "\n}"
                result.append("""
                    \(line)
                """)
            }
        }
        return result
    }

    /// Generate the variables for the translations.
    /// - Parameter dictionary: The parsed YML.
    /// - Returns: The syntax.
    static func generateTranslations(dictionary: [String: [String: String]]) -> String {
        var result = ""
        for language in getLanguages(dictionary: dictionary) {
            var variable = indent("var \(language): String {", by: indentOne)
            variable += indent("\nswitch self {", by: indentTwo)
            for entry in dictionary {
                let key = parse(key: entry.key)
                if key.1.isEmpty {
                    variable += indent("\ncase .\(entry.key):", by: indentTwo)
                    variable += indent("\n\"\(entry.value[language]!)\"", by: indentThree)
                } else {
                    let translation = parse(translation: entry.value[language]!, arguments: key.1)
                    variable += indent("\ncase let .\(entry.key):", by: indentTwo)
                    variable += indent("\n\"\(translation)\"", by: indentThree)
                }
            }
            variable += indent("\n    }\n}", by: indentOne)
            result += """
            \(variable)
            """
        }
        return result
    }

    /// Generate the function for getting the translated string for a specified language code.
    /// - Parameters:
    ///     - dictionary: The parsed YML.
    ///     - defaultLanguage: The syntax for the default language.
    /// - Returns: The syntax.
    static func generateLanguageFunction(
        dictionary: [String: [String: String]],
        defaultLanguage: StringLiteralExprSyntax
    ) -> String {
        let defaultLanguage = StringLiteral(defaultLanguage).value!.description
        var result = "func string(for language: String) -> String {\n"
        for language in getLanguages(dictionary: dictionary) where language != defaultLanguage {
            result += indent("if language.hasPrefix(\"\(language)\") {", by: indentTwo)
            result += indent("\nreturn \(language)", by: indentThree)
            result += indent("\n} else", by: indentTwo)
        }
        result += """
        {
            return \(defaultLanguage)
        }
        }
        """
        return result
    }

    /// Get the available languages.
    /// - Parameter dictionary: The parsed YML.
    /// - Returns: The syntax
    static func getLanguages(dictionary: [String: [String: String]]) -> [String] {
        dictionary.first?.value.map { $0.key } ?? []
    }

    /// Parse the key for a phrase.
    /// - Parameter key: The key definition including parameters.
    /// - Returns: The key.
    static func parse(key: String) -> (String, [String]) {
        let parts = key.split(separator: "(")
        if parts.count == 1 {
            return (key, [])
        }
        let arguments = parts[1].dropLast().split(separator: ", ").map { String($0) }
        return (.init(parts[0]), arguments)
    }

    /// Parse the translation for a phrase.
    /// - Parameters:
    ///     - translation: The translation without correct escaping.
    ///     - arguments: The arguments.
    /// - Returns: The syntax.
    static func parse(translation: String, arguments: [String]) -> String {
        var translation = translation
        for argument in arguments {
            translation.replace("(\(argument))", with: "\\(\(argument))")
        }
        return translation
    }

    /// Indent each line of a text by a certain amount of whitespaces.
    /// - Parameters:
    ///     - string: The text.
    ///     - count: The indentation.
    /// - Returns: The syntax.
    static func indent(_ string: String, by count: Int) -> String {
        .init(
            string
                .components(separatedBy: "\n")
                .map { "\n" + Array(repeating: " ", count: count).joined() + $0 }
                .joined()
                .trimmingPrefix("\n")
        )
    }
}

// swiftlint:enable force_unwrapping force_cast
