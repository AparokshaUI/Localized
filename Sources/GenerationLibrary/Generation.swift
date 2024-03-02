//
//  Generation.swift
//  Localized
//
//  Created by david-swift on 02.03.2024.
//

import Yams

/// Generate the Swift code for the plugin and macro.
public enum Generation {

    /// Number of spaces for indentation 1.
    static let indentOne = 4
    /// Number of spaces for indentation 2.
    static let indentTwo = 8
    /// Number of spaces for indentation 3.
    static let indentThree = 12

    /// An error that occurs during code generation.
    public enum GenerationError: Error {

        /// A translation in the default language missing for a specific key.
        /// Missing translations in other languages will cause the default language to be used.
        case missingTranslationInDefaultLanguage(key: String)
        /// An unknown error occured while parsing the YML.
        case unknownYMLPasingError
        /// The default language information is missing.
        case missingDefaultLanguage

    }

    /// Get the Swift code for the plugin and macro.
    /// - Parameter yml: The YML code.
    /// - Returns: The code.
    public static func getCode(yml: String) throws -> [String] {
        guard var dict = try Yams.load(yaml: yml) as? [String: Any] else {
            throw GenerationError.unknownYMLPasingError
        }
        guard let defaultLanguage = dict["default"] as? String else {
            throw GenerationError.missingDefaultLanguage
        }
        dict["default"] = nil
        guard let dictionary = dict as? [String: [String: String]] else {
            throw GenerationError.unknownYMLPasingError
        }
        return [
            """
            enum Localized {

                static var yml: String {
                    \"""
            \(indent(yml, by: indentTwo))
                    \"""
                }

            \(generateEnumCases(dictionary: dictionary))

                var string: String { string(for: System.getLanguage()) }

            \(try generateTranslations(dictionary: dictionary, defaultLanguage: defaultLanguage))

            \(generateLanguageFunction(dictionary: dictionary, defaultLanguage: defaultLanguage))

            }
            """,
            """
            enum Loc {

            \(generateStaticLocVariables(dictionary: dictionary))

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
    /// - Parameters:
    ///     - dictionary: The parsed YML.
    ///     - defaultLanguage: The default language.
    /// - Returns: The syntax.
    static func generateTranslations(dictionary: [String: [String: String]], defaultLanguage: String) throws -> String {
        var result = ""
        for language in getLanguages(dictionary: dictionary) {
            var variable = indent("var \(language): String {", by: indentOne)
            variable += indent("\nswitch self {", by: indentTwo)
            for entry in dictionary {
                let key = parse(key: entry.key)
                guard let valueForLanguage = entry.value[language] ?? entry.value[defaultLanguage] else {
                    throw GenerationError.missingTranslationInDefaultLanguage(key: key.0)
                }
                let value = parseValue(
                    defaultTranslation: valueForLanguage,
                    translations: entry.value,
                    language: language,
                    arguments: key.1
                )
                if key.1.isEmpty {
                    variable += indent("\ncase .\(entry.key):", by: indentTwo)
                    variable += value
                } else {
                    variable += indent("\ncase let .\(entry.key):", by: indentTwo)
                    variable += value
                }
            }
            variable += indent("\n    }\n}", by: indentOne)
            result += """
            \(variable)

            """
        }
        return result
    }

    /// Parse the content of a switch case.
    /// - Parameters:
    ///     - defaultTranslation: The translation without any conditions (always required).
    ///     - translations: All the available translations for an entry.
    ///     - language: The language.
    ///     - arguments: The arguments of the entry.
    /// - Returns: The syntax.
    static func parseValue(
        defaultTranslation: String,
        translations: [String: String],
        language: String,
        arguments: [String] = []
    ) -> String {
        var value = "\n"
        let conditionTranslations = translations.filter { $0.key.hasPrefix(language + "(") }
        let lastTranslation = parse(translation: defaultTranslation, arguments: arguments)
        if conditionTranslations.isEmpty {
            return indent("\n\"\(lastTranslation)\"", by: indentThree)
        }
        for translation in conditionTranslations {
            var condition = translation.key.split(separator: "(")[1]
            condition.removeLast()
            value.append(indent("""
             if \(condition) {
                \"\(parse(translation: translation.value, arguments: arguments))\"
            } else
            """, by: indentThree))
        }
        value.append("""
         {
            \"\(lastTranslation)\"
        }
        """)
        return value
    }

    /// Generate the function for getting the translated string for a specified language code.
    /// - Parameters:
    ///     - dictionary: The parsed YML.
    ///     - defaultLanguage: The default language.
    /// - Returns: The syntax.
    static func generateLanguageFunction(
        dictionary: [String: [String: String]],
        defaultLanguage: String
    ) -> String {
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
        var languages: Set<String> = []
        for key in dictionary {
            languages = languages.union(key.value.compactMap { $0.key.components(separatedBy: "(").first })
        }
        return .init(languages)
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
