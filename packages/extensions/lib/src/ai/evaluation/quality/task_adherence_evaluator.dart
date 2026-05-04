import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';
import 'task_adherence_evaluator_context.dart';

/// Evaluates how accurately an AI system adhered to its assigned task,
/// instructions, and any tool use.
///
/// Returns a [NumericMetric] named `"TaskAdherence"` scored 1–5 (fail below
/// 3). Optionally requires a [TaskAdherenceEvaluatorContext] and a
/// [ChatConfiguration].
@Source(
  name: 'TaskAdherenceEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class TaskAdherenceEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String taskAdherenceMetricName = 'TaskAdherence';

  @override
  List<String> get evaluationMetricNames => const [taskAdherenceMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating whether an AI system accurately adhered to the task assigned to it.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<TaskAdherenceEvaluatorContext>().firstOrNull;
    final conversationHistory = messages.map((m) => '[${m.role.value}]: ${m.text}').join('\n');
    final response = modelResponse.text;
    final toolsSection = ctx != null && ctx.toolDefinitions.isNotEmpty
        ? '\nAVAILABLE TOOLS:\n${ctx.contents.map((c) => c.toString()).join("\n")}'
        : '';

    final prompt = '''
# Definition
**Task Adherence** measures how accurately the AI followed instructions in the conversation history and used available tools correctly.$toolsSection

# Ratings
## [TaskAdherence: 1] Completely ignored task instructions.
## [TaskAdherence: 2] Partially followed instructions with significant deviations.
## [TaskAdherence: 3] Mostly followed instructions with some notable deviations.
## [TaskAdherence: 4] Followed instructions well with minor deviations.
## [TaskAdherence: 5] Perfectly adhered to all task instructions.

# Data
CONVERSATION HISTORY:
$conversationHistory
RESPONSE: $response

# Tasks
## Score the RESPONSE's adherence to the task.
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
