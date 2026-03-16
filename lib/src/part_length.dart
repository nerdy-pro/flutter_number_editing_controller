/// Describes the length constraints of a number format part.
abstract class PartLength {}

/// A fixed-length part.
class DeterminedPartLength extends PartLength {
  /// The exact length of this part.
  final int length;

  /// Creates a fixed-length constraint of [length].
  DeterminedPartLength(this.length);
}

/// A variable-length part with minimum and maximum bounds.
class VariablePartLength extends PartLength {
  /// The minimum length of this part.
  final int min;

  /// The maximum length of this part.
  final int max;

  /// Creates a variable-length constraint between [min] and [max].
  VariablePartLength(this.min, this.max);
}

/// A part with a minimum length and no upper bound.
class AtLeastPartLength extends PartLength {
  /// The minimum length of this part.
  final int min;

  /// Creates a minimum-length constraint of [min].
  AtLeastPartLength(this.min);
}
