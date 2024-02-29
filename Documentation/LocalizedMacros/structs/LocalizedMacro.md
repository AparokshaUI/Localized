**STRUCT**

# `LocalizedMacro`

Implementation of the `localized` macro, which takes YML 
as a string and converts it into two enumerations.
Access a specific language using `Localized.key.language`, or use `Localized.key.string`
which automatically uses the system language on Linux, macOS and Windows.
Use `Loc.key` for a quick access to the automatically localized value.

## Properties
### `indentOne`

Number of spaces for indentation 1.

### `indentTwo`

Number of spaces for indentation 2.

### `indentThree`

Number of spaces for indentation 3.

## Methods
### `expansion(of:in:)`

Expand the `localized` macro.
- Parameters:
    - node: Information about the macro call.
    - context: The expansion context.
- Returns: The enumerations `Localized` and `Loc`.

### `generateEnumCases(dictionary:)`

Generate the cases for the `Localized` enumeration.
- Parameter dictionary: The parsed YML.
- Returns: The syntax.

### `generateStaticLocVariables(dictionary:)`

Generate the static variables and functions for the `Loc` type.
- Parameter dictionary: The parsed YML.
- Returns: The syntax.

### `generateTranslations(dictionary:)`

Generate the variables for the translations.
- Parameter dictionary: The parsed YML.
- Returns: The syntax.

### `generateLanguageFunction(dictionary:defaultLanguage:)`

Generate the function for getting the translated string for a specified language code.
- Parameters:
    - dictionary: The parsed YML.
    - defaultLanguage: The syntax for the default language.
- Returns: The syntax.

### `getLanguages(dictionary:)`

Get the available languages.
- Parameter dictionary: The parsed YML.
- Returns: The syntax

### `parse(key:)`

Parse the key for a phrase.
- Parameter key: The key definition including parameters.
- Returns: The key.

### `parse(translation:arguments:)`

Parse the translation for a phrase.
- Parameters:
    - translation: The translation without correct escaping.
    - arguments: The arguments.
- Returns: The syntax.

### `indent(_:by:)`

Indent each line of a text by a certain amount of whitespaces.
- Parameters:
    - string: The text.
    - count: The indentation.
- Returns: The syntax.
