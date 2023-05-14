abstract class Grouping {}

class WithGrouping extends Grouping {
  final int groupSize;
  final String groupingSymbol;

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

class NoGrouping extends Grouping {
  @override
  bool operator ==(Object other) => identical(this, other) || other is NoGrouping && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'NoGrouping{}';
  }
}
