import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:number_editing_controller/src/grouping.dart';
import 'package:number_editing_controller/src/mask_parser_iterator.dart';
import 'package:number_editing_controller/src/parts.dart';

/// Whether the currency symbol is placed before or after the number.
enum CurrencySymbolPosition {
  /// The symbol appears before the number (e.g. `$100`).
  prefix,

  /// The symbol appears after the number (e.g. `100 €`).
  suffix,
}

/// The result of formatting a [TextEditingValue] through [ParsedNumberFormat].
class FormatResult {
  /// The formatted text editing value.
  final TextEditingValue value;

  /// The numeric value extracted from the input, or `null` if empty or invalid.
  final num? number;

  /// Creates a [FormatResult] with the given [value] and [number].
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

/// Parses and formats numbers according to locale-aware ICU number format patterns.
class ParsedNumberFormat {
  /// The ordered list of format parts that make up this number format.
  final List<NumberFormatPart> parts;
  final bool _allowNegative;

  factory ParsedNumberFormat.currency({
    String? locale,
    String? currencyName,
    String? currencySymbol,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
    bool showCurrencySymbol = true,
  }) {
    final currentLocale = _verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final pattern = symbols.CURRENCY_PATTERN;

    return ParsedNumberFormat._withMask(
      mask: pattern,
      locale: currentLocale,
      symbols: symbols,
      currencyName: currencyName,
      currencySymbol: currencySymbol,
      minimalFractionDigits: 0,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
      allowNegative: allowNegative,
      showCurrencySymbol: showCurrencySymbol,
    );
  }

  factory ParsedNumberFormat.decimal({
    String? locale,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    String? decimalSeparator,
    String? groupSeparator,
    bool allowNegative = true,
  }) {
    final currentLocale = _verifiedLocale(locale, NumberFormat.localeExists)!;
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
      allowNegative: allowNegative,
    );
  }

  factory ParsedNumberFormat.integer({
    String? locale,
    String? groupSeparator,
    bool allowNegative = true,
  }) {
    final currentLocale = _verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final pattern = symbols.DECIMAL_PATTERN;

    return ParsedNumberFormat._withMask(
      mask: pattern,
      locale: currentLocale,
      symbols: symbols,
      minimalFractionDigits: 0,
      maximumFractionDigits: 0,
      decimalSeparator: symbols.DECIMAL_SEP,
      groupSeparator: groupSeparator,
      allowNegative: allowNegative,
    );
  }

  factory ParsedNumberFormat._withMask({
    required String mask,
    required String locale,
    required NumberSymbols symbols,
    int? minimalFractionDigits,
    int? maximumFractionDigits,
    String? currencyName,
    String? currencySymbol,
    String? decimalSeparator,
    String? groupSeparator,
    required bool allowNegative,
    bool showCurrencySymbol = true,
  }) {
    final currencyCode = currencyName ?? symbols.DEF_CURRENCY_CODE;
    final format = NumberFormat(mask);
    final resolvedCurrencySymbol =
        currencySymbol ?? format.simpleCurrencySymbol(currencyCode);
    final min = minimalFractionDigits ?? format.minimumFractionDigits;
    final max = maximumFractionDigits ?? format.maximumFractionDigits;

    var parts = mask.getNumberFormatParts(
      minDecimalPart: min,
      maxDecimalPart: max,
      currencySign: resolvedCurrencySymbol,
      decimalSeparatorSign: decimalSeparator ?? symbols.DECIMAL_SEP,
      groupSeparatorSign: groupSeparator ?? symbols.GROUP_SEP,
      allowNegative: allowNegative,
    );

    if (!showCurrencySymbol) {
      parts = parts.where((p) => p is! StaticPart).toList();
    }

    return ParsedNumberFormat._(parts, allowNegative);
  }

  ParsedNumberFormat._(this.parts, this._allowNegative);

  /// Resolves the currency symbol for the given parameters.
  static String resolvedSymbol({
    String? locale,
    String? currencyName,
    String? currencySymbol,
  }) {
    if (currencySymbol != null) {
      return currencySymbol;
    }
    final currentLocale = _verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final currencyCode = currencyName ?? symbols.DEF_CURRENCY_CODE;
    final format = NumberFormat(symbols.CURRENCY_PATTERN);
    return format.simpleCurrencySymbol(currencyCode);
  }

  /// Determines whether the currency symbol is a prefix or suffix
  /// for the given locale.
  static CurrencySymbolPosition symbolPosition({String? locale}) {
    final currentLocale = _verifiedLocale(locale, NumberFormat.localeExists)!;
    final symbols = numberFormatSymbols[currentLocale] as NumberSymbols;
    final pattern = symbols.CURRENCY_PATTERN;
    // In ICU patterns, \u00A4 is the currency placeholder.
    // If it appears before the first digit placeholder, it's a prefix.
    final currencyIndex = pattern.indexOf('\u00A4');
    final digitIndex = pattern.indexOf(RegExp('[0#]'));
    if (currencyIndex < 0) {
      return CurrencySymbolPosition.prefix;
    }
    return currencyIndex < digitIndex
        ? CurrencySymbolPosition.prefix
        : CurrencySymbolPosition.suffix;
  }

  FormatResult formatValue(TextEditingValue textEditingValue) {
    var result = textEditingValue;
    var charPosition = 0;

    if (result.text.isEmpty) {
      return FormatResult(result, null);
    }

    num number = 0;
    var isNegative = false;

    for (final part in parts) {
      final partResult = part.format(result, charPosition);
      charPosition += partResult.offset;
      result = partResult.value;
      final resultNumber = partResult.number;
      if (resultNumber != null) {
        if (part is RealPart && resultNumber <= 0) {
          // Check if the formatted text contains a minus sign
          final partText = result.text.substring(
            charPosition - partResult.offset,
            charPosition,
          );
          if (partText.startsWith('-')) {
            isNegative = true;
          }
        }
        if (isNegative && part is DecimalPart) {
          number -= resultNumber;
        } else {
          number += resultNumber;
        }
      } else if (part is RealPart) {
        return FormatResult(result, null);
      } else if (part is DecimalPart) {
        // do nothing
      }
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
    if (value is double && (value.isNaN || value.isInfinite)) {
      return '';
    }
    final result = StringBuffer();

    for (final part in parts) {
      if (part is StaticPart) {
        result.write(part.content);
        continue;
      }
      if (part is RealPart) {
        if (value < 0 && _allowNegative) {
          result.write('-');
        }
        final stringValue = value.abs().toInt().toString();
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
        final max = part.maxLength.clamp(0, 20);

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

String? _verifiedLocale(String? newLocale, bool Function(String) localeExists) {
  if (newLocale == null) {
    return _verifiedLocale(Intl.getCurrentLocale(), localeExists);
  }
  if (localeExists(newLocale)) {
    return newLocale;
  }
  for (final each in [
    _canonicalizedLocale(newLocale),
    _shortLocale(newLocale),
    'fallback',
  ]) {
    if (localeExists(each)) {
      return each;
    }
  }

  return newLocale;
}

String _canonicalizedLocale(String? aLocale) {
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
  // If it's longer than three, it's something odd, so don't touch it.
  if (region.length <= 3) {
    region = region.toUpperCase();
  }

  return '${aLocale[0]}${aLocale[1]}_$region';
}

/// Returns the short version of a locale name, e.g. 'en_US' => 'en'.
String _shortLocale(String aLocale) {
  if (aLocale.length < 2) {
    return aLocale;
  }

  return aLocale.substring(0, 2).toLowerCase();
}
