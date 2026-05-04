import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'groundedness_evaluator_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates how well an AI response is grounded in provided context,
/// without introducing unsupported information.
///
/// Returns a [NumericMetric] named `"Groundedness"` scored 1–5 (fail below 3).
/// Requires a [GroundednessEvaluatorContext] in [additionalContext] and a
/// [ChatConfiguration] with an AI model (GPT-4o recommended).
@Source(
  name: 'GroundednessEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class GroundednessEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String groundednessMetricName = 'Groundedness';

  @override
  List<String> get evaluationMetricNames => const [groundednessMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data.
- **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
- **Data**: Your input data include a CONTEXT, a QUERY, and a RESPONSE.
- **Tasks**: Evaluate the RESPONSE in relation to the CONTEXT.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<GroundednessEvaluatorContext>().firstOrNull;
    if (ctx == null) return null;

    final userRequest = messages.lastUserMessage?.text ?? '';
    final response = modelResponse.text;
    final prompt = '''
# Definition
**Groundedness** refers to the degree to which the response is based on the provided CONTEXT, without introducing information that is not supported by the context.

# Ratings
## [Groundedness: 1] (Ungrounded)
The response contradicts or ignores the provided context entirely. Contains significant unsupported claims.

## [Groundedness: 2] (Mostly Ungrounded)
The response includes some grounded information but introduces significant unsupported additions.

## [Groundedness: 3] (Partially Grounded)
The response is mostly grounded but includes some minor unsupported additions.

## [Groundedness: 4] (Grounded)
The response is well grounded in the context with only trivial unsupported elements.

## [Groundedness: 5] (Fully Grounded)
The response is entirely grounded in the context with no unsupported additions.

# Data
CONTEXT: ${ctx.groundingContext}
QUERY: $userRequest
RESPONSE: $response

# Tasks
## Please provide your assessment Score for the previous RESPONSE in relation to the CONTEXT based on the Definitions above.
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
