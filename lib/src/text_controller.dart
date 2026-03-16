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
class NumberEditingTextController extends TextEditingController {
  final ParsedNumberFormat _format;

  num? _number;

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
  }) : _format = ParsedNumberFormat.currency(
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
  }) : _format = ParsedNumberFormat.decimal(
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
  }) : _format = ParsedNumberFormat.integer(
          locale: locale,
          groupSeparator: groupSeparator,
          allowNegative: allowNegative,
        ) {
    number = value;
  }

  /// The underlying numeric value extracted from the formatted text.
  ///
  /// Returns `null` when the text field is empty or contains no valid number.
  num? get number => _number;

  /// Sets the numeric value and updates the displayed text with formatting.
  ///
  /// Setting to `null` clears the text field.
  set number(num? number) {
    _number = number;
    final text = number == null ? '' : _format.formatString(number);
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
}
