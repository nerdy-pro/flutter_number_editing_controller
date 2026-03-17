import 'package:flutter/material.dart';
import 'package:number_editing_controller/src/parsed_number_format.dart';

/// A [TextEditingController] that automatically formats user input as
/// numbers, decimals, or currencies with locale-aware formatting.
///
/// Use one of the named constructors to create an instance:
/// - [NumberEditingTextController.currency] for currency amounts
/// - [NumberEditingTextController.decimal] for decimal numbers
/// - [NumberEditingTextController.integer] for integers
///
/// The formatted text is displayed in the [TextField], while the underlying
/// numeric value can be accessed via the [number] property.
///
/// Formatting options such as [locale], [groupSeparator], and [allowNegative]
/// can be changed at any time. Changing an option automatically reformats the
/// current value.
class NumberEditingTextController extends TextEditingController {
  ParsedNumberFormat _format;

  num? _number;

  String? _locale;
  String? _groupSeparator;
  bool _allowNegative;

  // Currency-specific fields.
  String? _currencyName;
  String? _currencySymbol;
  String? _decimalSeparator;

  // Decimal-specific fields.
  int? _minimalFractionDigits;
  int? _maximumFractionDigits;

  // Tracks which constructor was used so we can rebuild the format.
  final _FormatType _formatType;

  /// Creates a controller instance suitable for formatting input as a currency amount.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [currencyName] - 3-letter ISO 4217 currency code (e.g. USD, EUR, TRY)
  /// [currencySymbol] - currency symbol (e.g. $, €, ₺)
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate the decimal part
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  NumberEditingTextController.currency({
    String? locale,
    String? currencyName,
    String? currencySymbol,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
  })  : _locale = locale,
        _currencyName = currencyName,
        _currencySymbol = currencySymbol,
        _decimalSeparator = decimalSeparator,
        _groupSeparator = groupSeparator,
        _allowNegative = allowNegative,
        _minimalFractionDigits = null,
        _maximumFractionDigits = null,
        _formatType = _FormatType.currency,
        _format = ParsedNumberFormat.currency(
          locale: locale,
          currencyName: currencyName,
          currencySymbol: currencySymbol,
          decimalSeparator: decimalSeparator,
          groupSeparator: groupSeparator,
          allowNegative: allowNegative,
        ) {
    number = value;
  }

  /// Creates a controller instance suitable for formatting input as a decimal number.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [minimalFractionDigits] - minimum number of fraction digits
  /// [maximumFractionDigits] - maximum number of fraction digits
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate the decimal part
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  NumberEditingTextController.decimal({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
  })  : _locale = locale,
        _minimalFractionDigits = minimalFractionDigits,
        _maximumFractionDigits = maximumFractionDigits,
        _decimalSeparator = decimalSeparator,
        _groupSeparator = groupSeparator,
        _allowNegative = allowNegative,
        _currencyName = null,
        _currencySymbol = null,
        _formatType = _FormatType.decimal,
        _format = ParsedNumberFormat.decimal(
          locale: locale,
          minimalFractionDigits: minimalFractionDigits,
          maximumFractionDigits: maximumFractionDigits,
          decimalSeparator: decimalSeparator,
          groupSeparator: groupSeparator,
          allowNegative: allowNegative,
        ) {
    number = value;
  }

  /// Creates a controller instance suitable for formatting input as an integer.
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [value] - optional initial value
  /// [groupSeparator] - symbol used to group digits
  /// [allowNegative] - whether to allow negative number input
  NumberEditingTextController.integer({
    String? locale,
    num? value,
    String? groupSeparator,
    bool allowNegative = true,
  })  : _locale = locale,
        _groupSeparator = groupSeparator,
        _allowNegative = allowNegative,
        _currencyName = null,
        _currencySymbol = null,
        _decimalSeparator = null,
        _minimalFractionDigits = null,
        _maximumFractionDigits = null,
        _formatType = _FormatType.integer,
        _format = ParsedNumberFormat.integer(
          locale: locale,
          groupSeparator: groupSeparator,
          allowNegative: allowNegative,
        ) {
    number = value;
  }

  /// The locale used for number formatting.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get locale => _locale;
  set locale(String? value) {
    if (_locale == value) return;
    _locale = value;
    _rebuildFormat();
  }

  /// The symbol used to group digits (e.g. `,` in `1,000`).
  ///
  /// Setting this rebuilds the format and reformats the current value.
  String? get groupSeparator => _groupSeparator;
  set groupSeparator(String? value) {
    if (_groupSeparator == value) return;
    _groupSeparator = value;
    _rebuildFormat();
  }

  /// Whether negative number input is allowed.
  ///
  /// Setting this rebuilds the format and reformats the current value.
  bool get allowNegative => _allowNegative;
  set allowNegative(bool value) {
    if (_allowNegative == value) return;
    _allowNegative = value;
    _rebuildFormat();
  }

  /// The underlying numeric value extracted from the formatted text.
  ///
  /// Returns `null` when the text field is empty or contains no valid number.
  num? get number => _number;

  /// Sets the numeric value and updates the displayed text with formatting.
  ///
  /// Setting to `null` clears the text field.
  set number(num? number) {
    final effectiveNumber =
        number != null && !_allowNegative && number < 0 ? -number : number;
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
    _format = switch (_formatType) {
      _FormatType.currency => ParsedNumberFormat.currency(
          locale: _locale,
          currencyName: _currencyName,
          currencySymbol: _currencySymbol,
          decimalSeparator: _decimalSeparator,
          groupSeparator: _groupSeparator,
          allowNegative: _allowNegative,
        ),
      _FormatType.decimal => ParsedNumberFormat.decimal(
          locale: _locale,
          minimalFractionDigits: _minimalFractionDigits,
          maximumFractionDigits: _maximumFractionDigits,
          decimalSeparator: _decimalSeparator,
          groupSeparator: _groupSeparator,
          allowNegative: _allowNegative,
        ),
      _FormatType.integer => ParsedNumberFormat.integer(
          locale: _locale,
          groupSeparator: _groupSeparator,
          allowNegative: _allowNegative,
        ),
    };
    _reformat();
  }

  void _reformat() {
    if (_number != null) {
      // Re-set via the number setter so the new format can alter the value
      // (e.g. stripping the sign when allowNegative becomes false).
      final currentNumber = _number!;
      number = currentNumber;
    }
  }
}

enum _FormatType { currency, decimal, integer }
