import 'package:flutter/material.dart';
import 'package:number_editing_controller/src/grouping.dart';
import 'package:number_editing_controller/src/part_length.dart';

/// The result of formatting a single [NumberFormatPart].
class PartFormatResult {
  /// The updated text editing value after formatting.
  final TextEditingValue value;

  /// The number of characters consumed by this part.
  final int offset;

  /// The numeric value extracted from this part, or `null` if none.
  final num? number;

  /// Creates a [PartFormatResult] with the given [value], [offset], and [number].
  PartFormatResult(this.value, this.offset, this.number);

  @override
  String toString() {
    return 'PartFormatResult{value: $value, offset: $offset, number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartFormatResult &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          offset == other.offset &&
          number == other.number;

  @override
  int get hashCode => value.hashCode ^ offset.hashCode ^ number.hashCode;
}

/// A segment of a number format pattern that knows how to format its portion of input.
abstract class NumberFormatPart {
  /// The length constraints of this part.
  PartLength get length;

  /// Formats the input [value] starting at [position] and returns the result.
  PartFormatResult format(TextEditingValue value, int position);
}

/// A part that represents static text (e.g. spaces or punctuation).
class StaticPart extends NumberFormatPart {
  /// The static text content.
  final String content;

  @override
  PartLength get length => DeterminedPartLength(content.length);

  StaticPart(this.content);

  @override
  PartFormatResult format(TextEditingValue value, int position) {
    var i = 0;
    var v = value;
    while (i < content.length && (position + i) <= v.text.length) {
      if ((position + i) == v.text.length ||
          content[i] != v.text[position + i]) {
        v = v.replaced(TextRange.collapsed(position + i), content[i]);
      }
      i++;
    }

    return PartFormatResult(v, i, 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticPart &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() {
    return 'StaticPart{content: $content}';
  }
}

/// A [StaticPart] that represents a currency symbol.
class CurrencySignPart extends StaticPart {
  /// Creates a currency sign part with the given symbol [content].
  CurrencySignPart(super.content);
}

/// A part that represents the integer portion of a number.
class RealPart extends NumberFormatPart {
  /// The digit grouping configuration.
  final Grouping grouping;

  /// Whether negative numbers are allowed.
  final bool allowNegative;

  /// Creates a [RealPart] with the given [grouping] and [allowNegative] flag.
  RealPart(this.grouping, this.allowNegative);

  @override
  PartLength get length => AtLeastPartLength(1);

  @override
  PartFormatResult format(TextEditingValue value, int position) {
    var i = 0;
    var v = value;
    var finished = false;

    final g = grouping;

    num number = 0;

    while ((position + i) < v.text.length && !finished) {
      final char = v.text[position + i];
      final nextChar =
          v.text.length == position + i + 1 ? null : v.text[position + i + 1];
      if (g is WithGrouping && char == g.groupingSymbol) {
        if (nextChar == null || !nextChar.isDigit) {
          finished = true;
          continue;
        }
        v = v.replaced(
          TextRange(start: position + i, end: position + i + 1),
          '',
        );
        i--;
        continue;
      }
      if ('-' == char && i == 0) {
        if (!allowNegative) {
          v = v.replaced(
            TextRange(start: position + i, end: position + i + 1),
            '',
          );
        } else {
          i++;
        }
        continue;
      }
      if (char.isDigit) {
        i++;
        continue;
      }
      finished = true;
    }
    if (i == 0) {
      return PartFormatResult(v, 0, null);
    }
    if (i != 0) {
      final numberText = v.text.substring(position, position + i);
      number = numberText == '-' ? 0 : num.parse(numberText);
    }
    if (i != 0 && g is WithGrouping) {
      final realPartLength = i;
      for (var j = 0; j < realPartLength; j++) {
        if (j != 0 && j % g.groupSize == 0) {
          v = v.replaced(
            TextRange.collapsed(position + realPartLength - j),
            g.groupingSymbol,
          );
          i++;
        }
      }
    }
    if (i == 0) {
      v = v.replaced(TextRange.collapsed(position + i), '0');
      i++;
    }

    return PartFormatResult(v, i, number);
  }

  @override
  String toString() {
    return 'RealPart{grouping: $grouping}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealPart &&
          runtimeType == other.runtimeType &&
          grouping == other.grouping;

  @override
  int get hashCode => grouping.hashCode;
}

/// A part that represents the fractional/decimal portion of a number.
class DecimalPart extends NumberFormatPart {
  /// The minimum number of decimal digits.
  final int minLength;

  /// The maximum number of decimal digits.
  final int maxLength;

  /// The decimal separator symbol (e.g. '.' or ',').
  final String decimalSeparator;

  /// Creates a [DecimalPart] with the given length bounds and [decimalSeparator].
  DecimalPart(this.minLength, this.maxLength, this.decimalSeparator);

  @override
  PartLength get length {
    if (minLength == 0 && maxLength == 0) {
      return DeterminedPartLength(0);
    }
    if (minLength == 0 && maxLength != 0) {
      return VariablePartLength(
        0,
        maxLength + decimalSeparator.length,
      );
    }

    return VariablePartLength(
      minLength + decimalSeparator.length,
      maxLength + decimalSeparator.length,
    );
  }

  @override
  PartFormatResult format(TextEditingValue value, int position) {
    var i = 0;
    var v = value;
    var finished = false;
    num number = 0;
    while ((position + i) < v.text.length && !finished) {
      if (v.text[position + i] == decimalSeparator && i == 0) {
        i++;
        continue;
      }
      if (v.text[position + i].isDigit && i != 0 && i < (maxLength + 1)) {
        i++;
        continue;
      }
      if (v.text[position + i].isDigit) {
        v = v.replaced(
          TextRange(start: position + i, end: position + i + 1),
          '',
        );
        continue;
      }
      finished = true;
    }
    if (i > 1) {
      number = num.parse('0.${v.text.substring(position + 1, position + i)}');
    }
    if (i == 0 && minLength != 0) {
      final suffix = '$decimalSeparator${'0' * minLength}';
      v = v.replaced(TextRange.collapsed(position + i), suffix);
      i += suffix.length;
    }

    return PartFormatResult(v, i, number);
  }

  @override
  String toString() {
    return 'DecimalPart{minLength: $minLength, maxLength: $maxLength, decimalSeparator: $decimalSeparator}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecimalPart &&
          runtimeType == other.runtimeType &&
          minLength == other.minLength &&
          maxLength == other.maxLength &&
          decimalSeparator == other.decimalSeparator;

  @override
  int get hashCode =>
      minLength.hashCode ^ maxLength.hashCode ^ decimalSeparator.hashCode;
}

extension on String {
  bool get isDigit {
    final codeUnit = codeUnitAt(0);
    return length == 1 &&
        codeUnit >= 0x30 && // '0'
        codeUnit <= 0x39; // '9'
  }
}
