import 'json_serialization/serializer_context.dart';
import 'utilities/json_output_fixer.dart';

class RelevanceTruthAndCompletenessRating {
  RelevanceTruthAndCompletenessRating(
    int relevance,
    String relevanceReasoning,
    List<String> relevanceReasons,
    int truth,
    String truthReasoning,
    List<String> truthReasons,
    int completeness,
    String completenessReasoning,
    List<String> completenessReasons,
  ) : relevance = relevance,
      relevanceReasoning = relevanceReasoning,
      relevanceReasons = relevanceReasons,
      truth = truth,
      truthReasoning = truthReasoning,
      truthReasons = truthReasons,
      completeness = completeness,
      completenessReasoning = completenessReasoning,
      completenessReasons = completenessReasons {
    (
      relevance,
      relevanceReasoning,
      relevanceReasons,
      truth,
      truthReasoning,
      truthReasons,
      completeness,
      completenessReasoning,
      completenessReasons,
    ) = (
      relevance,
      relevanceReasoning,
      relevanceReasons ?? [],
      truth,
      truthReasoning,
      truthReasons ?? [],
      completeness,
      completenessReasoning,
      completenessReasons ?? [],
    );
  }

  static final RelevanceTruthAndCompletenessRating inconclusive;

  int relevance;

  String relevanceReasoning;

  List<String> relevanceReasons;

  int truth;

  String truthReasoning;

  List<String> truthReasons;

  int completeness;

  String completenessReasoning;

  List<String> completenessReasons;

  bool get isInconclusive {
    return relevance < MinValue ||
        relevance > MaxValue ||
        truth < MinValue ||
        truth > MaxValue ||
        completeness < MinValue ||
        completeness > MaxValue;
  }

  static RelevanceTruthAndCompletenessRating fromJson(String jsonResponse) {
    var trimmed = JsonOutputFixer.trimMarkdownDelimiters(jsonResponse);
    return JsonSerializer.deserialize(
      trimmed,
      SerializerContext.defaultValue.relevanceTruthAndCompletenessRating,
    )!;
  }
}
