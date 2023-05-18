import 'package:flutter/cupertino.dart';
import 'package:number_editing_controller/parsed_number_format/grouping.dart';
import 'package:number_editing_controller/parsed_number_format/part_length.dart';

class FormatResult {
  final TextEditingValue value;
  final int offset;
  final num? number;

  FormatResult(this.value, this.offset, this.number);

  @override
  String toString() {
    return 'FormatResult{value: $value, offset: $offset, number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormatResult &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          offset == other.offset &&
          number == other.number;

  @override
  int get hashCode => value.hashCode ^ offset.hashCode ^ number.hashCode;
}

abstract class NumberFormatPart {
  PartLength get length;

  FormatResult format(TextEditingValue value, int position);
}

class StaticPart extends NumberFormatPart {
  final String content;

  @override
  PartLength get length => DeterminedPartLength(content.length);

  StaticPart(this.content);

  @override
  FormatResult format(TextEditingValue value, int position) {
    var i = 0;
    var v = value;
    while (i < content.length && (position + i) <= v.text.length) {
      if ((position + i) == v.text.length ||
          content[i] != v.text[position + i]) {
        v = v.replaced(TextRange.collapsed(position + i), content[i]);
      }
      i++;
    }

    return FormatResult(v, i, 0);
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

class CurrencySignPart extends StaticPart {
  CurrencySignPart(super.content);
}

class RealPart extends NumberFormatPart {
  final Grouping grouping;

  RealPart(this.grouping);

  @override
  PartLength get length => AtLeastPartLength(1);

  @override
  FormatResult format(TextEditingValue value, int position) {
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
        i++;
        continue;
      }
      if (char.isDigit) {
        i++;
        continue;
      }
      finished = true;
    }
    if (i == 0) {
      return FormatResult(v, 0, null);
    }
    if (i != 0) {
      final numberText = v.text.substring(position, position + i);
      number = num.parse(numberText);
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

    return FormatResult(v, i, number);
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

class DecimalPart extends NumberFormatPart {
  final int minLength;
  final int maxLength;
  final String decimalSeparator;

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
  FormatResult format(TextEditingValue value, int position) {
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
      final suffix = '$decimalSeparator${'0'.repeat(minLength)}';
      v = v.replaced(TextRange.collapsed(position + i), suffix);
      i += suffix.length;
    }

    return FormatResult(v, i, number);
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
    return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(this);
  }

  String repeat(int times) {
    final result = StringBuffer();
    for (var i = 0; i < times; i++) {
      result.write(this);
    }

    return result.toString();
  }
}
