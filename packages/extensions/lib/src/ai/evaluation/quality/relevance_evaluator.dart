import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates how well an AI response addresses the user's question.
///
/// Returns a [NumericMetric] named `"Relevance"` scored 1–5 (fail below 3).
/// Requires a [ChatConfiguration] with an AI model (GPT-4o recommended).
@Source(
  name: 'RelevanceEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class RelevanceEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String relevanceMetricName = 'Relevance';

  @override
  List<String> get evaluationMetricNames => const [relevanceMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
- **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
- **Data**: Your input data include a QUERY and a RESPONSE.
- **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final userRequest = messages.lastUserMessage?.text ?? '';
    final response = modelResponse.text;
    final prompt = '''
# Definition
**Relevance** refers to how effectively the response addresses the main aspects of the query. A relevant response directly addresses the question, covers all necessary points, and avoids unnecessary tangents.

# Ratings
## [Relevance: 1] (Irrelevant)
The response does not address the query at all, or addresses an entirely different topic.

## [Relevance: 2] (Barely Relevant)
The response mentions the topic but fails to address the actual question asked.

## [Relevance: 3] (Partially Relevant)
The response addresses some aspects of the query but misses key points or includes excessive off-topic content.

## [Relevance: 4] (Relevant)
The response effectively addresses the main aspects of the query with minor gaps.

## [Relevance: 5] (Highly Relevant)
The response fully addresses all aspects of the query with precision and completeness.

# Data
QUERY: $userRequest
RESPONSE: $response

# Tasks
## Please provide your assessment Score for the previous RESPONSE in relation to the QUERY based on the Definitions above.
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
