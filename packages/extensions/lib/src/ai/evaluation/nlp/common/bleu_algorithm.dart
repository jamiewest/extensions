import 'dart:math' as math;

import 'match_counter.dart';
import 'n_gram.dart';
import 'rational_number.dart';
import 'smoothing_function.dart';

/// Static helpers for computing BLEU scores.
///
/// See: Papineni et al. (2002), and the NLTK reference implementation.
class BLEUAlgorithm {
  /// Default weights: uniform 0.25 for 1–4 gram.
  static final List<double> defaultBLEUWeights = equalWeights(4);

  /// Generates [n] equal weights summing to 1.0.
  static List<double> equalWeights(int n) {
    if (n <= 0) throw ArgumentError('n must be greater than zero.');
    return List.filled(n, 1.0 / n);
  }

  /// Returns the reference length closest to [hypLength].
  static int closestRefLength(List<List<String>> references, int hypLength) {
    if (references.isEmpty) return 0;
    var best = references.first.length;
    var bestDiff = (best - hypLength).abs();
    for (final ref in references.skip(1)) {
      final len = ref.length;
      final diff = (len - hypLength).abs();
      if (diff < bestDiff || (diff == bestDiff && len < best)) {
        bestDiff = diff;
        best = len;
      }
    }
    return best;
  }

  /// Brevity penalty: penalizes hypotheses shorter than references.
  static double brevityPenalty(int closestRef, int hypLength) {
    if (hypLength <= 0) return 0.0;
    if (closestRef <= 0 || hypLength > closestRef) return 1.0;
    return math.exp(1.0 - closestRef / hypLength);
  }

  /// Modified n-gram precision (clipped against reference counts).
  static RationalNumber modifiedPrecision(
    List<List<String>> references,
    List<String> hypothesis, {
    required int n,
  }) {
    if (n <= 0) throw ArgumentError('n must be greater than zero.');
    if (references.isEmpty || hypothesis.isEmpty) return RationalNumber.zero;

    final hypCounts = MatchCounter<NGram<String>>(hypothesis.createNGrams(n));

    // Build max reference counts.
    final maxCounts = <NGram<String>, int>{};
    for (final ref in references) {
      final refCounts = MatchCounter<NGram<String>>(ref.createNGrams(n));
      for (final entry in refCounts.entries) {
        final existing = maxCounts[entry.key] ?? 0;
        if (entry.value > existing) maxCounts[entry.key] = entry.value;
      }
    }

    // Clip hypothesis counts.
    var clippedSum = 0;
    var hypSum = 0;
    for (final entry in hypCounts.entries) {
      hypSum += entry.value;
      final maxRef = maxCounts[entry.key] ?? 0;
      clippedSum += entry.value < maxRef ? entry.value : maxRef;
    }

    return RationalNumber(clippedSum, math.max(1, hypSum));
  }

  /// Computes the sentence-level BLEU score.
  static double sentenceBLEU(
    List<List<String>> references,
    List<String> hypothesis, {
    List<double>? weights,
    List<double> Function(List<RationalNumber>, int)? smoothingFunction,
  }) {
    if (references.isEmpty) throw ArgumentError('references cannot be empty.');
    if (hypothesis.isEmpty) throw ArgumentError('hypothesis cannot be empty.');

    final w = weights ?? defaultBLEUWeights;
    if (w.isEmpty) throw ArgumentError('weights cannot be empty.');

    final precisions = <RationalNumber>[];
    for (var i = 0; i < w.length; i++) {
      final prec =
          modifiedPrecision(references, hypothesis, n: i + 1);
      if (i == 0 && prec.numerator == 0) return 0.0;
      precisions.add(prec);
    }

    final hypLen = hypothesis.length;
    final bp = brevityPenalty(closestRefLength(references, hypLen), hypLen);
    final smooth = (smoothingFunction ?? SmoothingFunction.method0)(
        precisions, hypLen);

    var score = 0.0;
    for (var i = 0; i < w.length; i++) {
      if (smooth[i] > 0) score += w[i] * math.log(smooth[i]);
    }
    return bp * math.exp(score);
  }
}
