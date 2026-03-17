# number_editing_controller

[![Pub Version](https://img.shields.io/pub/v/number_editing_controller)](https://pub.dev/packages/number_editing_controller)
[![License](https://img.shields.io/github/license/nerdy-pro/flutter_number_editing_controller)](https://github.com/nerdy-pro/flutter_number_editing_controller/blob/main/LICENSE)

A Flutter `TextEditingController` that automatically formats numbers, decimals, and currencies as the user types. Built with full locale support.

Developed by [nerdy.pro](https://nerdy.pro).

## Features

- **As-you-type formatting** for integers, decimals, and currency amounts
- **Locale-aware** grouping and decimal separators (e.g. `1,234.56` in English, `1.234,56` in German)
- **Currency support** with automatic symbol placement based on locale
- **Extracts the numeric value** via `controller.number`
- **Negative number support** with optional `allowNegative` flag
- **Custom separators** for decimal and grouping characters

![number_editing_controller demo](https://raw.githubusercontent.com/nerdy-pro/flutter_number_editing_controller/main/img/screenshot.gif)

## Getting started

Install the package:

```shell
flutter pub add number_editing_controller
```

## Usage

Create a controller and assign it to a `TextField`:

```dart
final controller = NumberEditingTextController.currency(currencyName: 'USD');

TextField(
  controller: controller,
  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
)
```

Read the numeric value at any time:

```dart
final value = controller.number; // e.g. 1234.56
```

### Integer input

```dart
final controller = NumberEditingTextController.integer();
```

### Decimal input

```dart
final controller = NumberEditingTextController.decimal();
```

### Currency input

```dart
final controller = NumberEditingTextController.currency(currencyName: 'EUR');
```

### Configuration options

All constructors accept the following parameters:

| Parameter | Description |
|-----------|-------------|
| `locale` | Locale for number formatting (e.g. `'en'`, `'de'`, `'ja'`). Defaults to the current locale. |
| `allowNegative` | Whether to allow negative numbers. Defaults to `true`. |
| `groupSeparator` | Custom digit grouping symbol (e.g. `','`, `'.'`, `' '`). |
| `value` | Initial numeric value. |

The `currency()` constructor also accepts:

| Parameter | Description |
|-----------|-------------|
| `currencyName` | ISO 4217 currency code (e.g. `'USD'`, `'EUR'`, `'JPY'`). |
| `currencySymbol` | Custom currency symbol (e.g. `'$'`, `'€'`, `'₺'`). |
| `decimalSeparator` | Custom decimal separator symbol. |

The `decimal()` constructor also accepts:

| Parameter | Description |
|-----------|-------------|
| `minimalFractionDigits` | Minimum number of decimal digits to display. |
| `maximumFractionDigits` | Maximum number of decimal digits allowed. |
| `decimalSeparator` | Custom decimal separator symbol. |

### Examples

```dart
// US Dollar with locale
final usd = NumberEditingTextController.currency(
  currencyName: 'USD',
  locale: 'en',
);

// Euro in German locale
final eur = NumberEditingTextController.currency(
  currencyName: 'EUR',
  locale: 'de',
);

// Positive-only integer
final positive = NumberEditingTextController.integer(
  allowNegative: false,
);

// Decimal with precision control
final precise = NumberEditingTextController.decimal(
  minimalFractionDigits: 2,
  maximumFractionDigits: 4,
  locale: 'en',
);
```

A working example app is available in the [example](https://github.com/nerdy-pro/flutter_number_editing_controller/tree/main/example) directory.

### Disposing the controller

Like any `TextEditingController`, dispose of it when it is no longer needed:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```
