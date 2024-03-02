//
//  Tests.swift
//  Localized
//
//  Created by david-swift on 27.02.2024.
//

import Foundation
import Localized

#localized(default: "en", yml: """
hello(name):
    en: Hello, (name)!
    de: Hallo, (name)!
    fr: Salut, (name)!

house:
    en: House
    de: Haus
    fr: Maison

helloPair(name1, name2):
    en: Hello, (name1) and (name2)!
    de: Hallo, (name1) und (name2)!
    fr: Salut, (name1) et (name2)!
""")

/// Test cases for the `localized` macro.
@main
enum Tests {

    /// Test the `localized` macro.
    static func main() {
        print("EN: \(Localized.hello(name: "Peter").en)")
        print("DE: \(Localized.hello(name: "Ruedi").de)")
        print("SYSTEM: \(Loc.hello(name: "Sams"))")
        print("FR: \(Localized.house.fr)")
        print("DE_CH: \(Localized.house.string(for: "de_CH"))")
        print("SYSTEM: \(Localized.house.string)")
        print("EN: \(Localized.helloPair(name1: "Max", name2: "Ruedi").en)")
    }

}
