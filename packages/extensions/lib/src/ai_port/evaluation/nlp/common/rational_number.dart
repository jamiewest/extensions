class RationalNumber {
  RationalNumber(
    int numerator,
    int denominator,
  ) :
      numerator = numerator,
      denominator = denominator {
    if (denominator == 0) {
      throw divideByZeroException("denominator cannot be zero.");
    }
  }

  static final RationalNumber zero = new(0, 1);

  final int numerator;

  final int denominator;

  double toDouble() {
    return (double)numerator / denominator;
  }

  String toDebugString() {
    return '${numerator}/${denominator}';
  }

  @override
  bool equals({RationalNumber? other, Object? obj, }) {
    return other.numerator == numerator && other.denominator == denominator;
  }

  @override
  int getHashCode() {
    return HashCode.combine(numerator, denominator);
  }

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is RationalNumber &&
    zero == other.zero &&
    numerator == other.numerator &&
    denominator == other.denominator; }
  @override
  int get hashCode { return Object.hash(zero, numerator, denominator); }
}
