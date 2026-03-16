/// Configuration for how digits are grouped in formatted numbers.
abstract class Grouping {}

/// Groups digits using a separator symbol at a fixed interval.
class WithGrouping extends Grouping {
  /// The number of digits per group.
  final int groupSize;

  /// The symbol used to separate groups (e.g. ',' or ' ').
  final String groupingSymbol;

  /// Creates a grouping with the given [groupSize] and [groupingSymbol].
  WithGrouping(this.groupSize, this.groupingSymbol);

  @override
  String toString() {
    return 'WithGrouping{groupSize: $groupSize, groupingSymbol: $groupingSymbol}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithGrouping &&
          runtimeType == other.runtimeType &&
          groupSize == other.groupSize &&
          groupingSymbol == other.groupingSymbol;

  @override
  int get hashCode => groupSize.hashCode ^ groupingSymbol.hashCode;
}

/// No digit grouping applied.
class NoGrouping extends Grouping {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoGrouping && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'NoGrouping{}';
  }
}
