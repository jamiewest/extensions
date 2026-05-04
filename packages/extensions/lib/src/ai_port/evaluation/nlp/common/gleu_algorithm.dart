/// Google-BLEU (GLEU) algorithm implementation for evaluating the quality of
/// a response. Python implementation reference:
/// https://www.nltk.org/api/nltk.translate.gleu_score.html.
class GLEUAlgorithm {
  GLEUAlgorithm();

  static double sentenceGLEU(
    List<List<String>> references,
    List<String> hypothesis,
    {int? minN, int? maxN, },
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
    var hypNGrams = new(hypothesis.createAllNGrams(minN, maxN));
    var truePosFalsePos = hypNGrams.sum();
    var hypCounts = [];
    for (final reference in references) {
      var refNGrams = new(reference.createAllNGrams(minN, maxN));
      var truePosFalseNeg = refNGrams.sum();
      var overlapNGrams = hypNGrams.intersect(refNGrams);
      var truePos = overlapNGrams.sum();
      var nAll = Math.max(truePosFalsePos, truePosFalseNeg);
      if (nAll > 0) {
        hypCounts.add((truePos, nAll));
      }
    }
    var corpusNMatch = 0;
    var corpusNAll = 0;
    /* TODO: unsupported node kind "unknown" */
    // foreach (var (truePos, nAll) in hypCounts)
    //         {
      //             corpusNMatch += truePos;
      //             corpusNAll += nAll;
      //         }
    if (corpusNAll == 0) {
      return 0.0;
    } else {
      return (double)corpusNMatch / corpusNAll;
    }
  }
}
