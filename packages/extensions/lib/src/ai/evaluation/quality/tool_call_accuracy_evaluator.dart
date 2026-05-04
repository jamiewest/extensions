import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../../function_call_content.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';
import 'tool_call_accuracy_evaluator_context.dart';

/// Evaluates how accurately an AI system used the tools available to it,
/// examining relevance, parameter correctness, and value extraction accuracy.
///
/// Returns a [NumericMetric] named `"ToolCallAccuracy"` scored 1–5 (fail
/// below 3). Requires a [ToolCallAccuracyEvaluatorContext] and a
/// [ChatConfiguration].
@Source(
  name: 'ToolCallAccuracyEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class ToolCallAccuracyEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String toolCallAccuracyMetricName = 'ToolCallAccuracy';

  @override
  List<String> get evaluationMetricNames => const [toolCallAccuracyMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating whether an AI system used its available tools correctly.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<ToolCallAccuracyEvaluatorContext>().firstOrNull;
    if (ctx == null) return null;

    final toolCalls = modelResponse.messages
        .expand((m) => m.contents)
        .whereType<FunctionCallContent>()
        .map((c) => '- ${c.name}(${c.arguments})')
        .join('\n');
    final toolDefs = ctx.contents.map((c) => c.toString()).join('\n');
    final userRequest = messages.lastUserMessage?.text ?? '';

    final prompt = '''
# Definition
**Tool Call Accuracy** measures how accurately the AI used available tools — whether the right tools were called, with correct parameter names, and accurate values extracted from the conversation.

AVAILABLE TOOLS:
$toolDefs

# Ratings
## [ToolCallAccuracy: 1] Wrong tools called or completely incorrect parameters.
## [ToolCallAccuracy: 2] Partially correct tool calls with significant parameter errors.
## [ToolCallAccuracy: 3] Correct tools called but with some parameter errors.
## [ToolCallAccuracy: 4] Correct tools called with mostly correct parameters.
## [ToolCallAccuracy: 5] Perfectly accurate tool calls with all correct parameters.

# Data
QUERY: $userRequest
TOOL CALLS MADE:
${toolCalls.isEmpty ? "(none)" : toolCalls}

# Tasks
## Score the accuracy of the tool calls.
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
