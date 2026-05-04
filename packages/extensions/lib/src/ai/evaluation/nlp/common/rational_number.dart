/// A numerator/denominator pair used in BLEU precision calculations.
class RationalNumber {
  /// Creates a [RationalNumber].
  ///
  /// Throws [ArgumentError] if [denominator] is zero.
  RationalNumber(this.numerator, this.denominator) {
    if (denominator == 0) throw ArgumentError('denominator cannot be zero.');
  }

  /// The zero rational number (0/1).
  static final RationalNumber zero = RationalNumber(0, 1);

  /// The numerator.
  final int numerator;

  /// The denominator.
  final int denominator;

  /// Converts to a double.
  double toDouble() => numerator / denominator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RationalNumber &&
          numerator == other.numerator &&
          denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}
