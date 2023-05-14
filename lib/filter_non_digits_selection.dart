import 'package:flutter/material.dart';

class FilteredTextWithSelectionResult {
  final String result;
  final TextSelection selection;

  FilteredTextWithSelectionResult(this.result, this.selection);
}

FilteredTextWithSelectionResult filterStringWithSelection({
  required String input,
  required TextSelection originalSelection,
  required bool Function(String) filter,
}) {
  var selection = originalSelection;
  var temp = '';
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (filter(c)) {
      temp += c;
    } else {
      if (i < originalSelection.start) {
        selection = selection.copyWith(
          baseOffset: selection.baseOffset - 1,
          extentOffset: selection.extentOffset - 1,
        );
      } else if (i < originalSelection.end) {
        selection = selection.copyWith(
          extentOffset: selection.extentOffset - 1,
        );
      }
    }
  }

  return FilteredTextWithSelectionResult(temp, selection);
}
