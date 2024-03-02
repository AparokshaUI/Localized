**STRUCT**

# `LocalizedMacro`

Implementation of the `localized` macro, which takes YML 
as a string and converts it into two enumerations.
Access a specific language using `Localized.key.language`, or use `Localized.key.string`
which automatically uses the system language on Linux, macOS and Windows.
Use `Loc.key` for a quick access to the automatically localized value.

## Methods
### `expansion(of:in:)`

Expand the `localized` macro.
- Parameters:
    - node: Information about the macro call.
    - context: The expansion context.
- Returns: The enumerations `Localized` and `Loc`.
