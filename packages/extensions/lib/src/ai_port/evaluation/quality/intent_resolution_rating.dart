import 'json_serialization/serializer_context.dart';
import 'utilities/json_output_fixer.dart';

class IntentResolutionRating {
  const IntentResolutionRating(
    int resolutionScore,
    String explanation,
    String agentPerceivedIntent,
    String actualUserIntent,
    bool conversationHasIntent,
    bool correctIntentDetected,
    bool intentResolved,
  ) : resolutionScore = resolutionScore,
      explanation = explanation,
      agentPerceivedIntent = agentPerceivedIntent,
      actualUserIntent = actualUserIntent,
      conversationHasIntent = conversationHasIntent,
      correctIntentDetected = correctIntentDetected,
      intentResolved = intentResolved;

  static final IntentResolutionRating inconclusive;

  int resolutionScore;

  String explanation;

  String agentPerceivedIntent;

  String actualUserIntent;

  bool conversationHasIntent;

  bool correctIntentDetected;

  bool intentResolved;

  bool get isInconclusive {
    return resolutionScore < MinValue || resolutionScore > MaxValue;
  }

  static IntentResolutionRating fromJson(String jsonResponse) {
    var trimmed = JsonOutputFixer.trimMarkdownDelimiters(jsonResponse);
    return JsonSerializer.deserialize(
      trimmed,
      SerializerContext.defaultValue.intentResolutionRating,
    )!;
  }
}
