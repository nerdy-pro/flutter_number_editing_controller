abstract class PartLength {}

class DeterminedPartLength extends PartLength {
  final int length;

  DeterminedPartLength(this.length);
}

class VariablePartLength extends PartLength {
  final int min;
  final int max;

  VariablePartLength(this.min, this.max);
}

class AtLeastPartLength extends PartLength {
  final int min;

  AtLeastPartLength(this.min);
}
