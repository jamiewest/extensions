import 'dart:math' as math;

import 'match_counter.dart';
import 'n_gram.dart';

/// Computes Google-BLEU (GLEU) scores.
///
/// GLEU measures n-gram overlap across a range of gram sizes, penalizing both
/// under-generation and over-generation.
///
/// Reference: NLTK gleu_score implementation.
class GLEUAlgorithm {
  /// Computes the sentence-level GLEU score.
  ///
  /// [references] are one or more reference token lists.
  /// [hypothesis] is the generated token list.
  /// [minN] and [maxN] define the n-gram size range (default 1–4).
  static double sentenceGLEU(
    List<List<String>> references,
    List<String> hypothesis, {
    int minN = 1,
    int maxN = 4,
  }) {
    if (references.isEmpty) throw ArgumentError('references cannot be empty.');
    if (hypothesis.isEmpty) throw ArgumentError('hypothesis cannot be empty.');

    final hypCounts = MatchCounter<NGram<String>>(
        hypothesis.createAllNGrams(minN: minN, maxN: maxN));
    final truePosFalsePos = hypCounts.sum();

    var corpusNMatch = 0;
    var corpusNAll = 0;

    for (final reference in references) {
      final refCounts = MatchCounter<NGram<String>>(
          reference.createAllNGrams(minN: minN, maxN: maxN));
      final truePosFalseNeg = refCounts.sum();
      final overlapCounts = hypCounts.intersect(refCounts);
      final truePos = overlapCounts.sum();
      final nAll = math.max(truePosFalsePos, truePosFalseNeg);
      if (nAll > 0) {
        corpusNMatch += truePos;
        corpusNAll += nAll;
      }
    }

    if (corpusNAll == 0) return 0.0;
    return corpusNMatch / corpusNAll;
  }
}
