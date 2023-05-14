import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:number_editing_controller/parsed_number_format/grouping.dart';
import 'package:number_editing_controller/parsed_number_format/mask_parser_iterator.dart';
import 'package:number_editing_controller/parsed_number_format/parts.dart';

class FormatResult {
  final TextEditingValue value;
  final num? number;

  FormatResult(this.value, this.number);

  @override
  String toString() {
    return 'FormatResult{value: $value, number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormatResult &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          number == other.number;

  @override
  int get hashCode => value.hashCode ^ number.hashCode;
}

class ParsedNumberFormat {
  final List<NumberFormatPart> parts;

  factory ParsedNumberFormat.currency({
    String? locale,
    String? currencyName,
    String? decimalSeparator,
    String? groupSeparator,
  }) {
    final currentLocale = verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final pattern = symbols.CURRENCY_PATTERN;

    return ParsedNumberFormat._withMask(
      mask: pattern,
      locale: currentLocale,
      symbols: symbols,
      currencyName: currencyName,
      minimalFractionDigits: 0,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
    );
  }

  factory ParsedNumberFormat.decimal({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    String? decimalSeparator,
    String? groupSeparator,
  }) {
    final currentLocale = verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final pattern = symbols.DECIMAL_PATTERN;

    return ParsedNumberFormat._withMask(
      mask: pattern,
      locale: currentLocale,
      symbols: symbols,
      minimalFractionDigits: minimalFractionDigits,
      maximumFractionDigits: maximumFractionDigits,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
    );
  }

  factory ParsedNumberFormat._withMask({
    required String mask,
    required String locale,
    required NumberSymbols symbols,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    String? currencyName,
    String? decimalSeparator,
    String? groupSeparator,
  }) {
    final currencyCode = currencyName ?? symbols.DEF_CURRENCY_CODE;
    final format = NumberFormat(mask);
    final currencySymbol = format.simpleCurrencySymbol(currencyCode);
    final min = minimalFractionDigits ?? format.minimumFractionDigits;
    final max = maximumFractionDigits ?? format.maximumFractionDigits;

    final parts = mask.getNumberFormatParts(
      minDecimalPart: min,
      maxDecimalPart: max,
      currencySign: currencySymbol,
      decimalSeparatorSign: decimalSeparator ?? symbols.DECIMAL_SEP,
      groupSeparatorSign: groupSeparator ?? symbols.GROUP_SEP,
    );

    return ParsedNumberFormat._(parts);
  }

  ParsedNumberFormat._(this.parts);

  FormatResult formatValue(TextEditingValue textEditingValue) {
    var result = textEditingValue;
    var charPosition = 0;

    if (result.text.isEmpty) {
      return FormatResult(result, null);
    }

    num number = 0;

    for (final part in parts) {
      final partResult = part.format(result, charPosition);
      charPosition += partResult.offset;
      result = partResult.value;
      number += partResult.number;
    }
    if (charPosition != result.text.length) {
      result = result.replaced(
        TextRange(start: charPosition, end: result.text.length),
        '',
      );
    }

    return FormatResult(result, number);
  }

  String formatString(num value) {
    final result = StringBuffer();

    for (final part in parts) {
      if (part is StaticPart) {
        result.write(part.content);
        continue;
      }
      if (part is RealPart) {
        final stringValue = value.toInt().toString();
        final grouping = part.grouping;
        if (grouping is NoGrouping) {
          result.write(stringValue);
          continue;
        }
        if (grouping is WithGrouping) {
          final symbol = grouping.groupingSymbol;
          final length = grouping.groupSize;
          for (var i = 0; i < stringValue.length; i++) {
            if (i != 0 && ((stringValue.length - i) % length) == 0) {
              result.write(symbol);
            }
            result.write(stringValue[i]);
          }
          continue;
        }
      }
      if (part is DecimalPart) {
        final min = part.minLength;
        final max = part.maxLength;

        final stringValue = value.toStringAsFixed(max).split('.').last;
        final hasSignificantDigits =
            stringValue.characters.any((e) => e != '0');
        if (min == 0 && !hasSignificantDigits) {
          continue;
        }
        result.write(part.decimalSeparator);
        final minPart = stringValue.substring(0, min);
        result.write(minPart);
        var maxPart = stringValue.substring(min, max);
        while (maxPart.endsWith('0')) {
          maxPart = maxPart.substring(0, maxPart.length - 1);
        }
        result.write(maxPart);
      }
    }

    return result.toString();
  }
}

String? verifiedLocale(String? newLocale, bool Function(String) localeExists) {
  if (newLocale == null) {
    return verifiedLocale(Intl.getCurrentLocale(), localeExists);
  }
  if (localeExists(newLocale)) {
    return newLocale;
  }
  for (final each in [
    canonicalizedLocale(newLocale),
    shortLocale(newLocale),
    'fallback',
  ]) {
    if (localeExists(each)) {
      return each;
    }
  }

  return newLocale;
}

String canonicalizedLocale(String? aLocale) {
  if (aLocale == null) {
    return Intl.getCurrentLocale();
  }
  if (aLocale == 'C') {
    return 'en_ISO';
  }
  if (aLocale.length < 5) {
    return aLocale;
  }
  if (aLocale[2] != '-' && (aLocale[2] != '_')) {
    return aLocale;
  }
  var region = aLocale.substring(3);
// If it's longer than three it's something odd, so don't touch it.
  if (region.length <= 3) {
    region = region.toUpperCase();
  }

  return '${aLocale[0]}${aLocale[1]}_$region';
}

/// Return the short version of a locale name, e.g. 'en_US' => 'en'
String shortLocale(String aLocale) {
  if (aLocale.length < 2) {
    return aLocale;
  }

  return aLocale.substring(0, 2).toLowerCase();
}
