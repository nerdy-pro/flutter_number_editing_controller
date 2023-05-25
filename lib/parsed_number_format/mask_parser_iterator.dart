import 'package:flutter/material.dart';
import 'package:number_editing_controller/parsed_number_format/grouping.dart';
import 'package:number_editing_controller/parsed_number_format/parts.dart';

extension NumberFormatPartExt on String {
  List<NumberFormatPart> getNumberFormatParts({
    required int minDecimalPart,
    required int maxDecimalPart,
    required String currencySign,
    required String decimalSeparatorSign,
    required String groupSeparatorSign,
    required bool allowNegative,
  }) {
    final chunks = <_PartChunk>[];
    var i = 0;
    while (true) {
      if (i == length) {
        break;
      }
      final chunk = _PartChunk.fromString(substring(i));
      i += chunk.content.length;
      chunks.add(chunk);
    }

    final result = <NumberFormatPart>[];

    final hasDecimalPart = maxDecimalPart != 0;

    var passedDecimalSeparator = false;
    for (final c in chunks) {
      if (c.content == '.') {
        passedDecimalSeparator = true;
      }
      if (c.content.isNumberPart) {
        if (passedDecimalSeparator && hasDecimalPart) {
          result.add(
            DecimalPart(
              minDecimalPart,
              maxDecimalPart,
              decimalSeparatorSign,
            ),
          );
        }
        if (!passedDecimalSeparator) {
          final content = c.content;
          if (content.contains(',') && groupSeparatorSign.isNotEmpty) {
            final grouping = content.split(',').last.length;
            result.add(
              RealPart(
                WithGrouping(grouping, groupSeparatorSign),
                allowNegative,
              ),
            );
          } else {
            result.add(
              RealPart(NoGrouping(), allowNegative),
            );
          }
        }
      } else {
        if (c.content != '.') {
          var content = '';
          for (final char in c.content.characters) {
            if (char == '\u00A4') {
              if (content.isNotEmpty) {
                result.add(StaticPart(content));
                content = '';
              }
              result.add(CurrencySignPart(currencySign));
            } else {
              content += char;
            }
          }
          if (content.isNotEmpty) {
            result.add(StaticPart(content));
          }
        }
      }
    }

    return result;
  }
}

class _PartChunk {
  final String content;

  _PartChunk(this.content);

  factory _PartChunk.fromString(String input) {
    var s = input[0];
    for (var i = 1; i < input.length; i++) {
      final c = input[i];
      if (s.isNumberPart == c.isNumberPart) {
        s += c;
      } else {
        return _PartChunk(s);
      }
    }

    return _PartChunk(s);
  }
}

extension on String {
  bool get isNumberPart {
    return characters.every((e) => ['0', '#', ','].contains(e));
  }
}
