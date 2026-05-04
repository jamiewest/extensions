import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'intent_resolution_evaluator_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates how effectively an AI system identifies and resolves user intent.
///
/// Returns a [NumericMetric] named `"IntentResolution"` scored 1–5 (fail
/// below 3). Optionally requires an [IntentResolutionEvaluatorContext] and a
/// [ChatConfiguration].
@Source(
  name: 'IntentResolutionEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class IntentResolutionEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String intentResolutionMetricName = 'IntentResolution';

  @override
  List<String> get evaluationMetricNames => const [intentResolutionMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating whether an AI system correctly identified and resolved the user's intent.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<IntentResolutionEvaluatorContext>().firstOrNull;
    final userRequest = messages.lastUserMessage?.text ?? '';
    final response = modelResponse.text;

    final toolsSection = ctx != null && ctx.toolDefinitions.isNotEmpty
        ? '\nAVAILABLE TOOLS:\n${ctx.contents.map((c) => c.toString()).join("\n")}'
        : '';

    final prompt = '''
# Definition
**Intent Resolution** measures how accurately the AI identified the user's intent and produced a response that fulfills it.$toolsSection

# Ratings
## [IntentResolution: 1] The user's intent was completely misidentified.
## [IntentResolution: 2] The intent was partially identified but the response does not fulfill it.
## [IntentResolution: 3] The intent was identified but the response only partially fulfills it.
## [IntentResolution: 4] The intent was correctly identified and mostly fulfilled.
## [IntentResolution: 5] The intent was perfectly identified and completely fulfilled.

# Data
QUERY: $userRequest
RESPONSE: $response

# Tasks
## Score how well the RESPONSE resolves the user's intent.
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
