/// F1 score for a response is the ratio of the number of shared words between
/// the generated response and the reference response. Python implementation
/// reference
/// https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/evaluation/azure-ai-evaluation/azure/ai/evaluation/_evaluators/_f1_score/_f1_score.py.
class F1Algorithm {
  F1Algorithm();

  static double calculateF1Score(List<String> groundTruth, List<String> response, ) {
    if (groundTruth == null || groundTruth.length == 0) {
      Throw.argumentNullException(
        nameof(groundTruth),
        ''${nameof(groundTruth)}' cannot be null or empty.',
      );
    }
    if (response == null || response.length == 0) {
      Throw.argumentNullException(
        nameof(response),
        ''${nameof(response)}' cannot be null or empty.',
      );
    }
    var referenceTokens = new(groundTruth);
    var predictionTokens = new(response);
    var commonTokens = referenceTokens.intersect(predictionTokens);
    var numCommonTokens = commonTokens.sum();
    if (numCommonTokens == 0) {
      return 0.0;
    } else {
      var precision = (double)numCommonTokens / response.length;
      var recall = (double)numCommonTokens / groundTruth.length;
      var f1 = (2.0 * precision * recall) / (precision + recall);
      return f1;
    }
  }
}
