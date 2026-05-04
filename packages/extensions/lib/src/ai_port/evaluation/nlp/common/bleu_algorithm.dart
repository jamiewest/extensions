import '../../../../../../../lib/func_typedefs.dart';
import 'rational_number.dart';
import 'smoothing_function.dart';

/// Helper methods for calculating the BLEU score. See BLEU on Wikipedia or
/// NLTK implementation for more details.
class BLEUAlgorithm {
  BLEUAlgorithm();

  static final List<double> defaultBLEUWeights = EqualWeights(4);

  static int closestRefLength(List<List<String>> references, int hypLength, ) {
    if (!references.any()) {
      return 0;
    }
    var closestRefLength = 0;
    var smallestDiff = int.maxValue;
    for (final reference in references) {
      var refLength = reference.length;
      var diff = Math.abs(refLength - hypLength);
      if (diff < smallestDiff ||
               (diff == smallestDiff && refLength < closestRefLength)) {
        smallestDiff = diff;
        closestRefLength = refLength;
      }
    }
    return closestRefLength;
  }

  static double brevityPenalty(int closestRefLength, int hypLength, ) {
    if (hypLength <= 0) {
      return 0.0;
    }
    if (closestRefLength <= 0 || hypLength > closestRefLength) {
      return 1.0;
    }
    return Math.exp(1 - ((double)closestRefLength / hypLength));
  }

  static RationalNumber modifiedPrecision(
    List<List<String>> references,
    List<String> hypothesis,
    {int? n, },
  ) {
    if (n <= 0) {
      Throw.argumentOutOfRangeException(nameof(n), '`${nameof(n)}` must be greater than zero.');
    }
    if (references.length == 0 || hypothesis.length == 0) {
      return RationalNumber.zero;
    }
    var hypGrams = hypothesis.createNGrams(n);
    var hypCounts = new(hypGrams);
    var maxCounts = [];
    for (final rf in references) {
      var refGrams = rf.createNGrams(n);
      var refCounts = new(refGrams);
      for (final ct in refCounts) {
        int val;
        if (maxCounts.tryGetValue(ct.key)) {
          maxCounts[ct.key] = Math.max(val, ct.value);
        } else {
          maxCounts[ct.key] = ct.value;
        }
      }
    }
    var clippedCounts = [];
    for (final h in hypCounts) {
      var v;
      if (maxCounts.tryGetValue(h.key)) {
        clippedCounts[h.key] = Math.min(h.value, v);
      } else {
        // If the hypothesis n-gram is! in any reference, it is clipped to 0.
                clippedCounts[h.key] = 0;
      }
    }
    var numerator = clippedCounts.values.sum();
    var denominator = Math.max(1, hypCounts.sum());
    return rationalNumber(numerator, denominator);
  }

  /// Generate an n-sized array of equal weights that sum to 1.0.
  ///
  /// Returns: Array of equal sized values that sum to 1.0.
  ///
  /// [n] Number of weights to return.
  static List<double> equalWeights(int n) {
    if (n <= 0) {
      Throw.argumentOutOfRangeException(nameof(n), ''${nameof(n)}' must be greater than zero.');
    }
    var weights = List.filled(n, null);
    for (var i = 0; i < n; i++) {
      weights[i] = 1.0 / n;
    }
    return weights;
  }

  static double sentenceBLEU(
    List<List<String>> references,
    List<String> hypothesis,
    {List<double>? weights, Func2<List<RationalNumber>, int, List<double>>? smoothingFunction, },
  ) {
    if (references == null || references.length == 0) {
      Throw.argumentNullException(
        nameof(references),
        ''${nameof(references)}' cannot be null or empty.',
      );
    }
    if (hypothesis == null || hypothesis.length == 0) {
      Throw.argumentNullException(
        nameof(hypothesis),
        ''${nameof(hypothesis)}' cannot be null or empty.',
      );
    }
    if (weights == null) {
      weights = defaultBLEUWeights;
    }
    if (weights.length == 0) {
      Throw.argumentNullException(nameof(weights), ''${nameof(weights)}' cannot be empty.');
    }
    var precisionValues = List.filled(weights.length, null);
    for (var i = 0; i < weights.length; i++) {
      var n = i + 1;
      var prec = modifiedPrecision(references, hypothesis, n);
      if (i == 0 && prec.numerator == 0) {
        return 0.0;
      }
      precisionValues[i] = prec;
    }
    var hypLen = hypothesis.length;
    var closestRefLength = closestRefLength(references, hypLen);
    var brevityPenalty = brevityPenalty(closestRefLength, hypLen);
    if (smoothingFunction == null) {
      smoothingFunction = SmoothingFunction.method0;
    }
    var smoothedValues = smoothingFunction(precisionValues, hypLen);
    var score = 0.0;
    for (var i = 0; i < weights.length; i++) {
      if (smoothedValues[i] > 0) {
        score += weights[i] * Math.log(smoothedValues[i]);
      }
    }
    return brevityPenalty * Math.exp(score);
  }
}
