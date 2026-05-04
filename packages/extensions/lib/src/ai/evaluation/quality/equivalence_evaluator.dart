import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'equivalence_evaluator_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates whether an AI response is semantically equivalent to a ground
/// truth reference.
///
/// Returns a [NumericMetric] named `"Equivalence"` scored 1–5 (fail below 3).
/// Requires an [EquivalenceEvaluatorContext] and a [ChatConfiguration].
@Source(
  name: 'EquivalenceEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class EquivalenceEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String equivalenceMetricName = 'Equivalence';

  @override
  List<String> get evaluationMetricNames => const [equivalenceMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the semantic equivalence of a RESPONSE compared to a GROUND TRUTH.
- **Definition**: Evaluate how well the RESPONSE conveys the same meaning as the GROUND TRUTH.
- **Data**: Your input includes a GROUND TRUTH and a RESPONSE.
- **Tasks**: Score the equivalence of the RESPONSE.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<EquivalenceEvaluatorContext>().firstOrNull;
    if (ctx == null) return null;

    final response = modelResponse.text;
    final prompt = '''
# Definition
**Equivalence** measures whether the RESPONSE conveys the same meaning and factual content as the GROUND TRUTH, even if phrased differently.

# Ratings
## [Equivalence: 1] Completely different meaning from the GROUND TRUTH.
## [Equivalence: 2] Partially overlapping meaning with significant divergence.
## [Equivalence: 3] Generally similar meaning with some notable differences.
## [Equivalence: 4] Very similar meaning with only minor differences.
## [Equivalence: 5] Semantically identical meaning to the GROUND TRUTH.

# Data
GROUND TRUTH: ${ctx.groundTruth}
RESPONSE: $response

# Tasks
## Score the RESPONSE's semantic equivalence to the GROUND TRUTH.
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
