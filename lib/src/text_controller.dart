import 'package:flutter/material.dart';
import 'package:number_editing_controller/src/parsed_number_format.dart';

/// A [TextEditingController] that automatically formats user input as
/// numbers, decimals, or currencies with locale-aware formatting.
///
/// Use one of the factory constructors to create an instance:
/// - [NumberEditingTextController.currency] for currency amounts
/// - [NumberEditingTextController.decimal] for decimal numbers
/// - [NumberEditingTextController.integer] for integers
///
/// Or instantiate the subclasses directly:
/// - [CurrencyEditingController]
/// - [DecimalEditingController]
/// - [IntegerEditingController]
///
/// The formatted text is displayed in the [TextField], while the underlying
/// numeric value can be accessed via the [number] property.
///
/// Formatting options such as [locale], [groupSeparator], and [allowNegative]
/// can be changed at any time. Changing an option automatically reformats the
/// current value.
abstract interface class NumberEditingTextController
    implements TextEditingController {
  /// Creates a controller instance suitable for formatting input as a currency amount.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [currencyName] - 3-letter ISO 4217 currency code (e.g. USD, EUR, TRY)
  /// [currencySymbol] - currency symbol (e.g. $, €, ₺)
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate the decimal part
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  factory NumberEditingTextController.currency({
    String? locale,
    String? currencyName,
    String? currencySymbol,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative,
  }) = CurrencyEditingController;

  /// Creates a controller instance suitable for formatting input as a decimal number.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [minimalFractionDigits] - minimum number of fraction digits
  /// [maximumFractionDigits] - maximum number of fraction digits
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate the decimal part
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  factory NumberEditingTextController.decimal({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative,
  }) = DecimalEditingController;

  /// Creates a controller instance suitable for formatting input as an integer.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [value] - optional initial value
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  factory NumberEditingTextController.integer({
    String? locale,
    num? value,
    String? groupSeparator,
    bool allowNegative,
  }) = IntegerEditingController;

  /// The locale used for number formatting.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get locale;
  set locale(String? value);

  /// The symbol used to group digits (e.g. `,` in `1,000`).
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get groupSeparator;
  set groupSeparator(String? value);

  /// Whether negative number input is allowed.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  bool get allowNegative;
  set allowNegative(bool value);

  /// The underlying numeric value extracted from the formatted text.
  ///
  /// Returns `null` when the text field is empty or contains no valid number.
  num? get number;

  /// Sets the numeric value and updates the displayed text with formatting.
  ///
  /// Setting to `null` clears the text field.
  set number(num? number);
}

