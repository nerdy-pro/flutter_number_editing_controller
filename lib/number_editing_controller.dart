import 'package:flutter/widgets.dart';
import 'package:number_editing_controller/parsed_number_format/parsed_number_format.dart';

class NumberEditingTextController extends TextEditingController {
  final ParsedNumberFormat format;

  num? _number;

  NumberEditingTextController.currency({
    String? locale,
    String? currencyName,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
  }) : format = ParsedNumberFormat.currency(
          locale: locale,
          currencyName: currencyName,
          decimalSeparator: decimalSeparator,
          groupSeparator: groupSeparator,
        ) {
    number = value;
  }

  NumberEditingTextController.decimal({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    num? value,
    String? decimalSeparator,
    String? groupSeparator,
  }) : format = ParsedNumberFormat.decimal(
          locale: locale,
          minimalFractionDigits: minimalFractionDigits,
          maximumFractionDigits: maximumFractionDigits,
          decimalSeparator: decimalSeparator,
          groupSeparator: groupSeparator,
        ) {
    number = value;
  }

  num? get number => _number;

  set number(num? number) {
    _number = number;
    super.value = value.copyWith(
      text: number == null ? '' : format.formatString(number),
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final result = format.formatValue(newValue);
    _number = result.number;
    super.value = result.value;
  }
}
