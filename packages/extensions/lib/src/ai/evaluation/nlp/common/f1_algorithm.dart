import 'match_counter.dart';

/// Computes word-overlap F1 scores.
///
/// F1 = 2 * (precision * recall) / (precision + recall), where precision and
/// recall are computed over token multisets.
///
/// Reference: Azure AI Evaluation SDK F1 implementation.
class F1Algorithm {
  /// Computes the F1 score between [groundTruth] and [response] token lists.
  static double calculateF1Score(
      List<String> groundTruth, List<String> response) {
    if (groundTruth.isEmpty) throw ArgumentError('groundTruth cannot be empty.');
    if (response.isEmpty) throw ArgumentError('response cannot be empty.');

    final refCounts = MatchCounter<String>(groundTruth);
    final predCounts = MatchCounter<String>(response);
    final common = predCounts.intersect(refCounts);
    final numCommon = common.sum();

    if (numCommon == 0) return 0.0;

    final precision = numCommon / response.length;
    final recall = numCommon / groundTruth.length;
    return (2.0 * precision * recall) / (precision + recall);
  }
}
