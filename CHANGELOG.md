## 2.0.0

### Breaking changes

* Moved implementation files from `lib/parsed_number_format/` to `lib/src/`. Only `NumberEditingTextController` is exported from the public API.
* Renamed internal `FormatResult` in `parts.dart` to `PartFormatResult` to avoid naming collision.
* Removed unused `CurrencySignPart` class (replaced by `StaticPart`).
* Removed unused `PartLength` class hierarchy and `length` getters on format parts.
* Updated minimum SDK constraints to Dart >=3.3.0 and Flutter >=3.19.0.

### Bug fixes

* Fixed negative decimal numbers producing incorrect values when typed (e.g. `-5.14` was parsed as `-4.86`).
* Fixed crash (`RangeError`) when a group separator appeared at the start of input.
* Fixed crash (`UnsupportedError`) when setting `number` to `NaN` or `Infinity`.
* Fixed incorrect grouping for negative numbers with 6+ digits when typed (e.g. `-100000` was formatted as `-,100,000`).
* Fixed currency symbol duplication when typing a character before a leading currency symbol.

### Improvements

* Added `repository` and `topics` fields to `pubspec.yaml` for better pub.dev discoverability.
* Improved package description.
* Added `library` directive with documentation to the barrel export file.
* Added dartdoc comments to all public classes and members.
* Improved and corrected existing doc comments (grammar, terminology).
* Made internal locale utility functions private.
* Replaced custom `String.repeat` extension with Dart's built-in `*` operator.
* Replaced list-based `isDigit` check with a code unit comparison.
* Added `dispose()` calls in all example app controllers.
* Removed default Flutter counter test from the example app.
* Removed FVM dependency from CI workflows.
* Simplified GitHub Actions workflows.
* Rewrote README with usage examples, configuration tables, and parameter documentation.
* Expanded test suite from 11 to 114 tests covering formatting, locales, edge cases, caret positions, and bug regressions.

## 1.4.0

* Updated dependencies and flutter version

## 1.3.1

* Updated library layout

## 1.3.0

* Fixed documentation
* Updated flutter
* Updated dependencies

## 1.2.1

* Updated docs

## 1.2.0

* Added an optional `currencySymbol` parameter

## 1.1.0

* Added a flag to allow only unsigned input

## 1.0.2

* Fixed a bug with zero-input deletion

## 1.0.1

* Updated docs

## 1.0.0

* Initial release
