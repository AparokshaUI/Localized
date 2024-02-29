//
//  Localized.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(declaration, names: named(Localized), named(Loc))
public macro localized(default defaultLanguage: String, yml: String) = #externalMacro(
    module: "LocalizedMacros",
    type: "LocalizedMacro"
)
