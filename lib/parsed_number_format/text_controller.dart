import 'package:flutter/material.dart';
import 'package:number_editing_controller/parsed_number_format/parsed_number_format.dart';

class NumberEditingTextController extends TextEditingController {
  final ParsedNumberFormat _format;

  num? _number;

  /// Creates a controller instance suitable for formatting input as a money amount
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [currencyName] - 3-symbol currency code (ex. USD, EUR, TRY)
  /// [currencySymbol] - currency symbol (ex. $, €, ₺)
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate decimal part
  /// [groupSeparator] - symbol used to group number
  /// [allowNegative] - allow negative number input
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

  /// Creates a controller instance suitable for formatting input as a decimal
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [minimalFractionDigits] - minimal fraction digits
  /// [maximumFractionDigits] - maximal fraction digits
  /// [value] - optional initial value
  /// [decimalSeparator] - symbol used to separate decimal part
  /// [groupSeparator] - symbol used to group number
  /// [allowNegative] - allow negative number input
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

  /// Creates a controller instance suitable for formatting input as an integer
  ///
  /// [locale] - locale to be used for number formatting, defaults to [Intl.getCurrentLocale()]
  /// [value] - optional initial value
  /// [groupSeparator] - symbol used to group number
  /// [allowNegative] - allow negative number input
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

  /// Extracts the underlying number value
  num? get number => _number;

  /// Sets the underlying number value
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
