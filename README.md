# number_editing_controller

![Pub Version](https://img.shields.io/pub/v/number_editing_controller)
![GitHub](https://img.shields.io/github/license/nerdy-pro/flutter_number_editing_controller)

Missing number input controller for flutter apps

## Features

- formats as-you-type text fields as numbers (decimals, currency or integers)
- extracts `num` value from the input
- an example with `final controller = NumberEditingTextController.currency(currencyName: 'JPY');` controller

![iPhone 14](https://github.com/nerdy-pro/flutter_number_editing_controller/blob/main/img/screenshot.gif)


## Getting started

- install the library

```shell
flutter pub add number_editing_controller
```


## Usage



Working example can be found in [/example](https://github.com/nerdy-pro/flutter_number_editing_controller/tree/main/example) directory

- first you should define your controller

### integer input

```dart
final controller = NumberEditingTextController.integer();
```

### decimal input

```dart
final controller = NumberEditingTextController.decimal();
```

### currency amount input

```dart
final controller = NumberEditingTextController.currency();
```

- optionally you can provide `locale` to use locale-based formatting
- for `currency()` there's also `currencyName` and `currencySymbol` parameters available

- you can set `allowNegative` to `false` to allow only unsigned input

- set this `controller` as the controller for the target `TextField`
- now the `TextField` would filter out all non-integer symbols
- you can extract the value with `controller.number`
