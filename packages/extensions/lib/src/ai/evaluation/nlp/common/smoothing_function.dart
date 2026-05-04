import 'dart:math' as math;

import 'rational_number.dart';

/// Smoothing functions for BLEU scores.
///
/// Based on: "A Systematic Comparison of Smoothing Techniques for
/// Sentence-Level BLEU" — Chen and Cherry (ACL 2014).
class SmoothingFunction {
  /// Method 0: baseline — no smoothing; near-zero numerators use
  /// [double.minPositive] to avoid log(0).
  static List<double> method0(List<RationalNumber> precisions, int hypLen) {
    return [
      for (final p in precisions)
        p.numerator == 0 ? double.minPositive : p.toDouble(),
    ];
  }

  /// Method 4: proportional smoothing for short hypotheses.
  ///
  /// Scores shorter translations proportionally by dividing by
  /// `1/ln(len(hypothesis))` instead of `1/(2^k)`.
  static List<double> method4(List<RationalNumber> precisions, int hypLen) {
    const defaultK = 5.0;
    final smoothed = <double>[];
    var inc = 1;
    for (final p in precisions) {
      if (p.numerator == 0 && hypLen > 1) {
        final numerator =
            1.0 / (math.pow(2.0, inc) * defaultK / math.log(hypLen));
        smoothed.add(numerator / p.denominator);
        inc++;
      } else {
        smoothed.add(p.toDouble());
      }
    }
    return smoothed;
  }
}