/// Shared implementation for all [NumberEditingTextController] subtypes.
mixin _NumberEditingMixin on TextEditingController
    implements NumberEditingTextController {
  ParsedNumberFormat get _format;
  set _format(ParsedNumberFormat value);

  num? _number;

  String? _locale;
  String? _groupSeparator;
  bool _allowNegative = true;

  /// Subclasses must override to construct the appropriate format.
  ParsedNumberFormat _buildFormat();

  @override
  String? get locale => _locale;

  @override
  set locale(String? value) {
    if (_locale == value) {
      return;
    }
    _locale = value;
    _rebuildFormat();
  }

  @override
  String? get groupSeparator => _groupSeparator;

  @override
  set groupSeparator(String? value) {
    if (_groupSeparator == value) {
      return;
    }
    _groupSeparator = value;
    _rebuildFormat();
  }

  @override
  bool get allowNegative => _allowNegative;

  @override
  set allowNegative(bool value) {
    if (_allowNegative == value) {
      return;
    }
    _allowNegative = value;
    _rebuildFormat();
  }

  @override
  num? get number => _number;

  @override
  set number(num? number) {
    final effectiveNumber =
        (number != null && !_allowNegative && number < 0) ? -number : number;
    _number = effectiveNumber;
    final text =
        effectiveNumber == null ? '' : _format.formatString(effectiveNumber);
    super.value = value.copyWith(
      text: text,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final result = _format.formatValue(newValue);
    _number = result.number;
    super.value = result.value;
  }

  void _rebuildFormat() {
    _format = _buildFormat();
    if (_number != null) {
      number = _number;
    }
  }
}

/// A [NumberEditingTextController] that formats input as a currency amount.
///
/// Currency-specific options like [currencyName], [currencySymbol], and
/// [decimalSeparator] can be changed at any time.
class CurrencyEditingController extends TextEditingController
    with _NumberEditingMixin {
  String? _currencyName;
  String? _currencySymbol;
  String? _decimalSeparator;

  @override
  late ParsedNumberFormat _format;

  /// Creates a controller for formatting input as a currency amount.
  CurrencyEditingController({
    String? locale,
    String? currencyName,
    String? currencySymbol,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
  })  : _currencyName = currencyName,
        _currencySymbol = currencySymbol,
        _decimalSeparator = decimalSeparator {
    _locale = locale;
    _groupSeparator = groupSeparator;
    _allowNegative = allowNegative;
    _format = _buildFormat();
    number = value;
  }

  /// The 3-letter ISO 4217 currency code (e.g. USD, EUR, TRY).
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get currencyName => _currencyName;
  set currencyName(String? value) {
    if (_currencyName == value) {
      return;
    }
    _currencyName = value;
    _rebuildFormat();
  }

  /// The currency symbol (e.g. $, €, ₺).
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get currencySymbol => _currencySymbol;
  set currencySymbol(String? value) {
    if (_currencySymbol == value) {
      return;
    }
    _currencySymbol = value;
    _rebuildFormat();
  }

  /// The symbol used to separate the decimal part.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get decimalSeparator => _decimalSeparator;
  set decimalSeparator(String? value) {
    if (_decimalSeparator == value) {
      return;
    }
    _decimalSeparator = value;
    _rebuildFormat();
  }

  @override
  ParsedNumberFormat _buildFormat() => ParsedNumberFormat.currency(
        locale: _locale,
        currencyName: _currencyName,
        currencySymbol: _currencySymbol,
        decimalSeparator: _decimalSeparator,
        groupSeparator: _groupSeparator,
        allowNegative: _allowNegative,
      );
}

/// A [NumberEditingTextController] that formats input as a decimal number.
///
/// Decimal-specific options like [minimalFractionDigits],
/// [maximumFractionDigits], and [decimalSeparator] can be changed at any time.
class DecimalEditingController extends TextEditingController
    with _NumberEditingMixin {
  int? _minimalFractionDigits;
  int? _maximumFractionDigits;
  String? _decimalSeparator;

  @override
  late ParsedNumberFormat _format;

  /// Creates a controller for formatting input as a decimal number.
  DecimalEditingController({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
  })  : _minimalFractionDigits = minimalFractionDigits,
        _maximumFractionDigits = maximumFractionDigits,
        _decimalSeparator = decimalSeparator {
    _locale = locale;
    _groupSeparator = groupSeparator;
    _allowNegative = allowNegative;
    _format = _buildFormat();
    number = value;
  }

  /// The minimum number of fraction digits to display.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  int? get minimalFractionDigits => _minimalFractionDigits;
  set minimalFractionDigits(int? value) {
    if (_minimalFractionDigits == value) {
      return;
    }
    _minimalFractionDigits = value;
    _rebuildFormat();
  }

  /// The maximum number of fraction digits to display.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  int? get maximumFractionDigits => _maximumFractionDigits;
  set maximumFractionDigits(int? value) {
    if (_maximumFractionDigits == value) {
      return;
    }
    _maximumFractionDigits = value;
    _rebuildFormat();
  }

  /// The symbol used to separate the decimal part.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get decimalSeparator => _decimalSeparator;
  set decimalSeparator(String? value) {
    if (_decimalSeparator == value) {
      return;
    }
    _decimalSeparator = value;
    _rebuildFormat();
  }

  @override
  ParsedNumberFormat _buildFormat() => ParsedNumberFormat.decimal(
        locale: _locale,
        minimalFractionDigits: _minimalFractionDigits,
        maximumFractionDigits: _maximumFractionDigits,
        decimalSeparator: _decimalSeparator,
        groupSeparator: _groupSeparator,
        allowNegative: _allowNegative,
      );
}

/// A [NumberEditingTextController] that formats input as an integer.
class IntegerEditingController extends TextEditingController
    with _NumberEditingMixin {
  @override
  late ParsedNumberFormat _format;

  /// Creates a controller for formatting input as an integer.
  IntegerEditingController({
    String? locale,
    num? value,
    String? groupSeparator,
    bool allowNegative = true,
  }) {
    _locale = locale;
    _groupSeparator = groupSeparator;
    _allowNegative = allowNegative;
    _format = _buildFormat();
    number = value;
  }

  @override
  ParsedNumberFormat _buildFormat() => ParsedNumberFormat.integer(
        locale: _locale,
        groupSeparator: _groupSeparator,
        allowNegative: _allowNegative,
      );
}
