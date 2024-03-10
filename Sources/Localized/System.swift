//
//  System.swift
//  Localized
//
//  Created by david-swift on 28.02.2024.
//

import Foundation

/// The type system contains a function for parsing the system language.
public enum System {

    /// Remembers the system language after the first request.
    static var systemLanguage: String?

    /// Get the system language.
    /// - Returns: The system language.
    public static func getLanguage() -> String {
        if systemLanguage == nil {
            #if os(Linux)
            guard let lang = ProcessInfo.processInfo.environment["LANG"] else {
                return "en"
            }
            systemLanguage = lang
            #endif
            #if os(macOS)
            systemLanguage = Locale.preferredLanguages.first
            #endif
            #if os(Windows)
            let process = Process()
            process.executableURL = .init(
                fileURLWithPath: "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
            )
            process.arguments = ["-Command", "[System.Globalization.CultureInfo]::CurrentUICulture.Name"]

            let pipe = Pipe()
            process.standardOutput = pipe
            try? process.run()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            systemLanguage = .init(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            #endif
        }
        return systemLanguage ?? "en"
    }

}
