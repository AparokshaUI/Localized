> [!IMPORTANT]  
>
> **This project has moved. You can find it [here](https://git.aparoksha.dev/aparoksha/localized).**
>
> The decision is based on [this article](https://sfconservancy.org/GiveUpGitHub/).
>
> Thanks to [No GitHub](https://codeberg.org/NoGitHub) for the badge used below.
>
> [![No GitHub](https://nogithub.codeberg.page/badge.svg)](https://sfconservancy.org/GiveUpGitHub/)

<p align="center">
  <img width="256" alt="Localized Icon" src="Icons/Icon.png">
  <h1 align="center">Localized</h1>
</p>

<p align="center">
  <a href="https://github.com/AparokshaUI/Localized">
  GitHub
  </a>
  ·
  <a href="Documentation/README.md">
  Contributor Docs
  </a>
</p>

_Localized_ provides a Swift package plugin for localizing cross-platform Swift code.

Use YML syntax for defining available phrases:

```yml
hello(name):
    en: Hello, (name)!
    de: Hallo, (name)!
    fr: Salut, (name)!

house:
    en: House
    de: Haus
    fr: Maison

houses(count):
    en(count == "1"): There is one house.
    en: There are (count) houses.
    de(count == "1"): Es gibt ein Haus.
    de: Es gibt (count) Häuser.
```

Then, access the localized strings safely in your code:

```swift
// Use the system language
print(Loc.hello(name: "Peter"))
print(Loc.house)
print(Loc.houses(count: 1))

// Access the translation for a specific language
print(Localized.hello(name: "Peter").en)
print(Localized.house.fr)
```

## Table of Contents

- [Installation][4]
- [Usage][5]
- [Thanks][6]

## Installation

1. Open your Swift package in GNOME Builder, Xcode, or any other IDE.
2. Open the `Package.swift` file.
3. Into the `Package` initializer, under `dependencies`, paste:
```swift
.package(url: "https://github.com/AparokshaUI/Localized", from: "0.1.0")   
```

## Usage

### Definition

Define the available phrases in a file called `Localized.yml`.

```yml
default: en

export:
    en: Export Document
    de: Exportiere das Dokument

send(message, name):
    en(name == ""): Send (message).
    en: Send (message) to (name).
    de: Sende (message) to (name).
```

As you can see, you can add parameters using brackets after the key,
and conditions using brackets after the language (e.g. for pluralization).

The line `default: en` sets English as the fallback language.

Then, add the `Localized` dependency, the plugin and the `Localized.yml` resource
to the target in the `Package.swift` file.

```swift
.executableTarget(
    name: "PluginTests",
    dependencies: ["Localized"],
    resources: [.process("Localized.yml")],
    plugins: ["GenerateLocalized"]
)
```

### Usage

In most cases, you want to get the translated string in the system language.
This can be accomplished using the following syntax.

```swift
let export = Loc.export
let send = Loc.send(message: "Hello", name: "Peter")
```

You can access a specific language as well.

```swift
let export = Localized.export.en
let send = Localized.send(message: "Hallo", name: "Peter").de
```

If you want to get the translation for a specific language code, use the following syntax.
This function will return the translation for the default language if there's no translation for the prefix of that code available.

```swift
let export = Localized.export.string(for: "de-CH")
```

## Thanks

### Dependencies
- [Yams](https://github.com/jpsim/Yams) licensed under the [MIT license](https://github.com/jpsim/Yams/blob/main/LICENSE)

### Other Thanks
- The [contributors][7]
- [SwiftLint][8] for checking whether code style conventions are violated
- The programming language [Swift][9]
- [SourceDocs][10] used for generating the [docs][11]

[1]:    Tests/
[2]:	#goals
[3]:	#widgets
[4]:	#installation
[5]:	#usage
[6]:	#thanks
[7]:	Contributors.md
[8]:	https://github.com/realm/SwiftLint
[9]:	https://github.com/apple/swift
[10]:	https://github.com/SourceDocs/SourceDocs
[11]:	Documentation/README.md

