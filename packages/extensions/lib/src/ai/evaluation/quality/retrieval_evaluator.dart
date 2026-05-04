import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';
import 'retrieval_evaluator_context.dart';

/// Evaluates how well the retrieved context chunks are relevant to the user
/// request and ranked appropriately.
///
/// Returns a [NumericMetric] named `"Retrieval"` scored 1–5 (fail below 3).
/// Requires a [RetrievalEvaluatorContext] and a [ChatConfiguration].
@Source(
  name: 'RetrievalEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class RetrievalEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String retrievalMetricName = 'Retrieval';

  @override
  List<String> get evaluationMetricNames => const [retrievalMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating retrieval quality. Score how relevant and well-ranked the retrieved context chunks are for the given query.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final ctx = additionalContext.whereType<RetrievalEvaluatorContext>().firstOrNull;
    if (ctx == null) return null;

    final userRequest = messages.lastUserMessage?.text ?? '';
    final chunks = ctx.retrievedContextChunks.asMap().entries
        .map((e) => '[${e.key + 1}] ${e.value}')
        .join('\n');
    final prompt = '''
# Definition
**Retrieval** measures how relevant and well-ranked the retrieved context chunks are for the given QUERY.

# Ratings
## [Retrieval: 1] Chunks are entirely irrelevant to the QUERY.
## [Retrieval: 2] Chunks have very little relevance to the QUERY.
## [Retrieval: 3] Chunks are partially relevant but key information is missing or poorly ranked.
## [Retrieval: 4] Chunks are mostly relevant and reasonably ranked.
## [Retrieval: 5] Chunks are highly relevant and perfectly ranked for the QUERY.

# Data
QUERY: $userRequest
RETRIEVED CONTEXT CHUNKS:
$chunks

# Tasks
## Score the retrieval quality.
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
