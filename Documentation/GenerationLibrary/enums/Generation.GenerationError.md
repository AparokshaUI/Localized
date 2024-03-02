**ENUM**

# `Generation.GenerationError`

An error that occurs during code generation.

## Cases
### `missingTranslationInDefaultLanguage(key:)`

A translation in the default language missing for a specific key.
Missing translations in other languages will cause the default language to be used.

### `unknownYMLPasingError`

An unknown error occured while parsing the YML.

### `missingDefaultLanguage`

The default language information is missing.
