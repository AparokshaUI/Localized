//
//  Localized.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

/// A macro that takes the YML syntax and converts it into enumerations.
@freestanding(declaration, names: named(Localized), named(Loc))
public macro localized(default defaultLanguage: String, yml: String) = #externalMacro(
    module: "LocalizedMacros",
    type: "LocalizedMacro"
)
