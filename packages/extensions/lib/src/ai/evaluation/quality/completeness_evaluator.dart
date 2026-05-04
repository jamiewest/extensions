import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'completeness_evaluator_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates how completely an AI response covers the key information in a
/// ground truth reference.
///
/// Returns a [NumericMetric] named `"Completeness"` scored 1–5 (fail below 3).
/// Requires a [CompletenessEvaluatorContext] and a [ChatConfiguration].
@Source(
  name: 'CompletenessEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class CompletenessEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String completenessMetricName = 'Completeness';

  @override
  List<String> get evaluationMetricNames => const [completenessMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the completeness of a RESPONSE compared to a GROUND TRUTH.
- **Definition**: Evaluate how well the RESPONSE covers all key points in the GROUND TRUTH.
- **Data**: Your input includes a GROUND TRUTH and a RESPONSE.
- **Tasks**: Score the completeness of the RESPONSE.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<CompletenessEvaluatorContext>().firstOrNull;
    if (ctx == null) return null;

    final response = modelResponse.text;
    final prompt = '''
# Definition
**Completeness** measures whether the RESPONSE includes all key information, claims, and statements from the GROUND TRUTH.

# Ratings
## [Completeness: 1] Very incomplete — most key points are missing.
## [Completeness: 2] Mostly incomplete — several key points are missing.
## [Completeness: 3] Partially complete — some key points are covered.
## [Completeness: 4] Mostly complete — most key points are covered with minor omissions.
## [Completeness: 5] Fully complete — all key points from the GROUND TRUTH are covered.

# Data
GROUND TRUTH: ${ctx.groundTruth}
RESPONSE: $response

# Tasks
## Score the RESPONSE's completeness relative to the GROUND TRUTH.
- **ThoughtChain**: Think step by step. Start with "Let's think step by step:".
- **Explanation**: A very short explanation of why you think the input Data should get that Score.
- **Score**: An integer score (1–5) based on the definitions.

## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your Score</S2>.
# Output
''';
    return [
      ChatMessage.fromText(ChatRole.system, _systemPrompt),
      ChatMessage.fromText(ChatRole.user, prompt),
    ];
  }
}
