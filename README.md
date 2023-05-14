## Features

- formats as-you-type text fields as numbers (decimals, currency or integers)
- extracts `num` value from the input

## Getting started

- install the library

```shell
flutter pub add number_editing_controller
```


## Usage

- first you should define your controller
```dart
final controller = NumberEditingTextController.integer();
```

- set this `controller` as the controller for the target `TextField`
- now the `TextField` would filter out all non-integer symbols
- you can extract the value with `controller.number`
